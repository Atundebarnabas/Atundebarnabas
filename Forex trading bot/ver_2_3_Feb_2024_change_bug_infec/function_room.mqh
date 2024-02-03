//+------------------------------------------------------------------+
//|                                                function_room.mqh |
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
//+------------------------------------------------------------------+

// Time
bool inTrade;
int Oticket;
int OrderInTrade;
int candleType;
int ModifyOrder;
double stopLoss;
datetime tradeOpenTime;
string tradeOpenTimeStr;
string tradeDateTime;
double pip_val;
int symDigit;
double point;
string ordersym = "";
double orderProfit;
double lot_size = 0.01;
double highestPriceReached = 0;
double lowestPriceReached = 0;
extern double  highestBidPriceReached;
extern double lowestAskPriceReached;
double closingPrice;
double currentAsk;
double currentBid;
double activationPrice;
double initalCPrice;
double IC_stopPrice;
int symbolDigit;
double symbolAsk;
double symbolBid;
int symbolSpread;
extern datetime lastCandleTime;
extern datetime currentCandleTime;
double openPrice;
double closePrice;
// Moving average
double fastMa;
double slowMa;
int input f_MAPeriod = 21;
int input s_MAPeriod = 85; //85
input int pip_to_close = 2;
input double TdollarEquivalent= 1.5;
input double dollarEquiv = -1.5;
input int symbolSpreadMax = 30;
//Closing order
int closingOrder;
// Timeframe -- array
int timeFrame[] = {1,5,15,30,60,240};
int timeFrameSize = ArraySize(timeFrame);
// Timeframe -- array
int tfs[] = {15};
int tfSize = ArraySize(tfs);
// Symbol and other variables
// Total count of symbol in the Market watchlist (This varies with brokers)
int TotalSymbols = SymbolsTotal(true);
string sym_watchlist = "";

double accFreeMargin;
double accEquity;
double dEloss;
double fixedLoss;
int takeTradePercentage = 99;
// lot size, dollarEquivalent for stopLoss
// s rs msl mls df dff s d -- drmrd repeat
//Trade management
int tradeID;
int tradeTicket;
string tradeSymbol;
double tradeLot;
int tradeOrderType;
double tradeEntryPrice;
double tradeHedgePrice;
double tradeProfit;
double tradeHBPrice;
double tradeLAPrice;
int tradeHedging;
int tradeHedgingReached;
int tradeHedgeSignalSent;
int tradeClosed;
int tradeTakeOver;
int tradeTrailingP;
int tradeTaken;
int manuallyTaken;
string tradeTime;
double oldLotSize;
double newLotSize;
int tradeFromID;
double tradeProfitSum;
int tradeOut;
string tradeTimeFrame;
int tradeTfDigit;
//input bool allowManualTrading = false;

//Close trade variables
int lastOrderChecked = 0; // Initialize to 0
bool tradeClosedFlag = false; // Initialize a flag




// Bollinger Bands varaibles
input int bbPeriod = 50;

input double bandStdEntry = 2;
input int bandStdProfitExit = 1;
input int bandStdLossExit = 6;

int rsiPeriod = 14;
input double riskPerTrade = 0.005;
input int rsiLowerLevel = 40;
input int rsiUpperLevel = 60;

// GLOBAL VARIABLE
double lotSizeValue;
double pips;
double lotSizeCalculation;
double opti_LotSize;
double maxRiskperTrade = 0.003;
double stopLosstoUpdate;


// Indicators variables
double bbLowerEntry;
double bbUpperEntry;
double bbMid;
double bbLowerProfitExit;
double bbUpperProfitExit;
double bbLowerLossExit;
double bbUpperLossExit;
double rsiValue;
double symbolOpen;


bool tradeExecuted = False;



bool tradeProcessed = false;


int typeOfCandles(string symbol, int time, int candleIndex)
{
   openPrice = iOpen(symbol,time,candleIndex);
   closePrice = iClose(symbol,time,candleIndex);
   if(closePrice > openPrice)
   {
      candleType = 0; // Bullish candle formed  -- Green
      return candleType;
   }
   else if (closePrice < openPrice)
   {
      candleType = 1; // Bearish candle formed -- Red
      return candleType;
   }
   else
   {
      candleType = 4;   /// closed at opening position
      return candleType;
   } 
}


int typeOfCurrentCandle(string symbol, int time, int candleIndex)
{   
      openPrice = iOpen(symbol,time,candleIndex);
      closePrice = iClose(symbol,time,candleIndex);
      if (closePrice > openPrice)
      {
         candleType = 0; // Bullish candle formed, for the current candle, this candle is formed after a '3 line striking' signal is found
         return candleType;
      }
      else if (closePrice < openPrice)
      {
         candleType = 1; // Bearish candle formed, for the current candle, this candle is formed after a '3 line striking' signal is found
         return candleType;
      }
      else
      {
         candleType = 4; /// This candle closed at opening position
         return candleType;
      }
}


bool isNewCandle(string symbol, int time)
{
   currentCandleTime = iTime(symbol,time,1);
   if(lastCandleTime != currentCandleTime)
   {
      lastCandleTime = currentCandleTime;
      return true;
   }
   return false;
}







// Functions for stoploss
// Update stoploss and take profit for a sell and buy trade
bool updateBuyTrade(string symbol)
{


   if(OrderType() == OP_BUY && (OrderStopLoss() == 0 || OrderTakeProfit() == 0))
   {
      double o_point = MarketInfo(symbol, MODE_POINT);
      int o_digit = MarketInfo(symbol, MODE_DIGITS);
      double o_pip = o_point*10;
      //Alert("Pip: " + o_pip);
      double o_stoplevel = MarketInfo(symbol, MODE_STOPLEVEL);
      double stopLossDistance;
      double takeprofitDistance;
      
      if(o_stoplevel <= 50)
      {
         stopLossDistance = NormalizeDouble(o_stoplevel * o_pip + (4 * o_pip), o_digit);
         takeprofitDistance = NormalizeDouble(o_stoplevel * o_pip + (10 * o_pip), o_digit);
      }
      else
      {
         stopLossDistance = NormalizeDouble(o_stoplevel * o_pip + (1 * o_pip), o_digit);
         takeprofitDistance = NormalizeDouble(o_stoplevel * o_pip + (1 * o_pip), o_digit);
      }
      
      double stopLossPrice = NormalizeDouble(OrderOpenPrice() - stopLossDistance, o_digit);
      double takeprofitPrice = NormalizeDouble(OrderOpenPrice() + takeprofitDistance, o_digit);
      int OrderMode = OrderModify(OrderTicket(),0,NormalizeDouble(stopLossPrice, o_digit),NormalizeDouble(takeprofitPrice, o_digit),3,Blue);
      //if (OrderMode < 1) Alert("Error: " + GetLastError());
      return true;
   }
 return false;
}
bool updateSellTrade(string symbol)
{
         if(OrderType() == OP_SELL && (OrderStopLoss() == 0 || OrderTakeProfit() == 0))
         {
               double o_point = MarketInfo(symbol, MODE_POINT);
               int o_digit = MarketInfo(symbol, MODE_DIGITS);
               double o_pip = o_point*10;
               //Alert("Pip: " + o_pip);
               double o_stoplevel = MarketInfo(symbol, MODE_STOPLEVEL);
               double stopLossDistance;
               double takeprofitDistance;
               
               if(o_stoplevel <= 50)
               {
                  stopLossDistance = NormalizeDouble(o_stoplevel * o_pip + (30 * o_pip), o_digit);
                  takeprofitDistance = NormalizeDouble(o_stoplevel * o_pip + (10 * o_pip), o_digit);
               }
               else
               {
                  stopLossDistance = NormalizeDouble(o_stoplevel * o_pip + (1 * o_pip), o_digit);
                  takeprofitDistance = NormalizeDouble(o_stoplevel * o_pip + (1 * o_pip), o_digit);
               }
               
               double stopLossPrice = NormalizeDouble(OrderOpenPrice() + stopLossDistance, o_digit);
               double takeprofitPrice = NormalizeDouble(OrderOpenPrice() - takeprofitDistance, o_digit);
               int OrderMode = OrderModify(OrderTicket(),0,NormalizeDouble(stopLossPrice, o_digit),NormalizeDouble(takeprofitPrice, o_digit),3,Blue);
               //if (OrderMode < 1) Alert("Error: " + GetLastError());
               
               return true;
         }
  return false;
}

