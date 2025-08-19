# Extending the Legal System: A Guide for Lawyers

*How to Add New Legal Rules and Expand the Etherney eLISP Legal System*

## Table of Contents

1. [Overview: Building Your Legal Rule Library](#overview)
2. [Understanding the System Architecture](#architecture)
3. [Step-by-Step Rule Creation Process](#step-by-step)
4. [Legal Rule Patterns and Templates](#patterns)
5. [Testing Your New Legal Rules](#testing)
6. [Integration with Existing System](#integration)
7. [Advanced Rule Composition](#advanced)
8. [Real-World Examples](#examples)
9. [Best Practices for Legal Coding](#best-practices)
10. [Troubleshooting Common Issues](#troubleshooting)

---

## Overview: Building Your Legal Rule Library {#overview}

As a lawyer using the Etherney eLISP system, you can extend it with new legal rules from any area of law. This guide shows you how to:

- **Add new legal provisions** from statutes, regulations, or case law
- **Create reusable legal functions** for your practice area
- **Build complex legal decision systems** that handle multiple interacting rules
- **Test and validate** your legal logic for accuracy
- **Share your legal rules** with other lawyer-programmers

### Why Extend the System?

The base system provides inheritance calculations, but law is vast. You might need:
- **Contract law rules** for validity, interpretation, and remedies
- **Corporate law calculations** for dividends, voting rights, and compliance
- **Tax law computations** for different types of taxes and deductions
- **Criminal law guidelines** for sentencing and penalty calculations
- **Labor law formulas** for wages, benefits, and termination pay
- **Real estate calculations** for transfers, taxes, and valuations

---

## Understanding the System Architecture {#architecture}

### Core Components

The Etherney eLISP legal system has these key parts:

```
src/
├── evaluator.js          # Core eLISP interpreter
├── legal-rules/          # Your custom legal rules (create this)
│   ├── contract-law.lisp
│   ├── tax-law.lisp
│   └── corporate-law.lisp
examples/
├── legal-coding-examples.lisp  # Learning examples
└── lawyer-exercises.lisp       # Practice exercises
tests/
├── comprehensive-test-suite.lisp  # Main test suite
└── legal-rules-tests/            # Tests for your rules (create this)
    ├── contract-law-tests.lisp
    └── tax-law-tests.lisp
```

### Legal Rule Structure

Every legal rule follows this pattern:

```lisp
; 1. Documentation comment explaining the legal basis
; Legal basis: Article XXX of the Civil Code / Section YYY of the Tax Code

; 2. Function definition with descriptive name
(define rule-name
  (lambda (input-parameters)
    (begin
      ; 3. Input validation
      (define validated-inputs (validate-inputs input-parameters))
      
      ; 4. Legal logic implementation
      (define legal-result (apply-legal-logic validated-inputs))
      
      ; 5. Return structured result
      (format-legal-result legal-result))))
```

---

## Step-by-Step Rule Creation Process {#step-by-step}

### Step 1: Identify the Legal Rule

Start with a specific legal provision you want to implement:

**Example**: Article 1159 of the Civil Code (Obligation with a Period)
> "Every obligation whose performance does not depend upon a future or uncertain event, or upon a past event unknown to the parties, is demandable at once."

### Step 2: Analyze the Legal Logic

Break down the rule into logical components:

1. **Condition**: Performance doesn't depend on future/uncertain event
2. **Condition**: Performance doesn't depend on past unknown event  
3. **Result**: If both conditions true → obligation is demandable at once
4. **Result**: Otherwise → obligation is not yet demandable

### Step 3: Create the Directory Structure

```bash
mkdir -p src/legal-rules
mkdir -p tests/legal-rules-tests
```

### Step 4: Write the Legal Rule

Create [`src/legal-rules/obligations-law.lisp`](src/legal-rules/obligations-law.lisp):

```lisp
; =============================================================================
; OBLIGATIONS AND CONTRACTS LAW
; Based on Philippine Civil Code, Book IV
; =============================================================================

; Legal basis: Article 1159, Civil Code
; "Every obligation whose performance does not depend upon a future or 
; uncertain event, or upon a past event unknown to the parties, is 
; demandable at once."
(define is-obligation-demandable?
  (lambda (depends-on-future-event? depends-on-past-unknown-event?)
    (begin
      ; Validate inputs
      (define valid-inputs (and (boolean? depends-on-future-event?)
                                (boolean? depends-on-past-unknown-event?)))
      
      (if (not valid-inputs)
          (list 'error "Invalid input: expected boolean values")
          (begin
            ; Apply Article 1159 logic
            (define has-no-future-dependency (not depends-on-future-event?))
            (define has-no-past-dependency (not depends-on-past-unknown-event?))
            (define is-demandable (and has-no-future-dependency has-no-past-dependency))
            
            ; Return structured result
            (list 'article 1159
                  'demandable is-demandable
                  'reason (if is-demandable
                             "No future or past uncertain dependencies"
                             "Depends on future or past uncertain events")))))))

; Helper function for common obligation scenarios
(define check-common-obligation-types
  (lambda (obligation-type)
    (begin
      (define scenarios
        (list (cons 'immediate-payment (list #f #f))      ; Demandable now
              (cons 'conditional-sale (list #t #f))       ; Future event
              (cons 'insurance-claim (list #f #t))        ; Past unknown event
              (cons 'lottery-prize (list #t #t))))        ; Both dependencies
      
      (define scenario-data (assoc obligation-type scenarios))
      
      (if scenario-data
          (begin
            (define depends-future (car (cdr scenario-data)))
            (define depends-past (cadr (cdr scenario-data)))
            (is-obligation-demandable? depends-future depends-past))
          (list 'error "Unknown obligation type")))))
```

### Step 5: Create Tests for Your Rule

Create [`tests/legal-rules-tests/obligations-law-tests.lisp`](tests/legal-rules-tests/obligations-law-tests.lisp):

```lisp
; =============================================================================
; TESTS FOR OBLIGATIONS LAW RULES
; =============================================================================

; Load the obligations law rules
; (In a real system, you'd have an import mechanism)

; Test Article 1159 - Basic demandability
(define test-article-1159-basic
  (lambda ()
    (begin
      ; Test case 1: No dependencies - should be demandable
      (define result1 (is-obligation-demandable? #f #f))
      (define expected1 #t)
      (define test1-passed (eq? (get result1 'demandable) expected1))
      
      ; Test case 2: Future dependency - not demandable
      (define result2 (is-obligation-demandable? #t #f))
      (define expected2 #f)
      (define test2-passed (eq? (get result2 'demandable) expected2))
      
      ; Test case 3: Past dependency - not demandable
      (define result3 (is-obligation-demandable? #f #t))
      (define expected3 #f)
      (define test3-passed (eq? (get result3 'demandable) expected3))
      
      ; Test case 4: Both dependencies - not demandable
      (define result4 (is-obligation-demandable? #t #t))
      (define expected4 #f)
      (define test4-passed (eq? (get result4 'demandable) expected4))
      
      ; Return test results
      (list 'test-article-1159
            'case-1-no-deps test1-passed
            'case-2-future-dep test2-passed
            'case-3-past-dep test3-passed
            'case-4-both-deps test4-passed
            'all-passed (and test1-passed test2-passed test3-passed test4-passed)))))

; Test common obligation scenarios
(define test-common-scenarios
  (lambda ()
    (begin
      ; Test immediate payment obligation
      (define immediate-result (check-common-obligation-types 'immediate-payment))
      (define immediate-demandable (get immediate-result 'demandable))
      
      ; Test conditional sale
      (define conditional-result (check-common-obligation-types 'conditional-sale))
      (define conditional-demandable (get conditional-result 'demandable))
      
      ; Test insurance claim
      (define insurance-result (check-common-obligation-types 'insurance-claim))
      (define insurance-demandable (get insurance-result 'demandable))
      
      ; Return results
      (list 'common-scenarios-test
            'immediate-payment immediate-demandable    ; Should be #t
            'conditional-sale conditional-demandable   ; Should be #f
            'insurance-claim insurance-demandable      ; Should be #f
            'tests-passed (and immediate-demandable
                              (not conditional-demandable)
                              (not insurance-demandable))))))

; Run all tests
(define run-obligations-tests
  (lambda ()
    (begin
      (define basic-tests (test-article-1159-basic))
      (define scenario-tests (test-common-scenarios))
      
      (list 'obligations-law-tests
            'basic-tests basic-tests
            'scenario-tests scenario-tests
            'all-tests-passed (and (get basic-tests 'all-passed)
                                  (get scenario-tests 'tests-passed))))))

; Execute tests
(print "Running Obligations Law Tests...")
(define test-results (run-obligations-tests))
(print test-results)
```

### Step 6: Test Your Rule

```bash
# Create a test runner script
node -e "
const { evalProgramFromString, createGlobalEnv } = require('./src/evaluator.js');
const fs = require('fs');

// Load your legal rules
const rulesCode = fs.readFileSync('src/legal-rules/obligations-law.lisp', 'utf8');
const testsCode = fs.readFileSync('tests/legal-rules-tests/obligations-law-tests.lisp', 'utf8');

const env = createGlobalEnv();

try {
  // Load rules first
  evalProgramFromString(rulesCode, env);
  
  // Then run tests
  const result = evalProgramFromString(testsCode, env);
  
  console.log('Test Results:', result);
} catch (error) {
  console.error('Error:', error.message);
}
"
```

---

## Legal Rule Patterns and Templates {#patterns}

### Pattern 1: Simple Legal Condition

**Use Case**: Binary legal determinations (eligible/not eligible, valid/invalid)

```lisp
; Template for simple legal conditions
(define legal-condition-name
  (lambda (input1 input2 ...)
    (begin
      ; Input validation
      (define inputs-valid (validate-inputs input1 input2 ...))
      
      (if (not inputs-valid)
          (list 'error "Invalid inputs")
          (begin
            ; Legal logic
            (define condition-met (and/or legal-test1 legal-test2 ...))
            
            ; Return result
            (list 'rule-name "Rule Name"
                  'result condition-met
                  'legal-basis "Article/Section reference"))))))
```

**Example**: Voting eligibility
```lisp
(define eligible-to-vote?
  (lambda (age citizenship)
    (begin
      (define inputs-valid (and (number? age) (boolean? citizenship)))
      
      (if (not inputs-valid)
          (list 'error "Invalid inputs: age must be number, citizenship must be boolean")
          (begin
            (define age-requirement (>= age 18))
            (define citizenship-requirement citizenship)
            (define eligible (and age-requirement citizenship-requirement))
            
            (list 'rule "Voting Eligibility"
                  'eligible eligible
                  'legal-basis "Constitution, Article V, Section 1"))))))
```

### Pattern 2: Legal Calculation

**Use Case**: Computing legal amounts (taxes, damages, support, etc.)

```lisp
; Template for legal calculations
(define legal-calculation-name
  (lambda (base-amount factors...)
    (begin
      ; Input validation
      (define inputs-valid (validate-calculation-inputs base-amount factors...))
      
      (if (not inputs-valid)
          (list 'error "Invalid calculation inputs")
          (begin
            ; Apply legal formula
            (define calculated-amount (apply-legal-formula base-amount factors...))
            
            ; Apply limits/caps if any
            (define final-amount (apply-legal-limits calculated-amount))
            
            ; Return detailed result
            (list 'calculation "Calculation Name"
                  'base-amount base-amount
                  'factors factors...
                  'calculated-amount calculated-amount
                  'final-amount final-amount
                  'legal-basis "Article/Section reference"))))))
```

**Example**: Liquidated damages calculation
```lisp
(define calculate-liquidated-damages
  (lambda (contract-value delay-days penalty-rate)
    (begin
      (define inputs-valid (and (> contract-value 0) 
                               (>= delay-days 0) 
                               (> penalty-rate 0)))
      
      (if (not inputs-valid)
          (list 'error "Invalid inputs: amounts must be positive, delay non-negative")
          (begin
            ; Calculate daily penalty
            (define daily-penalty (* contract-value penalty-rate))
            (define total-penalty (* daily-penalty delay-days))
            
            ; Apply legal limit (e.g., max 10% of contract value)
            (define penalty-cap (* contract-value 0.10))
            (define final-penalty (min total-penalty penalty-cap))
            
            (list 'calculation "Liquidated Damages"
                  'contract-value contract-value
                  'delay-days delay-days
                  'penalty-rate penalty-rate
                  'calculated-penalty total-penalty
                  'final-penalty final-penalty
                  'legal-basis "Article 1226, Civil Code"))))))
```

### Pattern 3: Multi-Step Legal Process

**Use Case**: Complex legal procedures with multiple steps

```lisp
; Template for multi-step legal processes
(define legal-process-name
  (lambda (initial-data)
    (begin
      ; Step 1: Validate initial requirements
      (define step1-result (validate-initial-requirements initial-data))
      
      (if (get step1-result 'error)
          step1-result
          (begin
            ; Step 2: Apply first legal rule
            (define step2-result (apply-first-rule step1-result))
            
            (if (get step2-result 'error)
                step2-result
                (begin
                  ; Step 3: Apply second legal rule
                  (define step3-result (apply-second-rule step2-result))
                  
                  ; Continue for more steps...
                  
                  ; Final step: Generate conclusion
                  (generate-legal-conclusion step3-result))))))))
```

### Pattern 4: Legal Decision Tree

**Use Case**: Complex legal determinations with multiple branches

```lisp
; Template for legal decision trees
(define legal-decision-tree
  (lambda (case-facts)
    (begin
      ; Extract relevant facts
      (define fact1 (get case-facts 'fact1))
      (define fact2 (get case-facts 'fact2))
      (define fact3 (get case-facts 'fact3))
      
      ; Decision tree logic
      (if (legal-condition-1 fact1)
          ; Branch 1
          (if (legal-condition-2 fact2)
              (legal-outcome-A case-facts)
              (legal-outcome-B case-facts))
          ; Branch 2
          (if (legal-condition-3 fact3)
              (legal-outcome-C case-facts)
              (legal-outcome-D case-facts))))))
```

---

## Testing Your New Legal Rules {#testing}

### Test Categories

#### 1. Unit Tests
Test individual legal rules in isolation:

```lisp
(define test-individual-rule
  (lambda ()
    (begin
      ; Test with valid inputs
      (define result1 (your-legal-rule valid-input1 valid-input2))
      (define test1-passed (expected-result? result1))
      
      ; Test with edge cases
      (define result2 (your-legal-rule edge-case-input1 edge-case-input2))
      (define test2-passed (expected-edge-result? result2))
      
      ; Test with invalid inputs
      (define result3 (your-legal-rule invalid-input1 invalid-input2))
      (define test3-passed (error-result? result3))
      
      (list 'unit-test-results
            'valid-inputs test1-passed
            'edge-cases test2-passed
            'invalid-inputs test3-passed
            'all-passed (and test1-passed test2-passed test3-passed)))))
```

#### 2. Integration Tests
Test how your rules work with existing system:

```lisp
(define test-rule-integration
  (lambda ()
    (begin
      ; Test with existing inheritance system
      (define inheritance-result (calculate-inheritance 1000000 #t 2))
      (define your-rule-result (your-legal-rule inheritance-result))
      
      ; Verify integration works
      (define integration-works (valid-integration? your-rule-result))
      
      (list 'integration-test
            'inheritance-input inheritance-result
            'your-rule-output your-rule-result
            'integration-successful integration-works))))
```

#### 3. Legal Scenario Tests
Test with realistic legal scenarios:

```lisp
(define test-realistic-scenarios
  (lambda ()
    (begin
      ; Scenario 1: Common case
      (define scenario1 (list 'case-type 'common
                             'facts (list 'fact1 value1 'fact2 value2)))
      (define result1 (your-legal-rule scenario1))
      
      ; Scenario 2: Complex case
      (define scenario2 (list 'case-type 'complex
                             'facts (list 'fact1 value3 'fact2 value4 'fact3 value5)))
      (define result2 (your-legal-rule scenario2))
      
      ; Verify results match legal expectations
      (list 'scenario-tests
            'common-case (verify-legal-correctness result1 scenario1)
            'complex-case (verify-legal-correctness result2 scenario2)))))
```

### Test Automation

Create a comprehensive test runner:

```lisp
; Master test runner for all your legal rules
(define run-all-legal-tests
  (lambda ()
    (begin
      ; Run tests for each legal area
      (define contract-tests (run-contract-law-tests))
      (define tax-tests (run-tax-law-tests))
      (define corporate-tests (run-corporate-law-tests))
      
      ; Compile results
      (define all-passed (and (get contract-tests 'all-passed)
                             (get tax-tests 'all-passed)
                             (get corporate-tests 'all-passed)))
      
      (list 'comprehensive-legal-tests
            'contract-law contract-tests
            'tax-law tax-tests
            'corporate-law corporate-tests
            'all-tests-passed all-passed))))
```

---

## Integration with Existing System {#integration}

### Adding Your Rules to the Main System

#### 1. Create a Legal Rules Loader

Create [`src/legal-rules/loader.js`](src/legal-rules/loader.js):

```javascript
const fs = require('fs');
const path = require('path');
const { evalProgramFromString } = require('../evaluator.js');

class LegalRulesLoader {
  constructor() {
    this.loadedRules = new Map();
    this.rulesDirectory = path.join(__dirname);
  }

  loadRule(ruleName, environment) {
    const rulePath = path.join(this.rulesDirectory, `${ruleName}.lisp`);
    
    if (!fs.existsSync(rulePath)) {
      throw new Error(`Legal rule file not found: ${rulePath}`);
    }

    const ruleCode = fs.readFileSync(rulePath, 'utf8');
    
    try {
      evalProgramFromString(ruleCode, environment);
      this.loadedRules.set(ruleName, rulePath);
      console.log(`✅ Loaded legal rule: ${ruleName}`);
    } catch (error) {
      console.error(`❌ Failed to load legal rule ${ruleName}:`, error.message);
      throw error;
    }
  }

  loadAllRules(environment) {
    const ruleFiles = fs.readdirSync(this.rulesDirectory)
      .filter(file => file.endsWith('.lisp'))
      .map(file => path.basename(file, '.lisp'));

    for (const ruleName of ruleFiles) {
      try {
        this.loadRule(ruleName, environment);
      } catch (error) {
        console.warn(`Skipping rule ${ruleName} due to error:`, error.message);
      }
    }

    return this.loadedRules;
  }

  getLoadedRules() {
    return Array.from(this.loadedRules.keys());
  }
}

module.exports = { LegalRulesLoader };
```

#### 2. Update the Main Evaluator

Modify your main application to load legal rules:

```javascript
// In your main application file
const { createGlobalEnv } = require('./src/evaluator.js');
const { LegalRulesLoader } = require('./src/legal-rules/loader.js');

function createLegalEnvironment() {
  const env = createGlobalEnv();
  const loader = new LegalRulesLoader();
  
  // Load all legal rules
  const loadedRules = loader.loadAllRules(env);
  
  console.log(`Loaded ${loadedRules.size} legal rule modules:`);
  for (const [ruleName, rulePath] of loadedRules) {
    console.log(`  - ${ruleName}: ${rulePath}`);
  }
  
  return env;
}

// Use in your applications
const legalEnv = createLegalEnvironment();
```

#### 3. Create Rule-Specific Applications

Create specialized applications for different legal areas:

```javascript
// contract-law-calculator.js
const { createLegalEnvironment } = require('./src/legal-environment.js');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

async function runContractLawCalculator() {
  console.log('🏛️  Contract Law Calculator');
  console.log('==========================');
  
  const env = createLegalEnvironment();
  
  // Interactive contract analysis
  rl.question('Enter contract value: ₱', (value) => {
    rl.question('Enter delay in days: ', (days) => {
      rl.question('Enter penalty rate (decimal): ', (rate) => {
        
        const contractValue = parseFloat(value);
        const delayDays = parseInt(days);
        const penaltyRate = parseFloat(rate);
        
        // Call your legal rule
        const damagesCode = `(calculate-liquidated-damages ${contractValue} ${delayDays} ${penaltyRate})`;
        
        try {
          const result = evalProgramFromString(damagesCode, env);
          console.log('\n📋 Liquidated Damages Calculation:');
          console.log(JSON.stringify(result, null, 2));
        } catch (error) {
          console.error('❌ Calculation error:', error.message);
        }
        
        rl.close();
      });
    });
  });
}

runContractLawCalculator();
```

---

## Advanced Rule Composition {#advanced}

### Combining Multiple Legal Rules

#### 1. Rule Chaining

Chain multiple legal rules together:

```lisp
; Chain contract validity → enforceability → damages
(define comprehensive-contract-analysis
  (lambda (contract-data)
    (begin
      ; Step 1: Check validity
      (define validity-result (check-contract-validity contract-data))
      
      (if (get validity-result 'valid)
          (begin
            ; Step 2: Check enforceability
            (define enforceability-result (check-contract-enforceability contract-data validity-result))
            
            (if (get enforceability-result 'enforceable)
                (begin
                  ; Step 3: Calculate potential damages
                  (define damages-result (calculate-potential-damages contract-data))
                  
                  ; Combine all results
                  (list 'comprehensive-analysis
                        'validity validity-result
                        'enforceability enforceability-result
                        'damages damages-result
                        'overall-status 'fully-enforceable))
                
                ; Not enforceable
                (list 'comprehensive-analysis
                      'validity validity-result
                      'enforceability enforceability-result
                      'overall-status 'valid-but-unenforceable)))
          
          ; Not valid
          (list 'comprehensive-analysis
                'validity validity-result
                'overall-status 'invalid)))))
```

#### 2. Rule Hierarchies

Create hierarchical legal rule systems:

```lisp
; Master legal system with rule hierarchy
(define legal-system
  (lambda (case-type case-data)
    (begin
      ; Determine which legal area applies
      (define legal-area (determine-legal-area case-type))
      
      ; Route to appropriate legal subsystem
      (cond ((eq? legal-area 'contract-law)
             (contract-law-system case-data))
            ((eq? legal-area 'tort-law)
             (tort-law-system case-data))
            ((eq? legal-area 'property-law)
             (property-law-system case-data))
            ((eq? legal-area 'family-law)
             (family-law-system case-data))
            (else
             (list 'error "Unknown legal area" legal-area))))))

; Specialized subsystems
(define contract-law-system
  (lambda (case-data)
    (begin
      (define contract-type (get case-data 'contract-type))
      
      ; Route to specific contract rules
      (cond ((eq? contract-type 'sale)
             (sale-contract-rules case-data))
            ((eq? contract-type 'lease)
             (lease-contract-rules case-data))
            ((eq? contract-type 'employment)
             (employment-contract-rules case-data))
            (else
             (general-contract-rules case-data))))))
```

#### 3. Rule Conflict Resolution

Handle conflicts between legal rules:

```lisp
; Rule conflict resolution system
(define resolve-rule-conflicts
  (lambda (conflicting-results)
    (begin
      ; Extract rule priorities and sources
      (define rule-priorities (map get-rule-priority conflicting-results))
      (define rule-sources (map get-rule-source conflicting-results))
      
      ; Apply conflict resolution hierarchy:
      ; 1. Constitutional provisions
      ; 2. Statutes
      ; 3. Regulations
      ; 4. Case law
      ; 5. Legal principles
      
      (define resolved-result (apply-conflict-resolution-hierarchy conflicting-results))
      
      (list 'conflict-resolution
            'conflicting-rules conflicting-results
            'resolution-method 'legal-hierarchy
            'resolved-result resolved-result
            'explanation (generate-conflict-explanation conflicting-results resolved-result)))))
```

---

## Real-World Examples {#examples}

### Example 1: Complete Tax Law Module

Create [`src/legal-rules/tax-law.lisp`](src/legal-rules/tax-law.lisp):

```lisp
; =============================================================================
; TAX LAW CALCULATIONS
; Based on Philippine National Internal Revenue Code (NIRC)
; =============================================================================

; Legal basis: Section 24(A), NIRC - Individual Income Tax
(define calculate-individual-income-tax
  (lambda (annual-income filing-status dependents)
    (begin
      ; Input validation
      (define inputs-valid (and (>= annual-income 0)
                               (member filing-status '(single married))
                               (>= dependents 0)))
      
      (if (not inputs-valid)
          (list 'error "Invalid inputs for income tax calculation")
          (begin
            ; Calculate taxable income
            (define personal-exemption 50000)
            (define dependent-exemption (* dependents 25000))
            (define total-exemptions (+ personal-exemption dependent-exemption))
            (define taxable-income (max 0 (- annual-income total-exemptions)))
            
            ; Apply tax brackets
            (define tax-due (calculate-progressive-tax taxable-income))
            
            ; Apply filing status adjustments
            (define adjusted-tax (if (eq? filing-status 'married)
                                    (* tax-due 0.95)  ; 5% reduction for married
                                    tax-due))
            
            (list 'income-tax-calculation
                  'annual-income annual-income
                  'filing-status filing-status
                  'dependents dependents
                  'personal-exemption personal-exemption
                  'dependent-exemption dependent-exemption
                  'taxable-income taxable-income
                  'tax-due adjusted-tax
                  'effective-rate (/ adjusted-tax annual-income)
                  'legal-basis "Section 24(A), NIRC"))))))

; Helper function for progressive tax calculation
(define calculate-progressive-tax
  (lambda (taxable-income)
    (begin
      ; Tax brackets (simplified)
      (define brackets
        (list (list 0 250000 0.00)        ; ₱0 - ₱250K: 0%
              (list 250000 400000 0.20)   ; ₱250K - ₱400K: 20%
              (list 400000 800000 0.25)   ; ₱400K - ₱800K: 25%
              (list 800000 2000000 0.30)  ; ₱800K - ₱2M: 30%
              (list 2000000 8000000 0.32) ; ₱2M - ₱8M: 32%
              (list 8000000 999999999 0.35))) ; Above ₱8M: 35%
      
      (calculate-tax-from-brackets taxable-income brackets))))

; Legal basis: Section 27(A), NIRC - Corporate Income Tax
(define calculate-corporate-income-tax
  (lambda (net-income corporation-type)
    (begin
      ; Determine tax rate based on corporation type
      (define tax-rate
        (cond ((eq? corporation-type 'domestic) 0.30)      ; 30% for domestic
              ((eq? corporation-type 'foreign) 0.30)       ; 30% for foreign
              ((eq? corporation-type 'small-business) 0.20) ; 20% for small business
              (else 0.30)))
      
      (define tax-due (* net-income tax-rate))
      
      (list 'corporate-tax-calculation
            'net-income net-income
            'corporation-type corporation-type
            'tax-rate tax-rate
            'tax-due tax-due
            'legal-basis "Section 27(A), NIRC"))))

; Legal basis: Section 106, NIRC - Value Added Tax
(define calculate-vat
  (lambda (gross-sales vat-exempt-sales)
    (begin
      (define vat-rate 0.12)  ; 12% VAT rate
      (define vat-taxable-sales (- gross-sales vat-exempt-sales))
      (define v