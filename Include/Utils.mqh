//+------------------------------------------------------------------+
//|                                                         Util.mqh |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Arrays\ArrayString.mqh>
#include <Period.mqh>
#include <CommonEnums.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2005
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
class GrUtils{
   private:
      string prefix; 
   public:
   long labelCnt;   
   CArrayString* labels;
   void drawLabel(long chartId, datetime time, double price, string label, int size, color cl, int anchor);
   string drawLine(long chartId, double pr1, datetime time1, double pr2, datetime time2, color cl, int style);
   void drawArrow(long chartId, Period* p, Side s);
   void drawLabel(long chartId, Period* p, Side s, string label, int size, color cl);
   void GrUtils(){labelCnt = 0; labels = new CArrayString;}
   void ~GrUtils();
   void setPrefix(string pr);
};

void GrUtils::setPrefix(string pr){
   prefix = pr;
}

void GrUtils::~GrUtils(){
   Print("deleting utils constr");
   for(int i =0; i < labels.Total(); i++){
      string lb = labels.At(i);
      int ind = StringFind(lb,"_",0);      
      long chartId = StringToInteger(StringSubstr(lb,0,ind));
      ObjectDelete(chartId,lb);
   }
   delete labels;
   Print("deleted utils");
}

void GrUtils::drawLabel(long chartId, datetime time, double price, string label, int size, color cl, int anchor){
      string ident = chartId + "_" + prefix + "_" +labelCnt++;      
      labels.Add(ident);     
      ObjectCreate(chartId, ident, OBJ_TEXT, 0, time, price);
      ObjectSetInteger(chartId,ident,OBJPROP_ANCHOR,anchor);
      ObjectSetString(chartId,ident,OBJPROP_TEXT,label);            
      ObjectSetInteger(chartId,ident,OBJPROP_COLOR,cl);
      ObjectSetInteger(chartId,ident,OBJPROP_SELECTABLE,true);      
      ObjectSetString(chartId,ident,OBJPROP_FONT,"Arial");
      ObjectSetInteger(chartId,ident,OBJPROP_FONTSIZE,size);
}

void GrUtils::drawArrow(long chartId, Period* p, Side s){
      string ident = chartId + "_" + prefix + labelCnt++;
      labels.Add(ident);      
      if(s == Sell){
         ObjectCreate( chartId, ident, OBJ_ARROW_DOWN, 0, p.time, p.high + Point1);
         ObjectSetInteger(chartId,ident,OBJPROP_COLOR,Red);
      }else{
         ObjectCreate(chartId, ident, OBJ_ARROW_UP, 0, p.time, p.low -  Point1);
         ObjectSetInteger(chartId,ident,OBJPROP_COLOR,Blue);
      }
      ObjectSetInteger(chartId,ident,OBJPROP_SELECTABLE,true); 
}

void GrUtils::drawLabel(long chartId, Period* p, Side s, string label, int size, color cl){
      double price;
      int anchor;
      if(s == Sell){      	
         price = p.high + p.highLabelSize*Point1;
         p.highLabelSize += size;         
         anchor = ANCHOR_LOWER;
      }else{     
         price = p.low - p.lowLabelSize*Point1;
         p.lowLabelSize += size;               
         anchor = ANCHOR_UPPER;
      }      
      drawLabel(chartId,p.time,price,label,size,cl,anchor);
}

string  GrUtils::drawLine(long chartId, double pr1, datetime time1, double pr2, datetime time2, color cl, int style){            
      string ident = chartId + "_" + prefix +"_" + labelCnt++;      
      labels.Add(ident);      
      ObjectCreate(chartId, ident, OBJ_TREND, 0, time1, pr1, time2, pr2);
      ObjectSetInteger(chartId,ident,OBJPROP_COLOR,cl);      
      ObjectSetInteger(chartId,ident,OBJPROP_STYLE,style);      
      return ident;
}