// Close Position if OrderProfit() is in (loss) of 3.5 dollar equivalent
bool closeByDollarEquiv(string symbol)
{
       //ordersym = OrderSymbol();
               symbolDigit = SymbolInfoInteger(symbol,SYMBOL_DIGITS);
               symbolAsk = NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK), symbolDigit);
               symbolBid = NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID), symbolDigit);
               if(OrderType() == OP_BUY)
               {
                  if (OrderProfit() <= dollarEquiv)
                  {
                     //OrderModify(OrderTicket(),0,symbolBid,0,0);
                     OrderClose(OrderTicket(),OrderLots(),symbolBid,3,Yellow);
                     Alert("Symbol-Name: " + OrderSymbol());
                     return true;
                  }
                  
               }
               else if(OrderType() == OP_SELL)
               {
                  if(OrderProfit() <= dollarEquiv)
                  {
                     //OrderModify(OrderTicket(),0,symbolAsk,0,0);
                     OrderClose(OrderTicket(),OrderLots(),symbolAsk,3,Orange);
                     Alert("Symbol-Name: " + OrderSymbol());
                     return true;
                  }
                  
               }
               else{Alert("GOD IS GOOD, ALL THE TIME AND ALL THE TIME GOD IS GOOD");}
     
 
   return false;
}

bool setStoplossValue(double OpenPrice, string Tsymbol, double orderLot, double TradedollarEquivalent)
{
     int contractSize = MarketInfo(Tsymbol, MODE_LOTSIZE);
     //Alert(orderLot);
     //Alert(orderLot);
     //Alert(gettingPipvalueforOrders(ordersym));
     //Alert(TradedollarEquivalent*gettingPipvalueforOrders(ordersym));
     int Odigits = MarketInfo(Tsymbol, MODE_DIGITS);
     double o_point = MarketInfo(Tsymbol, MODE_POINT);
     if(OrderType() == OP_BUY && (OrderStopLoss() == 0 || OrderTakeProfit() == 0))
     {
        double TradestopLossValue = ((OpenPrice * (orderLot * contractSize) - TradedollarEquivalent) / (orderLot * contractSize));
        //Alert(TradestopLossValue);
        // calclulate stoploss value in account currency
        double exchangeRate = OrderOpenPrice(); // Get the OrderOpenprice of the currency pair 'Tsymbol'
        
        double priceDifference = MathAbs(OrderOpenPrice() - TradestopLossValue) * MathPow(10, Odigits);
        double stopLossValueBaseCurrency = priceDifference / MathPow(10, Odigits);
        double stopLossValueAccountCurrency = stopLossValueBaseCurrency * exchangeRate;
        
        double stopLossCalc = MathAbs(OrderOpenPrice() - stopLossValueAccountCurrency);
        int OrderMode = OrderModify(OrderTicket(),0,NormalizeDouble(stopLossCalc, Odigits),0,3,Blue);
        //if (OrderMode < 1) Alert("Error: " + GetLastError());
        return true;
       
     }
     else if (OrderType() == OP_SELL && (OrderStopLoss() == 0 || OrderTakeProfit() == 0))
     {
       double TradestopLossValue = ((OpenPrice * (orderLot * contractSize) + TradedollarEquivalent) / (orderLot * contractSize));
        //Alert(TradestopLossValue);
        // calclulate stoploss value in account currency
        double exchangeRate = OrderOpenPrice(); // Get the OrderOpenprice of the currency pair 'Tsymbol'
        
        double priceDifference = MathAbs(OrderOpenPrice() - TradestopLossValue) * MathPow(10, Odigits);
        double stopLossValueBaseCurrency = priceDifference / MathPow(10, Odigits);
        double stopLossValueAccountCurrency = stopLossValueBaseCurrency * exchangeRate;
        
        double stopLossCalc = MathAbs(OrderOpenPrice() + stopLossValueBaseCurrency);
        
        //Alert("stoploss: " + stopLossValueBaseCurrency);
        int OrderMode = OrderModify(OrderTicket(),0,NormalizeDouble(stopLossCalc, Odigits),0,3,Blue);
       //if (OrderMode < 1) Alert("Error: " + GetLastError());
       return true;
       //"GOD IS GOOD"
     }
     else{
       return false;
     }
     
 return false;
     
}

