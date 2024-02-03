#include <main.mqh>
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//|              J_manage_trade_Expert_Advisor.mq4 |
//|                                                       WEbarnabas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Company Name"
#property link      "http://www.company.com"
#property version   "1.00"
#property strict
#include <function_room.mqh>

 // Custom function to update bid and ask prices
/*void UpdateBidAskPrices(string symbol) {

       currentBid = NormalizeDouble(MarketInfo(symbol, MODE_BID), SymbolInfoInteger(symbol, SYMBOL_DIGITS));
       currentAsk = NormalizeDouble(MarketInfo(symbol, MODE_ASK), SymbolInfoInteger(symbol, SYMBOL_DIGITS));
       //Print("Current Bid price: ", currentBid, " for ", symbol);
       Print("Highest Bid price: ", highestBidPriceReached, " for ", symbol);
       if (currentBid > highestBidPriceReached) 
       {
           highestBidPriceReached = currentBid;
           Print("H( ",symbol," ): ", highestBidPriceReached);
       }
   
       else if (currentAsk < lowestAskPriceReached) 
       {
           lowestAskPriceReached = currentAsk;
           //Print("L( ",symbol," ): ", lowestAskPriceReached);
       }
}*/

struct SymbolData {
    string symbol;
    double highestBidPrice;
    double lowestAskPrice;
};

#define MAX_SYMBOLS 1000 // Change the number based on your requirement

SymbolData symbolData[MAX_SYMBOLS];
int totalSymbols = 0;

int FindSymbolIndex(string symbol) {
    for (int i = 0; i < totalSymbols; i++) {
        if (symbolData[i].symbol == symbol) {
            return i;
        }
    }
    return -1; // Symbol not found
}

void UpdateBidAskPrices(string symbol, int tradeId, double HB, double LA) 
{
    int symbolIndex = FindSymbolIndex(symbol);

    if (symbolIndex == -1) {
        if (totalSymbols < MAX_SYMBOLS) {
            symbolData[totalSymbols].symbol = symbol;
            symbolIndex = totalSymbols;
            totalSymbols++;
            Print("Total symbols count: ", totalSymbols);
        } else {
            Print("Max number of symbols reached.");
            return;
        }
    }

    currentBid = NormalizeDouble(MarketInfo(symbol, MODE_BID), SymbolInfoInteger(symbol, SYMBOL_DIGITS));
    currentAsk = NormalizeDouble(MarketInfo(symbol, MODE_ASK), SymbolInfoInteger(symbol, SYMBOL_DIGITS));

    //Print("Highest Bid price: ", symbolData[symbolIndex].highestBidPrice, " for ", symbol);
    //Print("Lowest Ask price (up): ", symbolData[symbolIndex].lowestAskPrice, " for ", symbol);
    //Print("LA(sell) value: ", LA);
    //Print("HB(buy) value: ", HB);

    if (currentBid > symbolData[symbolIndex].highestBidPrice) 
    {
        symbolData[symbolIndex].highestBidPrice = currentBid;
        //Print("H( ",symbol," ): ", symbolData[symbolIndex].highestBidPrice);
        if(symbolData[symbolIndex].highestBidPrice > HB || HB == 0.0)
        {
            highestBidPriceReached = currentBid;
            updateHB(tradeId,highestBidPriceReached);
            Print(highestBidPriceReached, " This is the highest BID price reached for ", symbol);
        }
        
    }

    if (currentAsk < symbolData[symbolIndex].lowestAskPrice || symbolData[symbolIndex].lowestAskPrice == 0.0) 
    {
        symbolData[symbolIndex].lowestAskPrice = currentAsk;
        //Print("L( ",symbol," ): ", symbolData[symbolIndex].lowestAskPrice);
        if (symbolData[symbolIndex].lowestAskPrice < LA || LA == 0.0) 
        {
            lowestAskPriceReached = currentAsk;
            updateLA(tradeId,lowestAskPriceReached);
            //Print(lowestAskPriceReached, " This is the lowest ASK price reached for ", symbol);
        }
        
    }
}


