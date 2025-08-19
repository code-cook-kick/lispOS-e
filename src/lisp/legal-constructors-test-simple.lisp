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

(define test
  (lambda (label expected actual)
    (begin
      (define test-total
        (+ test-total 1))
      (if (eq? expected actual)
          (define test-passed
          (+ test-passed 1))
          (define test-failed
          (+ test-failed 1))))))

(define test-with-output
  (lambda (label expected actual)
    (begin
      (define test-total
        (+ test-total 1))
      (if (eq? expected actual)
          (define test-passed
          (+ test-passed 1))
          (print "FAIL:" label "Expected:" expected "Actual:" actual)))))

(print "Running Tests...")

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

(test
  "event.valid? returns true for valid event"
  #t
  (event.valid? test-event))

(test
  "event.type returns correct type"
  'death
  (event.type test-event))

(test
  "event.get returns person"
  'Pedro
  (event.get test-event ':person))

(define test-fact
  (fact.make
    'heir-share
    (list 'Pedro 'Maria)
    (list ':share 0.5 ':basis 'S774)))

(test
  "fact.valid? returns true for valid fact"
  #t
  (fact.valid? test-fact))

(test
  "fact.pred returns correct predicate"
  'heir-share
  (fact.pred test-fact))

(test
  "fact.args returns correct arguments"
  (list 'Pedro 'Maria)
  (fact.args test-fact))

(test
  "fact.get returns share"
  0.5
  (fact.get test-fact ':share))

(test
  "fact.get returns basis"
  'S774
  (fact.get test-fact ':basis))

(define test-plist
  (list ':name 'Pedro ':age 45 ':city 'Madrid))

(test
  "plist-get returns correct value"
  'Pedro
  (plist-get test-plist ':name))

(test
  "plist-get returns correct number"
  45
  (plist-get test-plist ':age))

(test
  "plist-get returns false for missing key"
  #f
  (plist-get test-plist ':missing))

(define extended-plist
  (plist-put test-plist ':country 'Spain))

(test
  "plist-put adds new key"
  'Spain
  (plist-get extended-plist ':country))

(test
  "plist-put preserves existing keys"
  'Pedro
  (plist-get extended-plist ':name))

(test
  "event.get returns false for missing key"
  #f
  (event.get test-event ':missing))

(test
  "fact.get returns false for missing key"
  #f
  (fact.get test-fact ':missing))

(define empty-event
  (event.make 'death (list)))

(test
  "event with empty props is valid"
  #t
  (event.valid? empty-event))

(test
  "event with empty props has correct type"
  'death
  (event.type empty-event))

(define invalid-event
  (list 'not-event ':type 'death))

(test
  "invalid event tag returns false"
  #f
  (event.valid? invalid-event))

(define empty-fact
  (fact.make 'test (list) (list)))

(test
  "fact with empty props is valid"
  #t
  (fact.valid? empty-fact))

(test
  "fact with empty props returns false for missing prop"
  #f
  (fact.get empty-fact ':missing))

(define dup-plist
  (list ':name 'Pedro ':name 'Juan ':age 45))

(test
  "duplicate keys: last one wins"
  'Juan
  (plist-get dup-plist ':name))

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

(test
  "integration: correct number of heir facts"
  2
  (length heir-facts))

(define first-heir
  (nth heir-facts 0))

(test
  "integration: first heir fact is valid"
  #t
  (fact.valid? first-heir))

(test
  "integration: first heir predicate"
  'heir-share
  (fact.pred first-heir))

(test
  "integration: first heir share"
  0.5
  (fact.get first-heir ':share))

(define second-heir
  (nth heir-facts 1))

(test
  "integration: second heir fact is valid"
  #t
  (fact.valid? second-heir))

(test
  "integration: second heir share"
  0.5
  (fact.get second-heir ':share))

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
