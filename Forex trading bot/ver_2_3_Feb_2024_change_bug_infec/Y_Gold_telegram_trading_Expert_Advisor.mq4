#include <main.mqh>
#include <WinUser32.mqh> // Include this for MessageBox function
//+------------------------------------------------------------------+
//|                                            MyEABasedOnPHP.mq4    |
//|               Copyright 2023, Company Name                      |
//|                         http://www.company.com                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Company Name"
#property link      "http://www.company.com"
#property version   "1.00"
#property strict

//Define Ea name
string EaName = "Telegram signal Ea";

double highestPriceReached = 0;
double lowestPriceReached = 0;
extern double  highestBidPriceReached;
extern double lowestAskPriceReached;
double closingPrice;
double currentAsk;
double currentBid;
double activationPrice;
datetime tradeOpenTime;
int tradeTaken;

double point;
int symDigit;
double pip_val = 10 * point;
double lot_size = 0.01;
int symbolDigit;
double symbolAsk;
double symbolBid;
int symbolSpread;

string ordersym = "";
string Currency;

input int pip_to_close = 2;

input double TdollarEquivalent= 3.5;
input double dollarEquiv = -5.0;
input int symbolSpreadMax = 90;


// Define the structure to hold order details
struct OrderDetail {
    int id;
    string message;
};

OrderDetail orderDetails[]; // Define an array to store order details
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
    string url = "http://localhost/Ecardextract/connect3.php"; // Replace with your PHP script URL
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
                Print("No closing quote for the \"message\" key.");
            }
        } else {
            Print("No \"message\" key found in JSON data.");
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
    orderDetail.message = ExtractJsonValueString(jsonObject, "message");
    //orderDetail.trade_taken = ExtractJsonValueString(jsonObject, "taken");

    // Output parsed details for debugging
    /*Print("Parsed Order Detail:");
    Print("Id: ", orderDetail.id);
    Print("Symbol: ", orderDetail.symbol);
    Print("Buy Price: ", orderDetail.buy_price);
    Print("Sell Price: ", orderDetail.sell_price);*/

    // Add the order detail to the array
    ArrayResize(orderDetails, ArraySize(orderDetails) + 1);
    orderDetails[ArraySize(orderDetails) - 1] = orderDetail;
}

void update_signal_taken(int tradeId)
{
    string url = "http://localhost/Ecardextract/update3.php"; // Replace with the actual URL of your PHP script
    
    string headers;
    string post_data = "id=" + IntegerToString(tradeId); // Convert tradeId to string and format the POST data
    Print("tradeId: ", tradeId);
    Print("POST Data: ", post_data);
    uchar result[]; // Use uchar array for binary data
    uchar post_data_byte[];
    
    // Convert post_data string to byte
    StringToCharArray(post_data, post_data_byte);
    
    // Reset the last error code
    ResetLastError();

    int timeout = 2000; // Timeout below 1000 (1 sec.) is not enough for slow Internet connection

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
         Print("Error updating trade. HTTP Response Code: ", res);
         int error_code = GetLastError();
    }
}


// Function to check if the message contains a signal
bool MessageContainsSignal(string message, string signal) {
    return StringFind(message, signal) != -1;
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

int OnInit() {
    ArrayResize(orderDetails, 0); // Initialize the orderDetails array

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


            // Assuming these are global variables
            Currency = "XAUUSD";  
            //"XAUUSD";
                        // Periodically retrieve and print order details
                        string sender="";
                        string openTimeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                        sender+=StringFormat("%s,%f,%d|",Currency,lot_size,OP_BUY);
                        Alert(httpGET("http://localhost/Ecardextract/trade_signal1.php?order="+sender));
            


    if (getOrderDetails()) 
    {
        for (int i = 0; i < ArraySize(orderDetails); i++) 
        {
               
            //Print("Id: ", orderDetails[i].id);
            //Print("Symbol: ", orderDetails[i].symbol);
            //Print("Buy Price: ", orderDetails[i].buy_price);
            //Print("Sell Price: ", orderDetails[i].sell_price);

            int symDigit = SymbolInfoInteger(Currency, SYMBOL_DIGITS);
            double symAsk = SymbolInfoDouble(Currency,SYMBOL_ASK);
            double symBid = SymbolInfoDouble(Currency,SYMBOL_BID);
            symbolSpread = NormalizeDouble(SymbolInfoInteger(Currency, SYMBOL_SPREAD), symDigit);
            string message = orderDetails[i].message;
            Print("Message: ", message);
            
            
            string buySignal1 = "gold buy now";
            string buySignal2 = "gold buy now!";
            string sellSignal1 = "gold sell now";
            string sellSignal2 = "gold sell now!";
            
            

            
            
            // Convert the incoming message to lowercase for case-insensitive comparison
                   if (MessageContainsSignal(message, buySignal1) || MessageContainsSignal(message, buySignal2))
                   {
                       // Perform actions for a buy signal
                        
                       
                       /*if(StringLen(response) > 0)
                       {
                           Alert("Data inserted into `mt4order` table in MT4 database successfuly response: ", response);
                       }
                       else
                       {
                           Alert("Error, inserting data into database table");
                       }*/
                       
                       //OrderSend(Currency,OP_BUY,0.01,symbolAsk,3,0,0);
                       // Update signal taken
                       update_signal_taken(orderDetails[i].id);
                       //break;  // Exit the loop once a signal is detected
                       //
                   }
                   else if (MessageContainsSignal(message, sellSignal1) || MessageContainsSignal(message, sellSignal2)) {
                       // Perform actions for a sell signal
                       Print("Sell signal detected!");
                       string sender = StringFormat("%s,%f,%d|",Currency,lot_size,OP_SELL);
                       Print(httpGET("http://localhost/Ecardextract/trade_signal1.php?order=" + sender));
                       
                       OrderSend(Currency,OP_SELL,0.01,symbolBid,3,0,0);
                       // Update signal taken
                       update_signal_taken(orderDetails[i].id);
                       //break;  // Exit the loop once a signal is detected
                   }
            
            //Print("Not in position to to enter a trade in any of the trade directions");
            
            
            
             //Print("Higest P: ", highestPriceReached);
            // Manage trade -- Trailing
            
            
             }
            
        }
        
  //Code logic ends Here      
}