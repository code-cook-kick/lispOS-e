const { createGlobalEnv, evalProgramFromString } = require('./src/evaluator');

const env = createGlobalEnv();

console.log("=== Debugging Macro System ===\n");

// Test defmacro definition first
console.log("Test: Define a simple macro");
const defineTest = `(defmacro inc (x) (list '+ x 1))`;
const defineResult = evalProgramFromString(defineTest, env);
console.log("Define result:", defineResult);

// Check if macro is registered
console.log("Macro registered:", env.lookupMacro('inc') !== undefined);

// Test macro expansion step by step
console.log("\nTest: Use the macro");
const useTest = `(inc 41)`;
const useResult = evalProgramFromString(useTest, env);
console.log("Use result:", useResult);

// Test list construction
console.log("\nTest: List construction");
const listTest = `(list '+ 41 1)`;
const listResult = evalProgramFromString(listTest, env);
console.log("List result:", listResult);

// Test evaluation of constructed list
console.log("\nTest: Evaluate constructed list");
const evalTest = `(+ 41 1)`;
const evalResult = evalProgramFromString(evalTest, env);
console.log("Eval result:", evalResult);