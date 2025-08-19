(load "src/lisp/statute-api-final-working.lisp")

(print "")

(print "=== Etherney eLisp Test Suite ===")

(print "")

(define *test-total*
  0)

(define *test-passed*
  0)

(define *test-failed*
  0)

(define simple-assert
  (lambda (label expected actual)
    (begin
      (define *test-total*
        (+ *test-total* 1))
      (if (eq? expected actual)
          (define *test-passed*
          (+ *test-passed* 1))
          (define *test-failed*
          (+ *test-failed* 1)))
      (if (eq? expected actual)
          (print "[PASS]" label)
          (print "[FAIL]" label "Expected:" expected "Actual:" actual)))))

(define assert-true
  (lambda (label value)
    (begin
      (define *test-total*
        (+ *test-total* 1))
      (if value
          (define *test-passed*
          (+ *test-passed* 1))
          (define *test-failed*
          (+ *test-failed* 1)))
      (if value
          (print "[PASS]" label)
          (print "[FAIL]" label "Expected: true, Actual:" value)))))

(define assert-false
  (lambda (label value)
    (begin
      (define *test-total*
        (+ *test-total* 1))
      (if (not value)
          (define *test-passed*
          (+ *test-passed* 1))
          (define *test-failed*
          (+ *test-failed* 1)))
      (if (not value)
          (print "[PASS]" label)
          (print "[FAIL]" label "Expected: false, Actual:" value)))))

(define print-summary
  (lambda ()
    (begin
      (print "")
      (print "=== Test Summary ===")
      (print "Total:" *test-total* "tests")
      (print "Passed:" *test-passed*)
      (print "Failed:" *test-failed*)
      (if (> *test-failed* 0)
          (print "OVERALL: FAIL")
          (print "OVERALL: PASS"))
      (print ""))))

(print "--- Testing Conditionals & Truthiness ---")

