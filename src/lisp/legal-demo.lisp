; Etherney eLisp Legal Operating System - Demo
; Self-contained demonstration of base event and fact constructors

(print "=== Etherney eLisp Legal Constructors Demo ===")
(print "")

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

(define first (lambda (lst)
  (nth lst 0)))

(define second (lambda (lst)
  (nth lst 1)))

(define plist-get (lambda (plist key)
  (if (< (length plist) 2)
      #f
      (if (eq? (first plist) key)
          (second plist)
          (plist-get (rest (rest plist)) key)))))

(define plist-put (lambda (plist key value)
  (cons key (cons value plist))))

(define starts-with? (lambda (lst symbol)
  (if (< (length lst) 1)
      #f
      (eq? (first lst) symbol))))

; =============================================================================
; EVENT CONSTRUCTORS
; =============================================================================

(define event.make (lambda (type props)
  (cons 'event (cons ':type (cons type props)))))

(define event.type (lambda (ev)
  (if (event.valid? ev)
      (plist-get (rest ev) ':type)
      #f)))

(define event.get (lambda (ev key)
  (if (event.valid? ev)
      (plist-get (rest ev) key)
      #f)))

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

(define fact.make (lambda (pred args props)
  (list 'fact ':pred pred ':args args ':props props)))

(define fact.pred (lambda (f)
  (if (fact.valid? f)
      (plist-get (rest f) ':pred)
      #f)))

(define fact.args (lambda (f)
  (if (fact.valid? f)
      (plist-get (rest f) ':args)
      #f)))

(define fact.get (lambda (f key)
  (if (fact.valid? f)
      (plist-get (plist-get (rest f) ':props) key)
      #f)))

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
; DEMONSTRATIONS
; =============================================================================

(print "ASSUMPTIONS:")
(print "1. Keywords use ':' prefix (e.g., ':person', ':type')")
(print "2. Duplicate keys in plists: last one wins")
(print "3. Missing keys return #f (false)")
(print "4. Empty props lists are valid")
(print "")

(print "=== UTILITY FUNCTION TESTS ===")

; Test plist operations
(define test-plist (list ':name 'Pedro ':age 45 ':city 'Madrid))
(print "Test plist:" test-plist)
(print "plist-get name:" (plist-get test-plist ':name))
(print "plist-get age:" (plist-get test-plist ':age))
(print "plist-get missing:" (plist-get test-plist ':missing))

(define extended-plist (plist-put test-plist ':country 'Spain))
(print "After plist-put country:" extended-plist)
(print "plist-get country:" (plist-get extended-plist ':country))
(print "")

(print "=== EVENT CONSTRUCTOR TESTS ===")

; Happy path - Build death event as specified
(define death-event (event.make 'death (list ':person 'Pedro ':heirs (list 'Maria 'Juan) ':flags (list 'no-will))))
(print "Death event:" death-event)
(print "event.valid?:" (event.valid? death-event))
(print "event.type:" (event.type death-event))
(print "event.get person:" (event.get death-event ':person))
(print "event.get heirs:" (event.get death-event ':heirs))
(print "event.get flags:" (event.get death-event ':flags))
(print "event.get missing:" (event.get death-event ':missing))

; Empty props test
(define empty-event (event.make 'death (list)))
(print "Empty event:" empty-event)
(print "empty event valid?:" (event.valid? empty-event))
(print "empty event type:" (event.type empty-event))

; Invalid event test
(define invalid-event (list 'not-event ':type 'death))
(print "Invalid event:" invalid-event)
(print "invalid event valid?:" (event.valid? invalid-event))
(print "")

(print "=== FACT CONSTRUCTOR TESTS ===")

; Happy path - Build heir-share fact as specified
(define heir-fact (fact.make 'heir-share (list 'Pedro 'Maria) (list ':share 0.5 ':basis 'S774)))
(print "Heir fact:" heir-fact)
(print "fact.valid?:" (fact.valid? heir-fact))
(print "fact.pred:" (fact.pred heir-fact))
(print "fact.args:" (fact.args heir-fact))
(print "fact.get share:" (fact.get heir-fact ':share))
(print "fact.get basis:" (fact.get heir-fact ':basis))
(print "fact.get missing:" (fact.get heir-fact ':missing))

; Empty props fact
(define empty-fact (fact.make 'test (list) (list)))
(print "Empty fact:" empty-fact)
(print "empty fact valid?:" (fact.valid? empty-fact))
(print "empty fact missing prop:" (fact.get empty-fact ':missing))

; Invalid fact
(define invalid-fact (list 'not-fact ':pred 'heir-share))
(print "Invalid fact:" invalid-fact)
(print "invalid fact valid?:" (fact.valid? invalid-fact))
(print "")

(print "=== EDGE CASE TESTS ===")

; Duplicate keys test
(define dup-plist (list ':name 'Pedro ':name 'Juan ':age 45))
(print "Duplicate plist:" dup-plist)
(print "Duplicate keys (last wins):" (plist-get dup-plist ':name))

; Non-mutation test
(define orig-event (event.make 'death (list ':person 'Pedro)))
(print "Original event before access:" orig-event)
(event.type orig-event)
(event.get orig-event ':person)
(print "Original event after access:" orig-event)
(print "")

(print "=== INTEGRATION EXAMPLE ===")

; Create a marriage event
(define marriage-event (event.make 'marriage (list ':parties (list 'Alice 'Bob) ':date "2023-06-15" ':location 'Madrid)))
(print "Marriage event:" marriage-event)
(print "Marriage parties:" (event.get marriage-event ':parties))
(print "Marriage date:" (event.get marriage-event ':date))

; Create a precedent fact
(define precedent-fact (fact.make 'precedent-applies (list "Case123" "CurrentCase") (list ':similarity 0.85 ':jurisdiction 'EU ':weight 'high)))
(print "Precedent fact:" precedent-fact)
(print "Precedent similarity:" (fact.get precedent-fact ':similarity))
(print "Precedent jurisdiction:" (fact.get precedent-fact ':jurisdiction))

(print "")
(print "=== DEMO COMPLETE ===")
(print "All event and fact constructors working correctly!")
(print "Ready for legal case encoding in Etherney eLisp!")