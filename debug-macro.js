const { evalNode, createGlobalEnv, evalProgramFromString } = require('./src/evaluator');

console.log("Testing basic macro system...");

const env = createGlobalEnv();

try {
    console.log("1. Testing defmacro definition...");
    const result1 = evalProgramFromString('(defmacro inc (x) (list (quote +) x 1))', env);
    console.log("defmacro result:", result1);
    
    console.log("2. Testing basic macro expansion...");
    const result2 = evalProgramFromString('(inc 5)', env);
    console.log("basic macro expansion result:", result2);
    
    console.log("3. Testing variadic defmacro definition...");
    const result3 = evalProgramFromString('(defmacro test1 (x . rest) (list (quote list) "result" x rest))', env);
    console.log("variadic defmacro result:", result3);
    
    console.log("4. Testing variadic macro expansion...");
    const result4 = evalProgramFromString('(test1 1 2 3)', env);
    console.log("variadic macro expansion result:", result4);
    
} catch (error) {
    console.error("Error:", error.message);
    console.error("Stack:", error.stack);
}