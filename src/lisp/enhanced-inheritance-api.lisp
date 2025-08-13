; Etherney eLisp Legal Operating System - Enhanced Inheritance API
; Dynamic calculation for legitimate and illegitimate children shares
; Pure LISP implementation with complex legal reasoning

(print "=== Enhanced Inheritance API ===")
(print "Loading advanced legal reasoning system...")
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

; Filter function
(define filter2 (lambda (pred lst)
  (if (eq? (length lst) 0)
      (list)
      (if (pred (first lst))
          (cons (first lst) (filter2 pred (rest lst)))
          (filter2 pred (rest lst))))))

; =============================================================================
; ENHANCED INHERITANCE LOGIC
; =============================================================================

; Helper to extract heir information from event
; Event structure: (event :type death :person Pedro :legitimate-children (...) :illegitimate-children (...) :flags (...))
; Positions: 0=event, 1=:type, 2=death, 3=:person, 4=Pedro, 5=:legitimate-children, 6=(...), 7=:illegitimate-children, 8=(...), 9=:flags, 10=(...)

(define get-legitimate-children (lambda (ev)
  (if (> (length ev) 6)
      (nth ev 6)
      (list))))

(define get-illegitimate-children (lambda (ev)
  (if (> (length ev) 8)
      (nth ev 8)
      (list))))

