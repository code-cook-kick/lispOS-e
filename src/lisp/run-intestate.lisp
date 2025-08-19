(print
  "=== Loading Intestate Succession with Proper Dependencies ===")

(load "src/lisp/statute-api-final-working.lisp")

(load "src/lisp/macros.lisp")

(load "src/lisp/lambda-rules.lisp")

(load "src/lisp/intestate-succession-ph.lisp")

(print "✅ Intestate module loaded with lambda rules")

(print "=== SMOKE TEST ===")

(define EV
  (list
    'event
    ':type
    'death
    ':id
    'E001
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan 'Jose)
    ':jurisdiction
    'PH))

(print "✓ Test event created")

(define REG
  (list S-INTESTATE-BASIC))

(print
  "✓ Test registry created with"
  (safe-length REG)
  "statutes")

(define RES
  (registry.apply REG EV))

(define FACTS
  (first RES))

(print "✓ Registry application completed")

(print "  Facts count:" (safe-length FACTS))

(print
  "  Shares:"
  (safe-map (lambda (f)
  (fact.get f ':share)) FACTS))

(define total-shares
  (safe-fold
    (lambda (acc fact)
    (let
      ((share (fact.get fact ':share)))
      (if (eq? share null)
        acc
        (+ acc share))))
    0
    FACTS))

(print "  Total shares:" total-shares)

(print
  "  Mathematically correct:"
  (< (abs (- total-shares 1.0)) 0.01))

(print "")

(print "🎉 INTESTATE SUCCESSION SMOKE TEST COMPLETED!")
