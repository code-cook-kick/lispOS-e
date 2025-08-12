/**
 * Integration Tests
 * Tests for the complete interpreter pipeline
 */

const { LispTokenizer } = require('../src/tokenizer');
const { LispParser } = require('../src/parser');
const { evalNode, createGlobalEnv } = require('../src/evaluator');

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

    // Complete pipeline: source -> tokens -> AST -> evaluation
    interpretLisp(source) {
        const tokenizer = new LispTokenizer(source);
        const tokens = tokenizer.tokenize();
        
        const parser = new LispParser(source);
        const ast = parser.parse();
        
        const env = createGlobalEnv();
        return ast.map(node => evalNode(node, env));
    }

    run() {
        console.log('\n=== Integration Tests ===\n');

        // Basic pipeline tests
        this.test('Complete pipeline - number', () => {
            const result = this.interpretLisp('42');
            this.assertEqual(result[0], 42);
        });

        this.test('Complete pipeline - string', () => {
            const result = this.interpretLisp('"hello world"');
            this.assertEqual(result[0], 'hello world');
        });

        this.test('Complete pipeline - simple arithmetic', () => {
            const result = this.interpretLisp('(+ 1 2 3)');
            this.assertEqual(result[0], 6);
        });

        this.test('Complete pipeline - nested arithmetic', () => {
            const result = this.interpretLisp('(+ (* 2 3) (/ 8 2))');
            this.assertEqual(result[0], 10);
        });

        this.test('Complete pipeline - quoted expression', () => {
            const result = this.interpretLisp("'(1 2 3)");
            this.assertEqual(result[0].type, 'LIST');
            this.assertEqual(result[0].children.length, 3);
        });

        // Complex expressions
        this.test('Complex nested expression', () => {
            const result = this.interpretLisp('(* (+ 1 2 3) (- 10 4) (/ 12 3))');
            // (+ 1 2 3) = 6, (- 10 4) = 6, (/ 12 3) = 4
            // 6 * 6 * 4 = 144
            this.assertEqual(result[0], 144);
        });

        this.test('Multiple expressions in sequence', () => {
            const result = this.interpretLisp('(+ 1 2) (* 3 4) (- 10 5)');
            this.assertEqual(result.length, 3);
            this.assertEqual(result[0], 3);
            this.assertEqual(result[1], 12);
            this.assertEqual(result[2], 5);
        });

        // Print function integration
        this.test('Print function with arithmetic', () => {
            let output = '';
            const originalLog = console.log;
            console.log = (...args) => { output = args.join(' '); };
            
            const result = this.interpretLisp('(print (+ 10 20))');
            console.log = originalLog;
            
            this.assertEqual(output, '30');
            this.assertEqual(result[0], 30);
        });

        this.test('Print with mixed types', () => {
            let output = '';
            const originalLog = console.log;
            console.log = (...args) => { output = args.join(' '); };
            
            const result = this.interpretLisp('(print "Result:" (+ 5 5))');
            console.log = originalLog;
            
            this.assertEqual(output, 'Result: 10');
            this.assertEqual(result[0], 10);
        });

        // String handling with escapes
        this.test('String with escape sequences', () => {
            const result = this.interpretLisp('"Line 1\\nLine 2\\tTabbed"');
            this.assertEqual(result[0], 'Line 1\nLine 2\tTabbed');
        });

        // Boolean handling
        this.test('Boolean literals', () => {
            const result = this.interpretLisp('#t #f');
            this.assertEqual(result[0], true);
            this.assertEqual(result[1], false);
        });

        // Comments handling
        this.test('Comments are ignored', () => {
            const result = this.interpretLisp('; This is a comment\n(+ 1 2) ; Another comment');
            this.assertEqual(result[0], 3);
        });

        // Whitespace handling
        this.test('Whitespace normalization', () => {
            const result = this.interpretLisp('  (  +   1   2   3  )  ');
            this.assertEqual(result[0], 6);
        });

        // Error propagation tests
        this.test('Tokenizer error propagation', () => {
            this.assertThrows(() => this.interpretLisp('"unterminated string'));
        });

        this.test('Parser error propagation', () => {
            this.assertThrows(() => this.interpretLisp('(+ 1 2'));
        });

        this.test('Evaluator error propagation', () => {
            this.assertThrows(() => this.interpretLisp('undefined-variable'));
        });

        // Real-world examples
        this.test('Calculator-like expressions', () => {
            const expressions = [
                '(+ 10 5)',      // 15
                '(- 20 7)',      // 13
                '(* 6 8)',       // 48
                '(/ 100 4)',     // 25
                '(+ (* 3 4) (/ 20 5))' // 16
            ];
            
            const expected = [15, 13, 48, 25, 16];
            
            expressions.forEach((expr, i) => {
                const result = this.interpretLisp(expr);
                this.assertEqual(result[0], expected[i], `Expression: ${expr}`);
            });
        });

        this.test('Data structure representation', () => {
            const result = this.interpretLisp("'(person (name \"John\") (age 30))");
            this.assertEqual(result[0].type, 'LIST');
            this.assertEqual(result[0].children.length, 3);
            this.assertEqual(result[0].children[0].value, 'person');
        });

        // Performance test (simple)
        this.test('Moderate complexity expression', () => {
            const expr = '(+ (* (+ 1 2) (+ 3 4)) (* (+ 5 6) (+ 7 8)))';
            const result = this.interpretLisp(expr);
            // (+ (* 3 7) (* 11 15)) = (+ 21 165) = 186
            this.assertEqual(result[0], 186);
        });

        // Edge cases
        this.test('Empty input', () => {
            const result = this.interpretLisp('');
            this.assertEqual(result.length, 0);
        });

        this.test('Only whitespace and comments', () => {
            const result = this.interpretLisp('   ; just a comment\n  ');
            this.assertEqual(result.length, 0);
        });

        this.test('Floating point precision', () => {
            const result = this.interpretLisp('(/ 1 3)');
            this.assertEqual(Math.abs(result[0] - 0.3333333333333333) < 0.0000000000000001, true);
        });

        // REPL-like session simulation
        this.test('REPL session simulation', () => {
            const session = [
                '(+ 1 2)',
                '(* 3 4)',
                '(print "Hello")',
                "'(a b c)"
            ];
            
            let output = '';
            const originalLog = console.log;
            console.log = (...args) => { output += args.join(' ') + '\n'; };
            
            const results = session.map(expr => this.interpretLisp(expr)[0]);
            console.log = originalLog;
            
            this.assertEqual(results[0], 3);
            this.assertEqual(results[1], 12);
            this.assertEqual(results[2], 'Hello');
            this.assertEqual(results[3].type, 'LIST');
        });

        // Summary
        console.log(`\nIntegration Tests Complete:`);
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