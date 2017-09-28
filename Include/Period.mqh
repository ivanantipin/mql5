//+------------------------------------------------------------------+
//|                                                       Period.mqh |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Object.mqh>

enum ComboVersion{V1,V2};


class Period : public CObject
  {
public:
   double high;
   double low;
   double close;
   double open;
   datetime time;
   bool fake;
   
   int highLabelSize;
   int lowLabelSize;
   void Period(){highLabelSize = 0; lowLabelSize = 0; fake = false;}
   double range(){return high - low;}
};
