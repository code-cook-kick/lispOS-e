(load "src/lisp/statute-api-final-working.lisp")

(print "=== TESTING 6 HEIRS SHARE CALCULATION ===")

; Create event with 6 heirs (same as smoke.lisp)
(define EV-6-HEIRS
  (event.make 'death
    (list ':person 'Pedro
          ':flags  (list 'no-will)
          ':heirs  (list 'Maria 'Juan 'Jose 'Pepe 'Pilar 'chichi))))

(define RESULT-6 (registry.apply REG1 EV-6-HEIRS))
(define FACTS-6 (first RESULT-6))

(print "Facts count:" (length FACTS-6))
(print "Expected: 6")

(if (> (length FACTS-6) 0)
    (print "First fact share:" (fact.get (first FACTS-6) ':share))
    (print "No facts to check"))

(print "Expected share (1/6):" (/ 1 6))
(print "Expected share decimal: 0.16666666666666666")

(print "=== TEST COMPLETE ===")