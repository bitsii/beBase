use Math:Int;
use IO:File;

class Test:TestProcess{
   
   main() {
      return(TestProcess());
   }
   
   TestProcess() {
      var cnt = 0;
      var ei = System:Process.new();
      ei.numArgs.print();
      ei.execName.print();
      for (var i = ei.args.iterator;i.hasNext;;) {
         cnt = cnt++;
         i.next.print();
         //i.next;
      }
      if ((cnt == ei.numArgs) && (ei.execName != Text:String.new()))  {
         " PASSED TestProcess".print();
      } else {
         "!FAILED TestProcess".print();
         return(false);
      }
      return(true);
   }
   
}

