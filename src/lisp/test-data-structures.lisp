; Test to understand data structures in this LISP interpreter

(print "Testing data structures...")

; Test list function
(define test-list (list 1 2 3))
(print "test-list:" test-list)
(print "length test-list:" (length test-list))

; Test quoted list
(print "quoted list '(1 2 3):" '(1 2 3))

; Test first and rest on list
(print "first test-list:" (nth test-list 0))
(print "rest test-list:" (rest test-list))

; Test cons
(define consed-list (cons 0 test-list))
(print "consed-list:" consed-list)
(print "length consed-list:" (length consed-list))