void trailingStoploss()
{


  for(int y = 0; y < OrdersTotal(); y++)
  {
            ordersym = OrderSymbol();
            symbolDigit = SymbolInfoInteger(ordersym,SYMBOL_DIGITS);
            symbolAsk = NormalizeDouble(SymbolInfoDouble(ordersym,SYMBOL_ASK), symbolDigit);
            symbolBid = NormalizeDouble(SymbolInfoDouble(ordersym,SYMBOL_BID), symbolDigit);
            point = MarketInfo(ordersym, MODE_POINT);
            pip_val = 10*point;
         if(OrderType() == OP_BUY)
         {
            if (OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
            {
               if(OrderStopLoss() != 0)
               {
                           if(OrderStopLoss() < NormalizeDouble(symbolBid + (8 * pip_val), symbolDigit))
                           {
                              // We modify the Stoploss
                              OrderModify(
                                 OrderTicket(),
                                 OrderOpenPrice(),
                                 NormalizeDouble(OrderOpenPrice() + (3 * pip_val), symbolDigit),
                                 OrderTakeProfit(),
                                 CLR_NONE
                              );
                           }
                    
                           /*else if (OrderStopLoss() == NormalizeDouble(OrderOpenPrice() + (4 * pip_val), symbolDigit) && OrderStopLoss() < NormalizeDouble(symbolBid - (10 * pip_val), symbolDigit))
                           {
                                 OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(symbolBid + (4 * pip_val), symbolDigit), OrderTakeProfit() ,CLR_NONE);
                           }*/
              }
             }
         }
         else if(OrderType() == OP_SELL)
         {
            if (OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
            {

               if(OrderStopLoss() != 0)
               {
                     if(OrderStopLoss() > NormalizeDouble(symbolAsk - (8 * pip_val), symbolDigit))
                     {
                        // We modify the Stoploss
                        OrderModify(
                           OrderTicket(),
                           OrderOpenPrice(),
                           NormalizeDouble(OrderOpenPrice() - (3 * pip_val), symbolDigit),
                           OrderTakeProfit(),
                           CLR_NONE
                        );
                     }
                     /*else if (OrderStopLoss() == NormalizeDouble(OrderOpenPrice() - (4 * pip_val), symbolDigit)  && OrderStopLoss() > NormalizeDouble(symbolAsk - (8 * pip_val), symbolDigit))
                     {
                           OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(symbolAsk - (10 * pip_val), symbolDigit), OrderTakeProfit() ,CLR_NONE);
                     }*/
               }
            }
         }
  }
}




bool IsPositionOpen(string symbol)
{
     
      for (int i = 0; i < OrdersTotal(); i++)
      {
         
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
               if (OrderSymbol() == symbol)
               {
                  return true; // Position is already opened for the symbol
               }
         }
      }
      
      return false; // No position is opened for the symbol
}





void HedgingMode(double tradeOPrice , double cBid , double cAsk , double stopPrice , double lotSize , string symbol , int direction , int tradeHedgeReached , int signalSent)
{
    
    if (direction == 0)
    {
        // Check if the current bid price is less than or equal to the stop price
       
        if (cBid <= stopPrice)
        {
             //Alert("Current Bid: ", cBid);
             //Alert("HedgePrice: ", stopPrice);
             //Alert("EntryPrice: ", tradeOPrice);
            if (tradeHedgeReached == 0 && signalSent == 0)
            {
                string sender = "";
                string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                sender += StringFormat("%d,%s,%f,%d|", tradeID, symbol, lotSize, OP_SELL);
                Print(httpGET("http://localhost/Ecardextract/insert4.php?order=" + sender));
                update_hedge(tradeID,1,1,1);
                Alert("Sell signal for a buy trade, gotten hedge price ", symbol, " at price: ", cBid, " for: ", stopPrice);
            }
        }
        else if (tradeHedgingReached == 1 && cBid >= tradeOPrice && signalSent == 1)
        {
            // Check if the current bid price is greater than or equal to the initial trade price 
            // 
            // This condition is only triggered after the hedge price has been reached and a trade taken
            Alert("JESUS IS LORD FOREVER!");
            //Alert("Condition 2: !IsSignalSent(tradeID) =", !IsSignalSent(tradeID));
            string sender = "";
            string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
            sender += StringFormat("%d,%s,%f,%d|", tradeID,symbol,lotSize,OP_BUY);
            Print(httpGET("http://localhost/Ecardextract/insert4.php?order=" + sender));
            update_hedge(tradeID,1,0,0);
            Alert("Buy signal for buy trade, came back to open price ", symbol, " at price: ", cBid, " for: ", tradeOPrice);
        }
    }
    else if (direction == 1)
    { 
        // Check if the current ask price is greater than or equal to the stop price
        
        if (cAsk >= stopPrice)
        {
            //Alert("Current Ask: ", cAsk);
            //Alert("HedgePrice: ", stopPrice);
            //Alert("EntryPrice: ", tradeOPrice);
            if (tradeHedgeReached == 0 && signalSent == 0)
            {
                string sender = "";
                string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                sender += StringFormat("%d,%s,%f,%d|",tradeID,symbol,lotSize,OP_BUY);
                Print(httpGET("http://localhost/Ecardextract/insert4.php?order=" + sender));
                update_hedge(tradeID,1,1,1);
                Alert("Buy signal for a sell trade, gotten hedge price ", symbol, " at price: ", cAsk, " for: ", stopPrice);
                //Check to update database for mt4order trade, when hedge trades are still in open orders
            }
        }
        else if (tradeHedgeReached == 1 && cAsk <= tradeOPrice && signalSent == 1)
        {
            // Check if the current ask price is less than or equal to the initial trade price
            // This condition is only triggered after the hedge price has been reached and a trade taken
            string sender = "";
            string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
            sender += StringFormat("%d,%s,%f,%d|",tradeID,symbol,lotSize,OP_SELL);
            Print(httpGET("http://localhost/Ecardextract/insert4.php?order=" + sender));
            update_hedge(tradeID,1,0,0);
            Alert("Sell signal for sell trade, came back to open price ", symbol, " at price: ", cAsk, " for: ", tradeOPrice);
        }
    }  
}




void CheckClosedOrders()
{
    int totalOrders = OrdersTotal();
   
    for (int i = 0; i < totalOrders; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderCloseTime() != 0)
            {
                Alert("Trade closed: Ticket ", OrderTicket());
            }
        }
    }
}


// Define the structure to hold order details
struct OrderDetail {
    int id;
    string symbol;
    double lots;
    int ordertype;
    int trade_taken;
    int ticket;
    int close_trade;
    string time;
    string time_frame;
};

// Define the structure to hold order details -- for selecting 'some -- where trade_taken=1'
struct SelectDetail {
    int id;
    int ticket;
    string symbol;
    double lots;
    int ordertype;
    int close_trade;
    int trailing_p;
    int hedging;
    int hedging_reached;
    int hedge_signal;
    double entryprice;
    double hedgeprice;
    double orderprofit;
    double highestbidpricereached;
    double lowestaskpricereached;
    int trade_taken;
    int trade_out;
    string time;
    string tfdigit;
    double lotsize;
};

// Define the structure to hold order details -- for selecting 'all'
struct HedgeDetail {
    int id;
    int from_id;
    int orderticket;
    string symbol;
    double lot;
    double lotsize;
    int ordertype;
    double orderprofit;
    int trade_taken;
    int trade_out;
    int closetrade;
    int trailingP;
    datetime timing;
};

// Define the structure to hold order details -- for selecting 'all'
struct SelectHedgeDetail {
    int id;
    int from_id;
    int orderticket;
    string symbol;
    double lot;
    double entryprice;
    int ordertype;
    double orderprofit;
    int trade_taken;
    int trade_out;
    int closetrade;
    int take_over;
    int trailingP;
    datetime timing;
};


OrderDetail orderDetails[]; // Define an array to store order details
SelectDetail selectDetails[]; // Define an array to store order details
HedgeDetail hedgeDetails[]; // Define an array to store order details
SelectHedgeDetail selecthedgeDetails[]; // Define an array to store order details
int timerInterval = 1; // Interval in seconds for the OnTimer function 

// Function to extract a string value from JSON data
string ExtractJsonValueString(string jsonData, string key) {
    string searchString = "\"" + key + "\":\"";
    int startIndex = StringFind(jsonData, searchString);
    if (startIndex < 0) {
        return "";
    }
    int endIndex = StringFind(jsonData, "\"", startIndex + StringLen(searchString));
    if (endIndex < 0) {
        return "";
    }
    return StringSubstr(jsonData, startIndex + StringLen(searchString), endIndex - startIndex - StringLen(searchString));
}

// Function to extract an integer value from JSON data
int ExtractJsonValueInteger(string jsonData, string key) {
    string stringValue = ExtractJsonValueString(jsonData, key);
    return StringToInteger(stringValue);
}

// Function to extract a double value from JSON data
double ExtractJsonValueDouble(string jsonData, string key) {
    string stringValue = ExtractJsonValueString(jsonData, key);
    return StringToDouble(stringValue);
}



