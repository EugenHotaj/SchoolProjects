abstract class Tree[+T] 
case class Node[T](label:T, left:Tree[T], right:Tree[T]) extends Tree[T]
case class Leaf[T](label:T) extends Tree[T]

trait Addable[T]{
  def +(other:T) : T
}

class A(x:Int) extends Addable[A]{
  var value = x
  def +(other:A) = new A(value + other.value)

  override def toString() = "A(" + value + ")"
}

class B(x:Int) extends A(x){
  override def toString() = "B(" + value + ")"
}

class C(x:Int) extends B(x){
  override def toString() = "C(" + value + ")"
}

object Part2{

  def inOrder[T](tree:Tree[T]) : List[T] = 
    tree match{
      case Leaf(label) => List(label)
      case Node(label,left,right) => inOrder(left) ++ List(label) ++ inOrder(right)
    }

  def treeSum[T <: Addable[T]](tree:Tree[T]) : T =
    tree match{
      case Leaf(label) => label
      case Node(label,left,right) => label + treeSum(left) + treeSum(right)
    }

  def treeMap[T,V](func:(T)=>V,tree:Tree[T]) : Tree[V] = 
    tree match{
      case Leaf(label) => Leaf(func(label))
      case Node(label, left, right) => Node(func(label), treeMap(func,left), treeMap(func,right))
    }

  def BTreeMap(func:(B)=>B, tree:Tree[B]) : Tree[B] =
    treeMap(func,tree)

  def test() {
    def faa(a:A):A = new A(a.value+10)
    def fab(a:A):B = new B(a.value+20)
    def fba(b:B):A = new A(b.value+30)
    def fbb(b:B):B = new B(b.value+40)
    def fbc(b:B):C = new C(b.value+50)
    def fcb(c:C):B = new B(c.value+60)
    def fcc(c:C):C = new C(c.value+70)
    def fac(a:A):C = new C(a.value+80)
    def fca(c:C):A = new A(c.value+90)

    val myBTree: Tree[B] = Node(new B(4),Node(new B(2),Leaf(new B(1)),Leaf(new B(3))), 
                     Node(new B(6), Leaf(new B(5)), Leaf(new B(7))))

    val myATree: Tree[A] = myBTree

    println("inOrder = " + inOrder(myATree))
    println("Sum = " + treeSum(myATree))

    //println(BTreeMap(faa,myBTree)) -- BTreeMap[B] fails since A super of B 
    println(BTreeMap(fab,myBTree))
    //println(BTreeMap(fba,myBTree)) -- A super of B, fails for same reason as above
    println(BTreeMap(fbb,myBTree))
    println(BTreeMap(fbc,myBTree))
    //println(BTreeMap(fcb,myBTree)) -- Same reason, B super of C
    //println(BTreeMap(fcc,myBTree)) -- Attempting to pass B as parameter in place of C, but B super of C
    println(BTreeMap(fac,myBTree))
    //println(BTreeMap(fca,myBTree)) -- A super of C

    println(treeMap(faa,myATree))
    println(treeMap(fab,myATree))
    //println(treeMap(fba,myATree)) -- A super of B
    //println(treeMap(fbb,myATree)) -- Attempting to pass A as parameter in place of B, but A super of A 
    //println(treeMap(fbc,myATree)) -- Same as above
    //println(treeMap(fcb,myATree)) -- Attempting to pass A as parameter in place of C, but A super of C
    //println(treeMap(fcc,myATree)) -- Same as above 
    println(treeMap(fac,myATree))
    //println(treeMap(fca,myATree)) -- Same as above
  }

  def main(args:Array[String]) { 
    test();
  }
}

