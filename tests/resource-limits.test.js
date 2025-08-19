/**
 * Resource Limits and Trampoline Tests
 * Tests for the new resource management and trampoline functionality
 */

const { evalProgramFromString, createGlobalEnv, ResourceError } = require('../src/evaluator');
const { LispParser } = require('../src/parser');

class ResourceLimitsTestRunner {
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

    assertThrows(fn, expectedError = Error, expectedMessage = null) {
        try {
            fn();
            throw new Error('Expected function to throw an error');
        } catch (error) {
            if (!(error instanceof expectedError)) {
                throw new Error(`Expected ${expectedError.name}, got ${error.constructor.name}: ${error.message}`);
            }
            if (expectedMessage && !error.message.includes(expectedMessage)) {
                throw new Error(`Expected error message to contain "${expectedMessage}", got: ${error.message}`);
            }
        }
    }

    // Helper to evaluate Lisp code with resource limits
    evalLispWithLimits(code, maxSteps = 1000, maxMacroExpansions = 100, useTrampoline = false) {
        const env = createGlobalEnv();
        return evalProgramFromString(code, env, maxSteps, maxMacroExpansions, useTrampoline);
    }

    run() {
        console.log('\n=== Resource Limits and Trampoline Tests ===\n');

        // Step Budget Tests
        this.test('Step budget - simple expression within limit', () => {
            const result = this.evalLispWithLimits('(+ 1 2 3)', 10);
            this.assertEqual(result, 6);
        });

        this.test('Step budget - complex expression within limit', () => {
            const result = this.evalLispWithLimits('(+ (* 2 3) (/ 12 4))', 20);
            this.assertEqual(result, 9);
        });

        this.test('Step budget - exceeds limit with simple loop', () => {
            const infiniteLoop = `
                (define loop (lambda (n) (loop (+ n 1))))
                (loop 0)
            `;
            this.assertThrows(
                () => this.evalLispWithLimits(infiniteLoop, 50),
                ResourceError,
                'Step budget exceeded'
            );
        });

        this.test('Step budget - exceeds limit with recursive function', () => {
            const recursiveLoop = `
                (define factorial (lambda (n) 
                    (if (= n 0) 1 (* n (factorial (- n 1))))))
                (factorial 100)
            `;
            this.assertThrows(
                () => this.evalLispWithLimits(recursiveLoop, 100),
                ResourceError,
                'Step budget exceeded'
            );
        });

        this.test('Step budget - large but finite computation', () => {
            const largeComputation = `
                (define sum-to-n (lambda (n acc)
                    (if (= n 0) acc (sum-to-n (- n 1) (+ acc n)))))
                (sum-to-n 10 0)
            `;
            const result = this.evalLispWithLimits(largeComputation, 200);
            this.assertEqual(result, 55); // Sum of 1 to 10
        });

        // Macro Expansion Budget Tests
        this.test('Macro expansion budget - simple macro within limit', () => {
            const simpleMacro = `
                (define-macro when (lambda (condition . body)
                    (list 'if condition (cons 'begin body))))
                (when #t (+ 1 2))
            `;
            const result = this.evalLispWithLimits(simpleMacro, 100, 10);
            this.assertEqual(result, 3);
        });

        this.test('Macro expansion budget - exceeds limit with recursive macro', () => {
            const recursiveMacro = `
                (define-macro infinite-expand (lambda ()
                    (list 'infinite-expand)))
                (infinite-expand)
            `;
            this.assertThrows(
                () => this.evalLispWithLimits(recursiveMacro, 1000, 5),
                ResourceError,
                'Macro expansion budget exceeded'
            );
        });

        this.test('Macro expansion budget - nested macros within limit', () => {
            const nestedMacros = `
                (define-macro when (lambda (condition . body)
                    (list 'if condition (cons 'begin body))))
                (define-macro unless (lambda (condition . body)
                    (list 'when (list 'not condition) body)))
                (unless #f (+ 5 5))
            `;
            const result = this.evalLispWithLimits(nestedMacros, 200, 20);
            this.assertEqual(result, 10);
        });

        // Trampoline Tests
        this.test('Trampoline - simple tail recursion', () => {
            const tailRecursion = `
                (define countdown (lambda (n)
                    (if (= n 0) 
                        'done 
                        (countdown (- n 1)))))
                (countdown 5)
            `;
            const result = this.evalLispWithLimits(tailRecursion, 1000, 100, true);
            this.assertEqual(result.type, 'SYMBOL');
            this.assertEqual(result.value, 'done');
        });

        this.test('Trampoline - deep tail recursion without stack overflow', () => {
            const deepRecursion = `
                (define deep-countdown (lambda (n acc)
                    (if (= n 0) 
                        acc 
                        (deep-countdown (- n 1) (+ acc 1)))))
                (deep-countdown 100 0)
            `;
            const result = this.evalLispWithLimits(deepRecursion, 2000, 100, true);
            this.assertEqual(result, 100);
        });

        this.test('Trampoline - mutual recursion', () => {
            const mutualRecursion = `
                (define even? (lambda (n)
                    (if (= n 0) #t (odd? (- n 1)))))
                (define odd? (lambda (n)
                    (if (= n 0) #f (even? (- n 1)))))
                (even? 10)
            `;
            const result = this.evalLispWithLimits(mutualRecursion, 1000, 100, true);
            this.assertEqual(result, true);
        });

        this.test('Trampoline - still respects step budget', () => {
            const infiniteRecursion = `
                (define infinite (lambda (n)
                    (infinite (+ n 1))))
                (infinite 0)
            `;
            this.assertThrows(
                () => this.evalLispWithLimits(infiniteRecursion, 50, 100, true),
                ResourceError,
                'Step budget exceeded'
            );
        });

        // Combined Resource Limit Tests
        this.test('Combined limits - both step and macro budget enforced', () => {
            const complexCode = `
                (define-macro repeat (lambda (n . body)
                    (if (= n 0) 
                        '(begin)
                        (cons 'begin (cons (cons 'begin body) 
                                          (list (list 'repeat (- n 1) body)))))))
                (repeat 10 (+ 1 1))
            `;
            this.assertThrows(
                () => this.evalLispWithLimits(complexCode, 1000, 5),
                ResourceError,
                'Macro expansion budget exceeded'
            );
        });

        this.test('Combined limits - within both budgets', () => {
            const reasonableCode = `
                (define-macro when (lambda (condition . body)
                    (list 'if condition (cons 'begin body))))
                (define factorial (lambda (n)
                    (when (> n 0) 
                        (if (= n 1) 1 (* n (factorial (- n 1)))))))
                (factorial 5)
            `;
            const result = this.evalLispWithLimits(reasonableCode, 500, 50);
            this.assertEqual(result, 120);
        });

        // Edge Cases and Error Handling
        this.test('Zero step budget throws immediately', () => {
            this.assertThrows(
                () => this.evalLispWithLimits('(+ 1 2)', 0),
                ResourceError,
                'Step budget exceeded'
            );
        });

        this.test('Zero macro expansion budget allows non-macro code', () => {
            const result = this.evalLispWithLimits('(+ 1 2 3)', 100, 0);
            this.assertEqual(result, 6);
        });

        this.test('Zero macro expansion budget prevents macro usage', () => {
            const macroCode = `
                (define-macro test (lambda () 42))
                (test)
            `;
            this.assertThrows(
                () => this.evalLispWithLimits(macroCode, 100, 0),
                ResourceError,
                'Macro expansion budget exceeded'
            );
        });

        // Resource Error Properties
        this.test('ResourceError has correct properties', () => {
            try {
                this.evalLispWithLimits('(define loop (lambda () (loop))) (loop)', 10);
            } catch (error) {
                this.assertEqual(error.constructor.name, 'ResourceError');
                this.assertEqual(typeof error.message, 'string');
                this.assertEqual(typeof error.stack, 'string');
            }
        });

        // Performance and Behavior Tests
        this.test('Large step budget allows complex computation', () => {
            const complexComputation = `
                (define fibonacci (lambda (n)
                    (if (< n 2) n 
                        (+ (fibonacci (- n 1)) (fibonacci (- n 2))))))
                (fibonacci 10)
            `;
            const result = this.evalLispWithLimits(complexComputation, 5000, 100);
            this.assertEqual(result, 55); // 10th Fibonacci number
        });

        this.test('Trampoline vs non-trampoline behavior consistency', () => {
            const simpleRecursion = `
                (define sum-to-n (lambda (n acc)
                    (if (= n 0) acc (sum-to-n (- n 1) (+ acc n)))))
                (sum-to-n 5 0)
            `;
            
            const resultWithoutTrampoline = this.evalLispWithLimits(simpleRecursion, 200, 100, false);
            const resultWithTrampoline = this.evalLispWithLimits(simpleRecursion, 200, 100, true);
            
            this.assertEqual(resultWithoutTrampoline, resultWithTrampoline);
            this.assertEqual(resultWithoutTrampoline, 15); // Sum of 1 to 5
        });

        // Integration with Legal Reasoning Tests
        this.test('Resource limits work with legal reasoning code', () => {
            const legalCode = `
                (define make-fact (lambda (predicate args properties)
                    (list ':predicate predicate ':args args ':properties properties)))
                (define process-facts (lambda (facts acc)
                    (if (null? facts) acc
                        (process-facts (rest facts) 
                                     (cons (first facts) acc)))))
                (let ((facts (list (make-fact 'inherits '(john estate) '())
                                  (make-fact 'spouse '(john mary) '()))))
                    (length (process-facts facts '())))
            `;
            const result = this.evalLispWithLimits(legalCode, 1000, 100);
            this.assertEqual(result, 2);
        });

        // Summary
        console.log(`\nResource Limits Tests Complete:`);
        console.log(`  Passed: ${this.passed}`);
        console.log(`  Failed: ${this.failed}`);
        console.log(`  Total: ${this.passed + this.failed}`);
        
        return this.failed === 0;
    }
}

// Run tests if this file is executed directly
if (require.main === module) {
    const runner = new ResourceLimitsTestRunner();
    const success = runner.run();
    process.exit(success ? 0 : 1);
}

module.exports = ResourceLimitsTestRunner;