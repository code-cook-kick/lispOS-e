(load "src/lisp/statute-api-final-working.lisp")

(print "=== VERIFYING SHARE CALCULATION ===")

; Create event with 6 heirs
(define EV-6-HEIRS
  (event.make 'death
    (list ':person 'Pedro
          ':flags  (list 'no-will)
          ':heirs  (list 'Maria 'Juan 'Jose 'Pepe 'Pilar 'chichi))))

(define RESULT-6 (registry.apply REG1 EV-6-HEIRS))
(define FACTS-6 (first RESULT-6))

(print "Facts count:" (length FACTS-6))

(if (> (length FACTS-6) 0)
    (print "First fact raw structure:" (first FACTS-6))
    (print "No facts to examine"))

(print "Expected share (1/6):" (/ 1 6))

; Try to access the share directly by position
(if (> (length FACTS-6) 0)
    (print "Share from position access:" (nth (nth (first FACTS-6) 6) 1))
    (print "No facts to check share"))

(print "=== VERIFICATION COMPLETE ===")