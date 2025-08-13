const { evalNode, createGlobalEnv, evalProgramFromString } = require('./src/evaluator.js');

console.log("=== Testing Variadic Macro Fixes ===\n");

// Create global environment with built-ins
const globalEnv = createGlobalEnv();

const tests = [
    {
        name: "Basic variadic macro",
        code: `(defmacro test1 (x . rest) (list 'result x rest))
               (test1 1 2 3)`,
        expected: "(result 1 (2 3))"
    },
    {
        name: "Variadic with single argument",
        code: `(defmacro test2 (x . rest) (list 'result x rest))
               (test2 1)`,
        expected: "(result 1 ())"
    },
    {
        name: "Multiple fixed params + variadic",
        code: `(defmacro test3 (a b . rest) (list 'multi a b rest))
               (test3 1 2 3 4 5)`,
        expected: "(multi 1 2 (3 4 5))"
    },
    {
        name: "Fixed-arity macro (no variadic)",
        code: `(defmacro test4 (x y) (list 'fixed x y))
               (test4 10 20)`,
        expected: "(fixed 10 20)"
    },
    {
        name: "Nested macro with variadic",
        code: `(defmacro wrap (. xs) (cons 'wrapped xs))
               (wrap a b c)`,
        expected: "(wrapped a b c)"
    }
];

let passed = 0;
let failed = 0;

tests.forEach((test, index) => {
    console.log(`Test ${index + 1}: ${test.name}`);
    console.log(`Code: ${test.code}`);
    
    try {
        const result = evalProgramFromString(test.code, globalEnv);
        
        // Convert result to string for comparison
        let resultStr;
        if (result && typeof result === 'object' && result.toSExpression) {
            resultStr = result.toSExpression();
        } else if (Array.isArray(result)) {
            resultStr = `(${result.join(' ')})`;
        } else {
            resultStr = String(result);
        }
        
        console.log(`Result: ${resultStr}`);
        console.log(`Expected: ${test.expected}`);
        
        if (resultStr === test.expected) {
            console.log("✅ PASS\n");
            passed++;
        } else {
            console.log("❌ FAIL - Result doesn't match expected\n");
            failed++;
        }
        
    } catch (error) {
        console.log(`❌ FAIL - Error: ${error.message}\n`);
        failed++;
    }
});

// Test error conditions
console.log("=== Testing Error Conditions ===\n");

const errorTests = [
    {
        name: "Too few arguments for variadic macro",
        code: `(defmacro test5 (a b . rest) (list a b rest))
               (test5 1)`,
        shouldError: true,
        errorContains: "expects at least 2 arguments"
    },
    {
        name: "Wrong arity for fixed macro",
        code: `(defmacro test6 (x y) (list x y))
               (test6 1 2 3)`,
        shouldError: true,
        errorContains: "expects 2 arguments"
    },
    {
        name: "Expansion depth limit",
        code: `(defmacro recursive (x) (list 'recursive x))
               (recursive (recursive (recursive 1)))`,
        shouldError: false // This should work, just nested calls
    }
];

errorTests.forEach((test, index) => {
    console.log(`Error Test ${index + 1}: ${test.name}`);
    console.log(`Code: ${test.code}`);
    
    try {
        const result = evalProgramFromString(test.code, globalEnv);
        
        if (test.shouldError) {
            console.log(`❌ FAIL - Expected error but got result: ${result}\n`);
            failed++;
        } else {
            console.log(`✅ PASS - No error as expected\n`);
            passed++;
        }
        
    } catch (error) {
        if (test.shouldError) {
            if (test.errorContains && error.message.includes(test.errorContains)) {
                console.log(`✅ PASS - Got expected error: ${error.message}\n`);
                passed++;
            } else if (!test.errorContains) {
                console.log(`✅ PASS - Got expected error: ${error.message}\n`);
                passed++;
            } else {
                console.log(`❌ FAIL - Wrong error message. Expected to contain "${test.errorContains}", got: ${error.message}\n`);
                failed++;
            }
        } else {
            console.log(`❌ FAIL - Unexpected error: ${error.message}\n`);
            failed++;
        }
    }
});

console.log(`=== Results: ${passed} passed, ${failed} failed ===`);

if (failed === 0) {
    console.log("🎉 All variadic macro tests passed!");
} else {
    console.log("❌ Some tests failed. Variadic macros need more work.");
}