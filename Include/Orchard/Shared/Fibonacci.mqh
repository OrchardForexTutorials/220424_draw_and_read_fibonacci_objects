/*
 * Fibonacci.mqh
 *
 * Copyright 2022, Orchard Forex
 * https://orchardforex.com
 *
 */

/**=
 *
 * Disclaimer and Licence
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * All trading involves risk. You should have received the risk warnings
 * and terms of use in the README.MD file distributed with this software.
 * See the README.MD file for more information and before using this software.
 *
 **/

// Find(High/Low)Peak only look back. Not forward
int FindHighPeak( string symbol, ENUM_TIMEFRAMES timeframe, int start, int lookback,
                  double &value ) {

   int highBar = start;
   do {
      start   = highBar;
      highBar = iHighest( symbol, timeframe, MODE_HIGH, lookback, start );
   } while ( highBar != start );
   value = iHigh( symbol, timeframe, highBar );
   return ( highBar );
}

int FindLowPeak( string symbol, ENUM_TIMEFRAMES timeframe, int start, int lookback,
                 double &value ) {

   int lowBar = start;
   do {
      start  = lowBar;
      lowBar = iLowest( symbol, timeframe, MODE_LOW, lookback, start );
   } while ( lowBar != start );
   value = iLow( symbol, timeframe, lowBar );
   return ( lowBar );
}

// Just a wrapper to allow calling without chart id
bool DrawFibo( string name, datetime time1, double price1, datetime time2, double price2 ) {
   return ( DrawFibo( 0, name, time1, price1, time2, price2 ) );
}

// Draw a new fibo or just move the existing.
bool DrawFibo( long chartId, string name, datetime time1, double price1, datetime time2,
               double price2 ) {

   bool result = true;

   // If the fibo is already there just reuse it
   int  found  = ObjectFind( chartId, name );

   // Create the fibo object
   if ( found < 0 ) {
      result = ObjectCreate( chartId, name, OBJ_FIBO, 0, time1, price1, time2, price2 );
   }
   else {
      if ( ObjectGetInteger( 0, name, OBJPROP_TYPE ) != OBJ_FIBO ) {
         return ( false );
      }
      result &= ObjectSetInteger( chartId, name, OBJPROP_TIME, 0, time1 );
      result &= ObjectSetInteger( chartId, name, OBJPROP_TIME, 1, time2 );
      result &= ObjectSetDouble( chartId, name, OBJPROP_PRICE, 0, price1 );
      result &= ObjectSetDouble( chartId, name, OBJPROP_PRICE, 1, price2 );
   }

   // There are more things that can be set
   // I'm leaving them for now because you can also set them on screen
   // If you do set them here then values need to be passed to the function

   //// General properties
   // ObjectSetInteger(chartId, name, OBJPROP_COLOR, colour);
   // ObjectSetInteger(chartId, name, OBJPROP_STYLE, style);
   // ObjectSetInteger(chartId, name, OBJPROP_WIDTH, width);
   //  and more ...

   //// Values for levels
   // ObjectSetDouble(chartId,name,OBJPROP_LEVELVALUE,level,price);
   // ObjectSetInteger(chartId,name,OBJPROP_LEVELCOLOR,level,colour);
   // ObjectSetInteger(chartId,name,OBJPROP_LEVELSTYLE,level,style);
   // ObjectSetInteger(chartId,name,OBJPROP_LEVELWIDTH,level,width);
   // ObjectSetString(chartId,name,OBJPROP_LEVELTEXT,level,text);

   ChartRedraw( chartId );
   return ( result );
}

// Get the first fibo point - 100%
bool GetFiboStart( long chartId, string name, datetime &time, double &price ) {

   return ( GetFiboPoint( chartId, name, 0, time, price ) );
}

// Get the end fibo point - 0%
bool GetFiboEnd( long chartId, string name, datetime &time, double &price ) {

   return ( GetFiboPoint( chartId, name, 1, time, price ) );
}

// General purpose to get one of the points
//		This way there is common code
bool GetFiboPoint( long chartId, string name, int pointNumber, datetime &time, double &price ) {

   // If the fibo not found error
   int found = ObjectFind( chartId, name );
   if ( found < 0 ) {
      return ( false );
   }

   time  = ( datetime )ObjectGetInteger( chartId, name, OBJPROP_TIME, pointNumber );
   price = ObjectGetDouble( chartId, name, OBJPROP_PRICE, pointNumber );
   return ( true );
}

// Using an on screen fibo find any nominal ratio (38.2% would be 0.382)
//		of the retracement
// In the original video value1 and value2 are reversed. There is no
//		impact on the result, just changing names.
double GetFiboLevelByRatio( long chartId, string name, double ratio ) {

   datetime time;
   double   value1;
   double   value2;

   if ( !GetFiboStart( chartId, name, time, value1 ) ) {
      return ( 0 );
   }

   if ( !GetFiboEnd( chartId, name, time, value2 ) ) {
      return ( 0 );
   }

   return ( GetFiboLevelByRatio( value1, value2, ratio ) );
}

// More generic, does not need a fibo object to exist
//		Just uses the start and end points and the ratio
double GetFiboLevelByRatio( double value1, double value2, double ratio ) {

   return ( value2 + ( ( value1 - value2 ) * ratio ) );
}

// Read the price from one of the fibo levels on screen
//		Allows you to move the levels on a manually drawn fibo
//		and get those values back
double GetFiboLevel( long chartId, string name, int level ) {

   // If the fibo not found error
   int found = ObjectFind( chartId, name );
   if ( found < 0 ) {
      PrintFormat( "%s not found", name );
      return ( 0 );
   }

   // Can't specify an invalid level
   // I didn't worry about negative numbers
   if ( level >= ObjectGetInteger( chartId, name, OBJPROP_LEVELS ) ) {
      PrintFormat( "Invalid level %i", level );
      return ( 0 );
   }
   double ratio = ObjectGetDouble( chartId, name, OBJPROP_LEVELVALUE, level );

   return ( GetFiboLevelByRatio( chartId, name, ratio ) );
}
