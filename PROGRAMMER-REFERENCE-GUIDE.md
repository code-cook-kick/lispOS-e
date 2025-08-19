# Etherney eLISP Programmer's Reference Guide

*Complete Reference for Legal Programming with Etherney eLISP*

## 📖 Table of Contents

1. [Language Overview](#language-overview)
2. [Core Syntax and Keywords](#core-syntax)
3. [Data Types](#data-types)
4. [Built-in Functions](#built-in-functions)
5. [Special Forms](#special-forms)
6. [Legal-Specific Functions](#legal-functions)
7. [Standard Libraries](#standard-libraries)
8. [Error Handling](#error-handling)
9. [Best Practices](#best-practices)
10. [Quick Reference](#quick-reference)

---

## 🔍 Language Overview {#language-overview}

### **Etherney eLISP Characteristics**
- **Functional Programming**: Emphasizes functions and immutable data
- **Legal Domain Focus**: Optimized for legal reasoning and calculations
- **Strict Lambda Arity**: Lambda functions must have exactly 2 arguments: `(lambda <params> <single-body-expr>)`
- **Dynamic Typing**: Types determined at runtime
- **Prefix Notation**: Operators come before operands: `(+ 1 2)`

### **Legal Programming Philosophy**
- **Precision First**: Legal accuracy takes precedence over performance
- **Explicit Logic**: Legal reasoning must be clear and traceable
- **Immutable Data**: Legal facts don't change once established
- **Testable Rules**: Every legal rule must be verifiable

---

## 🔤 Core Syntax and Keywords {#core-syntax}

### **Basic Syntax Rules**
```lisp
; Comments start with semicolon
(function-name argument1 argument2 ...)  ; Function call
(define variable-name value)             ; Variable definition
(lambda (params) body)                   ; Function definition
```

### **Core Keywords**

#### **`define`** - Variable and Function Definition
```lisp
; Variable definition
(define pi 3.14159)
(define legal-age 18)

; Function definition
(define square (lambda (x) (* x x)))
(define is-adult? (lambda (age) (>= age legal-age)))
```

#### **`lambda`** - Function Creation
**IMPORTANT**: Etherney eLISP enforces strict lambda arity - exactly 2 arguments required.
```lisp
; Correct: Single parameter, single body expression
(lambda (x) (* x 2))

; Correct: Multiple parameters in list, single body
(lambda (x y) (+ x y))

; Correct: Complex body using begin
(lambda (x y) 
  (begin
    (define sum (+ x y))
    (* sum 2)))

; INCORRECT: Multiple body expressions without begin
(lambda (x y) 
  (define sum (+ x y))
  (* sum 2))  ; This will cause an error
```

#### **`begin`** - Sequential Execution
```lisp
(begin
  (define x 10)
  (define y 20)
  (+ x y))  ; Returns 30
```

#### **`if`** - Conditional Logic
```lisp
; Basic if-then-else
(if condition then-expression else-expression)

; Legal example
(if (>= age 18) 'adult 'minor)

; Nested conditions
(if (> income 250000)
    (if (> income 500000) 'high-tax 'medium-tax)
    'no-tax)
```

#### **`cond`** - Multiple Conditions
```lisp
(cond (condition1 result1)
      (condition2 result2)
      (else default-result))

; Legal tax bracket example
(cond ((< income 250000) 0.00)
      ((< income 400000) 0.20)
      ((< income 800000) 0.25)
      (else 0.30))
```

#### **`let`** - Local Variable Binding
```lisp
(let ((var1 value1)
      (var2 value2))
  body-expression)

; Legal calculation example
(let ((gross-income 500000)
      (deductions 50000))
  (- gross-income deductions))
```

---

## 📊 Data Types {#data-types}

### **Numbers**
```lisp
42          ; Integer
3.14159     ; Float
-17         ; Negative integer
1.5e6       ; Scientific notation (1,500,000)
```

### **Booleans**
```lisp
#t          ; True
#f          ; False

; Legal examples
(define is-married? #t)
(define has-children? #f)
```

### **Strings**
```lisp
"Hello, World!"
"Article 1318, Civil Code"
"₱1,000,000.00"

; String operations
(string-append "Hello, " "World!")  ; "Hello, World!"
(string-length "Legal")             ; 5
```

### **Symbols**
```lisp
'symbol
'legal-status
'contract-type

; Used for legal categories
'valid
'invalid
'pending
'enforceable
```

### **Lists**
```lisp
'(1 2 3 4)                    ; List of numbers
'(spouse child1 child2)       ; List of symbols
(list 'name "John" 'age 30)   ; Mixed list

; Legal data structures
(list 'case-type 'contract 'status 'valid)
```

### **Key-Value Pairs (Legal Data)**
```lisp
; Common pattern for legal data
(define legal-record
  (list 'case-id 12345
        'client "John Doe"
        'matter-type 'contract
        'status 'active))
```

---

## 🔧 Built-in Functions {#built-in-functions}

### **Arithmetic Operations**
```lisp
(+ 1 2 3)        ; Addition: 6
(- 10 3)         ; Subtraction: 7
(* 4 5)          ; Multiplication: 20
(/ 15 3)         ; Division: 5
(% 17 5)         ; Modulo: 2

; Legal calculations
(* salary 0.20)  ; 20% tax
(/ estate 4)     ; Divide estate among 4 heirs
```

### **Comparison Operations**
```lisp
(= 5 5)          ; Equal: #t
(< 3 5)          ; Less than: #t
(> 10 7)         ; Greater than: #t
(<= 5 5)         ; Less than or equal: #t
(>= 8 3)         ; Greater than or equal: #t

; Legal comparisons
(>= age 18)      ; Legal age check
(< penalty-rate 0.10)  ; Penalty rate limit
```

### **Logical Operations**
```lisp
(and #t #t)      ; Logical AND: #t
(or #f #t)       ; Logical OR: #t
(not #t)         ; Logical NOT: #f

; Legal logic
(and has-consent? has-object? has-cause?)  ; Contract validity
(or is-citizen? is-resident?)              ; Voting eligibility
```

### **List Operations**
```lisp
(car '(a b c))       ; First element: a
(cdr '(a b c))       ; Rest of list: (b c)
(cons 'x '(y z))     ; Add to front: (x y z)
(append '(a b) '(c d))  ; Combine lists: (a b c d)
(length '(1 2 3))    ; List length: 3

; Legal list operations
(car heirs-list)     ; First heir
(length beneficiaries)  ; Number of beneficiaries
```

### **Type Checking**
```lisp
(number? 42)         ; #t
(string? "hello")    ; #t
(boolean? #t)        ; #t
(list? '(a b c))     ; #t
(symbol? 'legal)     ; #t

; Legal type validation
(number? estate-value)    ; Validate monetary amount
(boolean? is-married?)    ; Validate boolean flag
```

### **String Operations**
```lisp
(string-append "Hello" " " "World")  ; "Hello World"
(string-length "Legal")              ; 5
(substring "Contract" 0 4)           ; "Cont"

; Legal string operations
(string-append "Case #" case-number)
(string-length client-name)
```

---

## 🎯 Special Forms {#special-forms}

### **`quote` and `'`** - Literal Data
```lisp
(quote (a b c))      ; Same as '(a b c)
'legal-status        ; Symbol literal
'(contract sale)     ; List literal

; Legal categories
'valid
'invalid
'pending
```

### **`set!`** - Variable Mutation
```lisp
(define x 10)
(set! x 20)          ; x is now 20

; Legal status updates
(set! case-status 'closed)
(set! payment-received? #t)
```

### **`apply`** - Function Application
```lisp
(apply + '(1 2 3 4))  ; Same as (+ 1 2 3 4)

; Legal calculations
(apply max penalty-amounts)  ; Find maximum penalty
(apply + fee-list)          ; Sum all fees
```

### **`map`** - List Transformation
```lisp
(map (lambda (x) (* x 2)) '(1 2 3))  ; (2 4 6)

; Legal transformations
(map calculate-tax income-list)       ; Calculate tax for each income
(map (lambda (heir) (get heir 'share)) heirs)  ; Extract shares
```

### **`filter`** - List Filtering
```lisp
(filter (lambda (x) (> x 5)) '(1 6 3 8 2))  ; (6 8)

; Legal filtering
(filter (lambda (case) (eq? (get case 'status) 'active)) cases)
(filter adult? person-list)  ; Filter adults only
```

---

## ⚖️ Legal-Specific Functions {#legal-functions}

### **Legal Data Access**
```lisp
; Get value from legal record
(define get
  (lambda (record key)
    ; Implementation for accessing legal data
    ))

; Usage
(get legal-record 'client-name)
(get contract-data 'effective-date)
```

### **Legal Validation Functions**
```lisp
; Age validation
(define is-adult?
  (lambda (age)
    (>= age 18)))

; Legal capacity check
(define has-legal-capacity?
  (lambda (person)
    (and (is-adult? (get person 'age))
         (not (get person 'incapacitated?)))))

; Contract element validation
(define has-essential-elements?
  (lambda (consent? object? cause?)
    (and consent? object? cause?)))
```

### **Legal Calculation Functions**
```lisp
; Progressive tax calculation
(define calculate-progressive-tax
  (lambda (income brackets)
    ; Implementation for tax brackets
    ))

; Inheritance distribution
(define distribute-estate
  (lambda (estate-value heirs)
    ; Implementation for estate distribution
    ))

; Penalty calculation
(define calculate-penalty
  (lambda (base-amount rate days)
    (* base-amount rate days)))
```

### **Legal Date Functions**
```lisp
; Date comparison for legal deadlines
(define is-past-deadline?
  (lambda (deadline current-date)
    ; Implementation for date comparison
    ))

; Calculate legal periods
(define add-legal-days
  (lambda (start-date days)
    ; Implementation for legal day calculation
    ))
```

---

## 📚 Standard Libraries {#standard-libraries}

### **Math Library**
```lisp
; Advanced mathematical functions
(abs -5)             ; Absolute value: 5
(max 3 7 2)          ; Maximum: 7
(min 8 4 6)          ; Minimum: 4
(round 3.7)          ; Round: 4
(floor 3.9)          ; Floor: 3
(ceiling 3.1)        ; Ceiling: 4

; Legal calculations
(round (* income tax-rate))      ; Round tax amount
(max 0 (- income deductions))    ; Ensure non-negative
```

### **List Processing Library**
```lisp
; Advanced list operations
(reverse '(a b c))               ; (c b a)
(sort '(3 1 4 2) <)             ; (1 2 3 4)
(member 'b '(a b c))             ; (b c)
(assoc 'key '((key value) (k2 v2)))  ; (key value)

; Legal list processing
(sort penalty-list >)            ; Sort penalties descending
(member case-type valid-types)   ; Check if case type is valid
```

### **String Processing Library**
```lisp
; String manipulation
(string-upcase "legal")          ; "LEGAL"
(string-downcase "CONTRACT")     ; "contract"
(string-trim "  text  ")         ; "text"

; Legal document processing
(string-upcase client-name)      ; Standardize names
(string-trim user-input)         ; Clean input data
```

---

## ⚠️ Error Handling {#error-handling}

### **Common Error Types**
```lisp
; Type errors
(+ "hello" 5)        ; Error: Cannot add string and number

; Arity errors (Etherney eLISP specific)
(lambda (x) (+ x) (* x 2))  ; Error: Lambda needs single body or begin

; Division by zero
(/ 10 0)             ; Error: Division by zero

; Undefined variables
undefined-var        ; Error: Variable not defined
```

### **Error Prevention Patterns**
```lisp
; Input validation
(define safe-divide
  (lambda (a b)
    (if (= b 0)
        (list 'error "Division by zero")
        (/ a b))))

; Type checking
(define safe-add
  (lambda (a b)
    (if (and (number? a) (number? b))
        (+ a b)
        (list 'error "Both arguments must be numbers"))))

; Legal validation
(define validate-legal-age
  (lambda (age)
    (if (and (number? age) (>= age 0) (<= age 150))
        age
        (list 'error "Invalid age"))))
```

### **Error Handling in Legal Code**
```lisp
; Comprehensive legal validation
(define validate-contract-data
  (lambda (contract-data)
    (begin
      (define consent (get contract-data 'consent))
      (define object (get contract-data 'object))
      (define cause (get contract-data 'cause))
      
      (if (not (boolean? consent))
          (list 'error "Consent must be boolean")
          (if (not (boolean? object))
              (list 'error "Object must be boolean")
              (if (not (boolean? cause))
                  (list 'error "Cause must be boolean")
                  (list 'valid contract-data)))))))
```

---

## 💡 Best Practices {#best-practices}

### **Legal Coding Standards**
```lisp
; 1. Use descriptive names for legal concepts
(define is-contract-valid? ...)     ; Good
(define check ...)                  ; Bad

; 2. Include legal basis in comments
; Legal basis: Article 1318, Civil Code
(define check-essential-elements ...)

; 3. Validate all legal inputs
(define calculate-tax
  (lambda (income)
    (if (and (number? income) (>= income 0))
        ; calculation logic
        (list 'error "Invalid income"))))

; 4. Use structured results for legal analysis
(list 'legal-analysis
      'rule 'Article-1318
      'result 'valid
      'reasoning "All essential elements present")
```

### **Function Design Patterns**
```lisp
; Pattern 1: Legal rule implementation
(define legal-rule-name
  (lambda (inputs)
    (begin
      ; 1. Validate inputs
      (define validation (validate-inputs inputs))
      
      ; 2. Apply legal logic
      (if (get validation 'valid)
          (begin
            ; 3. Implement rule
            (define result (apply-legal-rule inputs))
            
            ; 4. Return structured result
            (list 'rule-name 'rule-name
                  'inputs inputs
                  'result result
                  'legal-basis "Legal citation"))
          validation))))

; Pattern 2: Legal calculation
(define legal-calculation
  (lambda (base-amount factors)
    (begin
      ; Input validation
      (define inputs-valid (validate-calculation-inputs base-amount factors))
      
      (if inputs-valid
          (begin
            ; Apply calculation
            (define result (perform-calculation base-amount factors))
            
            ; Return detailed result
            (list 'calculation 'calculation-name
                  'base-amount base-amount
                  'factors factors
                  'result result))
          (list 'error "Invalid calculation inputs")))))
```

### **Testing Patterns**
```lisp
; Comprehensive legal testing
(define test-legal-function
  (lambda ()
    (begin
      ; Test valid cases
      (define test1 (legal-function valid-input1))
      (define test2 (legal-function valid-input2))
      
      ; Test edge cases
      (define test3 (legal-function edge-case-input))
      
      ; Test invalid inputs
      (define test4 (legal-function invalid-input))
      
      ; Verify results
      (list 'test-results
            'valid-cases (list test1 test2)
            'edge-cases (list test3)
            'error-cases (list test4)))))
```

---

## 📋 Quick Reference {#quick-reference}

### **Essential Keywords**
| Keyword | Purpose | Example |
|---------|---------|---------|
| `define` | Variable/function definition | `(define x 10)` |
| `lambda` | Function creation | `(lambda (x) (* x 2))` |
| `begin` | Sequential execution | `(begin expr1 expr2)` |
| `if` | Conditional | `(if test then else)` |
| `cond` | Multiple conditions | `(cond (test1 result1) (else default))` |
| `let` | Local binding | `(let ((x 1)) body)` |

### **Data Types**
| Type | Example | Test Function |
|------|---------|---------------|
| Number | `42`, `3.14` | `(number? x)` |
| Boolean | `#t`, `#f` | `(boolean? x)` |
| String | `"text"` | `(string? x)` |
| Symbol | `'symbol` | `(symbol? x)` |
| List | `'(a b c)` | `(list? x)` |

### **Common Operations**
| Operation | Function | Example |
|-----------|----------|---------|
| Addition | `+` | `(+ 1 2 3)` |
| Subtraction | `-` | `(- 10 3)` |
| Multiplication | `*` | `(* 4 5)` |
| Division | `/` | `(/ 15 3)` |
| Equal | `=` | `(= 5 5)` |
| Less than | `<` | `(< 3 5)` |
| Greater than | `>` | `(> 10 7)` |
| Logical AND | `and` | `(and #t #t)` |
| Logical OR | `or` | `(or #f #t)` |
| Logical NOT | `not` | `(not #t)` |

### **List Operations**
| Operation | Function | Example |
|-----------|----------|---------|
| First element | `car` | `(car '(a b c))` |
| Rest of list | `cdr` | `(cdr '(a b c))` |
| Add to front | `cons` | `(cons 'x '(y z))` |
| Combine lists | `append` | `(append '(a b) '(c d))` |
| List length | `length` | `(length '(1 2 3))` |
| Transform list | `map` | `(map func list)` |
| Filter list | `filter` | `(filter pred list)` |

### **Legal Function Template**
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
            ; 3. Legal logic implementation
            (define legal-result (apply-legal-rule legal-inputs))
            
            ; 4. Structured result
            (list 'legal-function 'function-name
                  'inputs legal-inputs
                  'result legal-result
                  'legal-basis "Legal citation"))))))
```

### **Common Legal Patterns**
```lisp
; Age validation
(>= age 18)

; Contract validity (Article 1318)
(and has-consent? has-object? has-cause?)

; Progressive calculation
(cond ((< amount threshold1) rate1)
      ((< amount threshold2) rate2)
      (else rate3))

; Legal data structure
(list 'case-id id
      'client-name name
      'matter-type type
      'status status)
```

---

## 🔗 Related Documentation

- [`LEGAL-CODING-GUIDE.md`](LEGAL-CODING-GUIDE.md) - Beginner's guide to legal coding
- [`EXTENDING-LEGAL-RULES.md`](EXTENDING-LEGAL-RULES.md) - How to add new legal rules
- [`STEP-BY-STEP-LEGAL-CODING-TUTORIAL.md`](STEP-BY-STEP-LEGAL-CODING-TUTORIAL.md) - Hands-on tutorial
- [`examples/legal-coding-examples.lisp`](examples/legal-coding-examples.lisp) - Practical examples
- [`examples/lawyer-exercises.lisp`](examples/lawyer-exercises.lisp) - Practice exercises

---

*This reference guide provides comprehensive documentation for programming legal applications with Etherney eLISP. Use it as your go-to resource for syntax, functions, and legal coding patterns.*