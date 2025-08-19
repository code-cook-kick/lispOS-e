# Etherney eLISP Quick Reference Card

*Essential Reference for Legal Programming*

## 🔤 Basic Syntax

```lisp
; Comments start with semicolon
(function-name arg1 arg2)        ; Function call
(define var-name value)          ; Variable definition
(lambda (params) body)           ; Function definition
(begin expr1 expr2 result)       ; Sequential execution
```

## 📊 Data Types

| Type | Example | Test |
|------|---------|------|
| **Number** | `42`, `3.14` | `(number? x)` |
| **Boolean** | `#t`, `#f` | `(boolean? x)` |
| **String** | `"text"` | `(string? x)` |
| **Symbol** | `'symbol` | `(symbol? x)` |
| **List** | `'(a b c)` | `(list? x)` |

## 🔧 Core Functions

### **Arithmetic**
```lisp
(+ 1 2 3)      ; Addition: 6
(- 10 3)       ; Subtraction: 7
(* 4 5)        ; Multiplication: 20
(/ 15 3)       ; Division: 5
(% 17 5)       ; Modulo: 2
```

### **Comparison**
```lisp
(= 5 5)        ; Equal: #t
(< 3 5)        ; Less than: #t
(> 10 7)       ; Greater than: #t
(<= 5 5)       ; Less/equal: #t
(>= 8 3)       ; Greater/equal: #t
```

### **Logic**
```lisp
(and #t #t)    ; Logical AND: #t
(or #f #t)     ; Logical OR: #t
(not #t)       ; Logical NOT: #f
```

### **Lists**
```lisp
(car '(a b c))         ; First: a
(cdr '(a b c))         ; Rest: (b c)
(cons 'x '(y z))       ; Prepend: (x y z)
(append '(a b) '(c d)) ; Join: (a b c d)
(length '(1 2 3))      ; Length: 3
```

## 🎯 Control Flow

### **Conditional**
```lisp
(if condition then-expr else-expr)

(cond (test1 result1)
      (test2 result2)
      (else default))
```

### **Local Variables**
```lisp
(let ((var1 val1)
      (var2 val2))
  body-expression)
```

## ⚖️ Legal Patterns

### **Contract Validity (Article 1318)**
```lisp
(and has-consent? has-object? has-cause?)
```

### **Age Validation**
```lisp
(>= age 18)  ; Legal age check
```

### **Progressive Calculation**
```lisp
(cond ((< amount 250000) 0.00)
      ((< amount 400000) 0.20)
      (else 0.30))
```

### **Legal Data Structure**
```lisp
(list 'case-id 12345
      'client "John Doe"
      'status 'active)
```

## 🔍 Common Legal Functions

### **Contract Law**
```lisp
; Check contract validity
(check-contract-validity consent? object? cause?)

; Calculate damages
(calculate-liquidated-damages contract-value days rate)
```

### **Family Law**
```lisp
; Child support
(calculate-child-support income children-count)

; Custody evaluation
(determine-custody-factors parent-info child-info)
```

### **Tax Law**
```lisp
; Income tax
(calculate-income-tax annual-income filing-status)

; Estate tax
(calculate-estate-tax gross-estate deductions exemptions)
```

### **Property Law**
```lisp
; Transfer tax
(calculate-property-transfer-tax value type location)

; Ownership determination
(determine-property-ownership owners acquisition-type)
```

## 🛠️ Utility Functions

### **Legal Data Access**
```lisp
(kv 'key 'value)       ; Create key-value pair
(get record 'key)      ; Extract value
```

### **Validation**
```lisp
(validate-monetary-amount amount)
(validate-legal-age age)
(validate-boolean-input input)
```

### **Formatting**
```lisp
(format-currency 1000)  ; "₱1,000.00"
(calculate-percentage part total)
```

## ⚠️ Lambda Rules (Etherney eLISP)

**CRITICAL**: Lambda must have exactly 2 arguments:
- Parameter list
- Single body expression

