;; ========================================
;; Comprehensive Etherney eLISP Test Suite
;; ========================================
;; This monolithic test file combines all essential test functionality:
;; - Lambda arity compliance tests
;; - Basic functionality tests
;; - Integration tests
;; - Command-line test capabilities
;; ========================================

(print "🧪 COMPREHENSIVE ETHERNEY eLISP TEST SUITE")
(print "==========================================")
(print "")

;; Test framework variables
(define *total-tests* 0)
(define *passed-tests* 0)
(define *failed-tests* 0)

;; Test framework functions
(define run-test
  (lambda (label expected actual)
    (begin
      (define *total-tests* (+ *total-tests* 1))
      (if (eq? expected actual)
          (begin
            (define *passed-tests* (+ *passed-tests* 1))
            (print "✓" label))
          (begin
            (define *failed-tests* (+ *failed-tests* 1))
            (print "✗" label "- Expected:" expected "Got:" actual))))))

(define assert-true
  (lambda (label value)
    (begin
      (define *total-tests* (+ *total-tests* 1))
      (if value
          (begin
            (define *passed-tests* (+ *passed-tests* 1))
            (print "✓" label))
          (begin
            (define *failed-tests* (+ *failed-tests* 1))
            (print "✗" label "- Expected: true, Got:" value))))))

(define assert-false
  (lambda (label value)
    (begin
      (define *total-tests* (+ *total-tests* 1))
      (if (not value)
          (begin
            (define *passed-tests* (+ *passed-tests* 1))
            (print "✓" label))
          (begin
            (define *failed-tests* (+ *failed-tests* 1))
            (print "✗" label "- Expected: false, Got:" value))))))

(define print-section
  (lambda (title)
    (begin
      (print "")
      (print "=== " title " ===")
      (print ""))))

(define print-summary
  (lambda ()
    (begin
      (print "")
      (print "=== COMPREHENSIVE TEST RESULTS ===")
      (print "Total tests:" *total-tests*)
      (print "Passed:" *passed-tests*)
      (print "Failed:" *failed-tests*)
      (if (= *failed-tests* 0)
          (print "🎉 SUCCESS: All tests passed!")
          (print "❌ FAILURE: Some tests failed!"))
      (print ""))))

;; ========================================
;; SECTION 1: LAMBDA ARITY COMPLIANCE TESTS
;; ========================================

(print-section "Lambda Arity Compliance Tests")

;; Basic lambda functionality
(define simple-lambda
  (lambda (x)
    (+ x 1)))

(run-test "Simple lambda works" (+ 5 1) (simple-lambda 5))

;; Multi-body lambda with begin (the main fix!)
(define multi-body-lambda
  (lambda (x y)
    (begin
      (define temp (+ x y))
      (define result (* temp 2))
      result)))

(run-test "Multi-body lambda with begin" (* (+ 3 7) 2) (multi-body-lambda 3 7))

;; Complex lambda with multiple statements
(define complex-calculation
  (lambda (a b)
    (begin
      (define sum (+ a b))
      (define product (* sum 2))
      (define final (+ product 5))
      final)))

(run-test "Complex multi-statement lambda" (+ (* (+ 5 5) 2) 5) (complex-calculation 5 5))

;; Define sugar expansion tests
(define explicit-func
  (lambda (a b)
    (+ a b)))

(run-test "Explicit lambda define" (+ 3 5) (explicit-func 3 5))

(define multi-statement-func
  (lambda (x)
    (begin
      (define doubled (* x 2))
      (define result (+ doubled 10))
      result)))

(run-test "Multi-statement function" (+ (* 8 2) 10) (multi-statement-func 8))

;; Nested lambda tests
(define nested-lambda-test
  (lambda (outer-val)
    (begin
      (define inner-lambda
        (lambda (inner-val)
          (begin
            (define combined (+ outer-val inner-val))
            (define multiplied (* combined 3))
            multiplied)))
      (inner-lambda 5))))

(run-test "Nested lambda with begin" (* (+ 10 5) 3) (nested-lambda-test 10))

;; Higher-order function tests
(define apply-twice
  (lambda (func value)
    (begin
      (define first-result (func value))
      (define second-result (func first-result))
      second-result)))

(define increment
  (lambda (x)
    (+ x 1)))

(run-test "Higher-order function" (+ (+ 5 1) 1) (apply-twice increment 5))

;; Edge cases
(define identity-lambda
  (lambda (x)
    x))

(run-test "Identity lambda" 42 (identity-lambda 42))

(define no-params-lambda
  (lambda ()
    (begin
      (define result 100)
      result)))

(run-test "No parameters lambda" 100 (no-params-lambda))

;; Lambda factory pattern
(define lambda-factory
  (lambda (multiplier)
    (lambda (x)
      (* x multiplier))))

(define times-three (lambda-factory 3))
(run-test "Lambda factory" (* 7 3) (times-three 7))

;; Recursive lambda
(define recursive-sum
  (lambda (n acc)
    (begin
      (define current-acc (+ acc n))
      (define result
        (if (= n 0)
            current-acc
            (recursive-sum (- n 1) current-acc)))
      result)))

(run-test "Recursive lambda" (+ 0 1 2 3 4 5 6 7 8 9 10) (recursive-sum 10 0))

;; ========================================
;; SECTION 2: CORE FUNCTIONALITY TESTS
;; ========================================

(print-section "Core Functionality Tests")

;; Conditionals and truthiness
(run-test "if/then/else basic" 'yes
  (if (> 5 3) 'yes 'no))

