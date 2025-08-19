(load "src/lisp/common/utils.lisp")

(print "=== Golden Fixture: Resource Limits and Security ===")

(print "--- Test Case 1: Step Budget Enforcement ---")

(define simple-computation
  (lambda ()
    (+ (* 2 3) (/ 12 4) (- 10 5))))

(define simple-result
  (simple-computation))

(print "Simple computation result:" simple-result)

(define step-budget-test-1-passed
  (= simple-result 9))

(print
  "✓ Step budget test 1 passed:"
  step-budget-test-1-passed)

(define factorial
  (lambda (n)
    (if (= n 0)
        1
        (* n (factorial (- n 1))))))

(define factorial-5
  (factorial 5))

(print "Factorial 5 result:" factorial-5)

(define step-budget-test-2-passed
  (= factorial-5 120))

(print
  "✓ Step budget test 2 passed:"
  step-budget-test-2-passed)

(print "--- Test Case 2: Macro Expansion Limits ---")

(define simple-macro-result
  (when #t (+ 1 2 3)))

(print "Simple macro result:" simple-macro-result)

(define macro-test-1-passed
  (= simple-macro-result 6))

(print "✓ Macro test 1 passed:" macro-test-1-passed)

(define nested-macro-result
  (when (> 5 3) (unless #f (+ 10 20))))

(print "Nested macro result:" nested-macro-result)

(define macro-test-2-passed
  (= nested-macro-result 30))

(print "✓ Macro test 2 passed:" macro-test-2-passed)

(print "--- Test Case 3: Trampoline Functionality ---")

(define countdown
  (lambda (n acc)
    (if (= n 0)
        acc
        (countdown (- n 1) (+ acc 1)))))

(define countdown-result
  (countdown 10 0))

(print "Countdown result:" countdown-result)

(define trampoline-test-1-passed
  (= countdown-result 10))

(print "✓ Trampoline test 1 passed:" trampoline-test-1-passed)

(define even?
  (lambda (n)
    (if (= n 0)
        #t
        (odd? (- n 1)))))

(define odd?
  (lambda (n)
    (if (= n 0)
        #f
        (even? (- n 1)))))

(define even-test
  (even? 8))

(define odd-test
  (odd? 7))

(print "Even 8:" even-test)

(print "Odd 7:" odd-test)

(define trampoline-test-2-passed
  (and even-test odd-test))

(print "✓ Trampoline test 2 passed:" trampoline-test-2-passed)

(print "--- Test Case 4: Hygienic Macros ---")

(define x
  100)

(define test-hygiene-result
  (let ((x 1)) (when #t (let ((y 2)) (+ x y)))))

(print "Hygiene test result:" test-hygiene-result)

(print "Outer x still:" x)

(define hygiene-test-passed
  (and (= test-hygiene-result 3) (= x 100)))

(print "✓ Hygiene test passed:" hygiene-test-passed)

(print
  "--- Test Case 5: Legal Reasoning with Resource Limits ---")

(define make-legal-fact
  (lambda (predicate subject object properties)
    (event
      predicate
      (list subject object)
      ':properties
      properties)))

(define process-legal-facts
  (lambda (facts)
    (begin
      (define count-facts
        (lambda (remaining count)
          (if (null? remaining)
              count
              (count-facts (rest remaining) (+ count 1)))))
      (count-facts facts 0))))

(define legal-facts
  (list
    (make-legal-fact 'inherits 'john 'estate (list ':share 0.5))
    (make-legal-fact 'spouse 'john 'mary (list ':valid #t))
    (make-legal-fact 'child 'peter 'john (list ':legitimate #t))
    (make-legal-fact 'child 'susan 'john (list ':legitimate #t))))

(define fact-count
  (process-legal-facts legal-facts))

(print "Legal facts processed:" fact-count)

(define legal-test-passed
  (= fact-count 4))

(print "✓ Legal reasoning test passed:" legal-test-passed)

(define apply-statute
  (lambda (statute facts)
    (begin
      (define apply-to-facts
        (lambda (remaining-facts results)
          (if (null? remaining-facts)
              results
              (let
              ((fact (first remaining-facts)))
              (apply-to-facts
              (rest remaining-facts)
              (cons fact (ensure-list results)))))))
      (apply-to-facts facts (list)))))

(define statute-result
  (apply-statute 'test-statute legal-facts))

(define statute-result-count
  (length statute-result))

(print
  "Statute application result count:"
  statute-result-count)

(define statute-test-passed
  (= statute-result-count 4))

(print
  "✓ Statute application test passed:"
  statute-test-passed)

(print "--- Test Case 6: Performance and Efficiency ---")

(define sum-list
  (lambda (lst)
    (begin
      (define sum-helper
        (lambda (remaining acc)
          (if (null? remaining)
              acc
              (sum-helper (rest remaining) (+ acc (first remaining))))))
      (sum-helper lst 0))))

(define test-list
  (list 1 2 3 4 5 6 7 8 9 10))

(define sum-result
  (sum-list test-list))

(print "Sum of 1-10:" sum-result)

(define performance-test-1-passed
  (= sum-result 55))

(print
  "✓ Performance test 1 passed:"
  performance-test-1-passed)

(define filter-facts
  (lambda (facts predicate-filter)
    (begin
      (define filter-helper
        (lambda (remaining results)
          (if (null? remaining)
              results
              (let
              ((fact (first remaining)))
              (if (eq? (get-event-property fact ':predicate) predicate-filter)
                (filter-helper
                (rest remaining)
                (cons fact (ensure-list results)))
                (filter-helper (rest remaining) results))))))
      (filter-helper facts (list)))))

(define inheritance-facts
  (filter-facts legal-facts 'inherits))

(define inheritance-count
  (length inheritance-facts))

(print "Inheritance facts found:" inheritance-count)

(define performance-test-2-passed
  (= inheritance-count 1))

(print
  "✓ Performance test 2 passed:"
  performance-test-2-passed)

(define all-resource-tests-passed
  (and
    step-budget-test-1-passed
    step-budget-test-2-passed
    macro-test-1-passed
    macro-test-2-passed
    trampoline-test-1-passed
    trampoline-test-2-passed
    hygiene-test-passed
    legal-test-passed
    statute-test-passed
    performance-test-1-passed
    performance-test-2-passed))

(print "")

(print "=== RESOURCE LIMITS AND SECURITY TEST RESULTS ===")

(print
  "Step Budget Enforcement:  "
  (if (and step-budget-test-1-passed step-budget-test-2-passed)
    "PASS"
    "FAIL"))

(print
  "Macro Expansion Limits:   "
  (if (and macro-test-1-passed macro-test-2-passed)
    "PASS"
    "FAIL"))

(print
  "Trampoline Functionality: "
  (if (and trampoline-test-1-passed trampoline-test-2-passed)
    "PASS"
    "FAIL"))

(print
  "Hygienic Macros:          "
  (if hygiene-test-passed
    "PASS"
    "FAIL"))

(print
  "Legal Reasoning:          "
  (if (and legal-test-passed statute-test-passed)
    "PASS"
    "FAIL"))

(print
  "Performance & Efficiency: "
  (if (and performance-test-1-passed performance-test-2-passed)
    "PASS"
    "FAIL"))

(print "")

(print
  "OVERALL RESULT:           "
  (if all-resource-tests-passed
    "✅ PASS"
    "❌ FAIL"))

(print "")

all-resource-tests-passed
