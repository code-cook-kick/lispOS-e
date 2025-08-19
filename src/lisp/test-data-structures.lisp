(print "Testing data structures...")

(define test-list
  (list 1 2 3))

(print "test-list:" test-list)

(print "length test-list:" (length test-list))

(print "quoted list '(1 2 3):" ' (1 2 3))

(print "first test-list:" (nth test-list 0))

(print "rest test-list:" (rest test-list))

(define consed-list
  (cons 0 test-list))

(print "consed-list:" consed-list)

(print "length consed-list:" (length consed-list))
