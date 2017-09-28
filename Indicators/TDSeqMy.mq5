#include <TDSeqObj.mqh>
#property indicator_chart_window
//--- indicator buffers
input bool needIntersect    = false;
input bool comboEnabled    = true;
input bool seqEnabled    = true;
input bool removeQualifiedRecycled  = true;
input int seqLength    = 13;
input int setupLength    = 9;
input bool comboCloseExceed1CloseAgo    = false;
input bool comboHLExceed1HLAgo    = true;
input bool comboCloseExceedPrevCdnBarClose    = true;
input int  comboStartCalcBarsBeforeSetupStart    = 2;
input bool finalComboCloseExceed1CloseAgo    = false;
input bool finalComboHLExceed1HLAgo    = false;
input bool finalComboCloseExceedPrevCdnBarClose    = true;
input bool finalComboCloseExceed2HighLowAgo    = false;
input bool sequentaFinalBarHighLowExceed8Close = true;
input bool sequentaFinalBarCloseExceed8HighLow = false;
input bool playSound1BarBeforeSignal = false;
input bool playSoundOnSignal = false;
input int comboFinalBarsStart = 11;
input int showBarsBeforeSignal = 2;
input int maxDefferedCdn = 8;
double Point1    = 0.00005;
int signalLengths[] = {13,21};
int comboSignalLengths[] = {13};
bool pointInitialized = false;
//1,5,15,30, 60, 240, D1,W1
double RI_SCALES[] = {4, 8, 10, 14, 25, 55, 65, 75};
double ES_SCALES[] = {0.025, 0.07, 0.04, 0.07, 0.1, 0.2, 0.3, 0.3};
double EUR_SCALES[] = {0.00003, 0.00005, 0.00005, 0.0001, 0.0001, 0.0002, 0.0005, 0.003};
double BRN_SCALES[] = {0.003, 0.01, 0.005, 0.01, 0.01, 0.02, 0.05, 0.3};
double DX_SCALES[] = {0.003, 0.01, 0.005, 0.01, 0.01, 0.02, 0.05, 0.3};
double ZN_SCALES[] = {0.0015, 0.005, 0.002, 0.005, 0.005, 0.01, 0.02, 0.3};
double SI_SCALES[] = {0.003, 0.01, 0.005, 0.01, 0.01, 0.02, 0.05, 0.3};




TDSequenta  *seq;



//+------------------------------------------------------------------+

//| Custom indicator initialization function                         |

//+------------------------------------------------------------------+



int OnInit(){      
   Point1 = initMashtab();
   Print("point is " + Point1);
	seq = new TDSequenta;
   seq.chartId = ChartID();   
	return(0);
}

void OnDeinit(const int reason){	
	if(seq != NULL){
		Print("deleted seq");
		delete seq;		
	}	
}

double initMashtab(){
   string st3 = StringSubstr(_Symbol, 0, 3);
   string st2 = StringSubstr(_Symbol, 0, 2);
   if(StringCompare(st3, "EUR", false) == 0){      
       return getPointForPeriod(EUR_SCALES);
   }else if(StringCompare(st2, "ES", false)  == 0){         
      return getPointForPeriod(ES_SCALES);
   }else if(StringCompare(st3, "BRN", false)  == 0){
      return getPointForPeriod(BRN_SCALES);
   }else if(StringCompare(st2, "RI", false)  == 0){
      return getPointForPeriod(RI_SCALES);
   }else if(StringCompare(st2, "SI", false)  == 0){
      return getPointForPeriod(SI_SCALES);
   }else if(StringCompare(st2, "SP", false)  == 0){
      return getPointForPeriod(ES_SCALES);
   }else if(StringCompare(st2, "DX", false)  == 0){
      return getPointForPeriod(BRN_SCALES);
   }else if(StringCompare(st2, "ZN", false)  == 0){
      return getPointForPeriod(ZN_SCALES);
   }else{
      return getPointForPeriod(EUR_SCALES);
   }
}

double getPointForPeriod(const double& scales[]){
   switch(_Period){   
      case PERIOD_M1:
         return scales[0];
      break;
      case PERIOD_M5:
         return scales[1];
      break;
      case PERIOD_M15:
         return scales[2];
      break;
      case PERIOD_M30:
         return scales[3];
      break;
      case PERIOD_H1:
         return scales[4];
      break;
      case PERIOD_H4:
         return scales[5];
      break;
      case PERIOD_D1:
         return scales[6];
      case PERIOD_W1:
         return scales[7];
         
      break;      
   }
   return 0;
}



  
//+------------------------------------------------------------------+

//| Custom indicator iteration function                              |

//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   
   if(rates_total - 2 == prev_calculated) return(prev_calculated);
   int st = prev_calculated + 1;
   if(rates_total - prev_calculated > 1500){
   		st = rates_total - 1500;
   }
   
   
   for(int i =st; i < rates_total - 1; i++){
      
      if(_Period == PERIOD_D1){
         if(high[i] == low[i]){
            continue;
         }
      }
      Period* p = new Period();
      p.close = close[i];
      p.high = high[i];
      p.low = low[i];
      p.open = open[i];
      p.time = time[i];
      seq.processPeriod(p);      
      }
   
   return(rates_total - 2);

  }
 
