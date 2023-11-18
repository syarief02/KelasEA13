#property copyright "MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"

extern double StopLoss = 50.0; // Stop loss in points
extern double TakeProfit = 100.0; // Take profit in points
extern double LotSize = 0.1; // Lot size for the order
extern double BreakEven = 20.0; // Break-even in points
extern double TrailingStop = 10.0; // Trailing stop in points

double AOBuffer[];

int OnInit()
{
  // Initialize the AO buffer
  ArraySetAsSeries(AOBuffer, true);
  return INIT_SUCCEEDED;
}

void OnTick()
{
  // Update the AO buffer
  int handle = iCustom(Symbol(), 0, "AO", 0, 1);
  AOBuffer[1] = iCustom(Symbol(), 0, "AO", 0, 2);
  int ticket;
  bool result;

  // Check for buy signal
  if (AOBuffer[1] < 0 && handle > 0)
  {
    // Open a buy order
    ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask - StopLoss * Point, Ask + TakeProfit * Point);
    if(ticket < 0)
    {
      Print("OrderSend failed with error #", GetLastError());
    }
  }

  // Check for sell signal
  else if (AOBuffer[1] > 0 && handle < 0)
  {
    // Open a sell order
    ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Bid + StopLoss * Point, Bid - TakeProfit * Point);
    if(ticket < 0)
    {
      Print("OrderSend failed with error #", GetLastError());
    }
  }

  // Apply break-even and trailing stop
  for(int i = OrdersTotal()-1; i >= 0; i--)
  {
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == 0)
      {
        if(OrderType() == OP_BUY)
        {
          if(Bid - OrderOpenPrice() > BreakEven * Point)
          {
            if(OrderStopLoss() < OrderOpenPrice() || OrderStopLoss() < Bid - TrailingStop * Point)
            {
              result = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * Point, OrderTakeProfit(), 0, clrNONE);
              if(!result)
              {
                Print("OrderModify failed with error #", GetLastError());
              }
            }
          }
        }
        else if(OrderType() == OP_SELL)
        {
          if(OrderOpenPrice() - Ask > BreakEven * Point)
          {
            if(OrderStopLoss() > OrderOpenPrice() || OrderStopLoss() > Ask + TrailingStop * Point)
            {
              result = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailingStop * Point, OrderTakeProfit(), 0, clrNONE);
              if(!result)
              {
                Print("OrderModify failed with error #", GetLastError());
              }
            }
          }
        }
      }
    }
  }
}

void OnDeinit(const int reason)
{
  //---
}