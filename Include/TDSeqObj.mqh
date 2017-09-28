//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2009, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include <CountDownTracker.mqh>
#include <SetupTracker.mqh>
#include <Period.mqh>
#include <Utils.mqh>
#include <TDSL.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TDSequenta
  {
private:
   CArrayObj        *setupTrackers;
   CArrayObj        *countDownTrackers;
   CArrayObj        *pendingStopLosses;
   SetupTracker     *pendingSetup;
public:
   CArrayObj        *periods;
   long              chartId;
   int               recycleLength;
   int               labelCnt;
   void              processPeriod(Period *p);
   void              processLast();
   void              recycleCancel();
   GrUtils            *utils;
   SetupTracker     *initSetup(Side sd);
   void              TDSequenta();
   void 			~TDSequenta();
   void              drawTDSTs(Period *p);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TDSequenta::TDSequenta()
  {
   periods=new CArrayObj;
   pendingStopLosses=new CArrayObj;
   setupTrackers=new CArrayObj;
   countDownTrackers=new CArrayObj;   
   chartId=-1;
   labelCnt=0;
   utils=new GrUtils();
  }
  
void TDSequenta::~TDSequenta(){
	delete periods;	
	delete setupTrackers;	
	delete countDownTrackers;
	delete utils;
	delete pendingSetup;
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SetupTracker *TDSequenta::initSetup(Side sd)
  {
   SetupTracker *ret=new SetupTracker;
   ret.setStart(periods.Total() -1);
   ret.side=sd;   
   ret.periods = periods;
   ret.chartId = chartId;
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TDSequenta::drawTDSTs(Period *p){
	int tot=setupTrackers.Total();
	int psize=periods.Total();
	int end=MathMax(0,tot-10);
	SetupTracker *resTr=NULL;
	SetupTracker *suppTr=NULL;
	for(int i=tot-1;i>=end;i--){
		SetupTracker *curr=setupTrackers.At(i);
		if(psize-curr.start>240){
			break;
		}
		if(curr.side==Sell){
			if(suppTr==NULL){
				suppTr=curr;
			}
		}else{
			if(resTr==NULL){
				resTr=curr;
			}
		}
	}
	if(resTr!=NULL){
		resTr.drawTdst(p.time);
	}
	if(suppTr!=NULL){
		suppTr.drawTdst(p.time);
	}
	for(int i =0; i < pendingStopLosses.Total(); i++){	
	   TDSL *sl = pendingStopLosses.At(i);
	   if(psize - sl.start > 10){
	      pendingStopLosses.Delete(i);
	      i--;
	      continue;
	   }	   	   
	   if(sl.id != NULL){
	      ObjectDelete(chartId,sl.id);
	   }
	   Period *slp = periods.At(sl.start);
	   sl.id = utils.drawLine(chartId, sl.price, slp.time,sl.price,p.time, Red,STYLE_SOLID);	   
	}
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TDSequenta::processPeriod(Period *p0){	
      periods.Add(p0);
      processLast();
}
  
void TDSequenta::processLast(){
   Period* p0 = periods.At(periods.Total() -1);
	int cind=periods.Total() -1;
	if(periods.Total()<6) return;
	Period *p4=periods.At(periods.Total() -5);
	for(int i=0;i<countDownTrackers.Total();i++){
		CountDownTracker *tr=countDownTrackers.At(i);
		tr.calc(cind);		
		
      for(int k = 0; k < tr.pendingStopLosses.Total(); k++){
         TDSL* psl = tr.pendingStopLosses.At(k);         
         pendingStopLosses.Add(psl);         
         tr.pendingStopLosses.Detach(k);
         k--;
      }
      

		if(tr.completed || (removeQualifiedRecycled && tr.recycled && tr.recycleValidated)){
			countDownTrackers.Delete(i);
			i--;
			continue;
		}
	}

	if(pendingSetup!=NULL){
		Side side=pendingSetup.side;
		if(side==Sell && p0.close<=p4.close
         || 
		side==Buy && p0.close>=p4.close){
			if(cind-pendingSetup.start<setupLength){
            	delete pendingSetup;
			}else{
				pendingSetup.calculateExtremum(periods.Total() - 1);
				recycleCancel();
			}
         pendingSetup=NULL;
      }else{
			pendingSetup.draw();
		}
     }

   if(pendingSetup!=NULL) {
		Side side=pendingSetup.side;
		if(cind-pendingSetup.start==setupLength - 1){
			pendingSetup.calculateTdst();			
			pendingSetup.calculateExtremum(periods.Total());
			setupTrackers.Add(pendingSetup);
			recycleCancel();
		}
	}else {
		Period* p1 = periods.At(periods.Total() - 2);
		Period* p5 = periods.At(periods.Total() - 6);
		if(p1.close<p5.close && p0.close>p4.close){
			pendingSetup=initSetup(Sell);
		} else if(p1.close>p5.close && p0.close<p4.close){
			pendingSetup=initSetup(Buy);
        }
	}

   int stind=setupTrackers.Total() -1;

	for(int i=stind;i>=0;i--){
		SetupTracker *st=setupTrackers.At(i);
		if(st.qualifyBar!=-1){
			break;
		}
		if(st.checkQualified(cind)){
			utils.drawArrow(chartId,p0,st.side);
		}
	}
   for(int i=stind;i>=0;i--)
     {
      SetupTracker *st=setupTrackers.At(i);
      if(!st.cdnCreated && seqEnabled )
        {
         if(!needIntersect || 
            st.checkIntersect(cind) || (cind-st.start==(setupLength - 1) && st.checkIntersect(cind-1)))
           {
            CountDownTracker *tr=new CountDownTracker();
            tr.setupTracker=st;
            tr.combo=false;
            tr.utils = utils;
            tr.init();
            st.cdnCreated=true;
            countDownTrackers.Add(tr);
            tr.calc(cind);            
           }
        }

      if(!st.comboCreated && comboEnabled)
        {
         st.comboCreated=true;
         CountDownTracker *com=new CountDownTracker();
         com.setupTracker=st;
         com.combo=true;
         com.utils = utils;
         com.init();
         countDownTrackers.Add(com);
         for(int r=st.start - comboStartCalcBarsBeforeSetupStart;r<=cind;r++)
           {
            com.calc(r);
           }           
        }
     }

   drawTDSTs(p0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TDSequenta::recycleCancel(){
   int stind=setupTrackers.Total() -1;
   SetupTracker *str = setupTrackers.At(stind);
   
	for(int i=0;i<countDownTrackers.Total();i++)
     {
      CountDownTracker *tr=countDownTrackers.At(i);
      if(tr.setupTracker == str){         
         continue;
      }
      if(tr.setupTracker.side==str.side)
        {
         tr.recycled=true;
         if(tr.setupTracker.range() < str.range() && str.range() < 2*tr.setupTracker.range() ){
         	tr.recycleValidated=true;
         }
		}else{
		   Period *p = periods.At(periods.Total() - 1);
         tr.cancelled=true;
         if(str.side == Sell && str.extremumClose >  tr.setupTracker.tdst ||
            str.side == Buy && str.extremumClose <  tr.setupTracker.tdst){
            tr.completed=true;
            //utils.drawLabel(tr.setupTracker.chartId,p,tr.setupTracker.side,"DE",5,LightBlue);
         }
         if(tr.setupTracker.range() < str.range()){            
         	tr.completed=true;         	
         	//utils.drawLabel(tr.setupTracker.chartId,p,tr.setupTracker.side,"DR",5,LightBlue);
         }
        }
     }
  }
//+------------------------------------------------------------------+