// Function to send HTTP GET request and retrieve order details
bool getOrderDetails() {
    string url = "http://localhost/Ecardextract/take_trade1.php"; // Replace with your PHP script URL
    string cookie = NULL;
    string headers;
    char post[];
    uchar result[]; // Use uchar array for binary data

    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for slow Internet connection

    int res = WebRequest("GET", url, cookie, NULL, timeout, post, 0, result, headers);

    if (res == 200) {
        // Convert the binary response to a string
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Split the response into individual JSON objects
        string jsonObjects[];
        StringSplit(responseText, "{}", jsonObjects);

        // Iterate through each JSON object and parse it
        for (int i = 0; i < ArraySize(jsonObjects); i++) {
            string jsonObject = jsonObjects[i];
            
            // Check if the JSON object is valid
            if (StringLen(jsonObject) > 0) {
                // Output the JSON object for debugging
                //Print("Parsed JSON Object:");
                //Print(jsonObject);

                // Call the function to parse JSON response
                ParseJsonResponse(jsonObject);
            }
        }

        // Find the "message" key in the JSON data
        int messageStart = StringFind(responseText, "\"message\":\"");
        if (messageStart >= 0) {
            messageStart += 11; // Move past the key and opening quote
            int messageEnd = StringFind(responseText, "\"", messageStart);
            if (messageEnd >= 0) {
                string message = StringSubstr(responseText, messageStart, messageEnd - messageStart);
                //Print("Message: ", message);
                //MessageBox(message, "Received Message", MB_ICONINFORMATION);
            } else {
                //Print("No closing quote for the \"message\" key.");
            }
        } else {
            //Print("No \"message\" key found in JSON data.");
        }

        // Find the "id" key in the JSON data
        int idStart = StringFind(responseText, "\"id\":\"");
        if (idStart >= 0) {
            idStart += 6; // Move past the key and opening quote
            int idEnd = StringFind(responseText, "\"", idStart);
            if (idEnd >= 0) {
                string idStr = StringSubstr(responseText, idStart, idEnd - idStart);
                int id = StringToInteger(idStr);
                //Print("ID: ", id);
            } else {
                //Print("No closing quote for the \"id\" key.");
            }
        } else {
            //Print("No \"id\" key found in JSON data.");
        }

        return true;
    } else {
        Print("HTTP request failed with error code: ", res);
        return false;
    }
}


// Function to send HTTP GET request and retrieve order details
bool selectTradeDetails() {
    string url = "http://localhost/Ecardextract/take_trade2.php"; // Replace with your PHP script URL
    string cookie = NULL;
    string headers;
    char post[];
    uchar result[]; // Use uchar array for binary data

    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for slow Internet connection

    int res = WebRequest("GET", url, cookie, NULL, timeout, post, 0, result, headers);

    if (res == 200) {
        // Convert the binary response to a string
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Split the response into individual JSON objects
        string jsonObjects[];
        StringSplit(responseText, "{}", jsonObjects);

        // Iterate through each JSON object and parse it
        for (int i = 0; i < ArraySize(jsonObjects); i++) {
            string jsonObject = jsonObjects[i];
            
            // Check if the JSON object is valid
            if (StringLen(jsonObject) > 0) {
                // Output the JSON object for debugging
                //Print("Parsed JSON Object:");
                //Print(jsonObject);

                // Call the function to parse JSON response
                ParseJsonResponse(jsonObject);
            }
        }

        // Find the "message" key in the JSON data
        int messageStart = StringFind(responseText, "\"message\":\"");
        if (messageStart >= 0) {
            messageStart += 11; // Move past the key and opening quote
            int messageEnd = StringFind(responseText, "\"", messageStart);
            if (messageEnd >= 0) {
                string message = StringSubstr(responseText, messageStart, messageEnd - messageStart);
                //Print("Message: ", message);
                //MessageBox(message, "Received Message", MB_ICONINFORMATION);
            } else {
                //Print("No closing quote for the \"message\" key.");
            }
        } else {
            //Print("No \"message\" key found in JSON data.");
        }

        // Find the "id" key in the JSON data
        int idStart = StringFind(responseText, "\"id\":\"");
        if (idStart >= 0) {
            idStart += 6; // Move past the key and opening quote
            int idEnd = StringFind(responseText, "\"", idStart);
            if (idEnd >= 0) {
                string idStr = StringSubstr(responseText, idStart, idEnd - idStart);
                int id = StringToInteger(idStr);
                //Print("ID: ", id);
            } else {
                //Print("No closing quote for the \"id\" key.");
            }
        } else {
            //Print("No \"id\" key found in JSON data.");
        }

        return true;
    } else {
        Print("HTTP request failed with error code: ", res);
        return false;
    }
}

// Function to send HTTP GET request and retrieve hedge order details
bool hedgeTradeDetails() {
    string url = "http://localhost/Ecardextract/take_trade3.php"; // Replace with your PHP script URL
    string cookie = NULL;
    string headers;
    char post[];
    uchar result[]; // Use uchar array for binary data

    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for slow Internet connection

    int res = WebRequest("GET", url, cookie, NULL, timeout, post, 0, result, headers);

    if (res == 200) {
        // Convert the binary response to a string
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Split the response into individual JSON objects
        string jsonObjects[];
        StringSplit(responseText, "{}", jsonObjects);

        // Iterate through each JSON object and parse it
        for (int i = 0; i < ArraySize(jsonObjects); i++) {
            string jsonObject = jsonObjects[i];
            
            // Check if the JSON object is valid
            if (StringLen(jsonObject) > 0) {
                // Output the JSON object for debugging
                //Print("Parsed JSON Object:");
                //Print(jsonObject);

                // Call the function to parse JSON response
                ParseJsonResponse(jsonObject);
            }
        }

        // Find the "message" key in the JSON data
        int messageStart = StringFind(responseText, "\"message\":\"");
        if (messageStart >= 0) {
            messageStart += 11; // Move past the key and opening quote
            int messageEnd = StringFind(responseText, "\"", messageStart);
            if (messageEnd >= 0) {
                string message = StringSubstr(responseText, messageStart, messageEnd - messageStart);
                //Print("Message: ", message);
                //MessageBox(message, "Received Message", MB_ICONINFORMATION);
            } else {
                //Print("No closing quote for the \"message\" key.");
            }
        } else {
            //Print("No \"message\" key found in JSON data.");
        }

        // Find the "id" key in the JSON data
        int idStart = StringFind(responseText, "\"id\":\"");
        if (idStart >= 0) {
            idStart += 6; // Move past the key and opening quote
            int idEnd = StringFind(responseText, "\"", idStart);
            if (idEnd >= 0) {
                string idStr = StringSubstr(responseText, idStart, idEnd - idStart);
                int id = StringToInteger(idStr);
                //Print("ID: ", id);
            } else {
                //Print("No closing quote for the \"id\" key.");
            }
        } else {
            //Print("No \"id\" key found in JSON data.");
        }

        return true;
    } else {
        Print("HTTP request failed with error code: ", res);
        return false;
    }
}

