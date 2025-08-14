;;; Intestate Succession Module Runner with Proper Load Order
;;; Ensures all dependencies are loaded before intestate succession

(print "=== Loading Intestate Succession with Proper Dependencies ===")

;; Load in correct order
(load "src/lisp/statute-api-final-working.lisp")
(load "src/lisp/macros.lisp")
(load "src/lisp/lambda-rules.lisp")          ; <- defines spawn-statute
(load "src/lisp/intestate-succession-ph.lisp")

(print "✅ Intestate module loaded with lambda rules")

;; Quick smoke test after loading
(print "=== SMOKE TEST ===")

;; Create minimal event using the available constructor
(define EV
  (list 'event ':type 'death
        ':id 'E001
        ':person 'Pedro
        ':flags (list 'no-will)
        ':heirs (list 'Maria 'Juan 'Jose)
        ':jurisdiction 'PH))

(print "✓ Test event created")

;; Build registry with basic intestate statute (from lambda-rules)
(define REG (list S-INTESTATE-BASIC))

(print "✓ Test registry created with" (safe-length REG) "statutes")

;; Apply and inspect
(define RES (registry.apply REG EV))
(define FACTS (first RES))

(print "✓ Registry application completed")
(print "  Facts count:" (safe-length FACTS))
(print "  Shares:" (safe-map (lambda (f) (fact.get f ':share)) FACTS))

;; Validate total shares
(define total-shares 
  (safe-fold 
    (lambda (acc fact)
      (let ((share (fact.get fact ':share)))
        (if (eq? share null) acc (+ acc share))))
    0
    FACTS))

(print "  Total shares:" total-shares)
(print "  Mathematically correct:" (< (abs (- total-shares 1.0)) 0.01))

(print "")
(print "🎉 INTESTATE SUCCESSION SMOKE TEST COMPLETED!")