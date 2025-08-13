const { createGlobalEnv, evalProgramFromString } = require('./src/evaluator');

const env = createGlobalEnv();

console.log("=== Testing Legal Domain-Specific Macros ===\n");

const macroTest = `
; Load the statute API and macros
(load "src/lisp/statute-api-final-working.lisp")
(load "src/lisp/macros.lisp")

; 1) event macro
(define EV1
  (event death :person Pedro :flags (no-will) :heirs (Maria Juan Jose)))
(print (event.type EV1))           ; => death
(print (event.get EV1 ':heirs))    ; => (Maria Juan Jose)

; 2) make-fact macro
(define FX1
  (make-fact heir-share (Pedro Maria) :share 0.5 :basis S774))
(print (fact.pred FX1))            ; => heir-share
(print (fact.get FX1 ':share))     ; => 0.5

; 3) statute macro + registry.apply
(statute S774 "Intestate (equal split demo)"
  (when (lambda (ev)
          (and (eq? (event.type ev) 'death)
               (eq? (first (event.get ev ':flags)) 'no-will))))
  (then  (lambda (ev) (equal-split-facts ev))))

(define REG (list S774))

(define R (registry.apply REG EV1))
(define F (first R))
(define REG2 (second R))

(print (length F))                 ; => 3
(print (map2 statute.weight REG))  ; => (0)
(print (map2 statute.weight REG2)) ; => (1)

"Macro system test complete!"
`;

try {
    const result = evalProgramFromString(macroTest, env);
    console.log("\nFinal result:", result);
} catch (error) {
    console.error("Error:", error.message);
}

console.log("\n=== Legal Macro Tests Complete ===");