// Function to send HTTP GET request and retrieve hedge order details
bool selectHedgeTrades() {
    string url = "http://localhost/Ecardextract/take_trade4.php"; // Replace with your PHP script URL
    string cookie = NULL;
    string headers;
    char post[];
    uchar result[]; // Use uchar array for binary data

    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for slow Internet connection

    int res = WebRequest("GET", url, cookie, NULL, timeout, post, 0, result, headers);

    if (res == 200) {
        // Convert the binary response to a string
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Split the response into individual JSON objects
        string jsonObjects[];
        StringSplit(responseText, "{}", jsonObjects);

        // Iterate through each JSON object and parse it
        for (int i = 0; i < ArraySize(jsonObjects); i++) {
            string jsonObject = jsonObjects[i];
            
            // Check if the JSON object is valid
            if (StringLen(jsonObject) > 0) {
                // Output the JSON object for debugging
                //Print("Parsed JSON Object:");
                //Print(jsonObject);

                // Call the function to parse JSON response
                ParseJsonResponse(jsonObject);
            }
        }

        // Find the "message" key in the JSON data
        int messageStart = StringFind(responseText, "\"message\":\"");
        if (messageStart >= 0) {
            messageStart += 11; // Move past the key and opening quote
            int messageEnd = StringFind(responseText, "\"", messageStart);
            if (messageEnd >= 0) {
                string message = StringSubstr(responseText, messageStart, messageEnd - messageStart);
                //Print("Message: ", message);
                //MessageBox(message, "Received Message", MB_ICONINFORMATION);
            } else {
                //Print("No closing quote for the \"message\" key.");
            }
        } else {
            //Print("No \"message\" key found in JSON data.");
        }

        // Find the "id" key in the JSON data
        int idStart = StringFind(responseText, "\"id\":\"");
        if (idStart >= 0) {
            idStart += 6; // Move past the key and opening quote
            int idEnd = StringFind(responseText, "\"", idStart);
            if (idEnd >= 0) {
                string idStr = StringSubstr(responseText, idStart, idEnd - idStart);
                int id = StringToInteger(idStr);
                //Print("ID: ", id);
            } else {
                //Print("No closing quote for the \"id\" key.");
            }
        } else {
            //Print("No \"id\" key found in JSON data.");
        }

        return true;
    } else {
        Print("HTTP request failed with error code: ", res);
        return false;
    }
}




void ParseJsonResponse(string jsonResponse) {
    // Clear the existing orderDetails array
    ArrayResize(orderDetails, 0);
    ArrayResize(selectDetails, 0);
    ArrayResize(hedgeDetails, 0);
    ArrayResize(selecthedgeDetails, 0);
    

    // Find the start of the JSON object
    int startIndex = StringFind(jsonResponse, "{");
    int endIndex = StringFind(jsonResponse, "}", startIndex);

    while (startIndex >= 0 && endIndex >= 0) {
        string jsonObject = StringSubstr(jsonResponse, startIndex, endIndex - startIndex + 1);

        // Output the JSON object for debugging
        //Print("Parsed JSON Object:");
        //Print(jsonObject);

        // Call the function to parse JSON response
        ParseJsonObject(jsonObject);

        // Find the next JSON object
        startIndex = StringFind(jsonResponse, "{", endIndex + 1);
        endIndex = StringFind(jsonResponse, "}", startIndex);
    }
}

void ParseJsonObject(string jsonObject) {
    OrderDetail orderDetail;
    orderDetail.id = ExtractJsonValueInteger(jsonObject, "id");
    orderDetail.ticket = ExtractJsonValueString(jsonObject, "ticket");
    orderDetail.symbol = ExtractJsonValueString(jsonObject, "symbol");
    orderDetail.lots = ExtractJsonValueString(jsonObject, "lots");
    orderDetail.ordertype = ExtractJsonValueString(jsonObject, "ordertype");
    orderDetail.close_trade = ExtractJsonValueString(jsonObject, "close_trade");
    orderDetail.trade_taken = ExtractJsonValueString(jsonObject, "trade_taken");
    orderDetail.time = ExtractJsonValueString(jsonObject, "time");
    orderDetail.time_frame = ExtractJsonValueString(jsonObject, "timeframe");
    
    
    SelectDetail selectDetail;
    selectDetail.id = ExtractJsonValueInteger(jsonObject, "id");
    selectDetail.ticket = ExtractJsonValueString(jsonObject, "ticket");
    selectDetail.symbol = ExtractJsonValueString(jsonObject, "symbol");
    selectDetail.lots = ExtractJsonValueString(jsonObject, "lots");
    selectDetail.ordertype = ExtractJsonValueString(jsonObject, "ordertype");
    selectDetail.entryprice = ExtractJsonValueString(jsonObject, "entryprice");
    selectDetail.hedgeprice = ExtractJsonValueString(jsonObject, "hedgeprice");
    selectDetail.orderprofit = ExtractJsonValueString(jsonObject, "orderprofit");
    selectDetail.highestbidpricereached = ExtractJsonValueString(jsonObject, "highestbidreached");
    selectDetail.lowestaskpricereached = ExtractJsonValueString(jsonObject, "lowestaskreached");
    selectDetail.hedging = ExtractJsonValueString(jsonObject, "hedging");
    selectDetail.hedging_reached = ExtractJsonValueString(jsonObject, "hedged_reached");
    selectDetail.hedge_signal = ExtractJsonValueString(jsonObject, "hedge_signal");
    selectDetail.close_trade = ExtractJsonValueString(jsonObject, "close_trade");
    selectDetail.trailing_p = ExtractJsonValueString(jsonObject, "trailing_p");
    selectDetail.trade_taken = ExtractJsonValueString(jsonObject, "trade_taken");
    selectDetail.trade_out = ExtractJsonValueString(jsonObject, "trade_out");
    selectDetail.time = ExtractJsonValueString(jsonObject, "time");
    selectDetail.tfdigit = ExtractJsonValueString(jsonObject, "tf_digit");
 
    HedgeDetail hedgeDetail;
    hedgeDetail.id = ExtractJsonValueInteger(jsonObject, "id");
    hedgeDetail.from_id = ExtractJsonValueInteger(jsonObject, "from_trade");
    hedgeDetail.orderticket = ExtractJsonValueString(jsonObject, "orderticket");
    hedgeDetail.symbol = ExtractJsonValueString(jsonObject, "symbol");
    hedgeDetail.lot = ExtractJsonValueString(jsonObject, "lot");
    hedgeDetail.lotsize = ExtractJsonValueString(jsonObject, "lotsize");
    hedgeDetail.orderprofit = ExtractJsonValueString(jsonObject, "orderprofit");
    hedgeDetail.ordertype = ExtractJsonValueString(jsonObject, "ordertype");
    hedgeDetail.closetrade = ExtractJsonValueString(jsonObject, "closetrade");
    hedgeDetail.trailingP = ExtractJsonValueString(jsonObject, "trailingP");
    hedgeDetail.trade_taken = ExtractJsonValueString(jsonObject, "trade_taken");
    hedgeDetail.trade_out = ExtractJsonValueString(jsonObject, "trade_out");
    
    
    SelectHedgeDetail selecthedgeDetail;
    selecthedgeDetail.id = ExtractJsonValueInteger(jsonObject, "id");
    selecthedgeDetail.from_id = ExtractJsonValueInteger(jsonObject, "from_trade");
    selecthedgeDetail.orderticket = ExtractJsonValueString(jsonObject, "orderticket");
    selecthedgeDetail.symbol = ExtractJsonValueString(jsonObject, "symbol");
    selecthedgeDetail.lot = ExtractJsonValueString(jsonObject, "lot");
    selecthedgeDetail.entryprice = ExtractJsonValueString(jsonObject, "entryprice");
    selecthedgeDetail.ordertype = ExtractJsonValueString(jsonObject, "ordertype");
    selecthedgeDetail.orderprofit = ExtractJsonValueString(jsonObject, "orderprofit");
    selecthedgeDetail.closetrade = ExtractJsonValueString(jsonObject, "closetrade");
    selecthedgeDetail.take_over = ExtractJsonValueString(jsonObject, "take_over");
    selecthedgeDetail.trailingP = ExtractJsonValueString(jsonObject, "trailingP");
    selecthedgeDetail.trade_taken = ExtractJsonValueString(jsonObject, "trade_taken");
    selecthedgeDetail.trade_out = ExtractJsonValueString(jsonObject, "trade_out");
    
    // Output parsed details for debugging
    /*Print("Parsed Order Detail:");
    Print("Id: ", orderDetail.id);
    Print("Symbol: ", orderDetail.symbol);
    Print("Buy Price: ", orderDetail.buy_price);
    Print("Sell Price: ", orderDetail.sell_price);*/

    // Add the order detail to the array
    ArrayResize(orderDetails, ArraySize(orderDetails) + 1);
    orderDetails[ArraySize(orderDetails) - 1] = orderDetail;
    
    // Add the order detail to the array
    ArrayResize(selectDetails, ArraySize(selectDetails) + 1);
    selectDetails[ArraySize(selectDetails) - 1] = selectDetail;
    
    // Add the order detail to the array
    ArrayResize(hedgeDetails, ArraySize(hedgeDetails) + 1);
    hedgeDetails[ArraySize(hedgeDetails) - 1] = hedgeDetail;
    
    // Add the order detail to the array
    ArrayResize(selecthedgeDetails, ArraySize(selecthedgeDetails) + 1);
    selecthedgeDetails[ArraySize(selecthedgeDetails) - 1] = selecthedgeDetail;
}

