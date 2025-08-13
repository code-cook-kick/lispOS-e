; Etherney eLisp Legal Operating System - Statute/Rule API
; Pure LISP implementation for legal statute processing
; Fixed version handling ASTNode symbol comparison

(print "=== Etherney eLisp Statute/Rule API ===")
(print "Loading statute processing system...")
(print "")

; =============================================================================
; EXISTING CONSTRUCTORS (from previous implementation)
; =============================================================================

; Basic list accessors
(define first (lambda (lst)
  (nth lst 0)))

(define second (lambda (lst)
  (nth lst 1)))

; Helper to check if a list starts with a specific symbol
(define starts-with? (lambda (lst symbol)
  (if (< (length lst) 1)
      #f
      (eq? (first lst) symbol))))

; Event constructors
(define event.make (lambda (type props)
  (cons 'event (cons ':type (cons type props)))))

(define event.type (lambda (ev)
  (if (event.valid? ev)
      (nth ev 2)
      #f)))

(define event.get (lambda (ev key)
  (event.get-helper (rest (rest (rest ev))) key)))

(define event.get-helper (lambda (props key)
  (if (< (length props) 2)
      #f
      (if (eq? (first props) key)
          (second props)
          (event.get-helper (rest (rest props)) key)))))

(define event.valid? (lambda (ev)
  (if (< (length ev) 3)
      #f
      (if (starts-with? ev 'event)
          (if (eq? (nth ev 1) ':type)
              #t
              #f)
          #f))))

; Fact constructors
(define fact.make (lambda (pred args props)
  (list 'fact ':pred pred ':args args ':props props)))

(define fact.pred (lambda (f)
  (if (fact.valid? f)
      (nth f 2)
      #f)))

(define fact.args (lambda (f)
  (if (fact.valid? f)
      (nth f 4)
      #f)))

(define fact.get (lambda (f key)
  (if (fact.valid? f)
      (fact.get-helper (nth f 6) key)
      #f)))

(define fact.get-helper (lambda (props key)
  (if (< (length props) 2)
      #f
      (if (eq? (first props) key)
          (second props)
          (fact.get-helper (rest (rest props)) key)))))

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
; UTILITY HELPERS
; =============================================================================

; Append two lists
(define append2 (lambda (list1 list2)
  (if (eq? (length list1) 0)
      list2
      (cons (first list1) (append2 (rest list1) list2)))))

; Map function over a list
(define map2 (lambda (fn lst)
  (if (eq? (length lst) 0)
      (list)
      (cons (fn (first lst)) (map2 fn (rest lst))))))

; Left fold
(define foldl (lambda (fn init lst)
  (if (eq? (length lst) 0)
      init
      (foldl fn (fn init (first lst)) (rest lst)))))

; Check if a list contains an element
(define contains? (lambda (lst elem)
  (if (eq? (length lst) 0)
      #f
      (if (eq? (first lst) elem)
          #t
          (contains? (rest lst) elem)))))

; =============================================================================
; SIMPLIFIED STATUTE APPROACH
; =============================================================================

; Create a statute as simple data structure (no lambda storage)
; Returns: ('statute id title weight props)
(define statute.make (lambda (id title props)
  (list 'statute id title 0 props)))

; Get statute ID (position 1)
(define statute.id (lambda (s)
  (nth s 1)))

; Get statute title (position 2)
(define statute.title (lambda (s)
  (nth s 2)))

; Get statute weight (position 3)
(define statute.weight (lambda (s)
  (nth s 3)))

; Get statute props (position 4)
(define statute.props (lambda (s)
  (nth s 4)))

; Create new statute with updated weight (pure - no mutation)
(define statute.with-weight (lambda (s w)
  (list 'statute 
        (statute.id s)
        (statute.title s)
        w
        (statute.props s))))

; =============================================================================
; HARDCODED STATUTE LOGIC (S774 - Intestate Inheritance)
; =============================================================================

; Check if event matches S774 conditions
(define s774.when (lambda (ev)
  (if (eq? (event.type ev) 'death)
      (contains? (event.get ev ':flags) 'no-will)
      #f)))

; Debug version of s774.when for testing
(define s774.when.debug (lambda (ev)
  (if (print "Debug - Checking S774 conditions...")
      (if (print (event.type ev))
          (if (print (eq? (event.type ev) 'death))
              (if (print (event.get ev ':flags))
                  (if (print (contains? (event.get ev ':flags) 'no-will))
                      (s774.when ev)
                      (s774.when ev))
                  (s774.when ev))
              (s774.when ev))
          (s774.when ev))
      (s774.when ev))))

; Generate facts for S774
(define s774.then (lambda (ev)
  (map2 (lambda (heir)
          (fact.make 'heir-share
                    (list (event.get ev ':person) heir)
                    (list ':share (/ 1 (length (event.get ev ':heirs))) ':basis 'S774)))
        (event.get ev ':heirs))))

; Evaluate S774 specifically
(define s774.eval (lambda (s ev)
  (if (s774.when.debug ev)
      (list (s774.then ev) (statute.with-weight s (+ (statute.weight s) 1)))
      (list (list) s))))

; =============================================================================
; REGISTRY SYSTEM
; =============================================================================

; Apply single statute to event based on its ID
(define statute.eval-by-id (lambda (s ev)
  (if (eq? (statute.id s) 'S774)
      (s774.eval s ev)
      (list (list) s))))

; Apply all statutes in registry to an event (pure)
; Returns: (all-facts, updated-registry)
(define registry.apply (lambda (registry ev)
  (if (eq? (length registry) 0)
      (list (list) (list))
      (list (append2 (first (statute.eval-by-id (first registry) ev))
                     (first (registry.apply (rest registry) ev)))
            (cons (second (statute.eval-by-id (first registry) ev))
                  (second (registry.apply (rest registry) ev)))))))

; =============================================================================
; DEMO AND TESTING
; =============================================================================

(print "=== STATUTE API DEMO ===")
(print "")

; Create the S774 statute
(define S774 (statute.make 'S774 "Intestate (equal split demo)" (list)))

; Debug: Print the statute structure
(print "Debug - S774 structure:")
(print S774)
(print "Debug - S774 ID:")
(print (statute.id S774))
(print "Debug - S774 weight:")
(print (statute.weight S774))
(print "")

; Create registry with S774
(define REG1 (list S774))

; Create sample death event
(define EV
  (event.make 'death
    (list ':person 'Pedro
          ':flags  (list 'no-will)
          ':heirs  (list 'Maria 'Juan 'Jose))))

(print "Sample Event:")
(print EV)
(print "")

; Apply registry to event
(print "Applying registry to event...")
(define result (registry.apply REG1 EV))
(define facts-out (first result))
(define REG2 (second result))

(print "Derived facts:")
(print facts-out)
(print "")

(print "Registry weights before:")
(print (map2 statute.weight REG1))
(print "Registry weights after:")
(print (map2 statute.weight REG2))
(print "")

; =============================================================================
; ASSERTIONS (Optional Testing)
; =============================================================================

; Simple assertion helper
(define assert= (lambda (label expected actual)
  (if (eq? expected actual)
      (print "PASS:" label)
      (print "FAIL:" label "Expected:" expected "Actual:" actual))))

(print "=== RUNNING ASSERTIONS ===")

; Test weight increment
(assert= "Weight increments correctly" 1 (statute.weight (first REG2)))

; Test facts count equals heirs count
(assert= "Facts count equals heirs count" 3 (length facts-out))

; Test share calculation (if facts exist)
(if (> (length facts-out) 0)
    (assert= "Share calculation correct" (/ 1 3) (fact.get (first facts-out) ':share))
    (print "No facts generated to test share calculation"))

(print "")
(print "=== STATUTE API COMPLETE ===")
(print "Ready for legal reasoning in Etherney eLisp!")
(print "")
(print "Demonstrated features:")
(print "- Statute definition and evaluation")
(print "- Registry application")
(print "- Fact derivation from events")
(print "- Statute weight tracking")
(print "- Pure functional approach (no mutation)")