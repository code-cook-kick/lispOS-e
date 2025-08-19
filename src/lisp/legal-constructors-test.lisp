(load "src/lisp/common/utils.lisp")

(print "=== Etherney eLisp Legal Constructors Test Suite ===")

(print "")

(print "ASSUMPTIONS:")

(print
  "1. Keywords use ':' prefix (e.g., ':person', ':type')")

(print "2. Duplicate keys in plists: last one wins")

(print "3. Missing keys return #f (false)")

(print "4. Non-symbol keys are allowed in plists")

(print "5. Empty props lists are valid")

(print "")

(define first
  (lambda (lst)
    (nth lst 0)))

(define second
  (lambda (lst)
    (nth lst 1)))

(define plist-get
  (lambda (plist key)
    (if (< (length plist) 2)
        #f
        (if (eq? (first plist) key)
          (second plist)
          (plist-get (rest (rest plist)) key)))))

(define plist-put
  (lambda (plist key value)
    (cons key (cons value plist))))

(define starts-with?
  (lambda (lst symbol)
    (if (< (length lst) 1)
        #f
        (eq? (first lst) symbol))))

(define event.make
  (lambda (type props)
    (kv 'event (cons ':type (cons type props)))))

(define event.type
  (lambda (ev)
    (if (event.valid? ev)
        (plist-get (rest ev) ':type)
        #f)))

(define event.get
  (lambda (ev key)
    (if (event.valid? ev)
        (plist-get (rest ev) key)
        #f)))

(define event.valid?
  (lambda (ev)
    (if (< (length ev) 3)
        #f
        (if (starts-with? ev 'event)
          (if (eq? (nth ev 1) ':type)
            #t
            #f)
          #f))))

(define fact.make
  (lambda (pred args props)
    (list 'fact ':pred pred ':args args ':props props)))

(define fact.pred
  (lambda (f)
    (if (fact.valid? f)
        (plist-get (rest f) ':pred)
        #f)))

(define fact.args
  (lambda (f)
    (if (fact.valid? f)
        (plist-get (rest f) ':args)
        #f)))

(define fact.get
  (lambda (f key)
    (if (fact.valid? f)
        (plist-get (plist-get (rest f) ':props) key)
        #f)))

(define fact.valid?
  (lambda (f)
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

(define test-total
  0)

(define test-passed
  0)

(define test-failed
  0)

(define first-failure
  "")

(define inc-total
  (lambda ()
    (define test-total
      (+ test-total 1))))

(define assert=
  (lambda (label expected actual)
    (begin
      (inc-total)
      (if (eq? expected actual)
          (define test-passed
          (+ test-passed 1))
          (define test-failed
          (+ test-failed 1))))))

(define record-failure
  (lambda (label expected actual)
    (begin
      (if (eq? first-failure "")
          (define first-failure
          label)
          #f)
      (print "FAIL:" label "Expected:" expected "Actual:" actual))))

(define assert-true
  (lambda (label condition)
    (begin
      (inc-total)
      (if (eq? condition #t)
          (define test-passed
          (+ test-passed 1))
          (define test-failed
          (+ test-failed 1))))))

(define assert-false
  (lambda (label condition)
    (begin
      (inc-total)
      (if (eq? condition #f)
          (define test-passed
          (+ test-passed 1))
          (define test-failed
          (+ test-failed 1))))))

(print "Running Happy Path Tests - Events...")

(define test-event
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':heirs
    (list 'Maria 'Juan)
    ':flags
    (list 'no-will))))

(assert-true
  "event.valid? returns true for valid event"
  (event.valid? test-event))

(assert=
  "event.type returns correct type"
  'death
  (event.type test-event))

(assert=
  "event.get returns person"
  'Pedro
  (event.get test-event ':person))

(assert=
  "event.get returns heirs list"
  (list 'Maria 'Juan)
  (event.get test-event ':heirs))

(assert=
  "event.get returns flags list"
  (list 'no-will)
  (event.get test-event ':flags))

(print "Running Happy Path Tests - Facts...")

(define test-fact
  (fact.make
    'heir-share
    (list 'Pedro 'Maria)
    (list ':share 0.5 ':basis 'S774)))

(assert-true
  "fact.valid? returns true for valid fact"
  (fact.valid? test-fact))

(assert=
  "fact.pred returns correct predicate"
  'heir-share
  (fact.pred test-fact))

(assert=
  "fact.args returns correct arguments"
  (list 'Pedro 'Maria)
  (fact.args test-fact))

(assert=
  "fact.get returns share"
  0.5
  (fact.get test-fact ':share))

(assert=
  "fact.get returns basis"
  'S774
  (fact.get test-fact ':basis))

(print "Running Plist Utility Tests...")

(define test-plist
  (list ':name 'Pedro ':age 45 ':city 'Madrid))

(assert=
  "plist-get returns correct value"
  'Pedro
  (plist-get test-plist ':name))

(assert=
  "plist-get returns correct number"
  45
  (plist-get test-plist ':age))

(assert-false
  "plist-get returns false for missing key"
  (plist-get test-plist ':missing))

(define extended-plist
  (plist-put test-plist ':country 'Spain))

(assert=
  "plist-put adds new key"
  'Spain
  (plist-get extended-plist ':country))

(assert=
  "plist-put preserves existing keys"
  'Pedro
  (plist-get extended-plist ':name))

(define dup-plist
  (list ':name 'Pedro ':name 'Juan ':age 45))

(assert=
  "duplicate keys: last one wins"
  'Juan
  (plist-get dup-plist ':name))

(print "Running Purity Tests...")

(define orig-event
  (event.make 'death (list ':person 'Pedro)))

(define orig-event-copy
  (event.make 'death (list ':person 'Pedro)))

(event.type orig-event)

(event.get orig-event ':person)

(assert=
  "event unchanged after type access"
  orig-event-copy
  orig-event)

(define orig-fact
  (fact.make 'test (list 'a 'b) (list ':prop 'value)))

(define orig-fact-copy
  (fact.make 'test (list 'a 'b) (list ':prop 'value)))

(fact.pred orig-fact)

(fact.args orig-fact)

(fact.get orig-fact ':prop)

(assert=
  "fact unchanged after access"
  orig-fact-copy
  orig-fact)

(print "Running Edge Case Tests...")

(assert-false
  "event.get returns false for missing key"
  (event.get test-event ':missing))

(assert-false
  "fact.get returns false for missing key"
  (fact.get test-fact ':missing))

(define empty-event
  (event.make 'death (list)))

(assert-true
  "event with empty props is valid"
  (event.valid? empty-event))

(assert=
  "event with empty props has correct type"
  'death
  (event.type empty-event))

(define invalid-event
  (list 'not-event ':type 'death))

(assert-false
  "invalid event tag returns false"
  (event.valid? invalid-event))

(define empty-fact
  (fact.make 'test (list) (list)))

(assert-true
  "fact with empty props is valid"
  (fact.valid? empty-fact))

(assert-false
  "fact with empty props returns false for missing prop"
  (fact.get empty-fact ':missing))

(print "Running Adversarial Tests...")

(define mixed-plist
  (list "string-key" 'value1 42 'value2))

(assert=
  "non-symbol string key works"
  'value1
  (plist-get mixed-plist "string-key"))

(assert=
  "non-symbol number key works"
  'value2
  (plist-get mixed-plist 42))

(print "Running Integration Test...")

(define equal-split
  (lambda (ev)
    (begin
      (define hs
        (event.get ev ':heirs))
      (if (eq? hs #f)
          (list)
          (if (= (length hs) 0)
            (list)
            (define sh
            (/ 1 (length hs))))))))

(define heir-event
  (event.make
    'death
    (list ':person 'Pedro ':heirs (list 'Maria 'Juan))))

(define heir-facts
  (equal-split heir-event))

(assert=
  "integration: correct number of heir facts"
  2
  (length heir-facts))

(define first-heir
  (nth heir-facts 0))

(assert-true
  "integration: first heir fact is valid"
  (fact.valid? first-heir))

(assert=
  "integration: first heir predicate"
  'heir-share
  (fact.pred first-heir))

(assert=
  "integration: first heir share"
  0.5
  (fact.get first-heir ':share))

(define second-heir
  (nth heir-facts 1))

(assert-true
  "integration: second heir fact is valid"
  (fact.valid? second-heir))

(assert=
  "integration: second heir share"
  0.5
  (fact.get second-heir ':share))

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
