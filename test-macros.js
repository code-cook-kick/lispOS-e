const { createGlobalEnv, evalProgramFromString } = require('./src/evaluator');

const env = createGlobalEnv();

console.log("=== Testing Macro System ===\n");

// Test 1: Simple macro definition and usage
console.log("Test 1: Simple increment macro");
const test1 = `
(defmacro inc (x) (list '+ x 1))
(inc 41)
`;

const result1 = evalProgramFromString(test1, env);
console.log("Result:", result1);
console.log("Expected: 42\n");

// Test 2: Macro with multiple arguments
console.log("Test 2: Macro with multiple arguments");
const test2 = `
(defmacro add-three (a b c) (list '+ a b c))
(add-three 10 20 30)
`;

const result2 = evalProgramFromString(test2, env);
console.log("Result:", result2);
console.log("Expected: 60\n");

// Test 3: Nested macro expansion
console.log("Test 3: Nested macro expansion");
const test3 = `
(defmacro double (x) (list '* x 2))
(defmacro quad (x) (list 'double (list 'double x)))
(quad 5)
`;

const result3 = evalProgramFromString(test3, env);
console.log("Result:", result3);
console.log("Expected: 20\n");

// Test 4: Macro that generates conditionals
console.log("Test 4: Macro generating conditionals");
const test4 = `
(defmacro when (condition body) (list 'if condition body))
(when (> 5 3) 'success)
`;

const result4 = evalProgramFromString(test4, env);
console.log("Result:", result4);
console.log("Expected: success\n");

// Test 5: Check that macros don't evaluate arguments
console.log("Test 5: Macros don't evaluate arguments");
const test5 = `
(defmacro debug-args (x) (list 'quote x))
(debug-args (+ 1 2))
`;

const result5 = evalProgramFromString(test5, env);
console.log("Result:", result5);
console.log("Expected: AST node for (+ 1 2), not 3\n");

console.log("=== Macro System Tests Complete ===");