### **Correct Lambda Usage**
```lisp
; Single expression body
(lambda (x) (* x 2))

; Multiple parameters
(lambda (x y) (+ x y))

; Complex body with begin
(lambda (x y)
  (begin
    (define sum (+ x y))
    (* sum 2)))
```

### **Incorrect Lambda Usage**
```lisp
; WRONG: Multiple expressions without begin
(lambda (x y)
  (define sum (+ x y))
  (* sum 2))  ; ERROR!
```

## 🧪 Testing Pattern

```lisp
(define test-legal-function
  (lambda ()
    (begin
      ; Test valid case
      (define result1 (legal-function valid-input))
      
      ; Test edge case
      (define result2 (legal-function edge-input))
      
      ; Test invalid input
      (define result3 (legal-function invalid-input))
      
      ; Return test results
      (list 'tests (list result1 result2 result3)))))
```

## 📋 Legal Function Template

```lisp
(define legal-function-name
  (lambda (legal-inputs)
    (begin
      ; 1. Input validation
      (define inputs-valid (validate-inputs legal-inputs))
      
      ; 2. Error handling
      (if (not inputs-valid)
          (list 'error "Invalid inputs")
          (begin
            ; 3. Legal logic
            (define result (apply-legal-rule legal-inputs))
            
            ; 4. Structured result
            (list 'function-name 'legal-function-name
                  'inputs legal-inputs
                  'result result
                  'legal-basis "Legal citation"))))))
```

## 🎯 Error Handling

### **Input Validation**
```lisp
(if (not (number? amount))
    (list 'error "Amount must be a number")
    ; proceed with calculation
    )
```

### **Safe Operations**
```lisp
; Safe division
(if (= divisor 0)
    (list 'error "Division by zero")
    (/ dividend divisor))
```

## 📊 Legal Calculations

### **Percentage-Based**
```lisp
; Tax calculation
(* income tax-rate)

; Estate distribution
(* estate-value heir-percentage)
```

### **Progressive Systems**
```lisp
; Tax brackets
(cond ((< income 250000) (* income 0.00))
      ((< income 400000) (+ 0 (* (- income 250000) 0.20)))
      (else (+ 30000 (* (- income 400000) 0.25))))
```

### **Proportional Distribution**
```lisp
; Divide among heirs
(define per-heir (/ total-amount heir-count))
```

## 🔗 Common Legal Constants

```lisp
; Ages
(define legal-age 18)
(define senior-age 60)

; Tax rates
(define vat-rate 0.12)
(define estate-tax-rate 0.06)

; Legal percentages (Article 996)
(define spouse-share 0.25)
(define children-share 0.75)
```

## 📚 Legal Citations

### **Civil Code**
- Article 1318: Contract essential elements
- Article 996: Intestate succession shares
- Articles 1191-1192: Contract breach remedies

### **Family Code**
- Article 194: Child support obligations
- Article 201: Spousal support
- Article 213: Child custody factors

### **Tax Code (NIRC)**
- Section 24(A): Individual income tax
- Section 84: Estate tax
- Section 106: Value Added Tax

### **Labor Code**
- Article 87: Overtime pay
- Article 279: Security of tenure
- Article 283: Separation pay

## 🚀 Quick Start Commands

```bash
# Run legal examples
npm run legal-examples

# Practice exercises
npm run legal-exercises

# Step-by-step tutorial
npm run tutorial

# Extension demo
npm run extending-demo

# Estate calculator
npm run estate-calculator
```

## 💡 Best Practices

1. **Always validate inputs** for legal accuracy
2. **Include legal basis** in comments and results
3. **Use descriptive names** for legal concepts
4. **Handle error cases** appropriately
5. **Test with realistic scenarios**
6. **Document legal reasoning**
7. **Follow lambda arity rules** strictly

---

*Keep this reference card handy while coding legal applications with Etherney eLISP!*