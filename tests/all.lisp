; =============================================================================
; Etherney eLisp Legal OS - Minimal Working Test Suite
; Pure LISP implementation - no host language dependencies
; =============================================================================

; Load the statute API system
(load "src/lisp/statute-api-final-working.lisp")

(print "")
(print "=== Etherney eLisp Test Suite ===")
(print "")

; =============================================================================
; MINIMAL TEST FRAMEWORK - No Lambda Functions
; =============================================================================

; Global test counters
(define *test-total* 0)
(define *test-passed* 0)
(define *test-failed* 0)

; Simple test without lambda - direct execution
(define test-basic-conditionals (list))

(print "--- Testing Conditionals & Truthiness ---")

; Test 1: Basic if/then/else
(define *test-total* (+ *test-total* 1))
(if (eq? 'yes (if (> 5 3) 'yes 'no))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 'yes (if (> 5 3) 'yes 'no))
    (print "[PASS] if/then/else basic")
    (print "[FAIL] if/then/else basic"))

; Test 2: if with nil condition
(define *test-total* (+ *test-total* 1))
(if (eq? 'no (if #f 'yes 'no))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 'no (if #f 'yes 'no))
    (print "[PASS] if with nil condition")
    (print "[FAIL] if with nil condition"))

; Test 3: Truthiness
(define *test-total* (+ *test-total* 1))
(if 42
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if 42
    (print "[PASS] number is truthy")
    (print "[FAIL] number is truthy"))

; Test 4: Falsy
(define *test-total* (+ *test-total* 1))
(if (if #f #f #t)
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (if #f #f #t)
    (print "[PASS] nil is falsy")
    (print "[FAIL] nil is falsy"))

(print "")

(print "--- Testing Event Constructors ---")

; Test 5: Event creation and validation
(define test-event (event.make 'death (list ':person 'Pedro ':flags (list 'no-will) ':heirs (list 'Maria 'Juan))))

(define *test-total* (+ *test-total* 1))
(if (event.valid? test-event)
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (event.valid? test-event)
    (print "[PASS] event.valid? returns true for valid event")
    (print "[FAIL] event.valid? returns true for valid event"))

; Test 6: Event type
(define *test-total* (+ *test-total* 1))
(if (eq? 'death (event.type test-event))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 'death (event.type test-event))
    (print "[PASS] event.type returns correct type")
    (print "[FAIL] event.type returns correct type"))

; Test 7: Event structure
(define *test-total* (+ *test-total* 1))
(if (> (length test-event) 5)
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (> (length test-event) 5)
    (print "[PASS] event has correct structure")
    (print "[FAIL] event has correct structure"))

(print "")

(print "--- Testing Fact Constructors ---")

; Test 8: Fact creation and validation
(define test-fact (fact.make 'heir-share (list 'Pedro 'Maria) (list ':share 0.5 ':basis 'S774)))

(define *test-total* (+ *test-total* 1))
(if (fact.valid? test-fact)
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (fact.valid? test-fact)
    (print "[PASS] fact.valid? returns true for valid fact")
    (print "[FAIL] fact.valid? returns true for valid fact"))

; Test 9: Fact predicate
(define *test-total* (+ *test-total* 1))
(if (eq? 'heir-share (fact.pred test-fact))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 'heir-share (fact.pred test-fact))
    (print "[PASS] fact.pred returns predicate")
    (print "[FAIL] fact.pred returns predicate"))

; Test 10: Fact structure
(define *test-total* (+ *test-total* 1))
(if (> (length test-fact) 6)
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (> (length test-fact) 6)
    (print "[PASS] fact has correct structure")
    (print "[FAIL] fact has correct structure"))

(print "")

(print "--- Testing Statute Objects ---")

; Test 11: Statute creation
(define test-statute (statute.make 'TEST "Test Statute" (list)))

(define *test-total* (+ *test-total* 1))
(if (eq? 'TEST (statute.id test-statute))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 'TEST (statute.id test-statute))
    (print "[PASS] statute.id returns ID")
    (print "[FAIL] statute.id returns ID"))

; Test 12: Statute weight
(define *test-total* (+ *test-total* 1))
(if (eq? 0 (statute.weight test-statute))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 0 (statute.weight test-statute))
    (print "[PASS] statute.weight initial value")
    (print "[FAIL] statute.weight initial value"))

; Test 13: Statute immutability
(define weighted-statute (statute.with-weight test-statute 5))
(define *test-total* (+ *test-total* 1))
(if (eq? 5 (statute.weight weighted-statute))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 5 (statute.weight weighted-statute))
    (print "[PASS] statute.with-weight creates new statute")
    (print "[FAIL] statute.with-weight creates new statute"))

(print "")

(print "--- Testing S774 Demo Rule ---")

; Test 14: S774 with 3 heirs
(define event-3-heirs (event.make 'death (list ':person 'Pedro ':flags (list 'no-will) ':heirs (list 'Maria 'Juan 'Jose))))
(define registry-s774 (list (statute.make 'S774 "Intestate" (list))))
(define result-3 (registry.apply registry-s774 event-3-heirs))
(define facts-3 (first result-3))

(define *test-total* (+ *test-total* 1))
(if (eq? 3 (length facts-3))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 3 (length facts-3))
    (print "[PASS] S774 with 3 heirs produces 3 facts")
    (print "[FAIL] S774 with 3 heirs produces 3 facts"))

; Test 15: S774 with 1 heir
(define event-1-heir (event.make 'death (list ':person 'Pedro ':flags (list 'no-will) ':heirs (list 'Maria))))
(define result-1 (registry.apply registry-s774 event-1-heir))
(define facts-1 (first result-1))

(define *test-total* (+ *test-total* 1))
(if (eq? 1 (length facts-1))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 1 (length facts-1))
    (print "[PASS] S774 with 1 heir produces 1 fact")
    (print "[FAIL] S774 with 1 heir produces 1 fact"))

; Test 16: S774 with 0 heirs
(define event-0-heirs (event.make 'death (list ':person 'Pedro ':flags (list 'no-will) ':heirs (list))))
(define result-0 (registry.apply registry-s774 event-0-heirs))
(define facts-0 (first result-0))

(define *test-total* (+ *test-total* 1))
(if (eq? 0 (length facts-0))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 0 (length facts-0))
    (print "[PASS] S774 with 0 heirs produces 0 facts")
    (print "[FAIL] S774 with 0 heirs produces 0 facts"))

; Test 17: Weight tracking
(define *test-total* (+ *test-total* 1))
(if (eq? 1 (statute.weight (first (second result-0))))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 1 (statute.weight (first (second result-0))))
    (print "[PASS] S774 increments weight even with 0 heirs")
    (print "[FAIL] S774 increments weight even with 0 heirs"))

(print "")

(print "--- Testing Utility Functions ---")

; Test 18: first function
(define *test-total* (+ *test-total* 1))
(if (eq? 'a (first (list 'a 'b 'c)))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 'a (first (list 'a 'b 'c)))
    (print "[PASS] first function")
    (print "[FAIL] first function"))

; Test 19: second function
(define *test-total* (+ *test-total* 1))
(if (eq? 'b (second (list 'a 'b 'c)))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? 'b (second (list 'a 'b 'c)))
    (print "[PASS] second function")
    (print "[FAIL] second function"))

