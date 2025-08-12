/**
 * Tokenizer Tests
 * Tests for the LispTokenizer class
 */

const { LispTokenizer, Token, TokenizerError } = require('../src/tokenizer');

class TestRunner {
    constructor() {
        this.passed = 0;
        this.failed = 0;
        this.tests = [];
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
        console.log('\n=== Tokenizer Tests ===\n');
        
        // Basic token tests
        this.test('Tokenize numbers', () => {
            const tokenizer = new LispTokenizer('42 3.14 -17');
            const tokens = tokenizer.tokenize();
            this.assertEqual(tokens.length, 4); // 3 numbers + EOF
            this.assertEqual(tokens[0].type, 'NUMBER');
            this.assertEqual(tokens[0].value, 42);
            this.assertEqual(tokens[1].type, 'NUMBER');
            this.assertEqual(tokens[1].value, 3.14);
            this.assertEqual(tokens[2].type, 'NUMBER');
            this.assertEqual(tokens[2].value, -17);
        });

        this.test('Tokenize strings', () => {
            const tokenizer = new LispTokenizer('"hello" "world\\n"');
            const tokens = tokenizer.tokenize();
            this.assertEqual(tokens.length, 3); // 2 strings + EOF
            this.assertEqual(tokens[0].type, 'STRING');
            this.assertEqual(tokens[0].value, 'hello');
            this.assertEqual(tokens[1].type, 'STRING');
            this.assertEqual(tokens[1].value, 'world\n');
        });

        this.test('Tokenize symbols', () => {
            const tokenizer = new LispTokenizer('hello + my-var');
            const tokens = tokenizer.tokenize();
            this.assertEqual(tokens.length, 4); // 3 symbols + EOF
            this.assertEqual(tokens[0].type, 'SYMBOL');
            this.assertEqual(tokens[0].value, 'hello');
            this.assertEqual(tokens[1].type, 'SYMBOL');
            this.assertEqual(tokens[1].value, '+');
            this.assertEqual(tokens[2].type, 'SYMBOL');
            this.assertEqual(tokens[2].value, 'my-var');
        });

        this.test('Tokenize parentheses', () => {
            const tokenizer = new LispTokenizer('()');
            const tokens = tokenizer.tokenize();
            this.assertEqual(tokens.length, 3); // LPAREN, RPAREN, EOF
            this.assertEqual(tokens[0].type, 'LPAREN');
            this.assertEqual(tokens[1].type, 'RPAREN');
        });

        this.test('Tokenize quotes', () => {
            const tokenizer = new LispTokenizer("'hello");
            const tokens = tokenizer.tokenize();
            this.assertEqual(tokens.length, 3); // QUOTE, SYMBOL, EOF
            this.assertEqual(tokens[0].type, 'QUOTE');
            this.assertEqual(tokens[1].type, 'SYMBOL');
            this.assertEqual(tokens[1].value, 'hello');
        });

        this.test('Tokenize booleans', () => {
            const tokenizer = new LispTokenizer('#t #f');
            const tokens = tokenizer.tokenize();
            this.assertEqual(tokens.length, 3); // 2 booleans + EOF
            this.assertEqual(tokens[0].type, 'BOOLEAN');
            this.assertEqual(tokens[0].value, true);
            this.assertEqual(tokens[1].type, 'BOOLEAN');
            this.assertEqual(tokens[1].value, false);
        });

        this.test('Tokenize complex expression', () => {
            const tokenizer = new LispTokenizer('(+ 1 (* 2 3))');
            const tokens = tokenizer.tokenize();
            const types = tokens.map(t => t.type);
            this.assertEqual(types, ['LPAREN', 'SYMBOL', 'NUMBER', 'LPAREN', 'SYMBOL', 'NUMBER', 'NUMBER', 'RPAREN', 'RPAREN', 'EOF']);
        });

        this.test('Skip comments', () => {
            const tokenizer = new LispTokenizer('; This is a comment\n(+ 1 2)');
            const tokens = tokenizer.tokenize();
            const types = tokens.map(t => t.type);
            this.assertEqual(types, ['LPAREN', 'SYMBOL', 'NUMBER', 'NUMBER', 'RPAREN', 'EOF']);
        });

        this.test('Handle whitespace', () => {
            const tokenizer = new LispTokenizer('  (  +   1   2  )  ');
            const tokens = tokenizer.tokenize();
            const types = tokens.map(t => t.type);
            this.assertEqual(types, ['LPAREN', 'SYMBOL', 'NUMBER', 'NUMBER', 'RPAREN', 'EOF']);
        });

        // Error cases
        this.test('Error on unterminated string', () => {
            const tokenizer = new LispTokenizer('"unterminated');
            this.assertThrows(() => tokenizer.tokenize(), TokenizerError);
        });

        this.test('Error on invalid character', () => {
            const tokenizer = new LispTokenizer('@invalid');
            this.assertThrows(() => tokenizer.tokenize(), TokenizerError);
        });

        this.test('Error on invalid number', () => {
            const tokenizer = new LispTokenizer('3.14.15');
            this.assertThrows(() => tokenizer.tokenize(), TokenizerError);
        });

        this.test('Source location tracking', () => {
            const tokenizer = new LispTokenizer('hello\nworld');
            const tokens = tokenizer.tokenize();
            this.assertEqual(tokens[0].line, 1);
            this.assertEqual(tokens[0].column, 1);
            this.assertEqual(tokens[1].line, 2);
            this.assertEqual(tokens[1].column, 1);
        });

        // Summary
        console.log(`\nTokenizer Tests Complete:`);
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