(define get-person (lambda (ev)
  (if (> (length ev) 4)
      (nth ev 4)
      'Unknown)))

(define get-flags (lambda (ev)
  (if (> (length ev) 10)
      (nth ev 10)
      (list))))

; Calculate inheritance shares based on legal rules
; Rule: Legitimate children get full shares, illegitimate get half shares
(define calculate-inheritance-shares (lambda (ev)
  (if (contains? (get-flags ev) 'no-will)
      (calculate-intestate-shares ev)
      (list))))

(define calculate-intestate-shares (lambda (ev)
  (if (and (> (length (get-legitimate-children ev)) 0) 
           (> (length (get-illegitimate-children ev)) 0))
      (calculate-mixed-shares ev)
      (if (> (length (get-legitimate-children ev)) 0)
          (calculate-legitimate-only-shares ev)
          (if (> (length (get-illegitimate-children ev)) 0)
              (calculate-illegitimate-only-shares ev)
              (list))))))

; Case 1: Only legitimate children
(define calculate-legitimate-only-shares (lambda (ev)
  (map2 (lambda (child)
          (fact.make 'heir-share
                    (list (get-person ev) child)
                    (list ':share (/ 1 (length (get-legitimate-children ev)))
                          ':status 'legitimate
                          ':basis 'intestate-succession)))
        (get-legitimate-children ev))))

; Case 2: Only illegitimate children  
(define calculate-illegitimate-only-shares (lambda (ev)
  (map2 (lambda (child)
          (fact.make 'heir-share
                    (list (get-person ev) child)
                    (list ':share (/ 1 (length (get-illegitimate-children ev)))
                          ':status 'illegitimate
                          ':basis 'intestate-succession)))
        (get-illegitimate-children ev))))

; Case 3: Mixed legitimate and illegitimate children
; Rule: Legitimate children get 2 units, illegitimate get 1 unit
(define calculate-mixed-shares (lambda (ev)
  (append2 (calculate-legitimate-mixed-shares ev)
           (calculate-illegitimate-mixed-shares ev))))

(define calculate-legitimate-mixed-shares (lambda (ev)
  (map2 (lambda (child)
          (fact.make 'heir-share
                    (list (get-person ev) child)
                    (list ':share (/ 2 (calculate-total-units ev))
                          ':status 'legitimate
                          ':basis 'mixed-inheritance)))
        (get-legitimate-children ev))))

(define calculate-illegitimate-mixed-shares (lambda (ev)
  (map2 (lambda (child)
          (fact.make 'heir-share
                    (list (get-person ev) child)
                    (list ':share (/ 1 (calculate-total-units ev))
                          ':status 'illegitimate
                          ':basis 'mixed-inheritance)))
        (get-illegitimate-children ev))))

; Calculate total inheritance units
; Legitimate children = 2 units each, Illegitimate = 1 unit each
(define calculate-total-units (lambda (ev)
  (+ (* 2 (length (get-legitimate-children ev)))
     (length (get-illegitimate-children ev)))))

; =============================================================================
; STATUTE SYSTEM
; =============================================================================

; Create a statute as simple data structure
(define statute.make (lambda (id title props)
  (list 'statute id title 0 props)))

(define statute.id (lambda (s)
  (nth s 1)))

(define statute.weight (lambda (s)
  (nth s 3)))

(define statute.with-weight (lambda (s w)
  (list 'statute 
        (statute.id s)
        (nth s 2)
        w
        (nth s 4))))

; Enhanced statute evaluation
(define enhanced-inheritance.when (lambda (ev)
  #t))

(define enhanced-inheritance.then (lambda (ev)
  (calculate-inheritance-shares ev)))

(define enhanced-inheritance.eval (lambda (s ev)
  (if (enhanced-inheritance.when ev)
      (list (enhanced-inheritance.then ev) (statute.with-weight s (+ (statute.weight s) 1)))
      (list (list) s))))

; Registry system
(define statute.eval-by-id (lambda (s ev)
  (enhanced-inheritance.eval s ev)))

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

(print "=== ENHANCED INHERITANCE DEMO ===")
(print "")

; Create enhanced inheritance statute
(define ENHANCED-S774 (statute.make 'ENHANCED-S774 "Dynamic Inheritance Calculator" (list)))
(define ENHANCED-REG (list ENHANCED-S774))

(print "Enhanced statute created")
(print "")

; Test Case 1: Only legitimate children
(print "TEST 1: Only legitimate children")
(define EV-LEGIT-ONLY
  (event.make 'death
    (list ':person 'Pedro
          ':legitimate-children (list 'Maria 'Juan 'Jose)
          ':illegitimate-children (list)
          ':flags (list 'no-will))))

(define RESULT-LEGIT (registry.apply ENHANCED-REG EV-LEGIT-ONLY))
(define FACTS-LEGIT (first RESULT-LEGIT))
(print "Legitimate only - Facts count:" (length FACTS-LEGIT))
(print "Expected: 3, each gets 1/3 = 0.3333...")
(print "")

; Test Case 2: Only illegitimate children
(print "TEST 2: Only illegitimate children")
(define EV-ILLEGIT-ONLY
  (event.make 'death
    (list ':person 'Pedro
          ':legitimate-children (list)
          ':illegitimate-children (list 'Ana 'Carlos)
          ':flags (list 'no-will))))

(define RESULT-ILLEGIT (registry.apply ENHANCED-REG EV-ILLEGIT-ONLY))
(define FACTS-ILLEGIT (first RESULT-ILLEGIT))
(print "Illegitimate only - Facts count:" (length FACTS-ILLEGIT))
(print "Expected: 2, each gets 1/2 = 0.5")
(print "")

; Test Case 3: Mixed legitimate and illegitimate children
(print "TEST 3: Mixed legitimate and illegitimate children")
(define EV-MIXED
  (event.make 'death
    (list ':person 'Pedro
          ':legitimate-children (list 'Maria 'Juan)
          ':illegitimate-children (list 'Ana 'Carlos 'Sofia)
          ':flags (list 'no-will))))

(define RESULT-MIXED (registry.apply ENHANCED-REG EV-MIXED))
(define FACTS-MIXED (first RESULT-MIXED))
(print "Mixed inheritance - Facts count:" (length FACTS-MIXED))
(print "Expected: 5 total")
(print "Legitimate children (2): each gets 2/7 = 0.2857...")
(print "Illegitimate children (3): each gets 1/7 = 0.1428...")
(print "Total units: (2 legit × 2) + (3 illegit × 1) = 7")
(print "")

(print "=== ENHANCED INHERITANCE COMPLETE ===")
(print "Dynamic inheritance calculation ready!")