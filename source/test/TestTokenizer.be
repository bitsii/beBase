use Math:Int;

class Test:TestTokenizer{
   
   main() {
      return(testTokenizer());
   }
   
   testTokenizer() {
      var delims = ",.;:";
      var str = "Hi;There,George.TaDa";
      var toker = Text:Tokenizer.new(delims, true);
      var toks = toker.tokenize(str);
      for (var i = toks.iterator;i.hasNext;;) {
         i.next.print();
      }
      
      /*
      if (uux + uuy == " Hi There. ") {
      (" PASSED add, equals" + uux + uuy).print();
      } else {
      "!FAILED add, equals".print();
      return(false);
      }
      */
      
      return(true);
   }
   
}

