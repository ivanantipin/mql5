//+------------------------------------------------------------------+
//|                                                  CommonEnums.mqh |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

enum Side {
   Sell,Buy
};

enum ComboCalcMethod{ ClExc2HL1CAgoAndPrevCdnBar, ClExc2HL1CAgoAndSetupLastBar};

enum ComboFinalBarsMethod{ ClExc2HL1C, ClExc1CAndSetupLastBar, ClExc2HAndSetupLastBar, ClExcLastCdnBar};
