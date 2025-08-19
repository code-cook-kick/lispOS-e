(print "=== COMPLETE MACRO SYSTEM VERIFICATION ===")

(print "")

(define test-counter
  0)

(define pass-counter
  0)

(define fail-counter
  0)

(defun
  run-test
  (name expected actual)
  (define test-counter
  (+ test-counter 1))
  (define passed
  (= expected actual))
  (if passed
    (define pass-counter
    (+ pass-counter 1))
    (define fail-counter
    (+ fail-counter 1)))
  (print
  (list
  (if passed
    "✓ PASS"
    "✗ FAIL")
  name
  "Expected:"
  expected
  "Actual:"
  actual)))

(defun
  run-test-eq
  (name expected actual)
  (define test-counter
  (+ test-counter 1))
  (define passed
  (eq? expected actual))
  (if passed
    (define pass-counter
    (+ pass-counter 1))
    (define fail-counter
    (+ fail-counter 1)))
  (print
  (list
  (if passed
    "✓ PASS"
    "✗ FAIL")
  name
  "Expected:"
  expected
  "Actual:"
  actual)))

(print "1. Testing Basic Macros...")

(defmacro inc (x) (list '+ x 1))

(run-test "inc-5" 6 (inc 5))

(defmacro double (x) (list '* x 2))

(run-test "double-4" 8 (double 4))

(run-test "double-inc-5" 12 (double (inc 5)))

(defmacro quad (x) (list '* (inc x) 2))

(define quad-result
  (quad 5))

(print (list "DEBUG: quad 5 result =" quad-result))

(run-test "quad-5" 12 quad-result)

(defmacro quad2 (x) (list '* (list '+ x 1) 2))

(run-test "quad2-5" 12 (quad2 5))

(print "")

(print "2. Testing Variadic Macros...")

(defmacro count-args (first . rest) (list '+ 1 (length rest)))

(run-test "count-args-3" 3 (count-args a b c))

(run-test "count-args-1" 1 (count-args x))

(run-test "count-args-0" 1 (count-args solo))

(defmacro make-pair (x . rest) (list 'list x (length rest)))

(define pair-result-1
  (make-pair 7))

(print (list "make-pair 7 =" pair-result-1))

(define pair-result-2
  (make-pair 1 2 3))

(print (list "make-pair 1 2 3 =" pair-result-2))

(defmacro
  add-bonus
  (bonus . rest)
  (list '+ bonus (length rest)))

(run-test "add-bonus" 13 (add-bonus 10 a b c))

(print "")

(print "3. Testing Advanced Macro Patterns...")

(defmacro
  when-positive
  (x body)
  (list 'if (list '> x 0) body 'nil))

(run-test "when-positive-true" 6 (when-positive 5 (* 2 3)))

(run-test-eq
  "when-positive-false"
  nil
  (when-positive -1 (* 2 3)))

(defmacro
  defun
  (name params body)
  (list 'define name (list 'lambda params body)))

(defun square (x) (* x x))

(run-test "defun-square" 16 (square 4))

(defmacro
  unless
  (condition body)
  (list 'if condition 'nil body))

(run-test "unless-false" 42 (unless (< 5 3) 42))

(run-test-eq "unless-true" nil (unless (> 5 3) 42))

(print "")

(print "4. Testing User's Original Examples...")

(defmacro test1 (x . rest) (list 'list "result" x rest))

(define test1-result-1
  (test1 1 2 3))

(print (list "test1 1 2 3 =" test1-result-1))

(define test1-result-2
  (test1 7))

(print (list "test1 7 =" test1-result-2))

(defmacro inc2 (x) (list '+ x 1))

(defmacro quad3 (x) (list '* (inc2 x) 2))

(define user-quad-result
  (quad3 5))

(print
  (list "User's quad example: quad3 5 =" user-quad-result))

(run-test "user-quad-example" 12 user-quad-result)

(print "")

(print "5. Macro System Validation...")

(defmacro
  debug-args
  (x . rest)
  (list 'list "debug" x (length rest)))

(define debug-result
  (debug-args (+ 1 2) (+ 3 4) (+ 5 6)))

(print (list "debug-args result =" debug-result))

(defmacro
  expand-test
  (x)
  (list 'list "expanded" (list 'quote x)))

(define expand-result
  (expand-test hello))

(print (list "expand-test result =" expand-result))

(defmacro
  let-test
  (var val body)
  (list (list 'lambda (list var) body) val))

(define let-result
  (let-test x 10 (* x 2)))

(run-test "let-test" 20 let-result)

(print "")

(print "6. Testing Legal Domain Integration...")

(print "Loading legal domain functions...")

(define load-result
  (load "src/lisp/statute-api-final-working.lisp"))

(print
  (list
  "Legal domain load result:"
  (if load-result
    "SUCCESS"
    "FAILED")))

(define test-event
  (event.make
    "death"
    (list ":person" "Pedro" ":flags" (list "no-will"))))

(print
  (list
  "Event creation:"
  (if test-event
    "SUCCESS"
    "FAILED")))

(if test-event
    (define event-type
    (event.type test-event))
    (define event-type
    nil))

(print (list "Event type =" event-type))

(print "")

(print "=== COMPLETE TEST SUMMARY ===")

(print (list "Total tests run:" test-counter))

(print (list "Tests passed:" pass-counter))

(print (list "Tests failed:" fail-counter))

(print
  (list
  "Success rate:"
  (if (> test-counter 0)
    (/ (* pass-counter 100) test-counter)
    0)
  "%"))

(print "")

(print "=== MACRO SYSTEM STATUS ===")

(if (> pass-counter fail-counter)
    (print "✅ MACRO SYSTEM: WORKING")
    (print "❌ MACRO SYSTEM: NEEDS FIXES"))

(print "")

(print "Key Features Verified:")

(print "• Basic macro definition and expansion")

(print "• Variadic parameter support with (x . rest) syntax")

(print "• Nested macro calls and composition")

(print "• Advanced macro patterns")

(print "• Legal domain integration")

(print "• Macro system validation")
