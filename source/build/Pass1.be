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
use Build:Visit;
use Build:NamePath;
use Build:VisitError;

final class Build:Visit:Pass1(Build:Visit:Visitor) {

   new() self {
      fields {
         Set printAstElements;
         Bool allAstElements;
         var f;
      }
   }
   
   new(Set _printAstElements, String _fname) Build:Visit:Pass1 {
      printAstElements = _printAstElements;
      allAstElements = printAstElements.isEmpty;
      if (def(_fname)) {
        f = IO:File:Path.new(_fname).file.writer.open();
      }
   }

   accept(Build:Node node) Build:Node {
     fields {
       String inClass;
       String inClassMethod;
     }
     if (node.typename == ntypes.CLASS) {
         if ("".sameType(node.held)) {
          inClass = node.held;
         } else {
          inClass = node.held.namepath.toString();
         }
         inClassMethod = null;
         inLine = null;
      }
      if (node.typename == ntypes.METHOD && def(inClass)) {
         if ("".sameType(node.held)) {
           inClassMethod = node.held;
         } elif (def(node.held.orgName)) {
           inClassMethod = inClass + "." + node.held.orgName;
         } elif (def(node.held.name)) {
           inClassMethod = inClass + "." + node.held.name;
         }
         //("inClassMethod " + inClassMethod).print();
      }
      if (def(inClassMethod) && def(node.nlc)) {
        String inLine = inClassMethod + "." + node.nlc;
      }
      if (allAstElements || (def(inClassMethod) && printAstElements.has(inClassMethod)) || (def(inLine) && printAstElements.has(inLine))) {
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

