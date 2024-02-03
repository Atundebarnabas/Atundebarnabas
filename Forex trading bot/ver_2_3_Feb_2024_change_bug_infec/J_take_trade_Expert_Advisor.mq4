#include <main.mqh>
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//|              J_take_trade_Expert_Advisor.mq4 |
//|                                                       WEbarnabas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Company Name"
#property link      "http://www.company.com"
#property version   "1.00"
#property strict
#include <function_room.mqh>




int OnInit() {
    ArrayResize(orderDetails, 0); // Initialize the orderDetails array
    ArrayResize(hedgeDetails, 0); // Initialize the orderDetails array

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

int openOrderId;

void OnTimer() 
{
    accFreeMargin = NormalizeDouble(AccountFreeMargin(),2);
    accEquity = NormalizeDouble(AccountEquity(),2);
      /*if (allowManualTrading) {
    // Your code to place trades manually
      } else {
          Print("Manual trading is disabled.");
      }*/
      
            /*if(accFreeMargin > (takeTradePercentage / 100.0 * accEquity))
            {
               Print("Can take trade");
            }
            else
            {
               Print("Can't take trade");
            }*/


    // Periodically retrieve and print order details
    if (getOrderDetails()) {
        for (int i = 0; i < ArraySize(orderDetails); i++) 
        {  
            //Print("Id: ", orderDetails[i].id);
            //Print("Incoming: ", orderDetails[i].symbol);
            tradeID = orderDetails[i].id;
            tradeTicket = orderDetails[i].ticket;
            tradeTaken = orderDetails[i].trade_taken;
            tradeTime = orderDetails[i].time;
            tradeTimeFrame = orderDetails[i].time_frame;
            //Print("Buy Price: ", orderDetails[i].buy_price);
            //Print("Sell Price: ", orderDetails[i].sell_price);
            Print("Trade: ", tradeID);
            
            // Delete "stale 😁😄" signal from the database after 3 seconds
            deleteStaleSignal(tradeID);
            
            currentAsk = MarketInfo(orderDetails[i].symbol,MODE_ASK);
            currentBid = MarketInfo(orderDetails[i].symbol,MODE_BID);
            symDigit = MarketInfo(orderDetails[i].symbol,MODE_DIGITS);
            point = MarketInfo(orderDetails[i].symbol,MODE_POINT);
            symbolSpread = NormalizeDouble(SymbolInfoInteger(orderDetails[i].symbol, SYMBOL_SPREAD), symDigit);
            pip_val = 10*point;
            
            
            /*if(accFreeMargin < (takeTradePercentage / 100.0 * accEquity))
            {*/
                  if(accFreeMargin > (takeTradePercentage / 100.0 * accEquity))
                  {
                     if(orderDetails[i].ordertype == 0 && orderDetails[i].trade_taken == 0)
                     {        
                              openOrderId = OrderSend(orderDetails[i].symbol,orderDetails[i].ordertype,orderDetails[i].lots,NormalizeDouble(currentAsk, symDigit),0,0,0,tradeTimeFrame);
                              if (openOrderId < 0) 
                              {
                                 //Print("Order rejected. Order error: " + GetLastError() + " For " + orderDetails[i].symbol);
                              }
                              else{
                                    for(int j = 0; j < OrdersTotal(); j++)
                                    {
                                       if(OrderSelect(j,SELECT_BY_POS))
                                       {
                                          stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() - (25 * pip_val), symDigit));
                                          update_priceDB_record(tradeID,OrderOpenPrice(),stopLoss,OrderTicket(),OrderOpenTime());  
                                       }
                                    }
                                    Alert("Update the trade details for ", tradeID, " ", orderDetails[i].symbol);
                                    string sender="";
                                    string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                                    sender+=StringFormat("%d,%f,%s|",tradeID,orderDetails[i].lots,openTimeStr);
                                    Print(httpGET("http://localhost/Ecardextract/trade_insert_lotsize.php?order="+sender));
                              }
                     }
                     else if (orderDetails[i].ordertype == 1 && orderDetails[i].trade_taken == 0)
                     {        
                              openOrderId = OrderSend(orderDetails[i].symbol,orderDetails[i].ordertype,orderDetails[i].lots,NormalizeDouble(currentBid, symDigit),0,0,0,tradeTimeFrame);
                              if (openOrderId < 0) 
                              {
                                 //Print("Order rejected. Order error: " + GetLastError() + " For " + orderDetails[i].symbol); 
                              }
                              else
                              {
                                     for(int j = 0; j < OrdersTotal(); j++)
                                     {
                                        if(OrderSelect(j,SELECT_BY_POS))
                                        {
                                             stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() + (25 * pip_val), symDigit));
                                             update_priceDB_record(tradeID,OrderOpenPrice(),stopLoss,OrderTicket(),OrderOpenTime());   
                                        }
                                     }
                                     Alert("Update the trade details for ", tradeID, " ", orderDetails[i].symbol);
                                     string sender="";
                                     string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                                     sender+=StringFormat("%d,%f,%s|",tradeID,orderDetails[i].lots,openTimeStr);
                                     Print(httpGET("http://localhost/Ecardextract/trade_insert_lotsize.php?order="+sender));
                              }
                     }
                     else
                     {
                           //Print("Not in position to to enter a trade in any of the trade directions");
                     }
                }
                else
                {
                     Print("Can't take a new trade now, Free margin is less less than 90% of your account equity.");
                }
             }
        }
        
         /*if (selectTradeDetails())
         {
             for (int i = 0; i < ArraySize(selectDetails); i++)
             {
                 // Iterate through your database records
         
                 tradeID = selectDetails[i].id; // Get the trade ID from the database
                 tradeTicket = selectDetails[i].ticket;
                 tradeTaken = selectDetails[i].trade_taken;
                 //Print(tradeID);
                 for (int h = 0; h < OrdersTotal(); h++)
                 {
                     if (OrderSelect(h, SELECT_BY_POS))
                     {
                         if (tradeTicket == OrderTicket())
                         {
                             // The trade in the database matches the currently open trade
                             // You can update order profit (PNL) here
                             //orderProfit = OrderProfit();
                             //update_OrderProfit(tradeID, orderProfit);
                         }
                     }
                 }
             }
         }*/
         
         if (hedgeTradeDetails())
         {
                   for (int i = 0; i < ArraySize(hedgeDetails); i++)
                   { 
                             
                                  //Print("LotSizing: ", hedgeDetails[i].lotsize);
                                  //Print("Incoming: ", hedgeDetails[i].symbol);
                            
                                 tradeID = hedgeDetails[i].id;
                                 tradeFromID = hedgeDetails[i].from_id;
                                 tradeTicket = hedgeDetails[i].orderticket;
                                 tradeTaken = hedgeDetails[i].trade_taken;
                                 //Alert("hedgeDetails[i].trade_taken: ", hedgeDetails[i].trade_taken);
                                 //Print("Buy Price: ", orderDetails[i].buy_price);
                                 //Print("Sell Price: ", orderDetails[i].sell_price);
                                 
                                 // Delete signal after current bid is 3 pips greater than the current Ask or Bid of the symbol
                                 if(hedgeDetails[i].ordertype == 0 && tradeTaken == 0)
                                 {
                                       //deleteHedgeStaleSignal(tradeID,0,0,tradeFromID);
                                 }
                                 else if(hedgeDetails[i].ordertype == 1 && tradeTaken == 0)
                                 {
                                       //deleteHedgeStaleSignal(tradeID,1,1,tradeFromID);
                                 }
                                 
                                 currentAsk = MarketInfo(hedgeDetails[i].symbol,MODE_ASK);
                                 currentBid = MarketInfo(hedgeDetails[i].symbol,MODE_BID);
                                 symDigit = MarketInfo(hedgeDetails[i].symbol,MODE_DIGITS);
                                 point = MarketInfo(hedgeDetails[i].symbol,MODE_POINT);
                                 symbolSpread = NormalizeDouble(SymbolInfoInteger(hedgeDetails[i].symbol, SYMBOL_SPREAD), symDigit);
                                 pip_val = 10*point;
                                 /*if(accFreeMargin < (takeTradePercentage / 100.0 * accEquity))
                                 {*/
                                          if(hedgeDetails[i].ordertype == 0 && tradeTaken == 0)
                                          {        
                                                   openOrderId = OrderSend(hedgeDetails[i].symbol,hedgeDetails[i].ordertype,hedgeDetails[i].lot,NormalizeDouble(currentAsk, symDigit),0,0,0,NULL);
                                                   if (openOrderId < 0) 
                                                   {
                                                      //Print("Order rejected. Order error: " + GetLastError() + " For " + hedgeDetails[i].symbol);
                                                   }
                                                   else{
                                                         for(int j = 0; j < OrdersTotal(); j++)
                                                         {
                                                            if(OrderSelect(j,SELECT_BY_POS))
                                                            {
                                                               update_hedge_trade_record(tradeID,OrderOpenPrice(),OrderTicket(),OrderOpenTime(),1,tradeFromID,hedgeDetails[i].lot);
                                                            }
                                                         }
                                                         Print("Updated the trade details for ", tradeID, " ", hedgeDetails[i].symbol);
                                                   }
                                          }
                                          else if (hedgeDetails[i].ordertype == 1 && tradeTaken == 0)
                                          {        
                                                   openOrderId = OrderSend(hedgeDetails[i].symbol,hedgeDetails[i].ordertype,hedgeDetails[i].lot,NormalizeDouble(currentBid, symDigit),0,0,0,NULL);
                                                   if (openOrderId < 0) 
                                                   {
                                                      //Print("Order rejected. Order error: " + GetLastError() + " For " + hedgeDetails[i].symbol); 
                                                   }
                                                   else
                                                   {
                                                          for(int j = 0; j < OrdersTotal(); j++)
                                                          {
                                                             if(OrderSelect(j,SELECT_BY_POS))
                                                             {
                                                                  update_hedge_trade_record(tradeID,OrderOpenPrice(),OrderTicket(),OrderOpenTime(),1,tradeFromID,hedgeDetails[i].lot);
                                                             }
                                                          }
                                                          Print("Updated the trade details for ", tradeID, " ", hedgeDetails[i].symbol);
                                                   }
                                          }
                                          else
                                          {
                                                //Print("Not in position to to enter a trade in any of the trade directions");
                                          }  
                                        //}
                                      }                    
             } 
             
             
             
             
