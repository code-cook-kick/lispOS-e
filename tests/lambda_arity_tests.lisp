(print "=== Lambda Arity Rule Tests ===")

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

(print "Testing lambda arity compliance...")

(define simple-lambda
  (lambda (x)
    (+ x 1)))

(run-test "Simple lambda works" 6 (simple-lambda 5))

(define multi-body-lambda
  (lambda (x y)
    (begin
      (define temp
        (+ x y))
      (define result
        (* temp 2))
      result)))

(run-test
  "Multi-body lambda with begin"
  20
  (multi-body-lambda 3 7))

(define complex-lambda
  (lambda (items)
    (begin
      (define count
        (length items))
      (define sum
        (if (> count 0)
            (+
            (first items)
            (if (> count 1)
              (second items)
              0))
            0))
      (define average
        (if (> count 0)
            (/ sum count)
            0))
      average)))

(run-test
  "Complex multi-statement lambda"
  7
  (complex-lambda ' (5 9)))

(print "")

(print "Testing define sugar expansion...")

(define explicit-func
  (lambda (a b)
    (+ a b)))

(run-test "Explicit lambda define" 8 (explicit-func 3 5))

(define multi-statement-func
  (lambda (x)
    (begin
      (define doubled
        (* x 2))
      (define result
        (+ doubled 10))
      result)))

(run-test
  "Multi-statement function"
  26
  (multi-statement-func 8))

(print "")

(print "Testing macro arguments with begin...")

(define when-then
  (lambda (condition then-lambda)
    (if condition
        (then-lambda)
        #f)))

(define test-condition
  #t)

(define test-result
  (when-then
    test-condition
    (lambda ()
    (begin
      (define x
        10)
      (define y
        20)
      (+ x y)))))

(run-test "Macro with multi-body lambda" 30 test-result)

(define nested-lambda-test
  (lambda (outer-val)
    (begin
      (define inner-lambda
        (lambda (inner-val)
          (begin
            (define combined
              (+ outer-val inner-val))
            (define multiplied
              (* combined 3))
            multiplied)))
      (inner-lambda 5))))

(run-test
  "Nested lambda with begin"
  45
  (nested-lambda-test 10))

(print "")

(print "Testing edge cases...")

(define identity-lambda
  (lambda (x)
    x))

(run-test "Identity lambda" 42 (identity-lambda 42))

(define no-params-lambda
  (lambda ()
    (begin
      (define result
        100)
      result)))

(run-test "No parameters lambda" 100 (no-params-lambda))

(define lambda-factory
  (lambda (multiplier)
    (lambda (x)
      (* x multiplier))))

(define times-three
  (lambda-factory 3))

(run-test "Lambda factory" 21 (times-three 7))

(print "")

(print "Testing common fixed patterns...")

(define process-event
  (lambda (event-type data)
    (begin
      (define event-id
        (+ 1000 (length data)))
      (define processed-data
        (list event-type event-id data))
      (define result
        (list 'processed processed-data))
      result)))

(run-test
  "Event processing pattern"
  '
  (processed (death 1003 (person spouse children)))
  (process-event 'death ' (person spouse children)))

(define generate-fact
  (lambda (predicate args properties)
    (begin
      (define fact-id
        (+ 2000 (length args)))
      (define timestamp
        "2024-01-01")
      (define complete-fact
        (list 'fact predicate args properties fact-id timestamp))
      complete-fact)))

(run-test
  "Fact generation pattern"
  '
  (fact heir-share (Pedro Maria) (share 0.5) 2002 "2024-01-01")
  (generate-fact 'heir-share ' (Pedro Maria) ' (share 0.5)))

(define process-list
  (lambda (items operation)
    (begin
      (define filtered
        (if (> (length items) 0)
            items
            '))
      (define mapped
        (map operation filtered))
      (define result
        (if (> (length mapped) 0)
            mapped
            '))
      result)))

(define double
  (lambda (x)
    (* x 2)))

(run-test
  "List processing pattern"
  '
  (2 4 6 8)
  (process-list ' (1 2 3 4) double))

(print "")

(print "Testing integration patterns...")

(define evaluate-statute
  (lambda (statute event)
    (begin
      (define applicable
        (eq? (first statute) 'applicable))
      (define result
        (if applicable
            (list 'facts (list 'generated-fact event))
            (list 'no-facts)))
      result)))

(run-test
  "Statute evaluation"
  '
  (facts (generated-fact test-event))
  (evaluate-statute ' (applicable rule) 'test-event))

(define process-registry
  (lambda (registry event)
    (begin
      (define count
        (length registry))
      (define processed-count
        0)
      (define results
        (if (> count 0)
            (list 'processed count event)
            (list 'empty)))
      results)))

(run-test
  "Registry processing"
  '
  (processed 3 death-event)
  (process-registry ' (s1 s2 s3) 'death-event))

(print "")

(print "Testing performance patterns...")

(define recursive-sum
  (lambda (n acc)
    (begin
      (define current-acc
        (+ acc n))
      (define result
        (if (= n 0)
            current-acc
            (recursive-sum (- n 1) current-acc)))
      result)))

(run-test "Recursive lambda" 55 (recursive-sum 10 0))

(define apply-twice
  (lambda (func value)
    (begin
      (define first-result
        (func value))
      (define second-result
        (func first-result))
      second-result)))

(define increment
  (lambda (x)
    (+ x 1)))

(run-test "Higher-order function" 7 (apply-twice increment 5))

(print "")

(print "=== TEST RESULTS ===")

(print "Total tests:" total-tests)

(print "Passed:" passed-tests)

(print "Failed:" failed-tests)

(if (= failed-tests 0)
    (print "SUCCESS: All lambda arity tests passed!")
    (print "FAILURE: Some tests failed!"))

(print "")

(print "=== Lambda Arity Tests Complete ===")

(= failed-tests 0)
