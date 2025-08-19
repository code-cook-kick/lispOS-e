(print "Testing basic list operations...")

(define simple-list
  (list 'a 'b 'c))

(print "simple-list:" simple-list)

(print "length simple-list:" (length simple-list))

(print "nth simple-list 0:" (nth simple-list 0))

(define first
  (lambda (lst)
    (nth lst 0)))

(print "first simple-list:" (first simple-list))

(define quoted-list
  '
  (a b c))

(print "quoted-list:" quoted-list)
