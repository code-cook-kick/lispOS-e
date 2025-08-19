(load "src/lisp/common/utils.lisp")

(print "=== Etherney eLisp Legal Constructors Test Suite ===")

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

(print "Running Tests...")

(define total-tests
  0)

(define passed-tests
  0)

(define failed-tests
  0)

(define run-test
  (lambda (label expected actual)
    (if (eq? expected actual)
        (define passed-tests
        (+ passed-tests 1))
        (define failed-tests
        (+ failed-tests 1)))))

(define inc-total
  (lambda (x)
    (define total-tests
      (+ total-tests 1))))

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

(inc-total #t)

(run-test
  "event.valid? returns true"
  #t
  (event.valid? test-event))

(inc-total #t)

(run-test
  "event.type returns death"
  'death
  (event.type test-event))

(inc-total #t)

(run-test
  "event.get person"
  'Pedro
  (event.get test-event ':person))

(define test-fact
  (fact.make
    'heir-share
    (list 'Pedro 'Maria)
    (list ':share 0.5 ':basis 'S774)))

(run-test
  "fact.valid? returns true"
  #t
  (fact.valid? test-fact))

(run-test
  "fact.pred returns heir-share"
  'heir-share
  (fact.pred test-fact))

(run-test "fact.get share" 0.5 (fact.get test-fact ':share))

(run-test "fact.get basis" 'S774 (fact.get test-fact ':basis))

(define test-plist
  (list ':name 'Pedro ':age 45))

(run-test
  "plist-get name"
  'Pedro
  (plist-get test-plist ':name))

(run-test "plist-get age" 45 (plist-get test-plist ':age))

(run-test
  "plist-get missing"
  #f
  (plist-get test-plist ':missing))

(define extended-plist
  (plist-put test-plist ':country 'Spain))

(run-test
  "plist-put country"
  'Spain
  (plist-get extended-plist ':country))

(run-test
  "event missing key"
  #f
  (event.get test-event ':missing))

(run-test
  "fact missing key"
  #f
  (fact.get test-fact ':missing))

(define empty-event
  (event.make 'death (list)))

(run-test "empty event valid" #t (event.valid? empty-event))

(run-test "empty event type" 'death (event.type empty-event))

(define invalid-event
  (list 'not-event ':type 'death))

(run-test "invalid event" #f (event.valid? invalid-event))

(define dup-plist
  (list ':name 'Pedro ':name 'Juan ':age 45))

(run-test
  "duplicate keys last wins"
  'Juan
  (plist-get dup-plist ':name))

(print "")

(print "=== TEST RESULTS ===")

(print "Total tests:" total-tests)

(print "Passed:" passed-tests)

(print "Failed:" failed-tests)

(if (= failed-tests 0)
    (print "SUCCESS: All tests passed!")
    (print "FAILURE: Some tests failed!"))

(print "")

(print "=== Test Suite Complete ===")
