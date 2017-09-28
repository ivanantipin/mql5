//+------------------------------------------------------------------+
//|                                                         TDSL.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include <CommonEnums.mqh>

class TDSL : public CObject {   
   public:
   double price;
   Side side;
   int start;   
   string id;
   void TDSL(){id = NULL;}
   
};
