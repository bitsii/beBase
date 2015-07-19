// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:LinkedList;
use Container:Map;
use Text:String;
use Logic:Bool;
use Math:Int;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;

final class Visit:Pass1(Visit:Visitor) {

   new() self {
      properties {
         Bool print = false;
         var f;
      }
   }
   
   new(Bool _print) Visit:Pass1 {
      print = _print;
   }
   
   new(Bool _print, String _fname) Visit:Pass1 {
      print = _print;
      f = IO:File:Path.new(_fname).file.writer.open();
   }

   accept(Build:Node node) Build:Node {
      if (print) {
         if (def(f)) {
            f.write(node.toString());
            f.write(Text:Strings.new().newline);
         } else {
            node.print();
         }
      }
      return(node.nextDescend);
   }
   
}