// Iterate through open orders
/*for (int f = 0; f < OrdersTotal(); f++) {
    // Reset the flag for each iteration
    tradeProcessed = false;

    if (OrderSelect(f, SELECT_BY_POS)) {
        int orderTicket = OrderTicket();

        // Call the PHP script to check if the trade exists in either table
        string tableName = "mt4order,hedge_trades";  // List of tables separated by commas
        string response = CheckOrderExistenceInDatabase(orderTicket, tableName);

        if (response == "true" && !tradeProcessed) {
            // The trade exists in one of the tables
            // Process accordingly, for example, call a function to handle the trade
            // ProcessExistingTrade(orderTicket);
            // Set the flag to indicate that the trade has been processed
            tradeProcessed = false;
            // Exit the loop once a trade is processed
            break;
        } else if (response == "false" && !tradeProcessed) {
            // The trade does not exist in either table and hasn't been processed yet
            // Process accordingly, for example, call a function to insert the trade details
            symDigit = MarketInfo(OrderSymbol(), MODE_DIGITS);
            point = MarketInfo(OrderSymbol(), MODE_POINT);
            pip_val = 10 * point;
            if (OrderType() == OP_BUY) {
                stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() - (10 * pip_val), symDigit));
            } else if (OrderType() == OP_SELL) {
                stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() + (10 * pip_val), symDigit));
            }

            string sender = "";
            string openTimeStr = TimeToString(OrderOpenTime(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
            sender += StringFormat("%d,%s, %f, %d, %f, %f, %f, %d, %d, %d, %d, %d, %s|", OrderTicket(), OrderSymbol(), OrderLots(), OrderType(), OrderOpenPrice(), stopLoss, OrderProfit(), 0, 0, 1, 0, 1, openTimeStr);
            Print(httpGET("http://localhost/Ecardextract/trade_signal2.php?order=" + sender));
            Print("JESUS IS LORD");
            
          if (selectTradeDetails())
          {
             for (int i = 0; i < ArraySize(selectDetails); i++)
             { 
               
                  //Print("Id: ", orderDetails[i].id);
                  //Print("Incoming: ", orderDetails[i].symbol);
                  tradeID = orderDetails[i].id;
                  string sender="";
                  string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                  sender+=StringFormat("%d,%f,%s|",tradeID,OrderLots(),openTimeStr);
                  Print(httpGET("http://localhost/Ecardextract/trade_insert_lotsize.php?order="+sender));
                  // Set the flag to indicate that the trade has been processed
              }
           }
            tradeProcessed = false;
            // Exit the loop once a trade is processed
            break;
        } else {
            // Handle the response error or already processed trade
            Print("Error in CheckOrderExistenceInDatabase response or trade already processed: ", response);
        }
    }
}*/


      
      

      
      
}



          