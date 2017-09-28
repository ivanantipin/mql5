//+------------------------------------------------------------------+
//|                                                 SetupTracker.mqh |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <Period.mqh>
#include <CommonEnums.mqh>
#include <Utils.mqh>


enum SeqFinalState {
   Done,   Recycled, Crossed, Expired
};

class SetupTracker : public CObject {
   private:
   GrUtils* utils;   
   public :		
	CArrayObj *periods;
   int start;
   int length;
   bool intersected;
   int lastDrawn;
   double tdst;
   double extremum;
   double extremumClose;
   bool comboCreated;
   bool cdnCreated;
   int qualifyBar;
   string tdstId;
   Side side;   
	void SetupTracker();	
   long chartId;
   void ~SetupTracker();
   void draw();	
   void removeDraw();	
   bool checkQualified(int ind);
   bool checkIntersect(int ind);
   void setStart(int sa);
   bool done(int ind, int cnt);
   void drawTdst(datetime endtime);
   void calculateTdst();
   void calculateExtremum(int end);
   double range();
};

void SetupTracker::SetupTracker(){
   utils = new GrUtils();
	comboCreated = false;
	cdnCreated = false; 
	intersected = false;
	qualifyBar=-1; 
	extremum = -1;	
	tdst = -1;
	length = setupLength;
	tdstId = NULL;
}

void SetupTracker::setStart(int sa){
   start = sa;
   lastDrawn = sa - 1;
   utils.setPrefix("TR " + start);
}


   

void SetupTracker::~SetupTracker(){
   delete utils;
}

void SetupTracker::calculateTdst(){
   int tot = periods.Total();
   tdst = (side == Sell) ? 1000000 : -1000000;   
   for(int i =start; i < start + length; i++){
      Period* p = periods.At(i);
      if(side == Sell){
         tdst = MathMin(tdst, p.low);
      }else{
         tdst = MathMax(tdst, p.high);
      }
   }
}

double SetupTracker::range(){
	return MathAbs(tdst - extremum);
}

void SetupTracker::calculateExtremum(int end){
   for(int i =start; i < end; i++){
      Period* p = periods.At(i);
      if(side == Buy){
         extremum = MathMin(tdst, p.low);
         extremumClose = MathMin(tdst, p.close);
      }else{
         extremum = MathMax(tdst, p.high);
         extremumClose = MathMax(tdst, p.close);
      }
   }
}

void SetupTracker::draw(){
   int end = periods.Total();
   if(end - start < 5) return;
   string str = "Setup" + IntegerToString(start); 
   for(int i =lastDrawn + 1; i < end; i++){
      Period* p = periods.At(i);
      int relIdx = i - start + 1;
      if(relIdx % 2 != 0){
         utils.drawLabel(chartId,p,side,IntegerToString(relIdx), 6, Yellow); 
      } 
   }
   
   
   
   lastDrawn = end -1;
}

bool SetupTracker::checkQualified(int ind){
   if(qualifyBar != -1) return true;
   if(!done(ind, length)) return false; 
   Period* p0 = periods.At(ind);
   Period* p2 = periods.At(ind - 2);
   Period* p3 = periods.At(ind - 3);
   if((side == Sell && p0.close >= MathMin(p2.high,p3.high))
   ||
   (side == Buy && p0.close <= MathMax(p2.low,p3.low))){
      qualifyBar = ind;
   }
   return qualifyBar != -1;
}

void SetupTracker::drawTdst(datetime endtime){
      if(tdstId != NULL){
         ObjectDelete(chartId,tdstId);
      }
      Period* p = periods.At(start);
      if(side == Sell){
         tdstId = utils.drawLine(chartId, tdst, p.time, tdst,endtime,LightBlue,STYLE_DASHDOT);
      }else{
         tdstId = utils.drawLine(chartId, tdst, p.time, tdst,endtime,Red,STYLE_DASHDOT);         
      }
}

bool SetupTracker::checkIntersect(int ind){
   if(!done(ind, length)) return false; 
   if(intersected) return true;
   Period* p0 = periods.At(ind);
   Period* p1 = periods.At(ind - 1);
   Period* p2 = periods.At(ind - 2);
   double l = 0;
   if(side == Sell && p0.low < p1.low && p0.low < p2.high
         || 
      side == Buy && p0.high > p1.high && p0.high > p2.low){
         intersected = true;
   }
   return intersected;
}


bool SetupTracker::done(int ind, int cnt){
   return ind - start + 1 >= cnt; 
}

