const { evalNode, createGlobalEnv, evalProgramFromString } = require('./src/evaluator');

console.log("=== CORRECTED COMPREHENSIVE SMOKE TEST ===");

const env = createGlobalEnv();

try {
    // First load the legal domain functions
    console.log("\n0. Loading legal domain functions...");
    const legalLoadResult = evalProgramFromString('(load "src/lisp/statute-api-final-working.lisp")', env);
    console.log("Legal domain load result:", legalLoadResult);
    
    console.log("\n1. Testing variadic macro (test1) - corrected version...");
    // Use 'list instead of undefined 'result symbol
    evalProgramFromString('(defmacro test1 (x . rest) (list (quote list) "result" x rest))', env);
    
    console.log("Testing: (test1 1 2 3) should return (list \"result\" 1 (2 3))");
    const result1 = evalProgramFromString('(test1 1 2 3)', env);
    console.log("Result:", result1);
    
    console.log("Testing: (test1 7) should return (list \"result\" 7 ())");
    const result2 = evalProgramFromString('(test1 7)', env);
    console.log("Result:", result2);
    
    console.log("\n2. Testing nested macros...");
    evalProgramFromString('(defmacro inc (x) (list (quote +) x 1))', env);
    evalProgramFromString('(defmacro quad (x) (list (quote *) (inc x) 2))', env);
    
    console.log("Testing: (quad 5) should return 12");
    const result3 = evalProgramFromString('(quad 5)', env);
    console.log("Result:", result3);
    
    console.log("\n3. Testing simple variadic macro with arithmetic...");
    evalProgramFromString('(defmacro add-all (first . rest) (if (= (length rest) 0) first (list (quote +) first (cons (quote add-all) rest))))', env);
    const result4 = evalProgramFromString('(add-all 1 2 3)', env);
    console.log("add-all result:", result4);
    
    console.log("\n4. Testing legal domain integration...");
    console.log("Loading src/lisp/macros.lisp...");
    const loadResult = evalProgramFromString('(load "src/lisp/macros.lisp")', env);
    console.log("Load result:", loadResult);
    
    if (loadResult && loadResult.type !== "error") {
        console.log("Testing event creation...");
        const eventResult = evalProgramFromString('(define EV (event death :person Pedro :flags (no-will) :heirs (Maria Juan Jose)))', env);
        console.log("Event creation result:", eventResult);
        
        if (eventResult && eventResult.type !== "error") {
            console.log("Testing statute definition...");
            const statuteResult = evalProgramFromString(`(statute S774 "Intestate (equal split demo)"
              (when (lambda (ev) (and (eq? (event.type ev) 'death)
                                      (eq? (first (event.get ev ':flags)) 'no-will))))
              (then  (lambda (ev) (equal-split-facts ev))))`, env);
            console.log("Statute definition result:", statuteResult);
            
            if (statuteResult && statuteResult.type !== "error") {
                console.log("Testing registry application...");
                const registryResult = evalProgramFromString('(define R (registry.apply (list S774) EV))', env);
                console.log("Registry result:", registryResult);
                
                if (registryResult && registryResult.type !== "error") {
                    console.log("Testing final length check...");
                    const lengthResult = evalProgramFromString('(length (first R))', env);
                    console.log("Length result:", lengthResult, "should be 3");
                }
            }
        }
    }
    
    console.log("\n=== CORRECTED SMOKE TEST COMPLETED ===");
    
} catch (error) {
    console.error("Error:", error.message);
    console.error("Stack:", error.stack);
}