(load "src/lisp/enhanced-inheritance-api.lisp")

(print "=== DEBUGGING ENHANCED INHERITANCE ===")

; Create a test event and examine its structure
(define DEBUG-EV
  (event.make 'death
    (list ':person 'Pedro
          ':legitimate-children (list 'Maria 'Juan 'Jose)
          ':illegitimate-children (list)
          ':flags (list 'no-will))))

(print "Debug event structure:")
(print DEBUG-EV)
(print "Event length:" (length DEBUG-EV))

(print "Position 4 (person):" (nth DEBUG-EV 4))
(print "Position 6 (legit children):" (nth DEBUG-EV 6))
(print "Position 8 (illegit children):" (nth DEBUG-EV 8))
(print "Position 10 (flags):" (nth DEBUG-EV 10))

(print "get-person result:" (get-person DEBUG-EV))
(print "get-legitimate-children result:" (get-legitimate-children DEBUG-EV))
(print "get-illegitimate-children result:" (get-illegitimate-children DEBUG-EV))
(print "get-flags result:" (get-flags DEBUG-EV))

(print "contains no-will?" (contains? (get-flags DEBUG-EV) 'no-will))

(print "=== DEBUG COMPLETE ===")