import java.util.ArrayList;
import java.util.List;

interface Sorted<T extends Comparable<? super T>> extends List<T> {
    Sorted<T> merge(Sorted<? extends T> otherList);
}

@SuppressWarnings("NullableProblems")
class SortedList<T extends Comparable<? super T>> extends ArrayList<T> implements Sorted<T>, Comparable<SortedList<? extends T>>{

    @Override
    public boolean add(T item){

        int placeToAdd = 0;

        while(placeToAdd < this.size() && this.get(placeToAdd).compareTo(item)<=0){
            placeToAdd++;
        }
        super.add(placeToAdd,item);

        return true;
    }

    @Override
    public Sorted<T> merge(Sorted<? extends T> otherList) {
        Sorted<T> merged = new SortedList<T>();

        for(int i=0; i< this.size(); i++){
            merged.add(this.get(i));
        }

        for (int i=0; i<otherList.size(); i++){
            merged.add(otherList.get(i));
        }

        return merged;
    }

    @Override
    public int compareTo(SortedList<? extends T> o) {

        int currentSize = this.size();
        int otherSize = o.size();

        for(int i=0; i<currentSize; i++){
            if(i+1 >  otherSize){
                return 1;
            }
            T currentItem = this.get(i);
            T otherItem = o.get(i);

            int comparison = currentItem.compareTo(otherItem);

            if(comparison>0)
                return 1;
            if(comparison<0)
                return -1;
        }

        if(currentSize==otherSize)
            return 0;

        return -1;
    }

    @Override
    public String toString(){
        StringBuilder sb = new StringBuilder();
        sb.append("[[");
        for(int i=0; i< this.size(); i++) {
            sb.append(this.get(i).toString());
            sb.append(" ");
        }
        sb.append("]]");
        return sb.toString();
    }
}

@SuppressWarnings("NullableProblems")
class A implements Comparable<A>{

    Integer x, y;

    A(Integer x, Integer y){
        this.x = x;
        this.y = y;
    }

    @Override
    public int compareTo(A o) {
        if(o instanceof B){
            return new Integer(x + y).compareTo(o.x + o.y + ((B) o).z);
        }
        return new Integer(x + y).compareTo(o.x + o.y);
    }

    @Override
    public String toString(){
        return "A<" + x + "," + y + ">";
    }
}

@SuppressWarnings("NullableProblems")
class B extends A implements Comparable<A>{

    Integer z;

    public B(Integer x, Integer y, Integer z){
        super(x,y);
        this.z = z;
    }

    @Override
    public int compareTo(A o) {
        if(o instanceof B){
            return new Integer(x + y + z).compareTo(o.x + o.y + ((B) o).z);
        }
        return new Integer(x + y + z).compareTo(o.x + o.y);
    }

    @Override
    public String toString(){
        return "B<" + x + "," + y + "," + z + ">";
    }
}

public class Part1 {

    public static void main(String[] args){
        test();
    }

    static<T extends Comparable<? super T>> void addToSortedList(SortedList<T> L, T z){
        L.add(z);
    }

    static void test() {
        SortedList<A> c1 = new SortedList<A>();
        SortedList<A> c2 = new SortedList<A>();
        for(int i = 35; i >= 0; i-=5) {
            addToSortedList(c1, new A(i,i+1));
            addToSortedList(c2, new B(i+2,i+3,i+4));
        }

        System.out.print("c1: ");
        System.out.println(c1);

        System.out.print("c2: ");
        System.out.println(c2);

        switch (c1.compareTo(c2)) {
            case -1:
                System.out.println("c1 < c2");
                break;
            case 0:
                System.out.println("c1 = c2");
                break;
            case 1:
                System.out.println("c1 > c2");
                break;
            default:
                System.out.println("Uh Oh");
                break;
        }

        Sorted<A> res = c1.merge(c2);
        System.out.print("Result: ");
        System.out.println(res);
    }
}
