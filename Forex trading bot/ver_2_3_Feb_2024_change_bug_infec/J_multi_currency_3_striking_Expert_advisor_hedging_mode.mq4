#include <main.mqh>
//+------------------------------------------------------------------+
//|              J_multi_currency_3_line_striking_Expert_Advisor.mq4 |
//|                                                       WEbarnabas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "WEbarnabas"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <function_room.mqh>
input string EaName = "3-linE striker";
string what_timeframe = "";
int tf_digit;
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    point = MarketInfo(sym_watchlist, MODE_POINT);
    pip_val = 10*point;
    accFreeMargin = NormalizeDouble(AccountFreeMargin(),2);
    accEquity = NormalizeDouble(AccountEquity(),2);
    //Alert(accFreeMargin);
    /*if(accFreeMargin < 15.0)
    {
         lot_size = 0.01;
         dEloss = 1.5;
    }
    if(accFreeMargin >= 15.0 && accFreeMargin <= 25.0)
    {
         lot_size = 0.03;
         dEloss = 4.51;
    }
    else if (accFreeMargin >= 26.0 && accFreeMargin <= 32.0)
    {
         lot_size = 0.04;
         dEloss = 6.00;
    }
    else if (accFreeMargin >= 33.0 && accFreeMargin <= 43.93)
    {
         lot_size = 0.05;
         dEloss = 7.80;
    }
    else if (accFreeMargin >= 43.94 && accFreeMargin <= 57.11)
    {
         lot_size = 0.07;
         dEloss = 10.14;
    }
    else if (accFreeMargin >= 57.12 && accFreeMargin <= 74.25)
    {
         lot_size = 0.09;
         dEloss = 13.18;
    }
    else if (accFreeMargin >= 74.26 && accFreeMargin <= 96.53)
    {
         lot_size = 0.11;
         dEloss = 17.14;
    }
    else if (accFreeMargin >= 96.54 && accFreeMargin <= 125.49)
    {
         lot_size = 0.14;
         dEloss = 22.28;
    }
    else if (accFreeMargin >= 125.50 && accFreeMargin <= 163.14)
    {
         lot_size = 0.19;
         dEloss = 28.96;
    }
    else if (accFreeMargin >= 163.15 && accFreeMargin <= 212.08)
    {
         lot_size = 0.24;
         dEloss = 37.65;
    }
    else if (accFreeMargin >= 212.09 && accFreeMargin <= 275.71)
    {
         lot_size = 0.32;
         dEloss = 48.94;
    }
    else if (accFreeMargin >= 275.72 && accFreeMargin <= 358.42)
    {
         lot_size = 0.41;
         dEloss = 63.63;
    }
    else if (accFreeMargin >= 358.43 && accFreeMargin <= 465.95)
    {
         lot_size = 0.54;
         dEloss = 82.72;
    }
    else if (accFreeMargin >= 465.96 && accFreeMargin <= 605.74)
    {
         lot_size = 0.70;
         dEloss = 107.53;
    }
    else if (accFreeMargin >= 605.75 && accFreeMargin <= 787.47)
    {
         lot_size = 0.91;
         dEloss = 139.79;
    }
    else if (accFreeMargin >= 787.48 && accFreeMargin <= 1023.71)
    {
         lot_size = 1.18;
         dEloss = 181.73;
    }
    else if (accFreeMargin >= 1023.72 && accFreeMargin <= 1330.82)
    {
         lot_size = 1.54;
         dEloss = 236.24;
    }
    else if (accFreeMargin >= 1330.83 && accFreeMargin <= 1729.99)
    {
         lot_size = 2.00;
         dEloss = 307.12;
    }
    else if (accFreeMargin >= 1730.0 && accFreeMargin <= 2249.10)
    {
         lot_size = 2.60;
         dEloss = 399.25;
    }
    else if (accFreeMargin >= 2249.11 && accFreeMargin <= 2923.03)
    {
         lot_size = 3.37;
         dEloss = 519.02;
    }
    else if (accFreeMargin >= 2923.04 && accFreeMargin <= 3800.98)
    {
         lot_size = 4.39;
         dEloss = 674.73;
    }
    else if (accFreeMargin >= 3800.99 && accFreeMargin <= 4941.28)
    {
         lot_size = 5.70;
         dEloss = 877.15;
    }
    else if (accFreeMargin >= 4941.29 && accFreeMargin <= 6423.67)
    {
         lot_size = 7.41;
         dEloss = 1140.30;
    }
    else if (accFreeMargin >= 6423.68 && accFreeMargin <= 8350.77)
    {
         lot_size = 9.64;
         dEloss = 1482.39;
    }
    else if (accFreeMargin >= 8350.78 && accFreeMargin <= 10856.01)
    {
         lot_size = 12.53;
         dEloss = 1927.10;
    }
    else if (accFreeMargin >= 10856.02 && accFreeMargin <= 14112.81)
    {
         lot_size = 16.28;
         dEloss = 2505.23;
    }
    else if (accFreeMargin >= 14112.82 && accFreeMargin <= 18346.66)
    {
         lot_size = 21.17;
         dEloss = 3256.80;
    }
    else if (accFreeMargin >= 18346.67 && accFreeMargin <= 23850.66)
    {
         lot_size = 27.52;
         dEloss = 4233.85;
    }
    else if (accFreeMargin >= 23850.67 && accFreeMargin <= 31005.86)
    {
         lot_size = 35.78;
         dEloss = 5504.00;
    }
    else if (accFreeMargin >= 31005.87 && accFreeMargin <= 40307.62)
    {
         lot_size = 46.51;
         dEloss = 7155.20;
    }
    else if (accFreeMargin >= 40307.63 && accFreeMargin <= 52399.90)
    {
         lot_size = 60.46;
         dEloss = 9301.76;
    }*/
    lot_size = 0.01;
    for(int a = 0; a < TotalSymbols; a++)
    {
    
            sym_watchlist = SymbolName(a,true);
            //SymbolSelect(sym_watchlist,true);
            //Print(sym_watchlist);
            symDigit = MarketInfo(sym_watchlist,MODE_DIGITS);
            point = MarketInfo(sym_watchlist, MODE_POINT);
            pip_val = 10*point;
            symbolSpread = NormalizeDouble(SymbolInfoInteger(sym_watchlist, SYMBOL_SPREAD), symDigit);
            for(int b = 0; b < timeFrameSize; b++)
            {
               fastMa = NormalizeDouble(iMA(sym_watchlist,timeFrame[b],f_MAPeriod,0,MODE_SMA,PRICE_CLOSE,0), symDigit);
               slowMa = NormalizeDouble(iMA(sym_watchlist,timeFrame[b],s_MAPeriod,0,MODE_SMA,PRICE_CLOSE,0), symDigit);
               //Print("FastMa: ", fastMa, " slowMa: ", slowMa, " for symbol: ", sym_watchlist, " For: ", timeFrame[b]);
     
            
                  symbolAsk = NormalizeDouble(MarketInfo(sym_watchlist, MODE_ASK), SymbolInfoInteger(sym_watchlist, SYMBOL_DIGITS));
                  symbolBid = NormalizeDouble(MarketInfo(sym_watchlist, MODE_BID), SymbolInfoInteger(sym_watchlist, SYMBOL_DIGITS));
            //Print("Close Price: ",iClose(sym_watchlist,PERIOD_CURRENT,1));
                     // Entry logic
                         if (IsPositionOpen(sym_watchlist))
                         {
                              //Alert("Symbol" + sym + " already in a trade!");
                              continue;
                         }

                     
                     //Print(inTrade);
                     //Alert(symDigit);
                     //Free margin < (50%equity) (50%100)
                     if(NormalizeDouble(MathAbs(iClose(sym_watchlist, timeFrame[b],1)-iOpen(sym_watchlist,timeFrame[b],1)),symDigit) >= (5 * pip_val))
                     {
                        //Alert(5 * pip_val);
                        //Alert("Pips for ", sym_watchlist, ": ", NormalizeDouble(MathAbs(iClose(sym_watchlist, timeFrame[0],1)-iOpen(sym_watchlist,timeFrame[0],1)),symDigit));
                     }
                     if (isNewCandle(sym_watchlist,timeFrame[b]))
                     {
                          
                          
                       //Alert("Current Candle closed for: ", sym_watchlist, " for: ", timeFrame[b]);
                       //Print(sym_watchlist);
                       //Alert("Type candle formed: ", typeOfCurrentCandle(sym_watchlist,timeFrame[0],1));
                       //Alert(timeFrame[0]);
                       //inTrade = False;
                       //
                     }
                       /*if(accFreeMargin > (takeTradePercentage / 100.0 * accEquity))
                       {*/
                          if(iClose(sym_watchlist,timeFrame[b],1) > iOpen(sym_watchlist,timeFrame[b],1) && iClose(sym_watchlist,timeFrame[b],2) < iOpen(sym_watchlist,timeFrame[b],2) && iClose(sym_watchlist,timeFrame[b],3) < iOpen(sym_watchlist,timeFrame[b],3) && iClose(sym_watchlist,timeFrame[b],4) < iOpen(sym_watchlist,timeFrame[b],4) && iClose(sym_watchlist,timeFrame[b],1) > MathAbs(NormalizeDouble(((iOpen(sym_watchlist,timeFrame[b],3) - iClose(sym_watchlist,timeFrame[b],3)) / 2) + iClose(sym_watchlist,timeFrame[b],3), symDigit)) && NormalizeDouble(MathAbs(iClose(sym_watchlist, timeFrame[b],1)-iOpen(sym_watchlist,timeFrame[b],1)),symDigit) >= (3 * pip_val) && NormalizeDouble(MathAbs(iClose(sym_watchlist, timeFrame[b],1)-iOpen(sym_watchlist,timeFrame[b],1)),symDigit) <= (40 * pip_val) && iClose(sym_watchlist,timeFrame[b],1) > fastMa && iClose(sym_watchlist,timeFrame[b],1) > slowMa && symbolSpread <= symbolSpreadMax)
                          {
                              Print("");
                              Print("Type candle formed: ", typeOfCurrentCandle(sym_watchlist,timeFrame[b],1), " FOR: ", sym_watchlist, " Timeframe: ", timeFrame[b], ".");
                              //Alert(":)Buy ", MathAbs(NormalizeDouble(((Open[3] - Close[3]) / 2) + Close[3],_Digits)) + " For: " + Close[3]);
                              //Alert(sym_watchlist);
                              //OrderInTrade = OrderSend(sym_watchlist,OP_BUY,lot_size,symbolAsk,0,0,0);
                              if(timeFrame[b] == 1)
                              {
                                 what_timeframe = "1 minute timeframe";
                                 tf_digit = 1;
                              }
                              else if(timeFrame[b] == 5)
                              {
                                 what_timeframe = "5 minutes timeframe";
                                 tf_digit = 5;
                              }
                              else if(timeFrame[b] == 15)
                              {
                                 what_timeframe = "15 minutes timeframe";
                                 tf_digit = 15;
                              }
                              else if(timeFrame[b] == 30)
                              {
                                 what_timeframe = "30 minutes timeframe";
                                 tf_digit = 30;
                              }
                              else if(timeFrame[b] == 60)
                              {
                                 what_timeframe = "1 hour timeframe";
                                 tf_digit = 60;
                              }
                              else if(timeFrame[b] == 240)
                              {
                                 what_timeframe = "4 hours timeframe";
                                 tf_digit = 240;
                              }
                              string sender="";
                              string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                              sender+=StringFormat("%s,%f,%d,%s,%s,%d|",sym_watchlist,lot_size,OP_BUY,EaName,what_timeframe,tf_digit);
                              Print(httpGET("http://localhost/Ecardextract/trade_signal1.php?order="+sender));
                             /*if(OrderInTrade < 1)
                             {}
                             else{
                                    tradeExecuted = True;
                                    Alert("Sent trade details to database: ", sym_watchlist);
                             }*/
                          }
                          //
                          else if (iClose(sym_watchlist,timeFrame[b],1) < iOpen(sym_watchlist,timeFrame[b],1) && iClose(sym_watchlist,timeFrame[b],2) > iOpen(sym_watchlist,timeFrame[b],2) && iClose(sym_watchlist,timeFrame[b],3) > iOpen(sym_watchlist,timeFrame[b],3) && iClose(sym_watchlist,timeFrame[b],4) > iOpen(sym_watchlist,timeFrame[b],4) && iClose(sym_watchlist,timeFrame[b],1) < MathAbs(NormalizeDouble(((iClose(sym_watchlist,timeFrame[b],3) - iOpen(sym_watchlist,timeFrame[b],3)) / 2) + iOpen(sym_watchlist,timeFrame[b],3), symDigit)) && MathAbs(NormalizeDouble(iClose(sym_watchlist, timeFrame[b],1)-iOpen(sym_watchlist,timeFrame[b],1),symDigit)) >= (3 *pip_val) && MathAbs(NormalizeDouble(iClose(sym_watchlist, timeFrame[b],1)-iOpen(sym_watchlist,timeFrame[b],1),symDigit)) <= (40 *pip_val) && iClose(sym_watchlist,timeFrame[b],1) < fastMa && iClose(sym_watchlist,timeFrame[b],1) < slowMa && symbolSpread <= symbolSpreadMax)
                          {
                                 Print("");
                                 Print("Type candle formed: ", typeOfCurrentCandle(sym_watchlist,timeFrame[b],1), " FOR: ", sym_watchlist, " Timeframe: ", timeFrame[b], ".");
                                 //Alert(sym_watchlist);
                                 //OrderInTrade = OrderSend(sym_watchlist,OP_SELL,lot_size,symbolBid,0,0,0);
                                 if(timeFrame[b] == 1)
                                 {
                                    what_timeframe = "1 minute timeframe";
                                    tf_digit = 1;
                                 }
                                 else if(timeFrame[b] == 5)
                                 {
                                    what_timeframe = "5 minutes timeframe";
                                    tf_digit = 5;
                                 }
                                 else if(timeFrame[b] == 15)
                                 {
                                    what_timeframe = "15 minutes timeframe";
                                    tf_digit = 15;
                                 }
                                 else if(timeFrame[b] == 30)
                                 {
                                    what_timeframe = "30 minutes timeframe";
                                    tf_digit = 30;
                                 }
                                 else if(timeFrame[b] == 60)
                                 {
                                    what_timeframe = "1 hour timeframe";
                                    tf_digit = 60;
                                 }
                                 else if(timeFrame[b] == 240)
                                 {
                                    what_timeframe = "4 hours timeframe";
                                    tf_digit = 240;
                                 }
                                 string sender="";
                                 string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                                 sender+=StringFormat("%s,%f,%d,%s,%s,%d|",sym_watchlist,lot_size,OP_SELL,EaName,what_timeframe,tf_digit);
                                 Print(httpGET("http://localhost/Ecardextract/trade_signal1.php?order="+sender));
                                if(OrderInTrade < 1)
                                {}
                                else{
                                       tradeExecuted = True;
                                       Alert("Sent trade details to database: ", sym_watchlist);
                                }
                          }
                          else
                          {
                             //Alert("JESUS IS LORD FOREVER!");
                          }
                        /*}
                        else
                        {
                           Print("Can't take a new signal now, Free margin is less less than 90% of your account equity.");
                        }*/
    
                 
                  
              }
    
         }
    
   /*
    // Bollinger Band
       for(int b = 0; b < TotalSymbols; b++)
       {
               sym_watchlist = SymbolName(b,true);
               //SymbolSelect(sym_watchlist,true);
               //Print(sym_watchlist);
               symDigit = MarketInfo(sym_watchlist,MODE_DIGITS);
               point = MarketInfo(sym_watchlist, MODE_POINT);
               pip_val = 10*point;
               symbolSpread = NormalizeDouble(SymbolInfoInteger(sym_watchlist, SYMBOL_SPREAD), symDigit);
               for(int c = 0; c < tfSize; c++)
               {
                     // Bollinger Band - Implemeting indicator - iBand()
                     bbLowerEntry = iBands(sym_watchlist,tfs[0],bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_LOWER,0);
                     bbUpperEntry = iBands(sym_watchlist,tfs[0],bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_UPPER,0);
                     bbMid = iBands(sym_watchlist,tfs[0],bbPeriod,bandStdEntry,0,PRICE_CLOSE,0,0);  
                     
                     bbLowerProfitExit = iBands(sym_watchlist,tfs[0],bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_LOWER,0);
                     bbUpperProfitExit = iBands(sym_watchlist,tfs[0],bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_UPPER,0);
                     
                     bbLowerLossExit = iBands(sym_watchlist,tfs[0],bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_LOWER,0);
                     bbUpperLossExit = iBands(sym_watchlist,tfs[0],bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_UPPER,0);
                     
                     rsiValue = iRSI(sym_watchlist,tfs[0],rsiPeriod,PRICE_CLOSE,0);
               }
                     //Define varaibles for necessary trade information
                     symbolAsk = NormalizeDouble(MarketInfo(sym_watchlist, MODE_ASK), SymbolInfoInteger(sym_watchlist, SYMBOL_DIGITS));
                     symbolBid = NormalizeDouble(MarketInfo(sym_watchlist, MODE_BID), SymbolInfoInteger(sym_watchlist, SYMBOL_DIGITS));
                     symbolOpen = NormalizeDouble(iOpen(sym_watchlist,tfs[0],0), symDigit);
                     if (IsPositionOpen(sym_watchlist))
                     {
                        //Alert("Symbol" + sym + " already in a trade!");
                        continue;
                     }
                        
                          if(symbolAsk < bbLowerEntry && symbolOpen > bbLowerEntry && symbolSpread <= symbolSpreadMax)
                          {
                              //Alert("Sending BOLLINGER BAND signal: ", "A BUY for the currency pair: ", sym_watchlist);
                              string sender="";
                              string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                              sender+=StringFormat("%s,%f,%d,%s|",sym_watchlist,lot_size,OP_BUY);
                              Print(httpGET("http://localhost/Ecardextract/trade_signal1.php?order="+sender));
                               tradeExecuted = True;
                          }
                          //
                          else if (symbolBid > bbUpperEntry && symbolOpen < bbUpperEntry && symbolSpread <= symbolSpreadMax)
                          {
                                 //Alert("Sending BOLLINGER BAND signal: ", "A SELL for the currency pair: ", sym_watchlist);
                                 //Alert(sym_watchlist);
                                 //OrderInTrade = OrderSend(sym_watchlist,OP_SELL,lot_size,symbolBid,0,0,0);
                                 string sender="";
                                 string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                                 sender+=StringFormat("%s,%f,%d,%s|",sym_watchlist,lot_size,OP_SELL);
                                 Print(httpGET("http://localhost/Ecardextract/trade_signal1.php?order="+sender));
                                
                                    tradeExecuted = True;
                                    //Alert("Sent trade details to database: ", sym_watchlist);
                             
                          }
                          
                    
       
       }*/
    
    // Manage Orders in trade
                
                
                
               /*for(int u = 0; u < OrdersTotal(); u++)
                 {
                          if(OrderSelect(u, SELECT_BY_POS,MODE_TRADES))
                          {
                           ordersym = OrderSymbol();
                           //Print(ordersym);
                           //currentBid = NormalizeDouble(MarketInfo(ordersym, MODE_BID), SymbolInfoInteger(ordersym, SYMBOL_DIGITS));
                           //currentAsk = NormalizeDouble(MarketInfo(ordersym, MODE_ASK), SymbolInfoInteger(ordersym, SYMBOL_DIGITS));
                           point = MarketInfo(ordersym, MODE_POINT);
                           pip_val = 10*point;
                           
                           symDigit = MarketInfo(ordersym, MODE_DIGITS);
                           symbolSpread = NormalizeDouble(SymbolInfoInteger(ordersym, SYMBOL_SPREAD), symDigit);
                           fixedLoss = dEloss;
                           //Print("Loss size: ", dEloss);
                           double entryPrice = OrderOpenPrice();
                           // Calculate the point at which P/L reaches -1.5
                           //double lossPoint = NormalizeDouble(MathAbs((currentBid - entryPrice) * 0.01),symDigit);
                           //Print("This trade P/L: ", lossPoint);
                           double lossPoint = MathAbs(fixedLoss * point);
                           //Print("Loss Point: ", lossPoint);
                           // Calculate the price at the lossPoint
                           //double priceAtLossPoint = NormalizeDouble(entryPrice - lossPoint, symDigit);
                           //Print("StopLoss Price: ",priceAtLossPoint);

                         
                         
                        int barr = iBars(ordersym, PERIOD_CURRENT);
                        double HighestBid = MarketInfo(ordersym, MODE_BID);
                        datetime timee = iTime(ordersym, PERIOD_CURRENT, 0);
                        int OrderSymbolDigit; 
                        
                        tradeOpenTime = OrderOpenTime();
                        
                        // In your order handling loop for a BUY trade:
                        if (OrderType() == OP_BUY) {
                        //Print(ordersym);
                            for (int d = barr - 1; d >= 0; d--) {
                                if (timee >= tradeOpenTime) {
                                    ordersym = OrderSymbol();
                                    // Call the custom function to update bid and ask prices
                                    UpdateBidAskPrices(ordersym);
                        
                                    // Calculate the closing price for a BUY trade (e.g., 5 pips below highest bid)
                                    double closingPrice = NormalizeDouble(highestBidPriceReached - (5 * pip_val), symDigit);
                                    
                                    //activationPrice
                                    activationPrice = NormalizeDouble(OrderOpenPrice() + (10 * pip_val), symDigit);
                                    //Print("Activation Price: ", activationPrice, " for: ", ordersym);
                                    //Print("Price to close at: ", closingPrice);
                                    initalCPrice = NormalizeDouble(activationPrice - (1 * pip_val),symDigit);
                                    IC_stopPrice = NormalizeDouble(OrderOpenPrice() + (3 * pip_val), symDigit);
                                    
                                    if(currentBid > activationPrice)
                                    {
                                           Print("Trailing activated for ", ordersym, "at price: ", closingPrice);
                                          // Check if the current bid is within the closing price range
                                          if (currentBid <= closingPrice) {
                                              // Close the BUY trade
                                              int ticket = OrderClose(OrderTicket(), OrderLots(), currentBid, 0, clrNONE);
                                              if (ticket > 0) {
                                                  Alert("Profit Trailed: Closed BUY trade for ",ordersym, " successfully at bid price: ", currentBid);
                                              } else {
                                                  //Print("Error closing BUY trade: ", GetLastError());
                                              }
                                          }
                                   }
                                   else if(currentBid == initalCPrice) 
                                   {  
                                           int ticket = OrderClose(OrderTicket(), OrderLots(), currentBid, 0, clrNONE);
                                           if (ticket > 0) {
                                               Alert("Initial profit target: Closed BUY trade for ",ordersym, " successfully at bid price: ", currentBid);
                                           } else {
                                               //Print("Error closing BUY trade: ", GetLastError());
                                           }
                                       
                                   }
                        
                                    // Rest of your BUY trade logic
                                } else {
                                    break; // Stop iterating when we reach the time of trade open
                                }
                            }
                            
                            
                            //HedgingMode(currentBid,currentAsk,lot_size,ordersym,OP_BUY); 
                            
                            if(OrderStopLoss() == 0)
                             {
                                stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() - (10 * pip_val), symDigit));
                                //Alert("StopLoss: ", stopLoss);
                                //closeByPips(ordersym,stopLoss);
                                //Alert(closeByPips(ordersym,stopLoss));
                                ModifyOrder = OrderModify(OrderTicket(), 0,stopLoss,OrderTakeProfit(),0,clrNONE);
                                if(ModifyOrder < 1) 
                                {
                                    //Alert("Error modifying stoploss: ", GetLastError());
                                }
                                else{
                                 Alert("StopLoss set", stopLoss);
                                }
                             }    
                        }
                        
                        // In your order handling loop for a SELL trade:
                        if (OrderType() == OP_SELL) {
                           //Print(ordersym);
                           
                            for (int d = barr - 1; d >= 0; d--) {
                                if (timee >= tradeOpenTime) {
                                    // Call the custom function to update bid and ask prices
                                    ordersym = OrderSymbol();
                                    UpdateBidAskPrices(ordersym);
                                    
                                    // Calculate the closing price for a SELL trade (e.g., 5 pips above lowest ask)
                                    double closingPrice = NormalizeDouble(lowestAskPriceReached + (5 * pip_val), symDigit);
                                    
                                    
                                    //activationPrice
                                    activationPrice = NormalizeDouble(OrderOpenPrice() - (10 * pip_val), symDigit);
                                    //Print(currentAsk);
                                    initalCPrice = NormalizeDouble(activationPrice + (1 * pip_val),symDigit);
                                    IC_stopPrice = NormalizeDouble(OrderOpenPrice() - (3 * pip_val), symDigit);
                                    
                                    if(currentAsk < activationPrice)
                                    {
                                       //Print("Closing Price: ", closingPrice);
                                       Print("Trailing activated for ", ordersym, " at price: ", closingPrice);
                                       // Check if the current ask is within the closing price range
                                       if (currentAsk >= closingPrice) {
                                           // Close the SELL trade
                                           int ticket = OrderClose(OrderTicket(), OrderLots(), currentAsk, 0, clrNONE);
                                           if (ticket > 0) {
                                               Print("Profit Trailed: Closed SELL trade for ",ordersym, " successfully at Ask price: ", currentAsk);
                                           } else {
                                               Print("Error closing SELL trade: ", GetLastError());
                                           }
                                       }
                                   }
                                   else if(currentAsk == initalCPrice) 
                                   {
                                      
                                           int ticket = OrderClose(OrderTicket(), OrderLots(), currentAsk, 0, clrNONE);
                                           if (ticket > 0) {
                                               Alert("Inital Profit target: Closed SELL trade for ",ordersym, " successfully at Ask price: ", currentAsk);
                                           } else {
                                               //Print("Error closing BUY trade: ", GetLastError());
                                           }
                                      
                                   }
                        
                                    // Rest of your SELL trade logic
                                } else {
                                    break; // Stop iterating when we reach the time of trade open
                                }
                            }
                           

                               
                               //Print("Current Ask: ", currentAsk);
                               //Print("Current Bid: ", currentBid);
                               //HedgingMode(currentBid,currentAsk,lot_size,ordersym,OP_SELL);
                               if(OrderStopLoss() == 0)
                               {
                                stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() + (10 * pip_val), symDigit));
                                //Print("StopLoss: ", stopLoss);
                                //closeByPips(ordersym,stopLoss);
                                ModifyOrder = OrderModify(OrderTicket(),0,stopLoss,OrderTakeProfit(),0,clrNONE);
                                //if(ModifyOrder < 1) //Alert("Error modifying stoploss: ", GetLastError());
                               }
                            
                      }
            }     
       }*/
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
       OnTick();
   
}
//+------------------------------------------------------------------+