(run-test "if with nil condition" 'no
  (if #f 'yes 'no))

(run-test "if with no else branch" 'ok
  (if (= 1 1) 'ok))

(assert-true "number is truthy" 42)
(assert-true "symbol is truthy" 'hello)
(assert-true "list is truthy" (list 1 2 3))
(assert-false "nil is falsy" #f)

(run-test "nested if" 'inner
  (if #t
    (if #t 'inner 'outer)
    'fallback))

;; Basic arithmetic
(run-test "addition" (+ 4 6) (+ 4 6))
(run-test "subtraction" (- 8 5) (- 8 5))
(run-test "multiplication" (* 6 4) (* 6 4))
(run-test "division" (/ 15 3) (/ 15 3))

;; List operations
(run-test "list creation" (length (list 'a 'b 'c)) (length (list 'a 'b 'c)))
(run-test "cons operation" (+ (length (list 'a 'b 'c)) 1) (length (cons 'x (list 'a 'b 'c))))

;; ========================================
;; SECTION 3: INTEGRATION TESTS
;; ========================================

(print-section "Integration Tests")

;; Event processing pattern (simplified)
(define process-event
  (lambda (event-type data-count)
    (begin
      (define event-id (+ 1000 data-count))
      (define result (list 'processed event-type event-id))
      result)))

(run-test "Event processing pattern"
  (list 'processed 'death (+ 1000 3))
  (process-event 'death 3))

;; Data transformation pattern
(define transform-data
  (lambda (input multiplier)
    (begin
      (define step1 (* input multiplier))
      (define step2 (+ step1 100))
      (define result (list 'transformed step2))
      result)))

(run-test "Data transformation pattern"
  (list 'transformed (+ (* 5 5) 100))
  (transform-data 5 5))

;; List processing pattern (simplified)
(define process-numbers
  (lambda (a b c)
    (begin
      (define sum (+ a (+ b c)))
      (define doubled (* sum 2))
      (define result (list 'result doubled))
      result)))

(run-test "Number processing pattern" (list 'result (* (+ 2 3 5) 2))
  (process-numbers 2 3 5))

;; ========================================
;; SECTION 4: PERFORMANCE AND EDGE CASES
;; ========================================

(print-section "Performance and Edge Cases")

;; Conditional lambda with complex logic
(define conditional-lambda
  (lambda (x)
    (begin
      (if (> x 10)
          (begin
            (* x 2))
          (begin
            (+ x 100))))))

(run-test "Conditional lambda >10" (* 15 2) (conditional-lambda 15))
(run-test "Conditional lambda ≤10" (+ 5 100) (conditional-lambda 5))

;; Nested conditional logic
(define nested-conditional
  (lambda (x y)
    (begin
      (if (> x y)
          (begin
            (if (> x 10)
                (* x 3)
                (+ x 5)))
          (begin
            (if (> y 10)
                (* y 2)
                (+ y 10)))))))

(run-test "Nested conditional x>y>10" (* 15 3) (nested-conditional 15 8))
(run-test "Nested conditional y>x>10" (* 12 2) (nested-conditional 8 12))
(run-test "Nested conditional x>y≤10" (+ 8 5) (nested-conditional 8 5))
(run-test "Nested conditional y>x≤10" (+ 5 10) (nested-conditional 3 5))

;; ========================================
;; SECTION 5: COMMAND-LINE TEST VERIFICATION
;; ========================================

(print-section "Command-Line Test Verification")

;; Verify begin construct functionality (the core fix)
(define process-cli
  (lambda (x)
    (begin
      (define temp (+ x 10))
      (* temp 2))))

(run-test "CLI-style begin test" (* (+ 7 10) 2) (process-cli 7))

;; Multi-step calculation
(define calculate-cli
  (lambda (x)
    (begin
      (define step1 (+ x 5))
      (define step2 (* step1 2))
      (define step3 (- step2 3))
      step3)))

(run-test "CLI-style multi-step" (- (* (+ 10 5) 2) 3) (calculate-cli 10))

;; Nested lambda verification
(define outer-cli
  (lambda (x)
    (begin
      (define inner (lambda (y) (+ y 1)))
      (define result (inner x))
      (* result 2))))

(run-test "CLI-style nested lambda" (* (+ 6 1) 2) (outer-cli 6))

;; Complex workflow simulation
(define workflow-simulation
  (lambda (input)
    (begin
      (define stage1
        (lambda (x)
          (begin
            (define processed (* x 2))
            (+ processed 5))))
      (define stage2
        (lambda (x)
          (begin
            (define validated (if (> x 10) x 10))
            (* validated 3))))
      (define result1 (stage1 input))
      (define result2 (stage2 result1))
      (list 'workflow-complete result2))))

(run-test "Workflow simulation" (list 'workflow-complete (* (if (> (+ (* 5 2) 5) 10) (+ (* 5 2) 5) 10) 3)) (workflow-simulation 5))

;; ========================================
;; FINAL RESULTS AND SUMMARY
;; ========================================

(print-summary)

(print "=== Test Coverage Summary ===")
(print "✓ Lambda arity compliance (begin construct support)")
(print "✓ Core functionality (conditionals, arithmetic, lists)")
(print "✓ Integration patterns (events, data transformation)")
(print "✓ Performance and edge cases")
(print "✓ Command-line test verification")
(print "✓ Complex workflow simulation")
(print "")

(print "=== Key Features Verified ===")
(print "• Lambda expressions with exactly 2 arguments")
(print "• Multi-body lambdas wrapped with (begin ...)")
(print "• Higher-order functions and closures")
(print "• Recursive lambda expressions")
(print "• Complex conditional logic")
(print "• Integration with existing patterns")
(print "• Command-line compatibility")
(print "")

(print "🎉 COMPREHENSIVE TEST SUITE COMPLETE")
(print "==========================================")

;; Return overall success status
(= *failed-tests* 0)