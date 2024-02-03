/*JESUS IS LORD*/
//+------------------------------------------------------------------+
//|                                                         main.mqh |
//|                                                       WEbarnabas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "WEbarnabas"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import

//Start return here
/*
       //takeProfitPrice = (Ask + 0.9);
       //stopLossPrice = (Ask - 4.5);
        if (isTradingAllowed())
        {     
             Alert("/////");
             //Alert("Take Profit Price: " + takeProfitPrice);
             //Alert("Stop Loss Price: " + stopLossPrice);
             Alert("////");
             //Alert("StopLevel = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));
             
             
             
             
             // Trading Strength
              // For bollinger Bands of standard deviation 1
               double bbLowerBand1 = iBands(NULL, 0, bbPeriod, bb1Deviation, bbShift, PRICE_CLOSE, MODE_LOWER,0);
               double bbUpperBand1 = iBands(NULL, 0, bbPeriod, bb1Deviation, bbShift, PRICE_CLOSE, MODE_UPPER,0);
               double bbMidBand1 = iBands(NULL, 0, bbPeriod, bb1Deviation, bbShift, PRICE_CLOSE, MODE_MAIN,0);
               
               //Alert("Bollinger lower Band (1 deviation): " + NormalizeDouble(bbLowerBand1, Digits));
               //Alert("Bollinger upper Band (1 deviation): " + NormalizeDouble(bbUpperBand1, Digits));
               //Alert("Bollinger middle Band (1 deviation): " + NormalizeDouble(bbMidBand1, Digits));
           
               // For bollinger Bands of standard deviation 4
               Alert("");
               double bbLowerBand4 = iBands(NULL, 0, bbPeriod, bb4Deviation, bbShift, PRICE_CLOSE, MODE_LOWER,0);
               double bbUpperBand4 = iBands(NULL, 0, bbPeriod, bb4Deviation, bbShift, PRICE_CLOSE, MODE_UPPER,0);
               double bbMidBand4 = iBands(NULL, 0, bbPeriod, bb4Deviation, bbShift, PRICE_CLOSE, MODE_MAIN,0);
               
               //Alert("Bollinger lower Band (4 deviation): " + NormalizeDouble(bbLowerBand4, Digits));
               //Alert("Bollinger upper Band (4 deviation): " + NormalizeDouble(bbUpperBand4, Digits));
               //Alert("Bollinger middle Band (4 deviation): " + NormalizeDouble(bbMidBand4, Digits));
           
               Alert(IsTradeAllowed(Symbol(), TimeCurrent()));
           
               if (signalPriceask < bbLowerBand1) //Buying -- Get into a long position
               {
                 Alert(Symbol() + " Getting into a long position!");
                 stopLossPrice = bbLowerBand4;
                 takeProfitPrice = bbMidBand1;
            
                 Alert("Entry-Price: " + signalPriceask);
                 Alert("");
                 Alert("Stop-Loss Price: " + stopLossPrice);
                 Alert("");
                 Alert("Take-profit Price: " + takeProfitPrice);
                 
                 
                 // Buy
                 int ticket = OrderSend(NULL, OP_BUY,0.01,Ask,10,stopLossPrice,takeProfitPrice);
                 Alert("OrderID: "+ ticket);
                 if (ticket < 0)
                 {
                     Alert("OrderSend Failed with error #", GetLastError());
                 }
                 else {
                     Alert("OrderSend placed successfully!");
                 }
                 
                 
                 if (signalPriceask == takeProfitPrice)
                 {
                     Alert("Taken Profit!");
                 }
                 else if (signalPriceask <= stopLossPrice)
                 {
                     Alert("Stoploss!");
                 }
               }
               else if (signalPricebid > bbUpperBand1) // Selling -- Get into a short position
               {
                    Alert("Getting into a short position!");
                     stopLossPrice = bbUpperBand4;
                     takeProfitPrice = bbMidBand1;
               
                    Alert("Entry-Price: " + signalPricebid);
                    Alert("");
                    Alert("Stop-Loss Price: " + stopLossPrice);
                    Alert("");
                    Alert("Take-profit Price: " + takeProfitPrice);
                    
                    //Sell
                      int ticket = OrderSend(Symbol(),OP_SELL,0.01,Bid,10,stopLossPrice,takeProfitPrice);
                      Alert("OrderID: "+ ticket);
                      if (ticket < 0)
                      {
                        Alert("OrderSend Failed with error #", GetLastError());
                      }
                      else {
                        Alert("OrderSend placed successfully!");
                      }
                    
                    if (signalPricebid == takeProfitPrice)
                    {
                        Alert("Taken Profit!");
                    }
                    else if (signalPricebid >= stopLossPrice)
                    {
                        Alert("Stoploss!");
                    }
               }
       
            } 
            
            
            
            Alert("Open Order: " + openOrders);
               
               for (int i = (openOrders-1); i < openOrders; i++)
               {
                     if (OrderSelect(i, SELECT_BY_POS) == true)
                     {
                         Alert("Order Open Price: " + OrderOpenPrice());
                         OpenPrice = OrderOpenPrice();
                     }  
               } 
               
               
               UpdatedPrice = OpenPrice + MathAbs((0.0001*15) * 1000);
            
                Alert("Price to change stopLoss: " + UpdatedPrice);
                Alert("Ask Price: " + Ask);
                       
               
                  for (int i = (openOrders-1); i < openOrders; i++)
                  {
                        if (OrderSelect(i, SELECT_BY_POS) == true)
                        {
                            Alert("Order Open Price: " + OrderOpenPrice());
                            OpenPrice = OrderOpenPrice();
                        }
                          
                         if(UpdatedPrice == Ask || Ask > UpdatedPrice)
                         {
                            
                            
                                 
                                 stopLoss = OpenPrice;
                                 takeProfit = 0;
                                 // OrderModify function
                                 //Alert("OrderID: "+ ticket);
                                 OrderModify(orderID,0,stopLoss,takeProfit,0);
                                 UpdatedPrice = OpenPrice + MathAbs((0.0001*15) * 1000);
                             
                         } 
                  

                    } 
            
            
            
            */

//+------------------------------------------------------------------+
