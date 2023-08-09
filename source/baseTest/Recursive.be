// Copyright 2016 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

/* The Great Computer Language Shootout
   http://shootout.alioth.debian.org/

   contributed by Craig Welch
*/

use Benchmark:Recursive;
use Math:Int;
use Math:Float;
   
final class Recursive {

   main() {
      
      any args = System:Process.new().args;
      Int n = Int.new(args[0]) - 1;
      
      ( "Ack(3," + (n + 1) + "): " + ack(3, n + 1) ).print();
      ( "Fib(" + (28.0 + n.toFloat()) + "): " + fibFloat(28.0 + n.toFloat()).toInt() ).print();
      ( "Fib(3): " + fib(3) ).print();
      ( "Tak(" + (3 * n) + "," + (2 * n) + "," + n + "): " + tak(3 * n, 2 * n, n) ).print();
      ( "Fib(3): " + fib(3) ).print();
      ( "Tak(3.0,2.0,1.0): " + takFloat(3.0, 2.0, 1.0) ).print();
      
	}
   
   ack(Int x, Int y) Int {
      if (x == 0) { return( y + 1 ); }
      if (y == 0) { return( ack( x - 1, 1) ); }
      return( ack( x - 1, ack( x, y - 1 ) ) );
   }
   
   tak(Int x, Int y, Int z) Int {
      if (y < x) {
         return(tak( tak(x - 1, y, z), tak(y - 1, z, x), tak(z - 1, x, y) ));
      }
      return(z);
   }
   
   takFloat(Float x, Float y, Float z) Float {
      if (y < x) {
         return(takFloat( takFloat(x - 1.0, y, z), takFloat(y - 1.0, z, x), takFloat(z - 1.0, x, y) ));
      }
      return(z);
   }
   
   fib(Int n) Int {
      if (n < 2) {
         return(1);
      }
      return(fib(n - 2) + fib(n - 1));
   }
   
   fibFloat(Float n) Float {
      if (n < 2.0) {
         return(1.0);
      }
      return(fibFloat(n - 2.0) + fibFloat(n - 1.0));
   }
   
}


