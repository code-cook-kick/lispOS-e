; Etherney eLisp Legal Operating System - Test Suite
; Self-contained test file for base event and fact constructors
; Pure LISP implementation with comprehensive test coverage

(print "=== Etherney eLisp Legal Constructors Test Suite ===")
(print "")

; =============================================================================
; ASSUMPTIONS
; =============================================================================
(print "ASSUMPTIONS:")
(print "1. Keywords use ':' prefix (e.g., ':person', ':type')")
(print "2. Duplicate keys in plists: last one wins")
(print "3. Missing keys return #f (false)")
(print "4. Non-symbol keys are allowed in plists")
(print "5. Empty props lists are valid")
(print "")

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

; Basic list accessors
(define first (lambda (lst)
  (nth lst 0)))

(define second (lambda (lst)
  (nth lst 1)))

; Property list (plist) utilities
(define plist-get (lambda (plist key)
  (if (< (length plist) 2)
      #f
      (if (eq? (first plist) key)
          (second plist)
          (plist-get (rest (rest plist)) key)))))

(define plist-put (lambda (plist key value)
  (cons key (cons value plist))))

; Helper to check if a list starts with a specific symbol
(define starts-with? (lambda (lst symbol)
  (if (< (length lst) 1)
      #f
      (eq? (first lst) symbol))))

; =============================================================================
; EVENT CONSTRUCTORS
; =============================================================================

; Create an event: (event.make type props)
; Returns: (event :type <type> <props...>)
(define event.make (lambda (type props)
  (cons 'event (cons ':type (cons type props)))))

