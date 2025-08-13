; Etherney eLisp Legal Operating System - Statute/Rule API
; Pure LISP implementation for legal statute processing
; Self-contained with all dependencies included

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

; Property list utilities
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

; Event constructors
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

; Fact constructors
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
; STATUTE CONSTRUCTORS
; =============================================================================

; Create a statute: (statute.make id title when then props)
; Returns: ('statute :id <id> :title <title> :when <when> :then <then> :weight 0 :props <props>)
(define statute.make (lambda (id title when then props)
  (list 'statute 
        ':id id 
        ':title title 
        ':when when 
        ':then then 
        ':weight 0 
        ':props props)))

; Get statute ID
(define statute.id (lambda (s)
  (plist-get (rest s) ':id)))

; Get statute when condition
(define statute.when (lambda (s)
  (plist-get (rest s) ':when)))

; Get statute then action
(define statute.then (lambda (s)
  (plist-get (rest s) ':then)))

; Get statute weight
(define statute.weight (lambda (s)
  (plist-get (rest s) ':weight)))

; Create new statute with updated weight (pure - no mutation)
(define statute.with-weight (lambda (s w)
  (list 'statute 
        ':id (statute.id s)
        ':title (plist-get (rest s) ':title)
        ':when (statute.when s)
        ':then (statute.then s)
        ':weight w
        ':props (plist-get (rest s) ':props))))

; =============================================================================
; STATUTE EVALUATION
; =============================================================================

; Evaluate a statute on an event (pure)
; Returns: (facts, updated-statute) or (nil, original-statute)
(define statute.eval (lambda (s ev)
  (if (statute.when-eval s ev)
      (list (statute.then-eval s ev) (statute.with-weight s (+ (statute.weight s) 1)))
      (list (list) s))))

; Helper to evaluate when condition
(define statute.when-eval (lambda (s ev)
  ((statute.when s) ev)))

; Helper to evaluate then action
(define statute.then-eval (lambda (s ev)
  ((statute.then s) ev)))

; =============================================================================
; REGISTRY APPLICATION
; =============================================================================

; Apply all statutes in registry to an event (pure)
; Returns: (all-facts, updated-registry)
(define registry.apply (lambda (registry ev)
  (if (eq? (length registry) 0)
      (list (list) (list))
      (list (append2 (first (statute.eval (first registry) ev))
                     (first (registry.apply (rest registry) ev)))
            (cons (second (statute.eval (first registry) ev))
                  (second (registry.apply (rest registry) ev)))))))

; =============================================================================
; DEMO STATUTE - INTESTATE INHERITANCE (S774)
; =============================================================================

; Helper: Check if event has no-will flag
(define has-no-will? (lambda (ev)
  (contains? (event.get ev ':flags) 'no-will)))

; When condition: death event with no-will flag
(define when-intestate (lambda (ev)
  (if (eq? (event.type ev) 'death)
      (has-no-will? ev)
      #f)))

; Helper: Create equal split facts for heirs
(define equal-split-facts (lambda (ev)
  (map2 (lambda (heir)
          (fact.make 'heir-share
                    (list (event.get ev ':person) heir)
                    (list ':share (/ 1 (length (event.get ev ':heirs))) ':basis 'S774)))
        (event.get ev ':heirs))))

; Then action: produce equal split facts
(define then-intestate (lambda (ev)
  (equal-split-facts ev)))

; Create the S774 statute
(define S774
  (statute.make 'S774 "Intestate (equal split demo)"
                when-intestate
                then-intestate
                (list)))

; Create registry with S774
(define REG1 (list S774))

; =============================================================================
; DEMO AND TESTING
; =============================================================================

(print "=== STATUTE API DEMO ===")
(print "")

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

; Test share calculation
(define expected-share (/ 1 3))
(define actual-share (fact.get (first facts-out) ':share))
(assert= "Share calculation correct" expected-share actual-share)

(print "")
(print "=== STATUTE API COMPLETE ===")
(print "Ready for legal reasoning in Etherney eLisp!")
(print "")
(print "Demonstrated features:")
(print "- Statute definition and evaluation")
(print "- Registry application")
(print "- Fact derivation from events")
(print "- Statute weight tracking")