(simple-assert
  "if/then/else basic"
  'yes
  (if (> 5 3)
    'yes
    'no))

(simple-assert
  "if with nil condition"
  'no
  (if #f
    'yes
    'no))

(simple-assert "if with no else branch" 'ok (if (= 1 1) 'ok))

(assert-true "number is truthy" 42)

(assert-true "symbol is truthy" 'hello)

(assert-true "list is truthy" (list 1 2 3))

(assert-false "nil is falsy" #f)

(simple-assert
  "nested if"
  'inner
  (if #t
    (if #t
      'inner
      'outer)
    'fallback))

(print "")

(print "--- Testing Event Constructors ---")

(define test-event
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan))))

(assert-true
  "event.valid? returns true for valid event"
  (event.valid? test-event))

(assert-false
  "event.valid? returns false for invalid event"
  (event.valid? (list 'not-event)))

(simple-assert
  "event.type returns correct type"
  'death
  (event.type test-event))

(assert-true
  "event has correct structure"
  (> (length test-event) 5))

(define original-length
  (length test-event))

(event.get test-event ':person)

(simple-assert
  "event unchanged after access"
  original-length
  (length test-event))

(print "")

(print "--- Testing Fact Constructors ---")

(define test-fact
  (fact.make
    'heir-share
    (list 'Pedro 'Maria)
    (list ':share 0.5 ':basis 'S774)))

(assert-true
  "fact.valid? returns true for valid fact"
  (fact.valid? test-fact))

(assert-false
  "fact.valid? returns false for invalid fact"
  (fact.valid? (list 'not-fact)))

(simple-assert
  "fact.pred returns predicate"
  'heir-share
  (fact.pred test-fact))

(simple-assert
  "fact.args returns arguments"
  (list 'Pedro 'Maria)
  (fact.args test-fact))

(assert-true
  "fact has correct structure"
  (> (length test-fact) 6))

(define original-fact-length
  (length test-fact))

(fact.get test-fact ':share)

(simple-assert
  "fact unchanged after access"
  original-fact-length
  (length test-fact))

(print "")

(print "--- Testing Statute Objects & Evaluation ---")

(define test-statute
  (statute.make 'TEST "Test Statute" (list)))

(simple-assert
  "statute.id returns ID"
  'TEST
  (statute.id test-statute))

(simple-assert
  "statute.title returns title"
  "Test Statute"
  (statute.title test-statute))

(simple-assert
  "statute.weight initial value"
  0
  (statute.weight test-statute))

(define weighted-statute
  (statute.with-weight test-statute 5))

(simple-assert
  "statute.with-weight creates new statute"
  5
  (statute.weight weighted-statute))

(simple-assert
  "original statute unchanged"
  0
  (statute.weight test-statute))

(define s774-statute
  (statute.make 'S774 "Intestate Inheritance" (list)))

(define test-event-3-heirs
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan 'Jose))))

(define eval-result
  (s774.eval s774-statute test-event-3-heirs))

(define facts
  (first eval-result))

(define updated-statute
  (second eval-result))

(simple-assert "s774.eval returns facts" 3 (length facts))

(simple-assert
  "s774.eval increments weight"
  1
  (statute.weight updated-statute))

(define empty-event
  (event.make
    'death
    (list ':person 'Pedro ':flags (list 'no-will) ':heirs (list))))

(define empty-result
  (s774.eval s774-statute empty-event))

(simple-assert
  "s774.eval with no heirs returns empty facts"
  0
  (length (first empty-result)))

(simple-assert
  "s774.eval with no heirs still increments weight"
  1
  (statute.weight (second empty-result)))

(print "")

(print "--- Testing Registry Application ---")

(define test-statute-reg
  (statute.make 'S774 "Test Statute" (list)))

(define test-registry
  (list test-statute-reg))

(define test-event-2-heirs
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan))))

(define registry-result
  (registry.apply test-registry test-event-2-heirs))

(define all-facts
  (first registry-result))

(define updated-registry
  (second registry-result))

(simple-assert
  "registry.apply returns correct fact count"
  2
  (length all-facts))

(simple-assert
  "registry.apply increments statute weight"
  1
  (statute.weight (first updated-registry)))

(simple-assert
  "original registry unchanged"
  0
  (statute.weight (first test-registry)))

(define second-result
  (registry.apply updated-registry test-event-2-heirs))

(simple-assert
  "second application increments weight again"
  2
  (statute.weight (first (second second-result))))

(print "")

(print "--- Testing S774 Demo Intestate Rule ---")

(define event-3-heirs
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan 'Jose))))

(define registry-s774
  (list (statute.make 'S774 "Intestate" (list))))

(define result-3
  (registry.apply registry-s774 event-3-heirs))

(define facts-3
  (first result-3))

(simple-assert
  "S774 with 3 heirs produces 3 facts"
  3
  (length facts-3))

(if
  (> (length facts-3) 0)
  (simple-assert
  "S774 3-heir share calculation"
  (/ 1 3)
  (nth (nth (first facts-3) 6) 1)))

(define event-5-heirs
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan 'Jose 'Ana 'Luis))))

(define result-5
  (registry.apply registry-s774 event-5-heirs))

(define facts-5
  (first result-5))

(simple-assert
  "S774 with 5 heirs produces 5 facts"
  5
  (length facts-5))

(define event-1-heir
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria))))

(define result-1
  (registry.apply registry-s774 event-1-heir))

(define facts-1
  (first result-1))

(simple-assert
  "S774 with 1 heir produces 1 fact"
  1
  (length facts-1))

(define event-0-heirs
  (event.make
    'death
    (list ':person 'Pedro ':flags (list 'no-will) ':heirs (list))))

(define result-0
  (registry.apply registry-s774 event-0-heirs))

(define facts-0
  (first result-0))

(simple-assert
  "S774 with 0 heirs produces 0 facts"
  0
  (length facts-0))

(simple-assert
  "S774 with 0 heirs still increments weight"
  1
  (statute.weight (first (second result-0))))

(print "")

(print "--- Testing Utility Functions ---")

(simple-assert "first function" 'a (first (list 'a 'b 'c)))

(simple-assert "second function" 'b (second (list 'a 'b 'c)))

(simple-assert
  "append2 function"
  (list 1 2 3 4)
  (append2 (list 1 2) (list 3 4)))

(simple-assert
  "append2 with empty first"
  (list 3 4)
  (append2 (list) (list 3 4)))

(simple-assert
  "append2 with empty second"
  (list 1 2)
  (append2 (list 1 2) (list)))

(define double
  (lambda (x)
    (* x 2)))

(simple-assert
  "map2 function"
  (list 2 4 6)
  (map2 double (list 1 2 3)))

(simple-assert
  "map2 with empty list"
  (list)
  (map2 double (list)))

(assert-true
  "contains? finds element"
  (contains? (list 'a 'b 'c) 'b))

(assert-false
  "contains? missing element"
  (contains? (list 'a 'b 'c) 'd))

(assert-false "contains? empty list" (contains? (list) 'a))

(print "")

(print-summary)

(print "=== Test Suite Complete ===")

(print "")

(print
  "All tests implemented in pure LISP with no host dependencies.")

(print "Coverage includes:")

(print "- Conditionals and truthiness")

(print "- Event constructors and accessors")

(print "- Fact constructors and accessors")

(print "- Statute objects and evaluation")

(print "- Registry application system")

(print "- S774 intestate inheritance rule")

(print "- Utility functions (map2, append2, contains?, etc.)")

(print "")

(print "Test framework features:")

(print "- Pure LISP assertion library")

(print "- Workarounds for ASTNode comparison issues")

(print "- Immutability verification")

(print "- Comprehensive edge case coverage")

(print "- Clean pass/fail reporting")