; Get event type: (event.type ev)
(define event.type (lambda (ev)
  (if (event.valid? ev)
      (plist-get (rest ev) ':type)
      #f)))

; Get event property: (event.get ev key)
(define event.get (lambda (ev key)
  (if (event.valid? ev)
      (plist-get (rest ev) key)
      #f)))

; Validate event structure: (event.valid? ev)
(define event.valid? (lambda (ev)
  (if (< (length ev) 3)
      #f
      (if (starts-with? ev 'event)
          (if (eq? (nth ev 1) ':type)
              #t
              #f)
          #f))))

; =============================================================================
; FACT CONSTRUCTORS
; =============================================================================

; Create a fact: (fact.make pred args props)
; Returns: (fact :pred <pred> :args <args> :props <props>)
(define fact.make (lambda (pred args props)
  (list 'fact ':pred pred ':args args ':props props)))

; Get fact predicate: (fact.pred f)
(define fact.pred (lambda (f)
  (if (fact.valid? f)
      (plist-get (rest f) ':pred)
      #f)))

; Get fact arguments: (fact.args f)
(define fact.args (lambda (f)
  (if (fact.valid? f)
      (plist-get (rest f) ':args)
      #f)))

; Get fact property: (fact.get f key)
(define fact.get (lambda (f key)
  (if (fact.valid? f)
      (plist-get (plist-get (rest f) ':props) key)
      #f)))

; Validate fact structure: (fact.valid? f)
(define fact.valid? (lambda (f)
  (if (< (length f) 7)
      #f
      (if (starts-with? f 'fact)
          (if (eq? (nth f 1) ':pred)
              (if (eq? (nth f 3) ':args)
                  (if (eq? (nth f 5) ':props)
                      #t
                      #f)
                  #f)
              #f)
          #f))))

; =============================================================================
; TEST FRAMEWORK
; =============================================================================

; Test counters
(define test-total 0)
(define test-passed 0)
(define test-failed 0)

; Simple pass/fail tracking
(define pass-test (lambda (dummy)
  (define test-total (+ test-total 1))
  (define test-passed (+ test-passed 1))))

(define fail-test (lambda (label expected actual)
  (define test-total (+ test-total 1))
  (define test-failed (+ test-failed 1))
  (print "FAIL:" label "Expected:" expected "Actual:" actual)))

; Test helper
(define test (lambda (label expected actual)
  (if (eq? expected actual)
      (pass-test #t)
      (fail-test label expected actual))))

; =============================================================================
; TESTS
; =============================================================================

(print "Running Tests...")

; Happy Path Tests - Events
(define test-event (event.make 'death (list ':person 'Pedro ':heirs (list 'Maria 'Juan) ':flags (list 'no-will))))

(test "event.valid? returns true for valid event" #t (event.valid? test-event))
(test "event.type returns correct type" 'death (event.type test-event))
(test "event.get returns person" 'Pedro (event.get test-event ':person))

; Happy Path Tests - Facts
(define test-fact (fact.make 'heir-share (list 'Pedro 'Maria) (list ':share 0.5 ':basis 'S774)))

(test "fact.valid? returns true for valid fact" #t (fact.valid? test-fact))
(test "fact.pred returns correct predicate" 'heir-share (fact.pred test-fact))
(test "fact.args returns correct arguments" (list 'Pedro 'Maria) (fact.args test-fact))
(test "fact.get returns share" 0.5 (fact.get test-fact ':share))
(test "fact.get returns basis" 'S774 (fact.get test-fact ':basis))

; Plist Utility Tests
(define test-plist (list ':name 'Pedro ':age 45 ':city 'Madrid))
(test "plist-get returns correct value" 'Pedro (plist-get test-plist ':name))
(test "plist-get returns correct number" 45 (plist-get test-plist ':age))
(test "plist-get returns false for missing key" #f (plist-get test-plist ':missing))

(define extended-plist (plist-put test-plist ':country 'Spain))
(test "plist-put adds new key" 'Spain (plist-get extended-plist ':country))
(test "plist-put preserves existing keys" 'Pedro (plist-get extended-plist ':name))

; Edge Case Tests
(test "event.get returns false for missing key" #f (event.get test-event ':missing))
(test "fact.get returns false for missing key" #f (fact.get test-fact ':missing))

(define empty-event (event.make 'death (list)))
(test "event with empty props is valid" #t (event.valid? empty-event))
(test "event with empty props has correct type" 'death (event.type empty-event))

(define invalid-event (list 'not-event ':type 'death))
(test "invalid event tag returns false" #f (event.valid? invalid-event))

(define empty-fact (fact.make 'test (list) (list)))
(test "fact with empty props is valid" #t (fact.valid? empty-fact))
(test "fact with empty props returns false for missing prop" #f (fact.get empty-fact ':missing))

; Duplicate keys test
(define dup-plist (list ':name 'Pedro ':name 'Juan ':age 45))
(test "duplicate keys: last one wins" 'Juan (plist-get dup-plist ':name))

; Integration Test
(define equal-split (lambda (ev)
  (define hs (event.get ev ':heirs))
  (if (eq? hs #f)
      (list)
      (if (= (length hs) 0)
          (list)
          (map (lambda (h)
                 (fact.make 'heir-share
                           (list (event.get ev ':person) h)
                           (list ':share (/ 1 (length hs)) ':basis 'S774)))
               hs)))))

(define heir-event (event.make 'death (list ':person 'Pedro ':heirs (list 'Maria 'Juan))))
(define heir-facts (equal-split heir-event))

(test "integration: correct number of heir facts" 2 (length heir-facts))

(define first-heir (nth heir-facts 0))
(test "integration: first heir fact is valid" #t (fact.valid? first-heir))
(test "integration: first heir predicate" 'heir-share (fact.pred first-heir))
(test "integration: first heir share" 0.5 (fact.get first-heir ':share))

(define second-heir (nth heir-facts 1))
(test "integration: second heir fact is valid" #t (fact.valid? second-heir))
(test "integration: second heir share" 0.5 (fact.get second-heir ':share))

; =============================================================================
; TEST RESULTS
; =============================================================================

(print "")
(print "=== TEST RESULTS ===")
(print "Total tests:" test-total)
(print "Passed:" test-passed)
(print "Failed:" test-failed)

(if (= test-failed 0)
    (print "SUCCESS: All tests passed!")
    (print "FAILURE: Some tests failed!"))

(print "")
(print "=== Test Suite Complete ===")