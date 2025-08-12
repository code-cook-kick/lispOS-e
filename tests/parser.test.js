/**
 * Parser Tests
 * Tests for the LispParser class
 */

const { LispParser, ParseError, ASTNode } = require('../src/parser');

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

    run() {
        console.log('\n=== Parser Tests ===\n');

        // Basic parsing tests
        this.test('Parse number', () => {
            const parser = new LispParser('42');
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'NUMBER');
            this.assertEqual(ast[0].value, 42);
        });

        this.test('Parse string', () => {
            const parser = new LispParser('"hello"');
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'STRING');
            this.assertEqual(ast[0].value, 'hello');
        });

        this.test('Parse symbol', () => {
            const parser = new LispParser('hello');
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'SYMBOL');
            this.assertEqual(ast[0].value, 'hello');
        });

        this.test('Parse boolean', () => {
            const parser = new LispParser('#t');
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'BOOLEAN');
            this.assertEqual(ast[0].value, true);
        });

        this.test('Parse empty list', () => {
            const parser = new LispParser('()');
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'LIST');
            this.assertEqual(ast[0].children.length, 0);
        });

        this.test('Parse simple list', () => {
            const parser = new LispParser('(+ 1 2)');
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'LIST');
            this.assertEqual(ast[0].children.length, 3);
            this.assertEqual(ast[0].children[0].type, 'SYMBOL');
            this.assertEqual(ast[0].children[0].value, '+');
            this.assertEqual(ast[0].children[1].type, 'NUMBER');
            this.assertEqual(ast[0].children[1].value, 1);
            this.assertEqual(ast[0].children[2].type, 'NUMBER');
            this.assertEqual(ast[0].children[2].value, 2);
        });

        this.test('Parse nested list', () => {
            const parser = new LispParser('(+ 1 (* 2 3))');
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'LIST');
            this.assertEqual(ast[0].children.length, 3);
            
            // Check nested list
            const nested = ast[0].children[2];
            this.assertEqual(nested.type, 'LIST');
            this.assertEqual(nested.children.length, 3);
            this.assertEqual(nested.children[0].value, '*');
            this.assertEqual(nested.children[1].value, 2);
            this.assertEqual(nested.children[2].value, 3);
        });

        this.test('Parse quoted expression', () => {
            const parser = new LispParser("'hello");
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'QUOTE');
            this.assertEqual(ast[0].children.length, 1);
            this.assertEqual(ast[0].children[0].type, 'SYMBOL');
            this.assertEqual(ast[0].children[0].value, 'hello');
        });

        this.test('Parse quoted list', () => {
            const parser = new LispParser("'(1 2 3)");
            const ast = parser.parse();
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'QUOTE');
            this.assertEqual(ast[0].children[0].type, 'LIST');
            this.assertEqual(ast[0].children[0].children.length, 3);
        });

        this.test('Parse multiple expressions', () => {
            const parser = new LispParser('42 "hello" (+ 1 2)');
            const ast = parser.parse();
            this.assertEqual(ast.length, 3);
            this.assertEqual(ast[0].type, 'NUMBER');
            this.assertEqual(ast[1].type, 'STRING');
            this.assertEqual(ast[2].type, 'LIST');
        });

        // Special form validation tests
        this.test('Validate if form - correct args', () => {
            const parser = new LispParser('(if #t 1 2)');
            const ast = parser.parse(); // Should not throw
            this.assertEqual(ast[0].children[0].value, 'if');
        });

        this.test('Validate if form - too few args', () => {
            const parser = new LispParser('(if #t)');
            this.assertThrows(() => parser.parse(), ParseError);
        });

        this.test('Validate lambda form - correct args', () => {
            const parser = new LispParser('(lambda (x) (* x x))');
            const ast = parser.parse(); // Should not throw
            this.assertEqual(ast[0].children[0].value, 'lambda');
        });

        this.test('Validate lambda form - invalid params', () => {
            const parser = new LispParser('(lambda x (* x x))');
            this.assertThrows(() => parser.parse(), ParseError);
        });

        // Error cases
        this.test('Error on unbalanced parentheses - missing close', () => {
            const parser = new LispParser('(+ 1 2');
            this.assertThrows(() => parser.parse(), ParseError);
        });

        this.test('Error on unbalanced parentheses - extra close', () => {
            const parser = new LispParser('(+ 1 2))');
            this.assertThrows(() => parser.parse(), ParseError);
        });

        this.test('Error on quote without expression', () => {
            const parser = new LispParser("'");
            this.assertThrows(() => parser.parse(), ParseError);
        });

        // Static utility tests
        this.test('Static parseString method', () => {
            const ast = LispParser.parseString('(+ 1 2)');
            this.assertEqual(ast.length, 1);
            this.assertEqual(ast[0].type, 'LIST');
        });

        this.test('Static validateSyntax method - valid', () => {
            const result = LispParser.validateSyntax('(+ 1 2)');
            this.assertEqual(result.valid, true);
            this.assertEqual(result.errors.length, 0);
        });

        this.test('Static validateSyntax method - invalid', () => {
            const result = LispParser.validateSyntax('(+ 1 2');
            this.assertEqual(result.valid, false);
            this.assertEqual(result.errors.length, 1);
        });

        this.test('Static astToLisp method', () => {
            const ast = LispParser.parseString('(+ 1 2)');
            const lisp = LispParser.astToLisp(ast);
            this.assertEqual(lisp, '(+ 1 2)');
        });

        this.test('Static extractSymbols method', () => {
            const ast = LispParser.parseString('(+ x (* y z))');
            const symbols = LispParser.extractSymbols(ast);
            // Sort both arrays to ensure consistent comparison
            const sortedSymbols = symbols.sort();
            const expectedSymbols = ['+', '*', 'x', 'y', 'z'].sort();
            this.assertEqual(sortedSymbols, expectedSymbols);
        });

        this.test('AST node toSExpression method', () => {
            const ast = LispParser.parseString('(+ 1 "hello")');
            const sexp = ast[0].toSExpression();
            this.assertEqual(sexp, '(+ 1 "hello")');
        });

        // Source location tracking
        this.test('Source location tracking', () => {
            const parser = new LispParser('(+ 1 2)');
            const ast = parser.parse();
            this.assertEqual(ast[0].sourceInfo.line, 1);
            this.assertEqual(ast[0].sourceInfo.column, 1);
        });

        // Summary
        console.log(`\nParser Tests Complete:`);
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