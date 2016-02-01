Control.Print.printDepth := 100;
Control.Print.printLength := 100;

fun partition x [] = ([],[])
  | partition x (y::ys) = let
      fun tuple x (y::ys) less more =
        if(x > y) then tuple x ys (less @ [y]) more
        else tuple x ys less (more @ [y])
        | tuple  _ [] less more = (less,more)
in
    tuple x (y::ys) [] []
end

fun partitionSort [] = []
  | partitionSort [x] = [x]
  | partitionSort (x::xs) = let
      val (left,right) = partition x xs
in
    ((partitionSort left) @ [x] @ (partitionSort right))
end

fun Sort _ [] = []
  | Sort _ [x] = [x]
  | Sort (op <) (x::xs) = let
      val (left, right) = let
	  fun partition f (y::ys) less more =
	    if(y < f) then partition f ys (less @ [y]) more
	    else partition f ys less (more @ [y])
	    | partition _ [] less more = (less,more)
      in
	  partition x xs [] []
      end 
  in
      ((Sort (op <) left) @ [x] @ (Sort (op <) right))
  end
			     
datatype 'a tree = empty | leaf of 'a | node of 'a * 'a tree * 'a tree

exception EmptyTree

fun maxTree _ empty = raise EmptyTree
  | maxTree _ (leaf(data)) = data
  | maxTree _ (node(data, empty, empty)) = data
  | maxTree (op <) (node(data,empty,right)) = let
      val biggest = maxTree (op <) right
  in
      if(data < biggest) then biggest else data
  end
  | maxTree (op <) (node(data,left,empty)) = let
      val biggest = maxTree (op <) left
  in
      if(data < biggest) then biggest else data
  end
  | maxTree (op <) (node(data,left,right)) = let
      val leftBiggest = maxTree (op <) left
      val rightBiggest = maxTree (op <) right
  in 
    if(data < leftBiggest) then 
	if(leftBiggest < rightBiggest) then rightBiggest else leftBiggest
    else
	if(data < rightBiggest) then rightBiggest else data
  end
    
fun Labels _ empty = []
  | Labels _ (leaf(data)) = [data]
  | Labels func (node(data,left,right)) = let
      val (x1,x2,x3) = func(data,left,right)
      val leftItem = Labels func x1
      val middleItem = Labels func x2
      val rightItem = Labels func x3
  in
      (leftItem @ middleItem @ rightItem)
  end

fun preorder (data : 'a, left : 'a tree, right : 'a tree) = (leaf(data),left,right)
fun inorder (data : 'a, left : 'a tree, right : 'a tree) = (left,leaf(data),right)
fun postorder (data : 'a, left : 'a tree, right : 'a tree) = (left,right,leaf(data))

fun lexLess _ [] [] = true 
  | lexLess _ [] (y::ys) = true
  | lexLess _ (x::xs) [] = false
  | lexLess (op <) (x::xs) (y::ys) =
    if(x < y) then true else 
      if(y < x) then false else lexLess (op <) xs ys

fun sortTreeList _ [] = []
  | sortTreeList _ [x] = [x]
  | sortTreeList (op <) (x::xs) = 
   Sort (fn(a,b) => lexLess (op <) (Labels inorder a) (Labels inorder b)) (x::xs)
