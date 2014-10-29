

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
        System.out.println("hi " + num);
    }
    
    public static void main(String[] args) {
        hi.print();
    }
    
}