int OnInit() {
    ArrayResize(orderDetails, 0); // Initialize the orderDetails array
    ArrayResize(selectDetails, 0); // Initialize the orderDetails array
    ArrayResize(selecthedgeDetails, 0); // Initialize the orderDetails array

    /*if (getOrderDetails()) {
        // Print the retrieved order details
        for (int i = 0; i < ArraySize(orderDetails); i++) {
            Print("Id: ", orderDetails[i].id);
            Print("Symbol: ", orderDetails[i].symbol);
            Print("Buy Price: ", orderDetails[i].buy_price);
            Print("Sell Price: ", orderDetails[i].sell_price);
        }
    }*/

    // Initialize the timer
    EventSetTimer(1);

    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    // Deinitialization code, if needed
    // Deinitialize your Expert Advisor here
    EventKillTimer();
}

void OnTimer() 
{
      //Alert("IN CHRIST WE MOVE, LIVE AND HAVE OUR BEING");
      if (selectTradeDetails())
      {
          for (int i = 0; i < ArraySize(selectDetails); i++)
          {
                    // Iterate through your database records
                    tradeID = selectDetails[i].id; // This is the order id, which serves as the custom identifier
                    tradeTicket = selectDetails[i].ticket; // This is the order ticket, which serves as the custom identifier
                    tradeSymbol = selectDetails[i].symbol; // This is the order symbol, which serves as the custom identifier
                    tradeLot = selectDetails[i].lots; // This is the order lot size, which serves as the custom identifier
                    tradeOrderType = selectDetails[i].ordertype; // This is the order type
                    tradeEntryPrice = selectDetails[i].entryprice; // This is the order entryprice.
                    tradeHedgePrice = selectDetails[i].hedgeprice; // This is the order hedgeprice.
                    tradeProfit = selectDetails[i].orderprofit; // This is the order Profit/loss.
                    tradeHBPrice = selectDetails[i].highestbidpricereached; // This is the Highest bid price reached
                    tradeLAPrice = selectDetails[i].lowestaskpricereached; // This is the lowest ask price reached
                    tradeClosed = selectDetails[i].close_trade; // This is the order lot size, which serves as the custom identifier
                    tradeTrailingP = selectDetails[i].trailing_p; // This is the order trailing indicatior, which serves as the custom identifier
                    tradeTaken = selectDetails[i].trade_taken; // This is the order trade taken indicator, which serves as the custom identifier
                    tradeOut = selectDetails[i].trade_out; // This is the order trade out indicator, which serves as the custom identifier
                    tradeTime = selectDetails[i].time; // Get trade open time
                    tradeHedging = selectDetails[i].hedging; // This is the order hedging value (0 or 1), which serves as the custom identifier
                    tradeHedgingReached = selectDetails[i].hedging_reached; // This is the order hedging value (0 or 1), which serves as the custom identifier
                    tradeHedgeSignalSent = selectDetails[i].hedge_signal; // This is the order hedging signal sent (0 or 1), which serves as the custom identifier
                    tradeTfDigit = selectDetails[i].tfdigit;
                    
                    
                        Print("TradeId: ", tradeID, " Symbol name: ", tradeSymbol);
                        //Print("");
                        //Print("");
                        
                    // Trade management (trailing, management variables)
                    currentBid = NormalizeDouble(MarketInfo(tradeSymbol, MODE_BID), SymbolInfoInteger(tradeSymbol, SYMBOL_DIGITS));
                    currentAsk = NormalizeDouble(MarketInfo(tradeSymbol, MODE_ASK), SymbolInfoInteger(tradeSymbol, SYMBOL_DIGITS));
                    point = MarketInfo(tradeSymbol, MODE_POINT);
                    pip_val = 10*point;
                    symDigit = MarketInfo(tradeSymbol, MODE_DIGITS);
                    symbolSpread = NormalizeDouble(SymbolInfoInteger(tradeSymbol, SYMBOL_SPREAD), symDigit);
                    int barr = iBars(tradeSymbol,tradeTfDigit);
                    double HighestBid = MarketInfo(tradeSymbol, MODE_BID);
                    datetime timee = iTime(tradeSymbol,tradeTfDigit, 0);
                    int OrderSymbolDigit;      
                    tradeOpenTime = StringToTime(tradeTime);
                    tradeDateTime = TimeToString(tradeTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                    
                        //Print("Symbol: ", tradeSymbol, " Current Ask: ", currentAsk);
                        
                       // The trade in the database matches the currently open trade
                       // You can update order profit (PNL) here
                                         
                       if(tradeClosed == 1 && tradeOrderType == 0 && tradeOut == 0 && tradeTrailingP == 0 && tradeHedging == 1)
                       {
                           Oticket = OrderClose(tradeTicket,tradeLot,currentBid,3,clrOrangeRed);
                           if(Oticket<1)
                           {
                                 //Alert("Error closing trade for ", tradeTicket, " symbol: ", tradeSymbol, " Error_", GetLastError());
                           }
                           else 
                           {
                                 Alert("Closed: ",tradeTicket," Symbol: ",tradeSymbol," -- Profit:) ",tradeProfit);
                                 //tradeDone(tradeID);
                           }
                           
                       }
                       else if(tradeClosed == 1 && tradeOrderType == 1 && tradeOut == 0 && tradeTrailingP == 0 && tradeHedging == 1)
                       {
                           Oticket = OrderClose(tradeTicket,tradeLot,currentAsk,3,clrBrown);
                           if(Oticket<1)
                           {
                                 // Alert("Error closing trade for ", tradeTicket, " symbol: ", tradeSymbol, " Error_", GetLastError());
                           }
                           else 
                           {
                                 Alert("Closed: ",tradeTicket," Symbol: ",tradeSymbol," -- Profit:) ",tradeProfit);
                                 //tradeDone(tradeID);
                           }
                       }
                             // Trail profit trade (not hedging trade)
                             // Trade profit management -- Hedging mode activation
                             //Print("Trade entry: ", tradeEntryPrice);
                             // In your  order handling loop for a BUY trade:
                                 if (tradeOrderType == 0 && tradeHedging == 0 && tradeTaken == 1) 
                                 {
                                    //Print(ordersym);
                                     for (int d = barr - 1; d >= 0; d--) 
                                     {
                                         if (timee >= tradeTime) 
                                         {
                                             // Call the custom function to update bid and ask prices
                                             //Print("Trade Symbol: ", tradeSymbol);
                                             UpdateBidAskPrices(tradeSymbol, tradeID, tradeHBPrice, tradeLAPrice);
                                           
                                 
                                             // Calculate the closing price for a BUY trade (e.g., 5 pips below highest bid)
                                             //Print("Symbol (buy): ", tradeSymbol, " Price ", highestBidPriceReached);
                                             double closingPrice = NormalizeDouble(tradeHBPrice - (3 * pip_val), symDigit);
                                             //Print("Symbol (buy): ", tradeSymbol, " Closing price ", closingPrice);
                                             //activationPrice
                                             //Print("Trade entry: ", tradeEntryPrice);
                                             activationPrice = NormalizeDouble(tradeEntryPrice + (10 * pip_val), symDigit);
                                             //Print("Symbol (buy): ", tradeSymbol, " Current Bid price ", currentBid);
                                             //Print("Activation Price: ", activationPrice, " for: ", ordersym);
                                             //Print("Price to close at: ", closingPrice);
                                             initalCPrice = NormalizeDouble(activationPrice - (1 * pip_val),symDigit);
                                             IC_stopPrice = NormalizeDouble(tradeEntryPrice + (3 * pip_val), symDigit);
                                             
                                             if(currentBid > activationPrice)
                                             {
                                                    //Alert("Bid Price: ", currentBid, " for ", tradeSymbol);
                                                    //Alert("Activation Price: ", activationPrice, " for ", tradeSymbol);
                                                    //Alert("Closing Price: ", closingPrice, " for ", tradeSymbol);
                                                    Print("Trailing (buy) activated for ", tradeSymbol, "at price: ", activationPrice);
                                                   // Check if the current bid is within the closing price range
                                                   if (currentBid <= closingPrice) 
                                                   {
                                                       // Close the BUY trade
                                                       int ticket = OrderClose(tradeTicket, tradeLot, currentBid, 0, clrNONE);
                                                       if (ticket > 0) 
                                                       {
                                                           Alert("Profit Trailed: Closed BUY trade for ",tradeSymbol, " ", tradeTicket, " successfully at bid price: ", currentBid);
                                                       } else 
                                                       {
                                                           //Print("Error closing BUY trade: ", GetLastError());
                                                       }
                                                   }
                                                   else if(currentBid == initalCPrice) 
                                                   {  
                                                       int ticket = OrderClose(tradeTicket, tradeLot, currentBid, 0, clrNONE);
                                                       if (ticket > 0) 
                                                       {
                                                           Alert("Initial profit target: Closed BUY trade for ",tradeSymbol, " successfully at bid price: ", currentBid);
                                                       } 
                                                       else 
                                                       {
                                                           Print("Error closing BUY trade: ", GetLastError());
                                                       }
                                                
                                                  }
                                             }
                                             else 
                                             {
                                                break; // Stop iterating when we reach the time of trade open
                                             }
                                     }
                                 }        
                             }
                             else if(tradeOrderType == 1 && tradeHedging == 0 && tradeTaken == 1)
                             {
                                       for (int d = barr - 1; d >= 0; d--) 
                                       {
                                            if (timee >= tradeTime) 
                                            {
                                                // Call the custom function to update bid and ask prices
                                                ordersym = tradeSymbol;
                                                //Print("Lowest ask price: ", tradeLAPrice);
                                                UpdateBidAskPrices(tradeSymbol, tradeID, tradeHBPrice, tradeLAPrice);
                                                // Calculate the closing price for a SELL trade (e.g., 5 pips above lowest ask)
                                                //Print("Symbol: ", tradeSymbol, " Price ", lowestAskPriceReached);
                                                double closingPrice = NormalizeDouble(tradeLAPrice + (3 * pip_val), symDigit);
                                                
                                                //Print("Closing Price: ", closingPrice);
                                                //activationPrice
                                                //Print("Trade entry: ", tradeEntryPrice);
                                                activationPrice = NormalizeDouble(tradeEntryPrice - (10 * pip_val), symDigit);
                                                initalCPrice = NormalizeDouble(activationPrice + (1 * pip_val),symDigit);
                                                IC_stopPrice = NormalizeDouble(tradeEntryPrice - (3 * pip_val), symDigit);
                                                
                                                if(currentAsk < activationPrice)
                                                {
                                                   //Print("Closing Price: ", closingPrice);
                                                   //Alert("Ask Price: ", currentAsk, " for ", tradeSymbol);
                                                   //Alert("Activation Price: ", activationPrice, " for ", tradeSymbol);
                                                   //Alert("Closing Price: ", closingPrice, " for ", tradeSymbol);
                                                   Print("Trailing (sell)  activated for ", tradeSymbol, " at price: ", closingPrice);
                                                   // Check if the current ask is within the closing price range
                                                   if (currentAsk >= closingPrice) {
                                                       // Close the SELL trade
                                                       int ticket = OrderClose(tradeTicket, tradeLot, currentAsk, 0, clrNONE);
                                                       if (ticket > 0) 
                                                       {
                                                           Alert("Profit Trailed: Closed SELL trade for ",tradeSymbol, " successfully at Ask price: ", currentAsk);
                                                       } else 
                                                       {
                                                           Print("Error closing SELL trade: ", GetLastError());
                                                       }
                                                   }
                                                   else if(currentAsk == initalCPrice) 
                                                   {
                                                  
                                                       int ticket = OrderClose(tradeTicket, tradeLot, currentAsk, 0, clrNONE);
                                                       if (ticket > 0) {
                                                           Alert("Inital Profit target: Closed SELL trade for ",tradeSymbol, " successfully at Ask price: ", currentAsk);
                                                       } else {
                                                           //Print("Error closing BUY trade: ", GetLastError());
                                                       }
                                                  
                                                   }
                                               }
                                                // Rest of your SELL trade logic
                                            
                                            else 
                                            {
                                                break; // Stop iterating when we reach the time of trade open
                                            }
                                      }
                                    }
                               }
                            
                        
                        // Sum profit or loss for the trades on
                             tradeProfitSum = get_total_order_profit(tradeID);
                             if(tradeHedging == 1 && tradeClosed == 0)
                             {
                                   Print("Symbol: ", tradeSymbol, " -- (", tradeProfitSum, ") ", tradeID);
                                   if (tradeProfitSum >= 0.5)
                                   {
                                       closeTrades(tradeID);
                                       Alert("Closing losing trades ", tradeSymbol, " :) (", tradeProfitSum ,") and the hedge trades to it ", tradeTicket, " -- ", tradeID);
                                          // update close_trade(mt4order) or closetrade(hedge_trades) to '1', then close the trades && update trailingP(mt4order) or trailingHP(hedge_trades) to '1', to start hedging the trades
                                       //update_trade_profiting(tradeID);
                                      
                                   }
                             }
                             
                             
                             
                             // Take a hedge trade here
                                  oldLotSize = GetLotsize(tradeID);
                                  //Print("Old lotSize: ", oldLotSize);
                                     newLotSize = NormalizeDouble(MathAbs(oldLotSize*1.33),2);
                                     if(newLotSize >= 0.01 && newLotSize <= 0.019)
                                     {
                                         newLotSize = 0.02;
                                         //Print("New Lot size: ", newLotSize, " for ", tradeSymbol);
                                         //HedgingMode(tradeEntryPrice,currentBid,currentAsk,tradeHedgePrice,newLotSize,tradeSymbol,tradeOrderType,tradeHedgingReached,tradeHedgeSignalSent); 
                                     }
                                     else
                                     {
                                          newLotSize = NormalizeDouble(MathAbs(oldLotSize*1.33),2);
                                          //Print("New Lot size: ", newLotSize, " for ", tradeSymbol);
                                     }   
                                     HedgingMode(tradeEntryPrice,currentBid,currentAsk,tradeHedgePrice,newLotSize,tradeSymbol,tradeOrderType,tradeHedgingReached,tradeHedgeSignalSent); 
                                  
                             
                             
                           bool matchFound = false;
                           for(int a = 0; a < OrdersTotal(); a++)
                           {
                              if(OrderSelect(a, SELECT_BY_POS))
                              { 
                                if(tradeTicket == OrderTicket())
                                {
                                    //Print("Symbol: ", tradeSymbol);
                                    matchFound = true;
                                    break;
                                }
                              }
                                      
                               
                           }
                           if (!matchFound && tradeHedging == 0)
                           {
                              // The trade in the database no longer exists as an open order
                              // You can take appropriate action, such as updating the 'close_trade' column in the database
                              Alert("Updated(no hedge) trade_out for: ", tradeID, " symbol and ticket: ", tradeSymbol, " ", tradeTicket); 
                              updateCloseTrade(tradeID,1,1);
                              Print("The trade with ID ", tradeID, " no longer exists as an open order.");
                           }
                           else if (!matchFound && tradeHedging == 1 && tradeClosed == 0)
                           {
                              // The trade in the database no longer exists as an open order
                              // You can take appropriate action, such as updating the 'close_trade' column in the database
                              updateCloseTrade(tradeID,1,0);
                              //Print("The trade with ID ", tradeID, " no longer exists as an open order.");
                           }
                           else if (!matchFound && tradeHedging == 1 && tradeClosed == 1 && tradeOut == 0)
                           {
                              // The trade in the database no longer exists as an open order
                              // You can take appropriate action, such as updating the 'close_trade' column in the database
                             update_takeOver(tradeID);
                              //Print("The trade with ID ", tradeID, " no longer exists as an open order.");
                           }
                          
                          
                           if(!matchFound && tradeHedging == 1 && tradeClosed == 1 && tradeOut == 0)
                           {
                              string message = checkClosedHedgeTrade(tradeID);
                              if(message == "All hedge closed. Take action accordingly.")
                              {
                                 updateCloseTrade(tradeID,1,1);
                                 Alert("Updated trade_out for: ", tradeID, " symbol and ticket: ", tradeSymbol, " ", tradeTicket); 
                              }
                              else 
                              {
                                 
                                    Print("Can't update trade_out for ",tradeSymbol," yet, Why?? -- ", checkClosedHedgeTrade(tradeID));
                                    //Print("The id: ", tradeID);
                              }
                           }
     
     //loop ends here
   }
 }  
 
    // Update P/L(profit or loss) for orignal trades
      
      for(int j = 0; j < OrdersTotal(); j++)
      {
         if(OrderSelect(j, SELECT_BY_POS))
         {
            orderProfit = OrderProfit();
            update_OrderProfit2(OrderTicket(), orderProfit);
            //Print(OrderProfit(), " -| ", OrderSymbol());
         }
      }
      
      
      // Hedge code management
       if (selectHedgeTrades())
       {
               for (int i = 0; i < ArraySize(selecthedgeDetails); i++)
               { 
                                
                    tradeID = selecthedgeDetails[i].id; // This is the order id, which serves as the custom identifier
                    tradeFromID = selecthedgeDetails[i].from_id; // This is the mt4order trade 'id', the parent to the hedge trade in respect to the 'id', of each trades in the mt4order
                    tradeTicket = selecthedgeDetails[i].orderticket; // This is the order ticket, which serves as the custom identifier
                    tradeSymbol= selecthedgeDetails[i].symbol; // This is the order symbol, which serves as the custom identifier
                    tradeLot = selecthedgeDetails[i].lot; // This is the order lot size, which serves as the custom identifier
                    tradeOrderType = selecthedgeDetails[i].ordertype; // This is the order lot size, which serves as the custom identifier
                    tradeEntryPrice = selecthedgeDetails[i].entryprice; // This is the order lot size, which serves as the custom identifier
                    tradeProfit = selecthedgeDetails[i].orderprofit; // This is the order lot size, which serves as the custom identifier
                    tradeClosed = selecthedgeDetails[i].closetrade; // This is the order lot size, which serves as the custom identifier
                    tradeTrailingP = selecthedgeDetails[i].trailingP; // This is the value of trailingP, which serves as the custom identifier
                    tradeTaken = selecthedgeDetails[i].trade_taken; // This is the order lot size, which serves as the custom identifier
                    tradeOut = selecthedgeDetails[i].trade_out; // This is the order lot size, which serves as the custom identifier 
                    tradeTime = selecthedgeDetails[i].timing; // This is the trade open time, which serves as the custom identifier 
                    tradeTakeOver = selecthedgeDetails[i].take_over;
                    
                    
                    
                    
                    //Close hedge trades (sum of P/L >= 0.5) -- This happens when the orignal (parent) of the hedge trades is closed already!
                    if(tradeClosed == 0 && tradeOut == 0 && tradeTakeOver == 1)
                    {
                          tradeProfitSum = get_total_order_profit(tradeFromID);
                          Print("Symbol hedge: ", tradeSymbol, " -- (", tradeProfitSum, ") ", tradeFromID);
                          if (tradeProfitSum >= 0.5)
                          {
                              closeTrades(tradeFromID);
                              Alert("Closing losing trades ", tradeSymbol, " :) (", tradeProfitSum ,") and the hedge trades to it ", tradeTicket, " -- ", tradeID);
                                 // update close_trade(mt4order) or closetrade(hedge_trades) to '1', then close the trades && update trailingP(mt4order) or trailingHP(hedge_trades) to '1', to start hedging the trades
                              //update_trade_profiting(tradeID);
                             
                          }
                    }
                    
                    
                    
                    // Close the trades here
                    if(tradeClosed == 1 && tradeOrderType == 0 && tradeOut == 0)
                    {
                        Oticket = OrderClose(tradeTicket,tradeLot,currentBid,3,clrOrangeRed);
                        if(Oticket<1)
                        {
                              Alert("Error closing trade for ", tradeTicket, " symbol: ", tradeSymbol, " Error_", GetLastError());
                        }
                        else 
                        {
                              Alert("Closed hedge (first a buy): ",tradeTicket," Symbol: ",tradeSymbol," -- Profit:)  ",tradeProfit);
                              //tradeDone(tradeID);
                        }
                        
                    }
                    else if(tradeClosed == 1 && tradeOrderType == 1 && tradeOut == 0)
                    {
                        Oticket = OrderClose(tradeTicket,tradeLot,currentAsk,3,clrBrown);
                        if(Oticket<1)
                        {
                              Alert("Error closing trade for ", tradeTicket, " symbol: ", tradeSymbol, " Error_", GetLastError());
                        }
                        else 
                        {
                              Alert("Closed hedge (first a sell): ",tradeTicket," Symbol: ",tradeSymbol," -- Profit:) ",tradeProfit);
                              //tradeDone(tradeID);
                        }
                    }
                    
                    
                     // Update P/L (profit / loss) for hedge trades
                   bool matchFound2 = false;
                   for (int b = 0; b < OrdersTotal(); b++)
                   {
                        if (OrderSelect(b, SELECT_BY_POS))
                        {
                            // Check if the custom identifier (order ticket) matches
                            if (tradeTicket == OrderTicket())
                            {
                                   // Update current profit of current hedge trades
                                   update_hedge_OrderProfit(tradeID,OrderProfit());
                                   // The trade in the database matches an open trade
                                   matchFound2 = true;
                                   break;
                            }
                        }
                   }
                   
                   if (!matchFound2)
                   {
                        // The trade in the database no longer exists as an open order
                        // You can take appropriate action, such as updating the 'close_trade' column in the database
                        updateCloseHedgeTrade(tradeID);
                        Print("The trade with ID ", tradeID, " no longer exists as an open order.");
                   }
                    
                    
               }
               
               
               
                
        }

}