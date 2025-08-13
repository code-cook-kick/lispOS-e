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
(define first-failure "")

; Increment test counter
(define inc-total (lambda ()
  (define test-total (+ test-total 1))))

; Assert equal helper
(define assert= (lambda (label expected actual)
  (inc-total)
  (if (eq? expected actual)
      (define test-passed (+ test-passed 1))
      (define test-failed (+ test-failed 1)))))

; Helper to record failure
(define record-failure (lambda (label expected actual)
  (if (eq? first-failure "")
      (define first-failure label)
      #f)
  (print "FAIL:" label "Expected:" expected "Actual:" actual)))

; Assert true helper
(define assert-true (lambda (label condition)
  (inc-total)
  (if (eq? condition #t)
      (define test-passed (+ test-passed 1))
      (define test-failed (+ test-failed 1))
      (record-failure label #t condition))))

; Assert false helper
(define assert-false (lambda (label condition)
  (inc-total)
  (if (eq? condition #f)
      (define test-passed (+ test-passed 1))
      (define test-failed (+ test-failed 1))
      (record-failure label #f condition))))

; =============================================================================
; HAPPY PATH TESTS - EVENTS
; =============================================================================

(print "Running Happy Path Tests - Events...")

; Build test event
(define test-event (event.make 'death (list ':person 'Pedro ':heirs (list 'Maria 'Juan) ':flags (list 'no-will))))

; Test event validation
(assert-true "event.valid? returns true for valid event" (event.valid? test-event))

; Test event type
(assert= "event.type returns correct type" 'death (event.type test-event))

; Test event properties
(assert= "event.get returns person" 'Pedro (event.get test-event ':person))
(assert= "event.get returns heirs list" (list 'Maria 'Juan) (event.get test-event ':heirs))
(assert= "event.get returns flags list" (list 'no-will) (event.get test-event ':flags))

; =============================================================================
; HAPPY PATH TESTS - FACTS
; =============================================================================

(print "Running Happy Path Tests - Facts...")

; Build test fact
(define test-fact (fact.make 'heir-share (list 'Pedro 'Maria) (list ':share 0.5 ':basis 'S774)))

; Test fact validation
(assert-true "fact.valid? returns true for valid fact" (fact.valid? test-fact))

; Test fact predicate
(assert= "fact.pred returns correct predicate" 'heir-share (fact.pred test-fact))

; Test fact arguments
(assert= "fact.args returns correct arguments" (list 'Pedro 'Maria) (fact.args test-fact))

; Test fact properties
(assert= "fact.get returns share" 0.5 (fact.get test-fact ':share))
(assert= "fact.get returns basis" 'S774 (fact.get test-fact ':basis))

; =============================================================================
; PLIST UTILITY TESTS
; =============================================================================

(print "Running Plist Utility Tests...")

; Test plist-get
(define test-plist (list ':name 'Pedro ':age 45 ':city 'Madrid))
(assert= "plist-get returns correct value" 'Pedro (plist-get test-plist ':name))
(assert= "plist-get returns correct number" 45 (plist-get test-plist ':age))
(assert-false "plist-get returns false for missing key" (plist-get test-plist ':missing))

; Test plist-put
(define extended-plist (plist-put test-plist ':country 'Spain))
(assert= "plist-put adds new key" 'Spain (plist-get extended-plist ':country))
(assert= "plist-put preserves existing keys" 'Pedro (plist-get extended-plist ':name))

; Test duplicate keys (last one wins)
(define dup-plist (list ':name 'Pedro ':name 'Juan ':age 45))
(assert= "duplicate keys: last one wins" 'Juan (plist-get dup-plist ':name))

; =============================================================================
; PURITY / NON-MUTATION TESTS
; =============================================================================

(print "Running Purity Tests...")

; Store original event
(define orig-event (event.make 'death (list ':person 'Pedro)))
(define orig-event-copy (event.make 'death (list ':person 'Pedro)))

; Call accessors
(event.type orig-event)
(event.get orig-event ':person)

; Check event unchanged
(assert= "event unchanged after type access" orig-event-copy orig-event)

; Store original fact
(define orig-fact (fact.make 'test (list 'a 'b) (list ':prop 'value)))
(define orig-fact-copy (fact.make 'test (list 'a 'b) (list ':prop 'value)))

; Call accessors
(fact.pred orig-fact)
(fact.args orig-fact)
(fact.get orig-fact ':prop)

; Check fact unchanged
(assert= "fact unchanged after access" orig-fact-copy orig-fact)

; =============================================================================
; EDGE CASE TESTS
; =============================================================================

(print "Running Edge Case Tests...")

; Missing keys
(assert-false "event.get returns false for missing key" (event.get test-event ':missing))
(assert-false "fact.get returns false for missing key" (fact.get test-fact ':missing))

; Empty props
(define empty-event (event.make 'death (list)))
(assert-true "event with empty props is valid" (event.valid? empty-event))
(assert= "event with empty props has correct type" 'death (event.type empty-event))

; Invalid tag
(define invalid-event (list 'not-event ':type 'death))
(assert-false "invalid event tag returns false" (event.valid? invalid-event))

; Facts with empty props
(define empty-fact (fact.make 'test (list) (list)))
(assert-true "fact with empty props is valid" (fact.valid? empty-fact))
(assert-false "fact with empty props returns false for missing prop" (fact.get empty-fact ':missing))

; =============================================================================
; ADVERSARIAL TESTS
; =============================================================================

(print "Running Adversarial Tests...")

; Non-symbol keys (if allowed)
(define mixed-plist (list "string-key" 'value1 42 'value2))
(assert= "non-symbol string key works" 'value1 (plist-get mixed-plist "string-key"))
(assert= "non-symbol number key works" 'value2 (plist-get mixed-plist 42))

; =============================================================================
; INTEGRATION TEST
; =============================================================================

(print "Running Integration Test...")

; Helper function for equal split
(define equal-split (lambda (ev)
  (define hs (event.get ev ':heirs))
  (if (eq? hs #f)
      (list)
      (if (= (length hs) 0)
          (list)
          (define sh (/ 1 (length hs)))
          (map (lambda (h)
                 (fact.make 'heir-share 
                           (list (event.get ev ':person) h)
                           (list ':share sh ':basis 'S774)))
               hs)))))

; Test integration
(define heir-event (event.make 'death (list ':person 'Pedro ':heirs (list 'Maria 'Juan))))
(define heir-facts (equal-split heir-event))

(assert= "integration: correct number of heir facts" 2 (length heir-facts))

; Check first heir fact
(define first-heir (nth heir-facts 0))
(assert-true "integration: first heir fact is valid" (fact.valid? first-heir))
(assert= "integration: first heir predicate" 'heir-share (fact.pred first-heir))
(assert= "integration: first heir share" 0.5 (fact.get first-heir ':share))

; Check second heir fact
(define second-heir (nth heir-facts 1))
(assert-true "integration: second heir fact is valid" (fact.valid? second-heir))
(assert= "integration: second heir share" 0.5 (fact.get second-heir ':share))

; =============================================================================
; TEST RESULTS
; =============================================================================

(print "")
(print "=== TEST RESULTS ===")
(print "Total tests:" test-total)
(print "Passed:" test-passed)
(print "Failed:" test-failed)

(if (> test-failed 0)
    (print "First failure:" first-failure)
    (print "All tests PASSED!"))

(if (= test-failed 0)
    (print "SUCCESS: All tests passed!")
    (print "FAILURE: Some tests failed!"))

(print "")
(print "=== Test Suite Complete ===")