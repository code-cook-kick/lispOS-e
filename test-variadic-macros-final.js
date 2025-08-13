const { evalNode, createGlobalEnv, evalProgramFromString } = require('./src/evaluator');

console.log("=== COMPREHENSIVE MACRO SYSTEM TEST ===");

const env = createGlobalEnv();

try {
    console.log("\n1. Testing basic macro (inc)...");
    evalProgramFromString('(defmacro inc (x) (list (quote +) x 1))', env);
    const result1 = evalProgramFromString('(inc 5)', env);
    console.log("Result:", result1, result1 === 6 ? "✓ PASS" : "✗ FAIL");
    
    console.log("\n2. Testing basic macro (double)...");
    evalProgramFromString('(defmacro double (x) (list (quote *) x 2))', env);
    const result2 = evalProgramFromString('(double 4)', env);
    console.log("Result:", result2, result2 === 8 ? "✓ PASS" : "✗ FAIL");
    
    console.log("\n3. Testing variadic macro (simple)...");
    evalProgramFromString('(defmacro test-variadic (x . rest) (list (quote +) x (length rest)))', env);
    const result3 = evalProgramFromString('(test-variadic 10 a b c)', env);
    console.log("Result:", result3, result3 === 13 ? "✓ PASS" : "✗ FAIL");
    
    console.log("\n4. Testing variadic macro (cons-all)...");
    evalProgramFromString('(defmacro cons-all (first . rest) (if (= (length rest) 0) first (list (quote cons) first (cons (quote cons-all) rest))))', env);
    const result4 = evalProgramFromString('(cons-all 1 2 3)', env);
    console.log("Result:", result4);
    
    console.log("\n5. Testing macro with quote...");
    evalProgramFromString('(defmacro make-list (x . rest) (cons (quote list) (cons x rest)))', env);
    const result5 = evalProgramFromString('(make-list 1 2 3)', env);
    console.log("Result:", result5);
    
    console.log("\n=== ALL TESTS COMPLETED ===");
    
} catch (error) {
    console.error("Error:", error.message);
    console.error("Stack:", error.stack);
}