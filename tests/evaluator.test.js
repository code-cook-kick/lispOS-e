/**
 * Evaluator Tests
 * Tests for the evaluator module
 */

const { evalNode, createGlobalEnv } = require('../src/evaluator');
const { LispParser } = require('../src/parser');

class TestRunner {
    constructor() {
        this.passed = 0;
        this.failed = 0;
    }

    test(name, testFn) {
        try {
            testFn();
            this.passed++;
            console.log(`✓ ${name}`);
        } catch (error) {
            this.failed++;
            console.log(`✗ ${name}`);
            console.log(`  Error: ${error.message}`);
        }
    }

    assertEqual(actual, expected, message = '') {
        if (JSON.stringify(actual) !== JSON.stringify(expected)) {
            throw new Error(`${message}\n  Expected: ${JSON.stringify(expected)}\n  Actual: ${JSON.stringify(actual)}`);
        }
    }

    assertThrows(fn, expectedError = Error) {
        try {
            fn();
            throw new Error('Expected function to throw an error');
        } catch (error) {
            if (!(error instanceof expectedError)) {
                throw new Error(`Expected ${expectedError.name}, got ${error.constructor.name}: ${error.message}`);
            }
        }
    }

    // Helper to parse and evaluate Lisp code
    evalLisp(code) {
        const ast = LispParser.parseString(code);
        const env = createGlobalEnv();
        return ast.map(node => evalNode(node, env));
    }

    run() {
        console.log('\n=== Evaluator Tests ===\n');

        // Basic evaluation tests
        this.test('Evaluate number', () => {
            const result = this.evalLisp('42');
            this.assertEqual(result[0], 42);
        });

        this.test('Evaluate string', () => {
            const result = this.evalLisp('"hello"');
            this.assertEqual(result[0], 'hello');
        });

        this.test('Evaluate quoted symbol', () => {
            const ast = LispParser.parseString("'hello");
            const env = createGlobalEnv();
            const result = evalNode(ast[0], env);
            this.assertEqual(result.type, 'SYMBOL');
            this.assertEqual(result.value, 'hello');
        });

        this.test('Evaluate quoted list', () => {
            const ast = LispParser.parseString("'(1 2 3)");
            const env = createGlobalEnv();
            const result = evalNode(ast[0], env);
            this.assertEqual(result.type, 'LIST');
            this.assertEqual(result.children.length, 3);
        });

        // Arithmetic tests
        this.test('Addition - no args', () => {
            const result = this.evalLisp('(+)');
            this.assertEqual(result[0], 0);
        });

        this.test('Addition - single arg', () => {
            const result = this.evalLisp('(+ 5)');
            this.assertEqual(result[0], 5);
        });

        this.test('Addition - multiple args', () => {
            const result = this.evalLisp('(+ 1 2 3 4)');
            this.assertEqual(result[0], 10);
        });

        this.test('Addition - with floats', () => {
            const result = this.evalLisp('(+ 1.5 2.5)');
            this.assertEqual(result[0], 4);
        });

        this.test('Subtraction - two args', () => {
            const result = this.evalLisp('(- 10 3)');
            this.assertEqual(result[0], 7);
        });

        this.test('Subtraction - multiple args', () => {
            const result = this.evalLisp('(- 20 5 3)');
            this.assertEqual(result[0], 12);
        });

        this.test('Multiplication - no args', () => {
            const result = this.evalLisp('(*)');
            this.assertEqual(result[0], 1);
        });

        this.test('Multiplication - multiple args', () => {
            const result = this.evalLisp('(* 2 3 4)');
            this.assertEqual(result[0], 24);
        });

        this.test('Division - two args', () => {
            const result = this.evalLisp('(/ 12 3)');
            this.assertEqual(result[0], 4);
        });

        this.test('Division - floating point', () => {
            const result = this.evalLisp('(/ 7 2)');
            this.assertEqual(result[0], 3.5);
        });

        // Nested arithmetic
        this.test('Nested arithmetic - simple', () => {
            const result = this.evalLisp('(+ (* 2 3) 4)');
            this.assertEqual(result[0], 10);
        });

        this.test('Nested arithmetic - complex', () => {
            const result = this.evalLisp('(+ (* 2 3) (/ 8 2))');
            this.assertEqual(result[0], 10);
        });

        this.test('Nested arithmetic - deep', () => {
            const result = this.evalLisp('(* (+ 1 2) (+ 3 4))');
            this.assertEqual(result[0], 21);
        });

        // Print function tests
        this.test('Print single value', () => {
            // Capture console output
            let output = '';
            const originalLog = console.log;
            console.log = (...args) => { output = args.join(' '); };
            
            const result = this.evalLisp('(print "hello")');
            console.log = originalLog;
            
            this.assertEqual(output, 'hello');
            this.assertEqual(result[0], 'hello');
        });

        this.test('Print multiple values', () => {
            let output = '';
            const originalLog = console.log;
            console.log = (...args) => { output = args.join(' '); };
            
            const result = this.evalLisp('(print 1 2 3)');
            console.log = originalLog;
            
            this.assertEqual(output, '1 2 3');
            this.assertEqual(result[0], 3); // Returns last argument
        });

        // Error cases
        this.test('Error on undefined variable', () => {
            const env = createGlobalEnv();
            const ast = LispParser.parseString('undefined-var');
            this.assertThrows(() => evalNode(ast[0], env), ReferenceError);
        });

        this.test('Error on non-function application', () => {
            this.assertThrows(() => this.evalLisp('(42 1 2)'), Error);
        });

        // Environment tests
        this.test('Global environment has built-ins', () => {
            const env = createGlobalEnv();
            // Test that built-in functions exist
            const plus = env.get('+');
            this.assertEqual(typeof plus, 'function');
            
            const print = env.get('print');
            this.assertEqual(typeof print, 'function');
        });

        this.test('Built-in functions work correctly', () => {
            const env = createGlobalEnv();
            const plus = env.get('+');
            const result = plus(1, 2, 3);
            this.assertEqual(result, 6);
        });

        // Multiple expressions
        this.test('Multiple expressions', () => {
            const result = this.evalLisp('(+ 1 2) (* 3 4) (- 10 5)');
            this.assertEqual(result.length, 3);
            this.assertEqual(result[0], 3);
            this.assertEqual(result[1], 12);
            this.assertEqual(result[2], 5);
        });

        // Edge cases
        this.test('Empty list evaluation', () => {
            const ast = LispParser.parseString('()');
            const env = createGlobalEnv();
            const result = evalNode(ast[0], env);
            this.assertEqual(result, null);
        });

        this.test('Zero in arithmetic', () => {
            const result = this.evalLisp('(* 5 0 10)');
            this.assertEqual(result[0], 0);
        });

        this.test('Negative numbers', () => {
            const result = this.evalLisp('(+ -1 -2 -3)');
            this.assertEqual(result[0], -6);
        });

        // Summary
        console.log(`\nEvaluator Tests Complete:`);
        console.log(`  Passed: ${this.passed}`);
        console.log(`  Failed: ${this.failed}`);
        console.log(`  Total: ${this.passed + this.failed}`);
        
        return this.failed === 0;
    }
}

// Run tests if this file is executed directly
if (require.main === module) {
    const runner = new TestRunner();
    const success = runner.run();
    process.exit(success ? 0 : 1);
}

module.exports = TestRunner;