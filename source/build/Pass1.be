// Copyright 2006 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
         any f;
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
         } elseIf (def(node.held.orgName)) {
           inClassMethod = inClass + "." + node.held.orgName;
         } elseIf (def(node.held.name)) {
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

