

public class Hi {
    
    static Hi hi = new Hi(10);
    int num;
    
    Hi() {
        //hi.print();
    }
    
    Hi(int num) {
        this.num = num;
        //hi.print();
    }
    
    void print() {
         System.Console.WriteLine("hi " + num);
    }
    
    static void Main(string[] args)
    {
        hi.print();
    }
    
}