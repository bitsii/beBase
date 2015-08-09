// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:LinkedList;
use Container:Map;
use Container:Set;
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
         Set printAstElements;
         Bool hasAstMethods;
         var f;
      }
   }
   
   new(Bool _print, Set _printAstElements, String _fname) Visit:Pass1 {
      print = _print;
      printAstElements = _printAstElements;
      hasAstMethods = printAstElements.isEmpty!;
      if (def(_fname)) {
        f = IO:File:Path.new(_fname).file.writer.open();
      }
   }

   accept(Build:Node node) Build:Node {
     vars {
       String inClass;
       String inClassMethod;
     }
     if (node.typename == ntypes.CLASS) {
         inClass = node.held.namepath.toString();
         inClassMethod = null;
         inLine = null;
      }
      if (node.typename == ntypes.METHOD && def(inClass)) {
         inClassMethod = inClass + "." + node.held.orgName;
         //("inClassMethod " + inClassMethod).print();
      }
      if (def(inClassMethod) && def(node.nlc)) {
        String inLine = inClassMethod + "." + node.nlc;
      }
      if (print || (hasAstMethods && def(inClassMethod) && printAstElements.has(inClassMethod)) || (hasAstMethods && def(inLine) && printAstElements.has(inLine))) {
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

