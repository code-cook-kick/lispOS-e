(load "src/lisp/statute-api-final-working.lisp")

(print "=== TESTING DYNAMIC HEIR CALCULATION ===")

(define EV-5-HEIRS
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan 'Jose 'Pepe 'Pilar))))

(define RESULT-5
  (registry.apply REG1 EV-5-HEIRS))

(define FACTS-5
  (first RESULT-5))

(print "5 heirs test:")

(print "Facts count:" (length FACTS-5))

(print "Expected: 5")

(define EV-2-HEIRS
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Alice 'Bob))))

(define RESULT-2
  (registry.apply REG1 EV-2-HEIRS))

(define FACTS-2
  (first RESULT-2))

(print "2 heirs test:")

(print "Facts count:" (length FACTS-2))

(print "Expected: 2")

(print "=== TEST COMPLETE ===")
