use Math:Int;

class Test:TestTokenizer{
   
   main() {
      return(testTokenizer());
   }
   
   testTokenizer() {
      any delims = ",.;:";
      any str = "Hi;There,George.TaDa";
      any toker = Text:Tokenizer.new(delims, true);
      any toks = toker.tokenize(str);
      for (any i = toks.iterator;i.hasNext;;) {
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