void update_priceDB_record(int tradeId, double openprice, double stoploss, int ticket, datetime time)
{
    string url = "http://localhost/Ecardextract/update_taken_trade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "id=" + IntegerToString(tradeId) + "&openprice=" + DoubleToString(openprice) + "&stoploss=" + DoubleToString(stoploss) + "&ticket=" + IntegerToString(ticket) + "&time=" + TimeToString(time, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    
    //Print("tradeId: ", tradeId);
    //Print("openprice: ", openprice);
    //Print("stoploss: ", stoploss);
    //Print("OrderTicket: ", ticket);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_priceDB_record' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}

//update trades highest BID price and lowest ASK price
      void updateHB(int tradeId, double HB)
      {
          string url = "http://localhost/Ecardextract/update_taken_trade.php"; // Replace with the actual URL of your PHP script
          
          string headers;
          
          // Format the POST data with both tradeId and pnl
          string post_data = "HBid=" + IntegerToString(tradeId) + "&HBPrice=" + DoubleToString(HB);
          
          //Print("tradeId: ", tradeId);
          //Print("openprice: ", openprice);
          //Print("stoploss: ", stoploss);
          //Print("OrderTicket: ", ticket);
          uchar result[]; // Use uchar array for binary data
          uchar post_data_byte[];
          
          // Convert post_data string to byte
          StringToCharArray(post_data, post_data_byte);
          
          // Reset the last error code
          ResetLastError();
      
          int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection
      
          int res = WebRequest(
              "POST",        // HTTP method
              url,           // URL
              headers,       // HTTP headers
              NULL,          // HTTP cookies
              timeout,       // Timeout in milliseconds
              post_data_byte, // POST data as bytes
              0,             // POST data size (0 means auto)
              result,        // Response data
              headers        // Response headers
          );
      
          if (res == 200) {
              // Convert the binary response to an array of characters
              string responseText;
              for (int i = 0; i < ArraySize(result); i++) {
                  responseText += CharToStr(result[i]);
              }
              
              // Process the response data or print it as needed
              //Print("Response: ", responseText);
          } else {
               Print("Error updating 'update_priceDB_record' trade. HTTP Response Code: ", res);
               int error_code = GetLastError();
          }
      }
      
      void updateLA(int tradeId, double LA)
      {
          string url = "http://localhost/Ecardextract/update_taken_trade.php"; // Replace with the actual URL of your PHP script
          
          string headers;
          
          // Format the POST data with both tradeId and pnl
          string post_data = "LAid=" + IntegerToString(tradeId) + "&LAPrice=" + DoubleToString(LA);
          
          //Print("tradeId: ", tradeId);
          //Print("openprice: ", openprice);
          //Print("stoploss: ", stoploss);
          //Print("OrderTicket: ", ticket);
          uchar result[]; // Use uchar array for binary data
          uchar post_data_byte[];
          
          // Convert post_data string to byte
          StringToCharArray(post_data, post_data_byte);
          
          // Reset the last error code
          ResetLastError();
      
          int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection
      
          int res = WebRequest(
              "POST",        // HTTP method
              url,           // URL
              headers,       // HTTP headers
              NULL,          // HTTP cookies
              timeout,       // Timeout in milliseconds
              post_data_byte, // POST data as bytes
              0,             // POST data size (0 means auto)
              result,        // Response data
              headers        // Response headers
          );
      
          if (res == 200) {
              // Convert the binary response to an array of characters
              string responseText;
              for (int i = 0; i < ArraySize(result); i++) {
                  responseText += CharToStr(result[i]);
              }
              
              // Process the response data or print it as needed
              //Print("Response: ", responseText);
          } else {
               Print("Error updating 'update_priceDB_record' trade. HTTP Response Code: ", res);
               int error_code = GetLastError();
          }
      }
   
//Delete stale signal function
void deleteStaleSignal(int tradeId)
{
    string url = "http://localhost/Ecardextract/update_taken_trade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "DSSid=" + IntegerToString(tradeId);
    
    Print("tradeId (going in to function): ", tradeId);
    //Print("openprice: ", openprice);
    //Print("stoploss: ", stoploss);
    //Print("OrderTicket: ", ticket);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_priceDB_record' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}


//Delete stale "HEDGE" signal function
void deleteHedgeStaleSignal(int tradeId, int hedge_reached, int hedge_signal_sent, int fromTrade)
{
    string url = "http://localhost/Ecardextract/update_taken_trade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "DHSid=" + IntegerToString(tradeId) + "&hr=" + IntegerToString(hedge_reached) + "&hss=" + IntegerToString(hedge_signal_sent)+ "&ft=" + IntegerToString(fromTrade);
    
    Print("tradeId (going in to function): ", tradeId);
    Print("FromtradeId (going in to function): ", fromTrade);
    //Print("openprice: ", openprice);
    //Print("stoploss: ", stoploss);
    //Print("OrderTicket: ", ticket);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_priceDB_record' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}

void update_hedge_trade_record(int tradeId, double openprice, int ticket, datetime time, int tradetaken, int fromTradeID, double orderLotsize)
{
    string url = "http://localhost/Ecardextract/update_taken_hedge_trade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "id=" + IntegerToString(tradeId) + "&openprice=" + DoubleToString(openprice) + "&ticket=" + IntegerToString(ticket) + "&time=" + TimeToString(time, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "&tradetaken=" + IntegerToString(tradetaken) + "&fromTradeID=" + IntegerToString(fromTradeID) + "&orderLotsize=" + DoubleToString(orderLotsize);
    
    Print("tradeId: ", tradeId);
    Print("openprice: ", openprice);
    Print("OrderTicket: ", ticket);
    Print("Trade taken: ", tradetaken);
    Print("Trade lot size: ", orderLotsize);
     Print("From Trade: ", fromTradeID);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    Print("Post Data: ", post_data);
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_hedge_trade_record' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}





/*void CheckIfTradeExistsInBothTables(int orderTicket) {
    string url = "http://localhost/Ecardextract/check_manual_trade.php"; // Replace with the actual URL of your PHP script

    string headers;
    string post_data = "ticket=" + IntegerToString(orderTicket);

    uchar result[];
    uchar post_data_byte[];

    StringToCharArray(post_data, post_data_byte);
    ResetLastError();

    int timeout = 2000;

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }

        Print("Response: ", responseText); // Print the response from the PHP script

        if (StringFind(responseText, "Ticket doesn't exist in both mt4order and hedge_trades.") != -1) {
            // Ticket doesn't exist, insert trade details into the mt4order table
            bool tradeInserted = false;
            for (int f = 0; f < OrdersTotal(); f++) {
                if (OrderSelect(f, SELECT_BY_POS)) {
                    if (OrderTicket() == orderTicket) {
                        // Check if the order ticket exists in both tables
                        bool existsInHedgeTrades = CheckOrderExistenceInDatabase(orderTicket, "hedge_trades");
                        bool existsInMt4Order = CheckOrderExistenceInDatabase(orderTicket, "mt4order");

                        if (!existsInHedgeTrades && !existsInMt4Order) 
                        {
                            symDigit = MarketInfo(OrderSymbol(), MODE_DIGITS);
                            point = MarketInfo(OrderSymbol(), MODE_POINT);
                            pip_val = 10 * point;
                            if (OrderType() == OP_BUY) {
                                stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() - (3 * pip_val), symDigit));
                            } else if (OrderType() == OP_SELL) {
                                stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() + (3 * pip_val), symDigit));
                            }

                            string sender = "";
                            string openTimeStr = TimeToString(OrderOpenTime(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                            sender += StringFormat("%d,%s, %f, %d, %f, %f, %f, %d, %d, %d, %d, %d, %s|", OrderTicket(), OrderSymbol(), OrderLots(), OrderType(), OrderOpenPrice(), stopLoss, OrderProfit(), 0, 0, 1, 0, 1, openTimeStr);
                            Print(httpGET("http://localhost/Ecardextract/trade_signal2.php?order=" + sender));
                            Print("JESUS IS LORD");

                            // Set the flag to indicate that the trade has been successfully inserted
                            tradeInserted = true;

                            // Exit the loop once the trade is processed
                            break;
                        }
                    }
                }
            }
        }
    } else {
        Print("Error checking trade in both tables. HTTP Response Code: ", res);
        int error_code = GetLastError();
    }
}*/

bool StringToBool(string value) {
    return StringToInteger(value) != 0;
}

bool CheckOrderExistenceInDatabase(int orderTicket, string tableName) {
    string url = "http://localhost/Ecardextract/check_order_existence.php";
    string headers;
    string post_data = "ticket=" + IntegerToString(orderTicket) + "&tables=mt4order,hedge_trades";

    uchar result[];
    uchar post_data_byte[];

    StringToCharArray(post_data, post_data_byte);
    ResetLastError();

    int timeout = 2000;

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }

        // Parse the response and return the result as a boolean value
        return (responseText == "true");
    } else {
        Print("Error checking order existence. HTTP Response Code: ", res);
        int error_code = GetLastError();
        // Handle the error accordingly
        return false;
    }
}


string checkClosedHedgeTrade(int tradeId) {
    string url = "http://localhost/Ecardextract/check_manual_trade.php";
    string headers;
    string post_data = "from_id=" + IntegerToString(tradeId);

    uchar result[];
    uchar post_data_byte[];

    StringToCharArray(post_data, post_data_byte);
    ResetLastError();

    int timeout = 2000;

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
          //Print("Are all hedge trade out: ", responseText); // Uncomment this line to print the entire response

            // Parse the response and return the result as a boolean value
            if (StringFind(responseText, "All hedge for the from_id closed") >= 0) {
                string message = "All hedge closed. Take action accordingly.";
                return message;
                // Add your code for the specific action when all hedge is closed
            } else if (StringFind(responseText, "Hedge trade still opened") >= 0) {
                string message = "Hedge trade still opened. Take action accordingly.";
                return message;
                // Add your code for the specific action when hedge trade is still opened
            } else {
                string message = "Unexpected response. Handle it accordingly.";
                return message;
                // Add your code for handling unexpected responses
            }
    } else {
        Print("Error checking order existence. HTTP Response Code: ", res);
        int error_code = GetLastError();
        // Handle the error accordingly
        return false;
    }
}

// Function to process the trade details and send them to the database
void ProcessTradeDetails(int orderTicket) {
    symDigit = MarketInfo(OrderSymbol(), MODE_DIGITS);
    point = MarketInfo(OrderSymbol(), MODE_POINT);
    pip_val = 10 * point;

    if (OrderType() == OP_BUY) {
        stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() - (3 * pip_val), symDigit));
    } else if (OrderType() == OP_SELL) {
        stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() + (3 * pip_val), symDigit));
    }

    string sender = "";
    string openTimeStr = TimeToString(OrderOpenTime(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    sender += StringFormat("%d,%s, %f, %d, %f, %f, %f, %d, %d, %d, %d, %d, %s|", OrderTicket(), OrderSymbol(), OrderLots(), OrderType(), OrderOpenPrice(), stopLoss, OrderProfit(), 0, 0, 1, 0, 1, openTimeStr);
    Print(httpGET("http://localhost/Ecardextract/trade_signal2.php?order=" + sender));
    Print("JESUS IS LORD");
}

/*for(int f = 0; f < OrdersTotal(); f++)
{
  if(OrderSelect(f, SELECT_BY_POS))
  {
   symDigit = MarketInfo(OrderSymbol(),MODE_DIGITS);
   point = MarketInfo(OrderSymbol(),MODE_POINT);
   pip_val = 10*point;
   //Alert(pip_val);
   if(OrderType() == OP_BUY){stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() - (10 * pip_val), symDigit));}
   else if(OrderType() == OP_SELL) {stopLoss = MathAbs(NormalizeDouble(OrderOpenPrice() + (10 * pip_val), symDigit));}
              
          string sender="";
          string openTimeStr = TimeToString(OrderOpenTime(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
          sender+=StringFormat("%d, %s, %.2f, %d, %.2f, %.2f, %.2f, %d, %d, %d, %d, %d, %s|", OrderTicket(), OrderSymbol(), OrderLots(), OrderType(), OrderOpenPrice(), stopLoss, OrderProfit(), 0, 0, 1, 0, 1, openTimeStr);
          Print(httpGET("http://localhost/Ecardextract/trade_signal2.php?order="+sender));
          Print("JESUS IS LORD");
   }
}*/



void update_OrderProfit2(int orderTicket, double pnl)
{
    string url = "http://localhost/Ecardextract/update4.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "orderticket=" + IntegerToString(orderTicket) + "&pnl=" + DoubleToString(pnl);
    
    //Print("tradeId: ", tradeId);
    //Print("PnL: ", pnl);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_OrderProfit' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}


void update_OrderProfit(int tradeId, double pnl)
{
    string url = "http://localhost/Ecardextract/update4.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "id=" + IntegerToString(tradeId) + "&pnl=" + DoubleToString(pnl);
    
    //Print("tradeId: ", tradeId);
    //Print("PnL: ", pnl);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_OrderProfit' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}

void update_hedge_OrderProfit(int tradeId, double pnl)
{
    string url = "http://localhost/Ecardextract/update4.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "hedgeID=" + IntegerToString(tradeId) + "&hedgepnl=" + DoubleToString(pnl);
    
    //Print("tradeId: ", tradeId);
    //Print("PnL: ", pnl);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_hedge_OrderProfit' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}

void update_takeOver(int tradeId)
{
    string url = "http://localhost/Ecardextract/update4.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "takeOverID=" + IntegerToString(tradeId);
    
    //Print("takeOverId: ", tradeId);
    //Print("PnL: ", pnl);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_hedge_OrderProfit' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}


void update_hedge(int tradeId, int hedgeValue, int hedge_reachedValue, int signal)
{
    string url = "http://localhost/Ecardextract/update_hedge.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "updateHedgeId=" + IntegerToString(tradeId) + "&hedging=" + IntegerToString(hedgeValue) + "&hedging_reached=" + IntegerToString(hedge_reachedValue) + "&signal_sent=" + IntegerToString(signal);
    
    //Print("tradeId: ", tradeId);
    //Print("Hedging: ", hedgeValue);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating Hedge trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}


void updateCloseTrade(int tradeId, int closeID, int out_trade)
{
    string url = "http://localhost/Ecardextract/update_closeTrade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "id=" + IntegerToString(tradeId) + "&closingid=" + IntegerToString(closeID) + "&Toutid=" + IntegerToString(out_trade);
    
    //Print("tradeId: ", tradeId);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'updateCloseTrade' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}



void updateCloseHedgeTrade(int tradeId)
{
    string url = "http://localhost/Ecardextract/update_closeTrade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "hedgeCID=" + IntegerToString(tradeId);
    
    //Print("tradeId: ", tradeId);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'updateCloseHedgeTrade' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}


void closeTrades(int tradeId)
{
    string url = "http://localhost/Ecardextract/update_closeTrade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "closeID=" + IntegerToString(tradeId);
    
    //Print("tradeId: ", tradeId);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'closeTrade' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}

void tradeDone(int tradeId)
{
    string url = "http://localhost/Ecardextract/update_closeTrade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "doneID=" + IntegerToString(tradeId);
    
    //Print("tradeId: ", tradeId);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
    } else {
         Print("Error updating 'tradeDone' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}

void update_trade_profiting(int tradeId)
{
    string url = "http://localhost/Ecardextract/update_closeTrade.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with both tradeId and pnl
    string post_data = "profitingID=" + IntegerToString(tradeId);
    
    //Print("tradeId: ", tradeId);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        Print("Response: ", responseText);
    } else {
         Print("Error updating 'update_trade_profiting' trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}

double GetLotsize(int tradeId) {
    string url = "http://localhost/Ecardextract/get_lotsize.php"; // Replace with the actual URL of your PHP script
    string headers;
    
    // Format the POST data with only tradeId
    string post_data = "id=" + IntegerToString(tradeId);

    uchar result[];
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);

    // Reset the last error code
    ResetLastError();

    int timeout = 2000;

    int res = WebRequest(
        "POST",
        url,
        headers,
        NULL,
        timeout,
        post_data_byte,
        0,
        result,
        headers
    );

    double lotSize = 0.0;  // Initialize to a default value

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }

        //Print("Full Response Text: ", responseText);

        // Parse the JSON response with 'lotsize' key
        int start = StringFind(responseText, "\"lotsize\":");
        if (start >= 0) {
            start += 10; // Move past the key and opening quote
            int end = StringFind(responseText, "}", start);
            if (end >= 0) {
                string lotSizeStr = StringSubstr(responseText, start, end - start);
                // Convert the lot size string to a double
                lotSize = StringToDouble(lotSizeStr);
                //Print("Lot Size: ", lotSize);
            } else {
                Print("No closing brace for the 'lotsize' key.");
            }
        } else {
            Print("No 'lotsize' key found in JSON data.");
        }
    } else {
        Print("Error updating 'GetLotsize' trade. HTTP Response Code: ", res);
        int error_code = GetLastError();
        Print("Last error code: ", error_code);
    }

    return lotSize;
}




double get_total_order_profit(int id)
{
    string url = "http://localhost/Ecardextract/get_sum_profit.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    
    // Format the POST data with the 'id' parameter
    string post_data = "id=" + IntegerToString(id);
    
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for a slow Internet connection

    int res = WebRequest(
        "POST",        // HTTP method
        url,           // URL
        headers,       // HTTP headers
        NULL,          // HTTP cookies
        timeout,       // Timeout in milliseconds
        post_data_byte, // POST data as bytes
        0,             // POST data size (0 means auto)
        result,        // Response data
        headers        // Response headers
    );

    if (res == 200) {
        // Convert the binary response to an array of characters
        string responseText;
        for (int i = 0; i < ArraySize(result); i++) {
            responseText += CharToStr(result[i]);
        }
        
        // Process the response data or print it as needed
        //Print("Response: ", responseText);
        
        // Parse the JSON response and get the total order profit
        double totalOrderProfit = 0.0;
        if (StringFind(responseText, "\"total_orderprofit\"") >= 0) {
            int valueStart = StringFind(responseText, ":", StringFind(responseText, "\"total_orderprofit\""));
            int valueEnd = StringFind(responseText, "}", valueStart);
            string valueStr = StringSubstr(responseText, valueStart + 1, valueEnd - valueStart - 1);
            totalOrderProfit = StringToDouble(valueStr);
        }

        return totalOrderProfit;
    } else {
        Print("Error getting total order profit. HTTP Response Code: ", res);
        int error_code = GetLastError();
        return 0.0;
    }
}





//+------------------------------------------------------------------+
#import "wininet.dll"
int InternetOpenW(string sAgent, int lAccessType, string sProxyName="", string sProxyBypass="", int lFlags=0);
int InternetOpenUrlW(int hinternetSession, string sUrl, string sHeaders="", int lHeadersLength=0, int lFlags=0, int lContext=0);
int InternetReadFile(int hFile, uchar &sBuffer[], int lNumBytesToRead, int &lNumberOfBytesRead);
int InternetCloseHandle(int hInet);


#import
int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig=0;
int Internet_Open_Type_Direct=1;

int hSession(bool Direct) {
   string InternetAgent="Mozilla/4.0 (compatible: MSIE 6.0; Windows NT 5.1; Q312461)";
   if (Direct) {
      if (hSession_Direct==0){
         hSession_Direct=InternetOpenW(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
      }
   return (hSession_Direct);
   } 
   else 
   {
   if (hSession_IEType==0){
      hSession_IEType = InternetOpenW(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0); 
   }
   return (hSession_IEType);
   }
 }
string httpGET (string strUrl) {
   int handler = hSession(false);
   int response = InternetOpenUrlW(handler, strUrl);
   if (response == 0) return("0");
   uchar ch[100000]; string toStr=""; int dwBytes, h=-1;
   while (InternetReadFile(response, ch, 100000, dwBytes)) {
      if (dwBytes<=0) break; toStr=toStr+CharArrayToString(ch, 0, dwBytes);
   }
   InternetCloseHandle(response);
   return (toStr);
}

