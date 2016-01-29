;; (fromTo k n) returns the list of integers from k to n.
;; Base Case: if k = n (i.e. if the size of the problem is 0), then the result is the list containing only n.
;; Hypothesis: Assume (fromTo (+ k 1) n) returns the list of integers from k+1 to n.
;; Recursive Step: (fromTo k n) = (cons k (FromTo (+ k 1) n).
(define (fromTo k n)
  (cond ((= k n) (list n)) 
	(else (cons k (fromTo (+ k 1) n)))
	))

;; (removeMults m L) returns L with multiples of m removed.
;; Base Case: L is the empty list.
;; Hypothesis: Assume (removeMults m (cdr L)) returns list with multiples of m removed.
;; Recursive Step: (removeMults m L) = (cons (car L) (removeMults m (cdr L))) ,  if m % (car L) != 0.
;;                                   = (removeMults m (cdr L))                ,  if m % (car L) == 0.
(define (removeMults m L)
  (cond ((null? L) '())
	((= 0 (modulo (car L) m)) (removeMults m (cdr L)))
	(else (cons (car L) (removeMults m (cdr L))))
	 ))

;; (removeAllMults L) returns L where each element of L is not a multiple of any other.
;; Base Case: L is the empty list.
;; Hypothesis: Assume (removeAllMults (cdr L)) returns list with all multiples removed.
;; Recursie Step: (removeAllMults L) = (removeAllMults (removeMults (car L) L)).   
(define (removeAllMults L)
  (cond ((null? L) '())
	(else (cons (car L) (removeAllMults (removeMults (car L) L))))
	))

;; (primes n) returns all primes less than or equal to n.
;; There's really no 'recursive reasoning' that can happen for this function.
;; While recursion is happening under the hood, this function itself does nothing recursive.
;; It simply calls fromTo to generate a list from 2->n (note 1 is excluded since it's not a prime 
;;   and would casue bugs since x % 1 = 0 forall x) then calls removeAllMults to remove all multiples
;;   in effect giving us all primes. 
(define (primes n)
  (removeAllMults (fromTo 2 n))
  )

;; (maxDepth L) return the maximum nesting depth of any element of L.
;; Base Case: L is the empty list.
;; Hypothesis: Assume (maxDepth (cdr L)) returns maximum nesting depth of any element of L.
;; Recursive Step: (maxDepth L) = (max (+ 1 (maxDepth (car L))) (maxDepth (cdr L))) , if (car L) is a list.
;;                              = (maxDepth (cdr L))                                , if (car L) not a list.
(define (maxDepth L)
  (cond ((null? L) 0)
	((list? (car L)) (max (+ 1 (maxDepth (car L))) (maxDepth (cdr L))))
	(else (maxDepth (cdr L)))
	))

;; (prefix exp) transforms exp from infix arithmetic to prefix arithmetic.
;; Base Case: L is not a list (i.e an atom) or L is a list with one item.
;; Hypothesis: (prefix (cdr L)) returns a list in prefix notation.
;; Recursive Step: (prefix L) = (list operator (prefix operand1) (prefix operand2)).
;;                            = (list (cadr L) (prefix (car L)) (prefix (caddr L))).
(define (prefix L)
  (cond ((list? L)
	 (cond ((null? (cdr L)) (car L))
		(else (list (cadr L) (prefix (car L)) (prefix (cddr L))))
	 ))
	(else L)
	))

;; (composition fns) returns a function which is the composition of all functions specified in fns.
;; Base Case: fns is a list containing only one function.
;; Hypothesis: (composition (cdr fns)) returns a composition of functions.
;; Recursvie Step: (composition fns) = (lambda (x) ((car lst) ((composition (cdr lst)) x))).
(define (composition fns)
  (cond ((null? (cdr fns)) (car fns)) 
	(else (lambda (x) ((car fns) ((composition (cdr fns)) x))))
	))
