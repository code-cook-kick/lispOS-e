(load "src/lisp/common/utils.lisp")

(print "=== Cons Misuse Prevention Tests ===")

(print "")

(define total-tests
  0)

(define passed-tests
  0)

(define failed-tests
  0)

(define run-test
  (lambda (label expected actual)
    (begin
      (define total-tests
        (+ total-tests 1))
      (if (equal? expected actual)
          (begin
          (define passed-tests
            (+ passed-tests 1))
          (print "✓" label))
          (begin
          (define failed-tests
            (+ failed-tests 1))
          (print "✗" label "- Expected:" expected "Got:" actual))))))

(print "Testing utility functions...")

(run-test
  "ensure-list with list"
  '
  (1 2 3)
  (ensure-list ' (1 2 3)))

(run-test "ensure-list with scalar" ' (42) (ensure-list 42))

(run-test
  "ensure-list with symbol"
  '
  (hello)
  (ensure-list 'hello))

(run-test
  "ensure-list with string"
  '
  ("test")
  (ensure-list "test"))

(run-test "ensure-list with nil" ' () (ensure-list ' ()))

(run-test "ensure-list with false" ' () (ensure-list #f))

(run-test
  "kv creates 2-element list"
  '
  (name "Pedro")
  (kv 'name "Pedro"))

(run-test "kv with numbers" ' (age 45) (kv 'age 45))

(run-test
  "kv with complex values"
  '
  (heirs (Maria Juan))
  (kv 'heirs ' (Maria Juan)))

(run-test
  "pair creates dotted pair"
  (list 'key 'value)
  (pair 'key 'value))

(run-test
  "safe-cons with list"
  '
  (1 2 3)
  (safe-cons 1 ' (2 3)))

(run-test "safe-cons with scalar" ' (1 2) (safe-cons 1 2))

(run-test "safe-cons with nil" ' (1) (safe-cons 1 ' ()))

(run-test
  "make-alist-entry"
  '
  (spouse "Maria")
  (make-alist-entry 'spouse "Maria"))

(run-test
  "safe-plist-put empty"
  '
  (:name "Pedro")
  (safe-plist-put ' () ':name "Pedro"))

(run-test
  "safe-plist-put existing"
  '
  (:age 45 :name "Pedro")
  (safe-plist-put ' (:name "Pedro") ':age 45))

(run-test
  "safe-append-to with list"
  '
  (new 1 2 3)
  (safe-append-to 'new ' (1 2 3)))

(run-test
  "safe-append-to with scalar"
  '
  (new old)
  (safe-append-to 'new 'old))

(print "")

(print "Testing fixed patterns...")

(define spouse-share
  (list 'spouse 1.0))

(run-test
  "R1 fix - scalar literal"
  '
  (spouse 1.0)
  spouse-share)

(define safe-alist-entry
  (kv 'heir-share 0.5))

(run-test
  "R2 fix - alist entry"
  '
  (heir-share 0.5)
  safe-alist-entry)

(define test-alist
  (list (kv 'name "Pedro") (kv 'age 45) (kv 'spouse "Maria")))

(run-test
  "Safe alist building"
  '
  ((name "Pedro") (age 45) (spouse "Maria"))
  test-alist)

(define maybe-list-1
  '
  (2 3))

(define maybe-list-2
  42)

(define safe-cons-1
  (cons 1 (ensure-list (ensure-list maybe-list-1))))

(define safe-cons-2
  (cons 1 (ensure-list (ensure-list maybe-list-2))))

(run-test
  "R2 fix - ensure-list with list"
  '
  (1 2 3)
  safe-cons-1)

(run-test
  "R2 fix - ensure-list with scalar"
  '
  (1 42)
  safe-cons-2)

(print "")

(print "Testing macro-safe patterns...")

(define make-safe-event
  (lambda (type props)
    (list 'event ':type type ':props props)))

(define test-event
  (make-safe-event
    'death
    (list ':person "Pedro" ':heirs ' ("Maria" "Juan"))))

(run-test
  "Safe event construction"
  '
  (event
  :type
  death
  :props
  (:person "Pedro" :heirs ("Maria" "Juan")))
  test-event)

(define make-safe-fact
  (lambda (pred args props)
    (list 'fact ':pred pred ':args args ':props props)))

(define test-fact
  (make-safe-fact
    'heir-share
    '
    ("Pedro" "Maria")
    (list ':share 0.5 ':basis "S774")))

(run-test
  "Safe fact construction"
  '
  (fact
  :pred
  heir-share
  :args
  ("Pedro" "Maria")
  :props
  (:share 0.5 :basis "S774"))
  test-fact)

(print "")

(print "Testing edge cases...")

(define nested-safe
  (kv 'outer (ensure-list (cons 'inner (ensure-list 'value))))
  (run-test
    "Nested safe cons"
    '
    (outer inner value)
    nested-safe)
  (define empty-safe
    (kv 'item (ensure-list ' ())))
  (run-test "Empty list handling" ' (item) empty-safe)
  (define complex-alist
    (list
      (kv 'person (kv 'name "Pedro"))
      (kv 'shares (list (kv 'spouse 0.25) (kv 'children 0.75)))
      (kv 'basis "Article 996")))
  (run-test
    "Complex nested alist"
    '
    ((person (name "Pedro"))
    (shares ((spouse 0.25) (children 0.75)))
    (basis "Article 996"))
    complex-alist)
  (define valid-cons-1
    (list 'item ' ()))
  (define valid-cons-2
    (kv 'item ' (1 2 3)))
  (run-test "Valid cons with empty list" ' (item) valid-cons-1)
  (run-test
    "Valid cons with list literal"
    '
    (item 1 2 3)
    valid-cons-2)
  (print "")
  (print "Testing performance patterns...")
  (define build-large-alist
    (lambda (n acc)
      (if (= n 0)
          acc
          (build-large-alist
          (- n 1)
          (kv (kv (cons 'key (cons n ' ())) n) (ensure-list acc))))))
  (define large-alist
    (build-large-alist 10 ' ()))
  (run-test "Large alist building" 10 (length large-alist))
  (define test-types
    (list 42 "string" 'symbol ' (1 2 3) ' () #t #f))
  (define ensured-types
    (map ensure-list test-types))
  (run-test "Ensure-list type safety" 7 (length ensured-types))
  (print "")
  (print "Testing integration with existing patterns...")
  (define test-plist
    '
    (:name "Pedro" :age 45))
  (define extended-plist
    (safe-plist-put test-plist ':spouse "Maria"))
  (run-test
    "Plist integration"
    "Maria"
    (plist-get extended-plist ':spouse))
  (define build-heir-list
    (lambda (heirs acc)
      (if (null? heirs)
          acc
          (build-heir-list
          (rest heirs)
          (cons (kv 'heir (first heirs)) (ensure-list acc))))))
  (define heir-list
    (build-heir-list ' ("Maria" "Juan" "Pedro") ' ()))
  (run-test "Heir list building" 3 (length heir-list))
  (print "")
  (print "=== TEST RESULTS ===")
  (print "Total tests:" total-tests)
  (print "Passed:" passed-tests)
  (print "Failed:" failed-tests)
  (if (= failed-tests 0)
      (print "SUCCESS: All cons misuse prevention tests passed!")
      (print "FAILURE: Some tests failed!"))
  (print "")
  (print "=== Cons Misuse Tests Complete ===")
  (= failed-tests 0))
