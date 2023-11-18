//+------------------------------------------------------------------+
//|                                               CloseAllProfit.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double lot = 0.02;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//---
   int k_period = 5;
   int d_period = 10;
   int slowing = 33;
   string ayat = "ayat-ayat cinta";

   Print("Ini adalah contoh : k period ",k_period);
   Print("Inii adalah : d period ", d_period);
   Print("Ini adalah slowing : ",slowing);
   Print(ayat);
   // Comment("Contoh contoh : ");

   // Print("Ini adalah panggilan function LotSize : ",LotSize());
   // Print("Ini adalah multiply lot : ",LotSizeMultiply());
   Ayam();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotSize() {
   return lot;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotSizeMultiply() {
   return LotSize() * 3.618;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Layer() {
   return 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Ayam() {
   Print("Ini adalah layer : ",Layer() ) ;
   Print("Ini adalah panggilan function LotSize : ",LotSize());
   Print("Ini adalah multiply lot : ",LotSizeMultiply());
}
//+------------------------------------------------------------------+
