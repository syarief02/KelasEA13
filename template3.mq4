#property version "1.0"
#property strict.
#property copyright "BuBat's Trading"
#property link "https://t.me/syariefazman"

extern string eaName = "MyEA"; // Set your desired EA name here
extern double lotSize = 0.01;       // Set your desired lot size here
extern double takeProfit = 500.0;   // Set your desired take profit level here
extern double stopLoss = 50.0;      // Set your desired stop loss level here
extern double rsiOverbought = 80.0; // Set your desired RSI overbought level here
extern double rsiOversold = 30.0;   // Set your desired RSI oversold level here
extern double pipstep = 10.0; // Set your desired pipstep distance here

datetime lastBarTime;
double lastEntryPrice = 0.0;

bool isNewBar()
{
    lastBarTime = 0;
    datetime currentBarTime = Time[0];
    if (currentBarTime > lastBarTime)
    {
        lastBarTime = currentBarTime;
        return true;
    }
    return false;
}

void OnInit()
{
    // Initialization function
    // Add any necessary initialization code here
}

void OnDeinit(const int reason)
{
    // Deinitialization function
}

void OnTick()
{
    datetime currentBarTime = iTime(Symbol(), Period(), 0);

    if (currentBarTime != lastBarTime)
    {
        // This is a new bar. You can put your entry code here.

        main();
        trailingStop();
        lastEntryPrice = 0.0; // Reset last entry price
    }
    else
    {
        // Check if there are any open positions
        int totalPositions = OrdersTotal();
        for (int i = 0; i < totalPositions; i++)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                // Check if the order type is buy or sell
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    // Calculate the current profit in pips
                    double currentProfitPips = (OrderType() == OP_BUY) ? (Bid - OrderOpenPrice()) / Point : (OrderOpenPrice() - Ask) / Point;

                    // Check if the current profit is greater than the pipstep distance from the last entry
                    if (currentProfitPips >= pipstep && OrderOpenPrice() != lastEntryPrice)
                    {
                        // Enter a new layer
                        if (OrderType() == OP_BUY)
                        {
                            double tp = Bid + takeProfit * Point;
                            double sl = Bid - stopLoss * Point;
                            if (OrderSend(Symbol(), OP_BUY, lotSize, Ask, 0, sl, tp, eaName) == -1)
                            {
                                Print("OrderSend failed with error code ", GetLastError());
                                return;
                            }
                        }
                        else if (OrderType() == OP_SELL)
                        {
                            double tp = Ask - takeProfit * Point;
                            double sl = Ask + stopLoss * Point;
                            if (OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, sl, tp, eaName) == -1)
                            {
                                Print("OrderSend failed with error code ", GetLastError());
                                return;
                            }
                        }

                        lastEntryPrice = OrderOpenPrice(); // Update last entry price
                    }
                }
            }
        }
    }
}

void main()
{
    // Your code here
    int trend = determineTrendBasedOnPsar();
    if (trend == 0)
    {
        buy();
    }
    else if (trend == 1)
    {
        sell();
    }
}

int determineTrendBasedOnPsar()
{
    // Determine trend based on psar
    double psar = iSAR(NULL, 0, 0.02, 0.2, 0);
    double close = Close[0];
    bool uptrend = close > psar;
    bool downtrend = close < psar;
    if (uptrend)
    {
        return 0;
    }
    else if (downtrend)
    {
        return 1;
    }
    else
    {
        return -1;
    }
}

void trailingStop()
{
    // Check if there are any open positions
    int totalPositions = OrdersTotal();
    for (int i = 0; i < totalPositions; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order type is buy or sell
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
                // Calculate the current profit in pips
                double currentProfitPips = (OrderType() == OP_BUY) ? (Bid - OrderOpenPrice()) / Point : (OrderOpenPrice() - Ask) / Point;

                // Calculate the new stop loss level based on the trailing stop percentage
                double newStopLossLevel = (OrderType() == OP_BUY) ? (OrderOpenPrice() - (stopLoss + currentProfitPips) * Point) : (OrderOpenPrice() + (stopLoss + currentProfitPips) * Point);
                if (currentProfitPips > 0 && newStopLossLevel != OrderStopLoss())
                {
                    if (OrderModify(OrderTicket(), OrderOpenPrice(), newStopLossLevel, OrderTakeProfit(), 0, clrNONE) == false)
                    {
                        int errorCode = GetLastError();
                        if (errorCode == 130)
                        {
                            Print("OrderModify failed with error code ", errorCode, ": Invalid stops");
                        }
                        else
                        {
                            Print("OrderModify failed with error code ", errorCode);
                        }
                    }
                    else
                    {
                        Print("Trailing stop modified for order ", OrderTicket());
                    }
                }
            }
        }
    }
}

void buy()
{
    double rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
    if (rsi < rsiOversold)
    {
        double tp = Bid + takeProfit * Point;
        double sl = Bid - stopLoss * Point;
        if (OrderSend(Symbol(), OP_BUY, lotSize, Ask, 0, sl, tp, eaName) == -1)
        {
            Print("OrderSend failed with error code ", GetLastError());
            return;
        }
    }
    else
    {
        // Print("RSI is not below oversold level");
        return;
    }
}

void sell()
{
    double rsi_sell = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
    if (rsi_sell > rsiOverbought)
    {
        double tp = Ask - takeProfit * Point;
        double sl = Ask + stopLoss * Point;
        if (OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, sl, tp, eaName) == -1)
        {
            Print("OrderSend failed with error code ", GetLastError());
            return;
        }
    }
    else
    {
        // Print("RSI is not above overbought level");
        return;
    }
}

double getLastEntryPrice()
{
    // Get the last entry price
    int totalPositions = OrdersTotal();
    for (int i = 0; i < totalPositions; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
                lastEntryPrice = OrderOpenPrice();
                break;
            }
        }
    }
    return lastEntryPrice;
}
