(load "src/lisp/statute-api-final-working.lisp")

(define EV1
  (event.make 'death
    (list ':person 'Pedro
          ':flags  (list 'no-will)
          ':heirs  (list 'Maria 'Juan 'Jose 'Pepe 'Pilar 'chichi))))

(define RES1 (registry.apply REG1 EV1))
(define FACTS1 (first RES1))
(define REG2   (second RES1))

(print "facts1.len=") (print (length FACTS1))     ; 3
(print "REG1.weights=") (print (map2 statute.weight REG1)) ; (0)
(print "REG2.weights=") (print (map2 statute.weight REG2)) ; (1)

(define EV2 (event.make 'sale (list ':person 'Pedro ':amount 100)))
(define RES2 (registry.apply REG2 EV2))
(define FACTS2 (first RES2))
(define REG3   (second RES2))

(print "facts2.len=") (print (length FACTS2))     ; 0
(print "REG3.weights=") (print (map2 statute.weight REG3)) ; (1)

(define RES3 (registry.apply REG2 EV1))
(define REG4 (second RES3))
(print "REG4.weights=") (print (map2 statute.weight REG4)) ; (2)

(map2 (lambda (f) (fact.get f ':basis)) FACTS1) ; (S774 S774 S774)
