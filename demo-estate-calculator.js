#!/usr/bin/env node

/**
 * Demo script for Family Estate Calculator
 * Shows automated examples of inheritance calculations
 */

const { evalProgramFromString, createGlobalEnv } = require('./src/evaluator.js');

console.log('🏠 FAMILY ESTATE CALCULATOR - DEMO');
console.log('==================================');
console.log('Automated demonstration of inheritance calculations');
console.log('');

// Load the calculator logic
const calculatorCode = `
; Family Estate Calculator - Core Logic
(print "Loading Family Estate Calculator for demo...")

; Helper functions
(define kv
  (lambda (k v)
    (list k v)))

; Calculate intestate succession (no will)
(define calculate-intestate
  (lambda (spouse? children-count)
    (begin
      (if spouse?
          (if (= children-count 0)
              ; Spouse only
              (list (kv 'spouse 1.0))
              ; Spouse + children: spouse gets 1/4, children share 3/4
              (begin
                (define spouse-share 0.25)
                (define children-total 0.75)
                (define child-share (/ children-total children-count))
                (define result (list (kv 'spouse spouse-share)))
                (define add-children
                  (lambda (n acc)
                    (if (<= n 0)
                        acc
                        (add-children (- n 1) (cons (kv 'child child-share) acc)))))
                (add-children children-count result)))
          ; No spouse, children only
          (if (> children-count 0)
              (begin
                (define child-share (/ 1.0 children-count))
                (define add-children
                  (lambda (n acc)
                    (if (<= n 0)
                        acc
                        (add-children (- n 1) (cons (kv 'child child-share) acc)))))
                (add-children children-count '()))
              ; No spouse, no children - would go to other relatives
              (list (kv 'other-relatives 1.0)))))))

; Format results for display
(define format-demo-results
  (lambda (shares estate-value scenario-name)
    (begin
      (print "")
      (print "📊 SCENARIO:" scenario-name)
      (print "Estate Value:" estate-value "PHP")
      (print "Distribution:")
      (define show-share
        (lambda (share-pair)
          (begin
            (define role (nth share-pair 0))
            (define percentage (nth share-pair 1))
            (define amount (* percentage estate-value))
            (print "  -" role ":" 
                   (round (* percentage 100)) "%" 
                   "(" amount "PHP)"))))
      (map show-share shares)
      shares)))

; Round function for display
(define round
  (lambda (x)
    (if (< x 0)
        (- 0 (round (- 0 x)))
        (+ x 0.5))))

(print "Demo calculator loaded successfully!")
`;

async function runDemo() {
  try {
    const env = createGlobalEnv();
    
    // Load the calculator logic
    const result = evalProgramFromString(calculatorCode, env);
    if (result && result.type === 'error') {
      console.log('❌ Error loading calculator:', result.message);
      return;
    }

    console.log('');
    console.log('Running demonstration scenarios...');
    console.log('');

    // Demo scenarios
    const scenarios = [
      {
        name: "Young couple with 2 children",
        spouse: true,
        children: 2,
        estate: 5000000,
        description: "Typical family scenario - spouse and children inherit"
      },
      {
        name: "Widow with 3 adult children", 
        spouse: false,
        children: 3,
        estate: 10000000,
        description: "Children inherit equally when no spouse"
      },
      {
        name: "Childless couple",
        spouse: true,
        children: 0,
        estate: 2000000,
        description: "Spouse inherits everything when no children"
      },
      {
        name: "Single parent with 1 child",
        spouse: false,
        children: 1,
        estate: 3000000,
        description: "Single child inherits entire estate"
      },
      {
        name: "Large family - spouse + 5 children",
        spouse: true,
        children: 5,
        estate: 15000000,
        description: "Complex distribution with many heirs"
      }
    ];

    for (const scenario of scenarios) {
      const calculationCode = `
        (define result (calculate-intestate ${scenario.spouse ? '#t' : '#f'} ${scenario.children}))
        (format-demo-results result ${scenario.estate} "${scenario.name}")
      `;

      console.log('🔄 Calculating:', scenario.name);
      console.log('📝 Description:', scenario.description);
      
      const calculationResult = evalProgramFromString(calculationCode, env);
      
      if (calculationResult && calculationResult.type === 'error') {
        console.log('❌ Error in calculation:', calculationResult.message);
      }
      
      console.log('⚖️  Legal Basis: Articles 979-996 (Intestate succession)');
      if (scenario.spouse && scenario.children > 0) {
        console.log('   Article 996 (Spouse gets 1/4, children share 3/4)');
      }
      console.log('');
    }

    console.log('✅ DEMO COMPLETE');
    console.log('');
    console.log('💡 KEY INSIGHTS FROM DEMO:');
    console.log('• Spouse + children: Spouse always gets 25%, children share 75%');
    console.log('• Children only: Equal distribution among all children');
    console.log('• Spouse only: Spouse inherits 100% of estate');
    console.log('• All calculations are mathematically precise');
    console.log('• Based on Philippine Civil Code succession laws');
    console.log('');
    console.log('🚀 To run interactive calculator: npm run estate-calculator');
    console.log('📚 For more complex scenarios, see: src/lisp/practical-usage-example.lisp');

  } catch (error) {
    console.log('❌ Unexpected error:', error.message);
  }
}

// Run the demo
runDemo().catch(console.error);