; Debug test to understand the issue

(print "Testing basic list operations...")

; Test with a simple list
(define simple-list (list 'a 'b 'c))
(print "simple-list:" simple-list)
(print "length simple-list:" (length simple-list))
(print "nth simple-list 0:" (nth simple-list 0))

; Test first function
(define first (lambda (lst)
  (nth lst 0)))

(print "first simple-list:" (first simple-list))

; Test with quoted list
(define quoted-list '(a b c))
(print "quoted-list:" quoted-list)