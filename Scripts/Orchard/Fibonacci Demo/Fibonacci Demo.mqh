/*

   Fibonacci Demo
   Copyright 2022, Orchard Forex
   https://www.orchardforex.com

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
input int InpLookback = 10; // Peak finder lookback

#include <Orchard/Shared/Fibonacci.mqh>

void OnStart() {

   string name = "MyFibo";

   // Part 1, find the peaks
   double highValue;
   int highBar = FindHighPeak( Symbol(), ( ENUM_TIMEFRAMES )Period(), 1, InpLookback, highValue );
   PrintFormat( "High peak is at bar %i value %f", highBar, highValue );

   double lowValue;
   int    lowBar = FindLowPeak( Symbol(), ( ENUM_TIMEFRAMES )Period(), 1, InpLookback, lowValue );
   PrintFormat( "Low peak is at bar %i value %f", lowBar, lowValue );

   // Part 2, draw fibo
   datetime time1, time2;
   double   value1, value2;
   if ( highBar > lowBar ) {
      time1  = iTime( Symbol(), Period(), highBar );
      value1 = highValue;
      time2  = iTime( Symbol(), Period(), lowBar );
      value2 = lowValue;
   }
   else {
      time1  = iTime( Symbol(), Period(), lowBar );
      value1 = lowValue;
      time2  = iTime( Symbol(), Period(), highBar );
      value2 = highValue;
   }
   DrawFibo( name, time1, value1, time2, value2 );
   Sleep( 100 ); // MT4 timing

   // Part 3, get the value from the levels
   PrintFormat( "Level 2=%f, level 6=%f", GetFiboLevel( 0, name, 2 ), GetFiboLevel( 0, name, 6 ) );

   // Part 4 - who needs the fibo object?
   PrintFormat( "Without drawing an object level 38.2=%f and level 161.8=%f",
                GetFiboLevelByRatio( value1, value2, 0.382 ),
                GetFiboLevelByRatio( value1, value2, 1.618 ) );
}
