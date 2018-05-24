//+------------------------------------------------------------------+
//|                                             CountDownTracker.mqh |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Arrays\ArrayInt.mqh>
#include <SetupTracker.mqh>
#include <Period.mqh>
#include <Utils.mqh>
#include <TDSL.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CountDownTracker : public CObject
  {
private:
public :
   SetupTracker     *setupTracker;
   int               nextSignalIndex;
   bool              lastSignalValidated;
   int               drawBarsBeforeSignal;
   bool              completed;
   bool              combo;
   bool              cancelled;
   bool              recycled;
   bool              recycleValidated;
   color             drawCol;
   CArrayInt        *bars;
   GrUtils          *utils;
   CArrayObj        *pendingStopLosses;
   void              CountDownTracker();
   void             ~CountDownTracker();
   bool              calcCompleted(const int &signalLengths[]);
   void              calc(int perIdx);
   double            calcSl(int lastIdx);
   void              drawSL(int idx,double sl);
   void              drawSignal(Period *p,int length);
   void              init();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountDownTracker::CountDownTracker()
  {
   bars=new CArrayInt;
   completed=false;
   cancelled= false;
   recycled=false;
   recycleValidated=false;
   pendingStopLosses=new CArrayObj;
   nextSignalIndex=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountDownTracker::~CountDownTracker()
  {
   delete bars;
   delete pendingStopLosses;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CountDownTracker::init()
  {
   if(combo)
     {
      drawCol=Pink;
        }else{
      drawCol=Red;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountDownTracker::calc(int perIdx)
  {
  
  
  
  if(completed){
      return;
  }
  
   Period* p0 = setupTracker.periods.At(perIdx);
   Period* p1 = setupTracker.periods.At(perIdx - 1);
   Period* p2 = setupTracker.periods.At(perIdx - 2);
   
        if(setupTracker.side == Sell && p0.close < setupTracker.tdst ||
               setupTracker.side == Buy && p0.close > setupTracker.tdst){
               completed = true;
        return;
     }


   if(combo)
     {
      int tot=bars.Total();
      Period *lp=NULL;
      if(tot==0)
        {
         lp = setupTracker.periods.At(perIdx-2);
           }else{
         lp=setupTracker.periods.At(bars.At(bars.Total()-1));
        }

      bool exceed2HL;
      bool exceedHL1HL;
      bool exceed1C;
      bool exceedLB;
      if(setupTracker.side==Sell)
        {
         exceed2HL=p0.close>=p2.high;
         exceedHL1HL=p0.high>p1.high;
         exceed1C = p0.close>p1.close;
         exceedLB = p0.close > lp.close;
           }else{
         exceed2HL=p0.close<=p2.low;
         exceedHL1HL=p0.low<p1.low;
         exceed1C = p0.close<p1.close;
         exceedLB = p0.close < lp.close;
        }

      bool flag=true;
      if(bars.Total()>=comboFinalBarsStart)
        {
         flag = flag && (exceed1C || !finalComboCloseExceed1CloseAgo);
         flag = flag && (exceedHL1HL || !finalComboHLExceed1HLAgo);
         flag = flag && (exceed2HL || !finalComboCloseExceed2HighLowAgo);
         flag = flag && (exceedLB || !finalComboCloseExceedPrevCdnBarClose);
           }else{
         flag = flag && (exceed1C || !comboCloseExceed1CloseAgo);
         flag = flag && (exceedHL1HL || !comboHLExceed1HLAgo);
         flag = flag && exceed2HL;
         flag = flag && (exceedLB || !comboCloseExceedPrevCdnBarClose);
        }
      if(flag)
        {
         bars.Add(perIdx);
         calcCompleted(comboSignalLengths);
        }
        }else{
      if(setupTracker.side==Sell && p0.close>=p2.high || setupTracker.side==Buy && p0.close<=p2.low)
        {
         bars.Add(perIdx);
         calcCompleted(signalLengths);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CountDownTracker::calcCompleted(const int &sl[])
  {
   if(completed) return true;
   int tot=bars.Total();
   Period *p0=setupTracker.periods.At(setupTracker.periods.Total() -1);
   if(setupTracker.periods.Total()-setupTracker.start>150 && cancelled)
     {
      completed=true;
      return true;
     }

   int nextSignal;

   if(nextSignalIndex==ArraySize(sl))
     {
      nextSignal=-1;
        }else{
      nextSignal=sl[nextSignalIndex];
     }

   if(tot==nextSignal)
     {

      nextSignalIndex++;
      lastSignalValidated=false;
        }else{
      if(nextSignalIndex<ArraySize(sl) && nextSignal-tot<=showBarsBeforeSignal || tot==8)
        {
         utils.drawLabel(setupTracker.chartId,p0,setupTracker.side,""+tot,7,drawCol);
        }
     }
   if(!lastSignalValidated && nextSignalIndex>0)
     {
      int length=sl[nextSignalIndex-1];
      int ind=bars.At(tot-1);
      int ind8=bars.At(7);
      Period *p=setupTracker.periods.At(ind);
      Period *p8=setupTracker.periods.At(ind8);
      bool completeFlag=true;
      //input bool sequentaFinalBarHighLowExceed8Close = true;
      //input bool sequentaFinalBarCloseExceed8HighLow = false;

      if(setupTracker.side==Sell)
        {
         completeFlag = completeFlag && (!sequentaFinalBarHighLowExceed8Close || p.high >= p8.close);
         completeFlag = completeFlag && (!sequentaFinalBarCloseExceed8HighLow || p.close >= p8.high);
           }else{
         completeFlag = completeFlag && (!sequentaFinalBarHighLowExceed8Close || p.low <= p8.close);
         completeFlag = completeFlag &&(!sequentaFinalBarCloseExceed8HighLow || p.close<=p8.low);
        }
      completeFlag=completeFlag || combo;

      if(completeFlag)
        {
               lastSignalValidated=true;
               drawSignal(p0,sl[nextSignalIndex-1]);
           }else{
               if(nextSignalIndex==ArraySize(sl) && bars.Total()>(sl[ArraySize(sl)-1]+maxDefferedCdn))
                 {
                        lastSignalValidated=true;
                        utils.drawLabel(setupTracker.chartId,p0,setupTracker.side,"-",7,drawCol);
                    }else{               
                        utils.drawLabel(setupTracker.chartId,p0,setupTracker.side,"+",7,drawCol);            
                 }
        }
     }

   completed=nextSignalIndex==ArraySize(sl) && lastSignalValidated;
   return completed;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountDownTracker::drawSignal(Period *p,int length)
  {
   string lb=""+length;
   if(cancelled)
     {
      lb+="c";
     }
   if(recycled)
     {
      if(recycleValidated)
        {
         lb+="R";
           }else{
         lb+="r";
        }
     }
   int idx=bars.At(bars.Total()-1);

   TDSL* sl = new TDSL();
   sl.price = calcSl(idx);
   sl.side=setupTracker.side;
   sl.start=idx-1;
   pendingStopLosses.Add(sl);
   utils.drawLabel(setupTracker.chartId,p,setupTracker.side,lb,15,drawCol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CountDownTracker::calcSl(int lastIndx)
  {
   Period *pp=setupTracker.periods.At(setupTracker.start);
   for(int i=setupTracker.start;i<=lastIndx;i++)
     {
      Period *p=setupTracker.periods.At(i);
      if(setupTracker.side==Sell && p.high>pp.high
         || 
         setupTracker.side==Buy && p.low<pp.low)
        {
         pp=p;
        }
     }
   return setupTracker.side==Sell ? pp.high+pp.range() : pp.low-pp.range();;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
