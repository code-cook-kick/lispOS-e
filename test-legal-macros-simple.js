const { createGlobalEnv, evalProgramFromString } = require('./src/evaluator');

const env = createGlobalEnv();

console.log("=== Testing Legal Domain-Specific Macros ===\n");

const macroTest = `
; Load the statute API and macros
(load "src/lisp/statute-api-final-working.lisp")
(load "src/lisp/macros.lisp")

; Test 1: event macro
(print "=== Testing event macro ===")
(define EV1 (event death :person Pedro :flags (no-will) :heirs (Maria Juan Jose)))
(print "Event type:")
(print (event.type EV1))
(print "Event heirs:")
(print (event.get EV1 ':heirs))

; Test 2: make-fact macro
(print "=== Testing make-fact macro ===")
(define FX1 (make-fact heir-share (Pedro Maria) :share 0.5 :basis S774))
(print "Fact predicate:")
(print (fact.pred FX1))
(print "Fact share:")
(print (fact.get FX1 ':share))

; Test 3: statute macro
(print "=== Testing statute macro ===")
(statute S999 "Test Statute"
  (when (lambda (ev) (eq? (event.type ev) 'death)))
  (then (lambda (ev) (list 'test-result))))

(print "Statute S999 created successfully")
(print (statute.id S999))

"All macro tests completed successfully!"
`;

try {
    const result = evalProgramFromString(macroTest, env);
    console.log("\nFinal result:", result);
} catch (error) {
    console.error("Error:", error.message);
}

console.log("\n=== Legal Macro Tests Complete ===");