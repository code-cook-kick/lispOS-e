(load "src/lisp/common/utils.lisp")

(print "=== Etherney eLisp Legal Constructors ===")

(print "Loading base event and fact constructors...")

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

(define get-props
  (lambda (lst)
    (rest lst)))

(define event.make
  (lambda (type props)
    (kv 'event (cons type props))))

(define event.type
  (lambda (ev)
    (if (event.valid? ev)
        (nth ev 1)
        #f)))

(define event.get
  (lambda (ev key)
    (if (event.valid? ev)
        (plist-get (rest (rest ev)) key)
        #f)))

(define event.valid?
  (lambda (ev)
    (if (< (length ev) 2)
        #f
        (starts-with? ev 'event))))

(define fact.make
  (lambda (pred args props)
    (list 'fact pred args props)))

(define fact.pred
  (lambda (f)
    (if (fact.valid? f)
        (nth f 1)
        #f)))

(define fact.args
  (lambda (f)
    (if (fact.valid? f)
        (nth f 2)
        #f)))

(define fact.get
  (lambda (f key)
    (if (fact.valid? f)
        (plist-get (nth f 3) key)
        #f)))

(define fact.valid?
  (lambda (f)
    (if (< (length f) 4)
        #f
        (starts-with? f 'fact))))

(print "Testing utility functions...")

(define test-list
  (list 'a 'b 'c))

(print "first test-list =>" (first test-list))

(print "second test-list =>" (second test-list))

(define test-plist
  (list "name" "Pedro" "age" 45 "city" "Madrid"))

(print
  "plist-get test-plist name =>"
  (plist-get test-plist "name"))

(print
  "plist-get test-plist age =>"
  (plist-get test-plist "age"))

(print
  "plist-get test-plist missing =>"
  (plist-get test-plist "missing"))

(define extended-plist
  (plist-put test-plist "country" "Spain"))

(print "After plist-put country Spain =>" extended-plist)

(print
  "plist-get extended-plist country =>"
  (plist-get extended-plist "country"))

(print "")

(print "Testing event constructors...")

(define death-event
  (event.make
    'death
    (list
    "person"
    "Pedro"
    "flags"
    (list 'no-will)
    "heirs"
    (list "Maria" "Juan"))))

(print "Created death event:" death-event)

(print "event.type death-event =>" (event.type death-event))

(print
  "event.get death-event person =>"
  (event.get death-event "person"))

(print
  "event.get death-event flags =>"
  (event.get death-event "flags"))

(print
  "event.get death-event heirs =>"
  (event.get death-event "heirs"))

(print
  "event.valid? death-event =>"
  (event.valid? death-event))

(define invalid-event
  (list 'not-event 'death))

(print
  "event.valid? invalid-event =>"
  (event.valid? invalid-event))

(print "")

(print "Testing fact constructors...")

(define heir-fact
  (fact.make
    'heir-share
    (list "Pedro" "Maria")
    (list "share" "1/2" "basis" "S774")))

(print "Created heir fact:" heir-fact)

(print "fact.pred heir-fact =>" (fact.pred heir-fact))

(print "fact.args heir-fact =>" (fact.args heir-fact))

(print
  "fact.get heir-fact share =>"
  (fact.get heir-fact "share"))

(print
  "fact.get heir-fact basis =>"
  (fact.get heir-fact "basis"))

(print "fact.valid? heir-fact =>" (fact.valid? heir-fact))

(define invalid-fact
  (list 'not-fact 'heir-share))

(print
  "fact.valid? invalid-fact =>"
  (fact.valid? invalid-fact))

(print "")

(print "Additional legal examples...")

(define marriage-event
  (event.make
    'marriage
    (list
    "parties"
    (list "Alice" "Bob")
    "date"
    "2023-06-15"
    "location"
    "Madrid")))

(print "Marriage event:" marriage-event)

(print
  "Marriage parties:"
  (event.get marriage-event "parties"))

(print "Marriage date:" (event.get marriage-event "date"))

(define contract-event
  (event.make
    'contract-formation
    (list
    "parties"
    (list "CompanyA" "CompanyB")
    "subject"
    "Software License"
    "value"
    50000)))

(print "Contract event:" contract-event)

(print "Contract value:" (event.get contract-event "value"))

(print
  "Contract subject:"
  (event.get contract-event "subject"))

(define precedent-fact
  (fact.make
    'precedent-applies
    (list "Case123" "CurrentCase")
    (list "similarity" 0.85 "jurisdiction" "EU" "weight" "high")))

(print "Precedent fact:" precedent-fact)

(print
  "Precedent similarity:"
  (fact.get precedent-fact "similarity"))

(print
  "Precedent jurisdiction:"
  (fact.get precedent-fact "jurisdiction"))

(define liability-fact
  (fact.make
    'liable-for
    (list "DefendantX" "Damages")
    (list "amount" 25000 "type" "compensatory" "certainty" 0.9)))

(print "Liability fact:" liability-fact)

(print "Liability amount:" (fact.get liability-fact "amount"))

(print "Liability type:" (fact.get liability-fact "type"))

(print "")

(print "=== Legal Constructors Loaded Successfully ===")

(print "Available functions:")

(print
  "  Event: event.make, event.type, event.get, event.valid?")

(print
  "  Fact: fact.make, fact.pred, fact.args, fact.get, fact.valid?")

(print "  Utility: first, second, plist-get, plist-put")

(print "")

(print "Data Model:")

(print
  "  Events: (event <type> <key1> <val1> <key2> <val2> ...)")

(print "  Facts: (fact <predicate> <args-list> <props-list>)")

(print "")

(print "Usage examples:")

(print
  "  (event.make 'death (list \"person\" \"John\" \"date\" \"2024-01-01\"))")

(print
  "  (fact.make 'heir-of (list \"John\" \"Jane\") (list \"share\" \"1/2\"))")

(print "")

(print "Ready for legal case encoding in Etherney eLisp!")
