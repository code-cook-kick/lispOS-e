; Etherney eLisp Legal Operating System
; Base Event and Fact Constructors
; Pure LISP implementation for legal case encoding

(print "=== Etherney eLisp Legal Constructors ===")
(print "Loading base event and fact constructors...")
(print "")

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

; Basic list accessors - work with JavaScript arrays
(define first (lambda (lst)
  (nth lst 0)))

(define second (lambda (lst)
  (nth lst 1)))

; Helper to extract value from AST node or return as-is
(define get-value (lambda (obj)
  obj))

; Helper to compare symbols (works with AST nodes)
(define symbol-eq? (lambda (a b)
  (eq? a b)))

; Property list (plist) utilities
; A plist is a flat list of alternating keys and values: (key1 val1 key2 val2)

(define plist-get (lambda (plist key)
  (if (< (length plist) 2)
      #f
      (if (symbol-eq? (first plist) key)
          (second plist)
          (plist-get (rest (rest plist)) key)))))

(define plist-put (lambda (plist key value)
  (cons key (cons value plist))))

; Helper to check if a list starts with a specific symbol
(define starts-with? (lambda (lst symbol)
  (if (< (length lst) 1)
      #f
      (symbol-eq? (first lst) symbol))))

; Helper to get the rest of a list after the first element
(define get-props (lambda (lst)
  (rest lst)))

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
      (plist-get (get-props ev) ':type)
      #f)))

; Get event property: (event.get ev key)
(define event.get (lambda (ev key)
  (if (event.valid? ev)
      (plist-get (get-props ev) key)
      #f)))

; Validate event structure: (event.valid? ev)
(define event.valid? (lambda (ev)
  (if (< (length ev) 3)
      #f
      (if (starts-with? ev 'event)
          (if (symbol-eq? (nth ev 1) ':type)
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
      (plist-get (get-props f) ':pred)
      #f)))

; Get fact arguments: (fact.args f)
(define fact.args (lambda (f)
  (if (fact.valid? f)
      (plist-get (get-props f) ':args)
      #f)))

; Get fact property: (fact.get f key)
(define fact.get (lambda (f key)
  (if (fact.valid? f)
      (plist-get (plist-get (get-props f) ':props) key)
      #f)))

; Validate fact structure: (fact.valid? f)
(define fact.valid? (lambda (f)
  (if (< (length f) 7)
      #f
      (if (starts-with? f 'fact)
          (if (symbol-eq? (nth f 1) ':pred)
              (if (symbol-eq? (nth f 3) ':args)
                  (if (symbol-eq? (nth f 5) ':props)
                      #t
                      #f)
                  #f)
              #f)
          #f))))

; =============================================================================
; EXAMPLES AND TESTS
; =============================================================================

(print "Testing utility functions...")

; Test basic list accessors
(define test-list (list 'a 'b 'c))
(print "first test-list =>" (first test-list))
(print "second test-list =>" (second test-list))

; Test plist operations with simple values
(define test-plist (list "name" "Pedro" "age" 45 "city" "Madrid"))
(print "plist-get test-plist name =>" (plist-get test-plist "name"))
(print "plist-get test-plist age =>" (plist-get test-plist "age"))
(print "plist-get test-plist missing =>" (plist-get test-plist "missing"))

(define extended-plist (plist-put test-plist "country" "Spain"))
(print "After plist-put country Spain =>" extended-plist)
(print "plist-get extended-plist country =>" (plist-get extended-plist "country"))
(print "")

(print "Testing event constructors...")

; Create a death event using string keys for better compatibility
(define death-event (event.make 'death (list "person" "Pedro" "flags" (list 'no-will) "heirs" (list "Maria" "Juan"))))
(print "Created death event:" death-event)

; Test event accessors
(print "event.type death-event =>" (event.type death-event))
(print "event.get death-event person =>" (event.get death-event "person"))
(print "event.get death-event flags =>" (event.get death-event "flags"))
(print "event.get death-event heirs =>" (event.get death-event "heirs"))
(print "event.valid? death-event =>" (event.valid? death-event))

; Test with invalid event
(define invalid-event (list 'not-event ':type 'death))
(print "event.valid? invalid-event =>" (event.valid? invalid-event))
(print "")

(print "Testing fact constructors...")

; Create an heir-share fact using string keys
(define heir-fact (fact.make 'heir-share (list "Pedro" "Maria") (list "share" "1/2" "basis" "S774")))
(print "Created heir fact:" heir-fact)

; Test fact accessors
(print "fact.pred heir-fact =>" (fact.pred heir-fact))
(print "fact.args heir-fact =>" (fact.args heir-fact))
(print "fact.get heir-fact share =>" (fact.get heir-fact "share"))
(print "fact.get heir-fact basis =>" (fact.get heir-fact "basis"))
(print "fact.valid? heir-fact =>" (fact.valid? heir-fact))

; Test with invalid fact
(define invalid-fact (list 'not-fact ':pred 'heir-share))
(print "fact.valid? invalid-fact =>" (fact.valid? invalid-fact))
(print "")

; =============================================================================
; ADDITIONAL EXAMPLES
; =============================================================================

(print "Additional legal examples...")

; Marriage event
(define marriage-event (event.make 'marriage (list "parties" (list "Alice" "Bob") "date" "2023-06-15" "location" "Madrid")))
(print "Marriage event:" marriage-event)
(print "Marriage parties:" (event.get marriage-event "parties"))

; Contract formation event
(define contract-event (event.make 'contract-formation (list "parties" (list "CompanyA" "CompanyB") "subject" "Software License" "value" 50000)))
(print "Contract event:" contract-event)
(print "Contract value:" (event.get contract-event "value"))

; Legal precedent fact
(define precedent-fact (fact.make 'precedent-applies (list "Case123" "CurrentCase") (list "similarity" 0.85 "jurisdiction" "EU" "weight" "high")))
(print "Precedent fact:" precedent-fact)
(print "Precedent similarity:" (fact.get precedent-fact "similarity"))
(print "Precedent jurisdiction:" (fact.get precedent-fact "jurisdiction"))

; Liability fact
(define liability-fact (fact.make 'liable-for (list "DefendantX" "Damages") (list "amount" 25000 "type" "compensatory" "certainty" 0.9)))
(print "Liability fact:" liability-fact)
(print "Liability amount:" (fact.get liability-fact "amount"))
(print "Liability type:" (fact.get liability-fact "type"))

(print "")
(print "=== Legal Constructors Loaded Successfully ===")
(print "Available functions:")
(print "  Event: event.make, event.type, event.get, event.valid?")
(print "  Fact: fact.make, fact.pred, fact.args, fact.get, fact.valid?")
(print "  Utility: first, second, plist-get, plist-put")
(print "")
(print "Usage examples:")
(print "  (event.make 'death (list \"person\" \"John\" \"date\" \"2024-01-01\"))")
(print "  (fact.make 'heir-of (list \"John\" \"Jane\") (list \"share\" \"1/2\"))")
(print "")
(print "Ready for legal case encoding in Etherney eLisp!")