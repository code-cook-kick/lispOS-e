#!/usr/bin/env node

/**
 * Family Estate Calculator
 * A practical application using Etherney eLISP for inheritance calculations
 * 
 * This tool helps families understand how estates will be distributed
 * according to Philippine succession law.
 */

const { evalProgramFromString, createGlobalEnv } = require('./src/evaluator.js');
const fs = require('fs');
const readline = require('readline');

console.log('🏠 FAMILY ESTATE CALCULATOR');
console.log('===========================');
console.log('Powered by Etherney eLISP Legal Reasoning System');
console.log('');

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Utility function to ask questions
function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.trim());
    });
  });
}

// Main calculator logic in eLISP
const calculatorCode = `
; Family Estate Calculator - Core Logic
(print "Loading Family Estate Calculator...")

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

; Calculate testate succession (with will)
(define calculate-testate
  (lambda (bequests-total spouse? children-count)
    (begin
      (define remainder (- 1.0 bequests-total))
      (if (<= remainder 0)
          ; Will covers everything
          (list (kv 'will-beneficiaries bequests-total))
          ; Partial will - remainder goes to intestate heirs
          (begin
            (define intestate-shares (calculate-intestate spouse? children-count))
            (define scale-shares
              (lambda (shares factor)
                (map (lambda (share-pair)
                       (kv (nth share-pair 0) (* (nth share-pair 1) factor)))
                     shares)))
            (cons (kv 'will-beneficiaries bequests-total)
                  (scale-shares intestate-shares remainder)))))))

; Validate total shares sum to 1.0
(define validate-shares
  (lambda (shares)
    (begin
      (define sum-shares
        (lambda (shares-list acc)
          (if (= (length shares-list) 0)
              acc
              (sum-shares (rest shares-list) 
                         (+ acc (nth (first shares-list) 1))))))
      (define total (sum-shares shares 0))
      (if (< (abs (- total 1.0)) 0.001)
          #t
          #f))))

; Format results for display
(define format-results
  (lambda (shares estate-value)
    (begin
      (print "")
      (print "=== INHERITANCE DISTRIBUTION ===")
      (define show-share
        (lambda (share-pair)
          (begin
            (define role (nth share-pair 0))
            (define percentage (nth share-pair 1))
            (define amount (* percentage estate-value))
            (print role ":" 
                   (round (* percentage 100)) "%" 
                   "(" amount "PHP)"))))
      (map show-share shares)
      (print "")
      (print "Total Estate Value:" estate-value "PHP")
      (define total-check (validate-shares shares))
      (if total-check
          (print "✅ Distribution is mathematically correct")
          (print "⚠️  Warning: Shares do not sum to 100%"))
      shares)))

; Round function for display
(define round
  (lambda (x)
    (if (< x 0)
        (- 0 (round (- 0 x)))
        (+ x 0.5))))

(print "Family Estate Calculator loaded successfully!")
`;

async function runCalculator() {
  try {
    // Initialize the eLISP environment
    const env = createGlobalEnv();
    
    // Load the calculator logic
    const result = evalProgramFromString(calculatorCode, env);
    if (result && result.type === 'error') {
      console.log('❌ Error loading calculator:', result.message);
      return;
    }

    console.log('');
    console.log('This calculator helps you understand inheritance distributions');
    console.log('according to Philippine succession law.');
    console.log('');

    // Get basic information
    const deceasedName = await askQuestion('👤 Name of deceased person: ');
    const estateValue = parseFloat(await askQuestion('💰 Total estate value (PHP): '));
    
    if (isNaN(estateValue) || estateValue <= 0) {
      console.log('❌ Please enter a valid estate value.');
      rl.close();
      return;
    }

    const hasWill = (await askQuestion('📜 Does the deceased have a will? (y/n): ')).toLowerCase() === 'y';
    
    let willTotal = 0;
    if (hasWill) {
      const willPercentage = parseFloat(await askQuestion('📋 What percentage of estate is covered by will? (0-100): '));
      if (isNaN(willPercentage) || willPercentage < 0 || willPercentage > 100) {
        console.log('❌ Please enter a valid percentage (0-100).');
        rl.close();
        return;
      }
      willTotal = willPercentage / 100;
    }

    const hasSpouse = (await askQuestion('💑 Is there a surviving spouse? (y/n): ')).toLowerCase() === 'y';
    const childrenCount = parseInt(await askQuestion('👶 Number of children: '));
    
    if (isNaN(childrenCount) || childrenCount < 0) {
      console.log('❌ Please enter a valid number of children.');
      rl.close();
      return;
    }

    console.log('');
    console.log('🔄 Calculating inheritance distribution...');

    // Prepare the calculation
    let calculationCode;
    if (hasWill && willTotal > 0) {
      calculationCode = `
        (define result (calculate-testate ${willTotal} ${hasSpouse} ${childrenCount}))
        (format-results result ${estateValue})
      `;
    } else {
      calculationCode = `
        (define result (calculate-intestate ${hasSpouse} ${childrenCount}))
        (format-results result ${estateValue})
      `;
    }

    // Execute the calculation
    const calculationResult = evalProgramFromString(calculationCode, env);
    
    if (calculationResult && calculationResult.type === 'error') {
      console.log('❌ Error in calculation:', calculationResult.message);
    } else {
      console.log('');
      console.log('📊 SUMMARY FOR', deceasedName.toUpperCase());
      console.log('Estate Value:', estateValue.toLocaleString(), 'PHP');
      console.log('Succession Type:', hasWill ? 'Testate (with will)' : 'Intestate (no will)');
      console.log('Family Structure:', 
        (hasSpouse ? 'Spouse + ' : '') + 
        (childrenCount > 0 ? childrenCount + ' children' : 'No children'));
      
      console.log('');
      console.log('⚖️  LEGAL BASIS:');
      if (hasWill) {
        console.log('- Articles 904-906 (Testate succession)');
        if (willTotal < 1.0) {
          console.log('- Article 960 (Partial intestacy)');
        }
      } else {
        console.log('- Articles 979-996 (Intestate succession)');
      }
      
      if (hasSpouse && childrenCount > 0) {
        console.log('- Article 996 (Spouse and children)');
      }
      
      console.log('');
      console.log('💡 NOTES:');
      console.log('- This is a simplified calculation for educational purposes');
      console.log('- Actual legal cases may involve additional complexities');
      console.log('- Consult a lawyer for official legal advice');
      console.log('- Legitime protection may apply in complex cases');
    }

  } catch (error) {
    console.log('❌ Unexpected error:', error.message);
  } finally {
    rl.close();
  }
}

// Run the calculator
runCalculator().catch(console.error);