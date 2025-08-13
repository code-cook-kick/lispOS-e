; Legal Domain-Specific Macros for Etherney eLisp
; Note: This file provides macros that work with the existing legal API
; The actual function implementations are loaded from statute-api-final-working.lisp

; --- utility builder for plist from alternating key/values ---
(define kv->plist
  (lambda (pairs)
    ; pairs is a flat list: (:k1 v1 :k2 v2 ...)
    pairs)) ; in our simple model, we accept it as-is

; (event death :person Pedro :flags (no-will) :heirs (Maria Juan))
; => Creates an event using the existing event constructor
(defmacro event (type . kvs)
  (list 'event.make
        (list 'quote type)
        (cons 'list kvs)))

; (make-fact heir-share (Pedro Maria) :share 0.5 :basis S774)
; => Creates a fact using the existing fact constructor
(defmacro make-fact (pred args . kvs)
  (list 'fact.make
        (list 'quote pred)
        (cons 'list args)
        (cons 'list kvs)))

; (statute S774 "Intestate (equal split demo)"
;   (when (lambda (ev) (and (eq? (event-type ev) 'death)
;                           (eq? (first (event-get ev ':flags)) 'no-will))))
;   (then  (lambda (ev) (equal-split-facts ev))))
; => Creates a statute using the existing statute constructor
(defmacro statute (id title when-clause then-clause . props)
  (list 'statute.make
        (list 'quote id)
        title
        (second when-clause)   ; (when <lambda ...>) -> extract lambda
        (second then-clause)   ; (then  <lambda ...>)
        (if (= (length props) 0) 'nil (cons 'list props))))