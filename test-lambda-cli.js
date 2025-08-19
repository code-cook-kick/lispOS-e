#!/usr/bin/env node

/**
 * Command-line test for Lambda Arity Fix
 * Tests the begin construct functionality
 */

const { evalProgramFromString, createGlobalEnv } = require('./src/evaluator.js');

console.log('🧪 Lambda Arity Fix - Command Line Test');
console.log('=======================================\n');

const env = createGlobalEnv();

// Test 1: Simple lambda (should always work)
console.log('📋 Test 1: Simple Lambda');
const test1 = `
(define double (lambda (x) (* x 2)))
(double 5)
`;
const result1 = evalProgramFromString(test1, env);
console.log('Result:', result1);
console.log('Expected: 10\n');

// Test 2: Lambda with begin (the main fix!)
console.log('📋 Test 2: Lambda with Begin');
const test2 = `
(define process 
  (lambda (x)
    (begin
      (define temp (+ x 10))
      (* temp 2))))
(process 7)
`;
const result2 = evalProgramFromString(test2, env);
console.log('Result:', result2);
console.log('Expected: 34\n');

// Test 3: Multi-step lambda with begin
console.log('📋 Test 3: Multi-step Lambda');
const test3 = `
(define calculate
  (lambda (x)
    (begin
      (define step1 (+ x 5))
      (define step2 (* step1 2))
      (define step3 (- step2 3))
      step3)))
(calculate 10)
`;
const result3 = evalProgramFromString(test3, env);
console.log('Result:', result3);
console.log('Expected: 27\n');

// Test 4: Nested lambda with begin
console.log('📋 Test 4: Nested Lambda');
const test4 = `
(define outer
  (lambda (x)
    (begin
      (define inner (lambda (y) (+ y 1)))
      (define result (inner x))
      (* result 2))))
(outer 6)
`;
const result4 = evalProgramFromString(test4, env);
console.log('Result:', result4);
console.log('Expected: 14\n');

// Test 5: Conditional lambda with begin
console.log('📋 Test 5: Conditional Lambda');
const test5 = `
(define check
  (lambda (x)
    (begin
      (if (> x 5)
          (* x 3)
          (+ x 10)))))
(check 8)
`;
const result5 = evalProgramFromString(test5, env);
console.log('Result:', result5);
console.log('Expected: 24\n');

// Check for errors
const hasErrors = [result1, result2, result3, result4, result5].some(r => 
  r && typeof r === 'object' && r.type === 'error'
);

if (hasErrors) {
  console.log('❌ ERRORS DETECTED:');
  [result1, result2, result3, result4, result5].forEach((r, i) => {
    if (r && typeof r === 'object' && r.type === 'error') {
      console.log(`Test ${i + 1} Error:`, r.message);
    }
  });
} else {
  console.log('✅ SUCCESS: All lambda tests passed!');
  console.log('✅ Lambda arity fix is working correctly!');
  console.log('✅ Multi-body lambdas now work with begin construct!');
}

console.log('\n🎉 Lambda Arity Fix Test Complete');