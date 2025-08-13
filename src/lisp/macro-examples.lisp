; =============================================================================
; Etherney eLisp Macro Examples
; Demonstrating the macro system with legal domain macros
; =============================================================================

; Load the statute API first to have the base functions available
(load "src/lisp/statute-api-final-working.lisp")

(print "=== Macro System Examples ===")
(print "")

; Basic macro examples
(print "--- Basic Macros ---")

; Simple increment macro
(defmacro inc (x) (list '+ x 1))
(print "inc macro defined")
(print "(inc 41) =>" (inc 41))

; Decrement macro
(defmacro dec (x) (list '- x 1))
(print "(dec 43) =>" (dec 43))

; When macro (conditional execution)
(defmacro when (condition body) (list 'if condition body))
(print "(when (> 5 3) 'success) =>" (when (> 5 3) 'success))
(print "(when (< 5 3) 'failure) =>" (when (< 5 3) 'failure))

(print "")

; Legal domain macros
(print "--- Legal Domain Macros ---")

; Legal domain macros with different names to avoid conflicts
; Event creation macro - syntactic sugar for event.make
(defmacro make-event (type props) (list 'event.make type props))
(print "make-event macro defined")

; Fact creation macro - syntactic sugar for fact.make
(defmacro make-fact (pred args props) (list 'fact.make pred args props))
(print "make-fact macro defined")

; Statute creation macro - syntactic sugar for statute.make
(defmacro make-statute (id title props) (list 'statute.make id title props))
(print "make-statute macro defined")

(print "")

; Test legal domain macros
(print "--- Testing Legal Domain Macros ---")

; Create an event using the macro
(define test-event-macro (make-event 'death (list ':person 'Pedro ':heirs (list 'Maria 'Juan))))
(print "Created event using macro:")
(print "Event type:" (event.type test-event-macro))
(print "Event valid?" (event.valid? test-event-macro))

; Create a fact using the macro
(define test-fact-macro (make-fact 'heir-share (list 'Pedro 'Maria) (list ':share 0.5)))
(print "Created fact using macro:")
(print "Fact predicate:" (fact.pred test-fact-macro))
(print "Fact valid?" (fact.valid? test-fact-macro))

; Create a statute using the macro
(define test-statute-macro (make-statute 'TEST-MACRO "Test Macro Statute" (list)))
(print "Created statute using macro:")
(print "Statute ID:" (statute.id test-statute-macro))
(print "Statute weight:" (statute.weight test-statute-macro))

(print "")

; Advanced macro: unless (opposite of when)
(defmacro unless (condition body) (list 'if condition #f body))
(print "--- Advanced Macros ---")
(print "(unless (> 3 5) 'not-greater) =>" (unless (> 3 5) 'not-greater))
(print "(unless (> 5 3) 'not-greater) =>" (unless (> 5 3) 'not-greater))

; Macro that generates multiple statements
(defmacro define-and-print (name value) 
  (list 'define name value))

(define-and-print test-var 42)
(print "define-and-print created test-var:" test-var)

(print "")
(print "=== Macro Examples Complete ===")
(print "")
(print "Key benefits of the macro system:")
(print "- Domain-specific syntax for legal constructs")
(print "- Code generation at compile time")
(print "- No runtime overhead")
(print "- Pure LISP implementation")