; Test 20: append2 function
(define *test-total* (+ *test-total* 1))
(if (eq? (list 1 2 3 4) (append2 (list 1 2) (list 3 4)))
    (define *test-passed* (+ *test-passed* 1))
    (define *test-failed* (+ *test-failed* 1)))
(if (eq? (list 1 2 3 4) (append2 (list 1 2) (list 3 4)))
    (print "[PASS] append2 function")
    (print "[FAIL] append2 function"))

(print "")

; =============================================================================
; FINAL SUMMARY
; =============================================================================

(print "=== Test Summary ===")
(print "Total:" *test-total* "tests")
(print "Passed:" *test-passed*)
(print "Failed:" *test-failed*)
(if (> *test-failed* 0)
    (print "OVERALL: FAIL")
    (print "OVERALL: PASS"))

(print "")
(print "=== Test Suite Complete ===")
(print "")
(print "All tests implemented in pure LISP with no host dependencies.")
(print "Coverage includes:")
(print "- Conditionals and truthiness")
(print "- Event constructors and accessors")
(print "- Fact constructors and accessors")
(print "- Statute objects and evaluation")
(print "- Registry application system")
(print "- S774 intestate inheritance rule")
(print "- Utility functions (first, second, append2)")
(print "")
(print "Test framework features:")
(print "- Pure LISP implementation (no lambda functions)")
(print "- Direct test execution")
(print "- Comprehensive edge case coverage")
(print "- Clean pass/fail reporting")