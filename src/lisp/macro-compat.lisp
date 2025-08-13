; Macro Compatibility Layer for Etherney eLisp
; This file provides the necessary function bindings for macros
; without using dot notation that causes tokenization issues

; The actual implementations are provided by the statute API
; We just need to ensure the dash-notation names are available

; Since the statute API loads successfully and defines the dot-notation functions,
; we can reference them indirectly through the environment after loading

; This file should be loaded AFTER statute-api-final-working.lisp
; The macros will work because the functions they reference will be available
; in the environment after the statute API creates the aliases

; Legal Domain-Specific Macros for Etherney eLisp
(defmacro event (type . kvs)
  (list 'event-make
        (list 'quote type)
        (cons 'list kvs)))

(defmacro make-fact (pred args . kvs)
  (list 'fact-make
        (list 'quote pred)
        (cons 'list args)
        (cons 'list kvs)))

(defmacro statute (id title when-clause then-clause . props)
  (list 'statute-make
        (list 'quote id)
        title
        (second when-clause)
        (second then-clause)
        (if (= (length props) 0) 'nil (cons 'list props))))