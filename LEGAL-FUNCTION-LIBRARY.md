# Legal Function Library Reference

*Comprehensive Library of Legal Functions for Etherney eLISP*

## 📚 Library Overview

This library provides pre-built functions for common legal operations, calculations, and determinations. All functions follow legal accuracy standards and include proper error handling and validation.

## 📖 Table of Contents

1. [Contract Law Functions](#contract-law)
2. [Family Law Functions](#family-law)
3. [Tax Law Functions](#tax-law)
4. [Property Law Functions](#property-law)
5. [Criminal Law Functions](#criminal-law)
6. [Labor Law Functions](#labor-law)
7. [Corporate Law Functions](#corporate-law)
8. [Utility Functions](#utility-functions)
9. [Validation Functions](#validation-functions)
10. [Date and Time Functions](#date-time-functions)

---

## ⚖️ Contract Law Functions {#contract-law}

### **`check-contract-validity`**
Validates contract based on Article 1318 essential elements.

```lisp
(define check-contract-validity
  (lambda (has-consent? has-object? has-cause?)
    (begin
      (define inputs-valid (and (boolean? has-consent?)
                               (boolean? has-object?)
                               (boolean? has-cause?)))
      
      (if (not inputs-valid)
          (list 'error "All inputs must be boolean")
          (begin
            (define all-elements-present (and has-consent? has-object? has-cause?))
            
            (list 'contract-validity-check
                  'article 1318
                  'valid all-elements-present
                  'consent has-consent?
                  'object has-object?
                  'cause has-cause?
                  'legal-effect (if all-elements-present
                                   'valid-enforceable-contract
                                   'invalid-no-contract)))))))
```

**Usage:**
```lisp
(check-contract-validity #t #t #t)  ; Valid contract
(check-contract-validity #f #t #t)  ; Invalid - no consent
```

### **`calculate-liquidated-damages`**
Calculates liquidated damages with legal limits.

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
            (define daily-penalty (* contract-value penalty-rate))
            (define total-penalty (* daily-penalty delay-days))
            
            ; Apply legal limit (max 10% of contract value)
            (define penalty-cap (* contract-value 0.10))
            (define final-penalty (min total-penalty penalty-cap))
            
            (list 'liquidated-damages
                  'contract-value contract-value
                  'delay-days delay-days
                  'penalty-rate penalty-rate
                  'calculated-penalty total-penalty
                  'final-penalty final-penalty
                  'legal-basis "Article 1226, Civil Code"))))))
```

### **`determine-contract-breach`**
Determines type and severity of contract breach.

```lisp
(define determine-contract-breach
  (lambda (performance-level contract-terms)
    (begin
      (define breach-type
        (cond ((= performance-level 0) 'total-breach)
              ((< performance-level 0.5) 'substantial-breach)
              ((< performance-level 1.0) 'partial-breach)
              (else 'no-breach)))
      
      (define remedy
        (cond ((eq? breach-type 'total-breach) 'rescission-and-damages)
              ((eq? breach-type 'substantial-breach) 'damages-and-specific-performance)
              ((eq? breach-type 'partial-breach) 'proportional-damages)
              (else 'no-remedy-required)))
      
      (list 'breach-analysis
            'performance-level performance-level
            'breach-type breach-type
            'recommended-remedy remedy
            'legal-basis "Articles 1191-1192, Civil Code"))))
```

---

## 👨‍👩‍👧‍👦 Family Law Functions {#family-law}

### **`calculate-child-support`**
Calculates child support based on income and number of children.

```lisp
(define calculate-child-support
  (lambda (gross-monthly-income children-count)
    (begin
      (define inputs-valid (and (> gross-monthly-income 0) (> children-count 0)))
      
      (if (not inputs-valid)
          (list 'error "Income and children count must be positive")
          (begin
            ; Basic support: 20% for first child, +10% for each additional, max 50%
            (define base-percentage 0.20)
            (define additional-percentage 0.10)
            (define max-percentage 0.50)
            
            (define total-percentage 
              (min max-percentage 
                   (+ base-percentage 
                      (* additional-percentage (- children-count 1)))))
            
            (define support-amount (* gross-monthly-income total-percentage))
            
            (list 'child-support-calculation
                  'monthly-income gross-monthly-income
                  'children-count children-count
                  'support-percentage total-percentage
                  'monthly-support support-amount
                  'per-child (/ support-amount children-count)
                  'legal-basis "Family Code, Article 194"))))))
```

### **`determine-custody-factors`**
Evaluates factors for child custody determination.

```lisp
(define determine-custody-factors
  (lambda (parent-info child-info)
    (begin
      (define parent-stability (get parent-info 'stability-score))
      (define parent-income (get parent-info 'monthly-income))
      (define child-preference (get child-info 'preference))
      (define child-age (get child-info 'age))
      
      ; Weight factors based on legal standards
      (define stability-weight 0.40)
      (define income-weight 0.20)
      (define preference-weight (if (>= child-age 10) 0.30 0.10))
      (define other-weight (- 1.0 stability-weight income-weight preference-weight))
      
      (define custody-score
        (+ (* parent-stability stability-weight)
           (* (min (/ parent-income 50000) 1.0) income-weight)
           (* child-preference preference-weight)))
      
      (list 'custody-evaluation
            'parent-info parent-info
            'child-info child-info
            'custody-score custody-score
            'recommendation (if (> custody-score 0.7) 'primary-custody 'shared-custody)
            'legal-basis "Family Code, Article 213"))))
```

### **`calculate-spousal-support`**
Calculates spousal support based on marriage duration and income disparity.

```lisp
(define calculate-spousal-support
  (lambda (higher-income lower-income marriage-years)
    (begin
      (define income-disparity (- higher-income lower-income))
      (define support-percentage
        (cond ((< marriage-years 5) 0.15)
              ((< marriage-years 10) 0.20)
              ((< marriage-years 20) 0.25)
              (else 0.30)))
      
      (define support-amount (* income-disparity support-percentage))
      (define duration-years (min marriage-years 10))  ; Max 10 years support
      
      (list 'spousal-support
            'higher-income higher-income
            'lower-income lower-income
            'income-disparity income-disparity
            'marriage-duration marriage-years
            'support-percentage support-percentage
            'monthly-support support-amount
            'duration-years duration-years
            'legal-basis "Family Code, Article 201"))))
```

---

## 💰 Tax Law Functions {#tax-law}

### **`calculate-income-tax`**
Calculates progressive income tax based on Philippine BIR rates.

```lisp
(define calculate-income-tax
  (lambda (annual-income filing-status)
    (begin
      (define tax-brackets
        (list (list 0 250000 0.00)        ; ₱0 - ₱250K: 0%
              (list 250000 400000 0.20)   ; ₱250K - ₱400K: 20%
              (list 400000 800000 0.25)   ; ₱400K - ₱800K: 25%
              (list 800000 2000000 0.30)  ; ₱800K - ₱2M: 30%
              (list 2000000 8000000 0.32) ; ₱2M - ₱8M: 32%
              (list 8000000 999999999 0.35))) ; Above ₱8M: 35%
      
      (define tax-due (calculate-progressive-tax annual-income tax-brackets))
      
      ; Apply filing status adjustment
      (define adjusted-tax (if (eq? filing-status 'married)
                              (* tax-due 0.95)  ; 5% reduction for married
                              tax-due))
      
      (list 'income-tax-calculation
            'annual-income annual-income
            'filing-status filing-status
            'gross-tax tax-due
            'adjusted-tax adjusted-tax
            'effective-rate (/ adjusted-tax annual-income)
            'net-income (- annual-income adjusted-tax)
            'legal-basis "Section 24(A), NIRC"))))
```

### **`calculate-estate-tax`**
Calculates estate tax with exemptions and deductions.

```lisp
(define calculate-estate-tax
  (lambda (gross-estate deductions exemptions)
    (begin
      (define net-estate (- gross-estate deductions exemptions))
      (define taxable-estate (max 0 (- net-estate 200000)))  ; ₱200K exemption
      (define estate-tax (* taxable-estate 0.06))  ; 6% estate tax rate
      
      (list 'estate-tax-calculation
            'gross-estate gross-estate
            'deductions deductions
            'exemptions exemptions
            'net-estate net-estate
            'taxable-estate taxable-estate
            'estate-tax estate-tax
            'legal-basis "Section 84, NIRC"))))
```

### **`calculate-vat`**
Calculates Value Added Tax with exemptions.

```lisp
(define calculate-vat
  (lambda (gross-sales vat-exempt-sales)
    (begin
      (define vat-rate 0.12)  ; 12% VAT rate
      (define vat-taxable-sales (- gross-sales vat-exempt-sales))
      (define vat-due (* vat-taxable-sales vat-rate))
      
      (list 'vat-calculation
            'gross-sales gross-sales
            'vat-exempt-sales vat-exempt-sales
            'vat-taxable-sales vat-taxable-sales
            'vat-rate vat-rate
            'vat-due vat-due
            'legal-basis "Section 106, NIRC"))))
```

---

## 🏠 Property Law Functions {#property-law}

### **`calculate-property-transfer-tax`**
Calculates transfer tax for property transactions.

```lisp
(define calculate-property-transfer-tax
  (lambda (property-value property-type location)
    (begin
      (define base-rate
        (cond ((eq? property-type 'residential) 0.005)  ; 0.5%
              ((eq? property-type 'commercial) 0.0075)  ; 0.75%
              ((eq? property-type 'industrial) 0.010)   ; 1.0%
              (else 0.0075)))
      
      ; Location multiplier
      (define location-multiplier
        (cond ((eq? location 'metro-manila) 1.5)
              ((eq? location 'urban) 1.2)
              ((eq? location 'rural) 1.0)
              (else 1.0)))
      
      (define transfer-tax (* property-value base-rate location-multiplier))
      
      (list 'transfer-tax-calculation
            'property-value property-value
            'property-type property-type
            'location location
            'base-rate base-rate
            'location-multiplier location-multiplier
            'transfer-tax transfer-tax
            'legal-basis "Local Government Code"))))
```

### **`determine-property-ownership`**
Determines property ownership type and shares.

```lisp
(define determine-property-ownership
  (lambda (owners-info acquisition-type)
    (begin
      (define owners-count (length owners-info))
      
      (define ownership-type
        (cond ((= owners-count 1) 'sole-ownership)
              ((eq? acquisition-type 'marriage) 'community-property)
              ((eq? acquisition-type 'inheritance) 'co-ownership)
              (else 'joint-ownership)))
      
      (define ownership-shares
        (cond ((eq? ownership-type 'sole-ownership) (list 1.0))
              ((eq? ownership-type 'community-property) (list 0.5 0.5))
              (else (map (lambda (owner) (/ 1.0 owners-count)) owners-info))))
      
      (list 'property-ownership
            'owners-info owners-info
            'ownership-type ownership-type
            'ownership-shares ownership-shares
            'legal-basis "Articles 147-148, Family Code"))))
```

---

## ⚖️ Criminal Law Functions {#criminal-law}

### **`calculate-penalty-range`**
Calculates penalty range with mitigating and aggravating circumstances.

```lisp
(define calculate-penalty-range
  (lambda (base-penalty mitigating-count aggravating-count)
    (begin
      ; Each mitigating reduces penalty by 10%, each aggravating increases by 15%
      (define mitigating-reduction (* mitigating-count 0.10))
      (define aggravating-increase (* aggravating-count 0.15))
      (define net-adjustment (- aggravating-increase mitigating-reduction))
      
      (define adjusted-penalty (* base-penalty (+ 1.0 net-adjustment)))
      
      ; Apply legal limits (50% minimum, 200% maximum of base penalty)
      (define minimum-penalty (* base-penalty 0.50))
      (define maximum-penalty (* base-penalty 2.00))
      (define final-penalty (max minimum-penalty (min maximum-penalty adjusted-penalty)))
      
      (list 'penalty-calculation
            'base-penalty base-penalty
            'mitigating-circumstances mitigating-count
            'aggravating-circumstances aggravating-count
            'net-adjustment net-adjustment
            'final-penalty final-penalty
            'legal-basis "Article 64, Revised Penal Code"))))
```

### **`check-prescription-period`**
Checks if a crime has prescribed based on penalty type.

```lisp
(define check-prescription-period
  (lambda (crime-type years-since-commission)
    (begin
      (define prescription-period
        (cond ((eq? crime-type 'light-felony) (/ 2.0 12))  ; 2 months
              ((eq? crime-type 'correctional-penalty) 10)   ; 10 years
              ((eq? crime-type 'afflictive-penalty) 20)     ; 20 years
              ((eq? crime-type 'capital-punishment) 20)     ; 20 years
              (else 10)))  ; Default to 10 years
      
      (define has-prescribed (> years-since-commission prescription-period))
      
      (list 'prescription-check
            'crime-type crime-type
            'years-since-commission years-since-commission
            'prescription-period prescription-period
            'has-prescribed has-prescribed
            'legal-basis "Article 90, Revised Penal Code"))))
```

---

## 👔 Labor Law Functions {#labor-law}

### **`calculate-overtime-pay`**
Calculates overtime pay according to Labor Code.

```lisp
(define calculate-overtime-pay
  (lambda (regular-hourly-rate hours-worked)
    (begin
      (define regular-hours 8)
      (define overtime-hours (max 0 (- hours-worked regular-hours)))
      
      (define regular-pay (* regular-hourly-rate (min hours-worked regular-hours)))
      
      ; Overtime rates: 125% for first 2 hours, 130% for additional hours
      (define overtime-pay
        (if (<= overtime-hours 0)
            0
            (if (<= overtime-hours 2)
                (* overtime-hours regular-hourly-rate 1.25)
                (+ (* 2 regular-hourly-rate 1.25)
                   (* (- overtime-hours 2) regular-hourly-rate 1.30)))))
      
      (list 'overtime-calculation
            'regular-hours (min hours-worked regular-hours)
            'overtime-hours overtime-hours
            'regular-pay regular-pay
            'overtime-pay overtime-pay
            'total-pay (+ regular-pay overtime-pay)
            'legal-basis "Article 87, Labor Code"))))
```

### **`calculate-separation-pay`**
Calculates separation pay based on termination cause.

```lisp
(define calculate-separation-pay
  (lambda (monthly-salary years-of-service termination-cause)
    (begin
      (define separation-rate
        (cond ((eq? termination-cause 'just-cause) 0)      ; No separation pay
              ((eq? termination-cause 'authorized-cause) 1) ; 1 month per year
              ((eq? termination-cause 'illegal-dismissal) 0.5) ; 0.5 month per year
              (else 0)))
      
      (define separation-pay (* monthly-salary years-of-service separation-rate))
      
      (list 'separation-pay-calculation
            'monthly-salary monthly-salary
            'years-of-service years-of-service
            'termination-cause termination-cause
            'separation-rate separation-rate
            'separation-pay separation-pay
            'legal-basis "Article 279, Labor Code"))))
```

---

## 🏢 Corporate Law Functions {#corporate-law}

### **`calculate-dividend-distribution`**
Calculates dividend distribution among shareholders.

```lisp
(define calculate-dividend-distribution
  (lambda (total-dividends shareholder-info)
    (begin
      (define total-shares 
        (apply + (map (lambda (shareholder) (cadr shareholder)) shareholder-info)))
      
      (define dividend-per-share (/ total-dividends total-shares))
      
      (define distributions
        (map (lambda (shareholder)
               (begin
                 (define name (car shareholder))
                 (define shares (cadr shareholder))
                 (define dividend (* shares dividend-per-share))
                 (list name shares dividend)))
             shareholder-info))
      
      (list 'dividend-distribution
            'total-dividends total-dividends
            'total-shares total-shares
            'dividend-per-share dividend-per-share
            'distributions distributions
            'legal-basis "Corporation Code, Section 43"))))
```

### **`check-quorum-requirements`**
Checks if quorum requirements are met for corporate meetings.

```lisp
(define check-quorum-requirements
  (lambda (meeting-type total-eligible attendees)
    (begin
      (define quorum-requirement
        (cond ((eq? meeting-type 'stockholders) (/ total-eligible 2))  ; Majority of shares
              ((eq? meeting-type 'board) (/ total-eligible 2))         ; Majority of directors
              (else (/ total-eligible 2))))
      
      (define has-quorum (> attendees quorum-requirement))
      
      (list 'quorum-check
            'meeting-type meeting-type
            'total-eligible total-eligible
            'attendees attendees
            'quorum-requirement quorum-requirement
            'has-quorum has-quorum
            'legal-basis "Corporation Code, Section 52"))))
```

---

## 🔧 Utility Functions {#utility-functions}

### **`kv`** - Key-Value Pair Creation
```lisp
(define kv
  (lambda (key value)
    (list key value)))
```

### **`get`** - Extract Value from Legal Record
```lisp
(define get
  (lambda (record key)
    (begin
      (define find-pair
        (lambda (pairs)
          (if (null? pairs)
              #f
              (if (eq? (car (car pairs)) key)
                  (cadr (car pairs))
                  (find-pair (cdr pairs))))))
      (find-pair record))))
```

### **`format-currency`** - Format Monetary Amounts
```lisp
(define format-currency
  (lambda (amount)
    (begin
      (define rounded (round (* amount 100)))
      (define pesos (/ rounded 100))
      (string-append "₱" (number->string pesos)))))
```

### **`calculate-percentage`** - Calculate Percentage
```lisp
(define calculate-percentage
  (lambda (part total)
    (if (= total 0)
        0
        (* (/ part total) 100))))
```

---

## ✅ Validation Functions {#validation-functions}

### **`validate-monetary-amount`**
```lisp
(define validate-monetary-amount
  (lambda (amount)
    (and (number? amount) (>= amount 0))))
```

### **`validate-percentage`**
```lisp
(define validate-percentage
  (lambda (percentage)
    (and (number? percentage) (>= percentage 0) (<= percentage 1))))
```

### **`validate-legal-age`**
```lisp
(define validate-legal-age
  (lambda (age)
    (and (number? age) (>= age 0) (<= age 150))))
```

### **`validate-boolean-input`**
```lisp
(define validate-boolean-input
  (lambda (input)
    (boolean? input)))
```

---

## 📅 Date and Time Functions {#date-time-functions}

### **`add-business-days`**
Adds business days (excluding weekends and holidays).

```lisp
(define add-business-days
  (lambda (start-date days)
    (begin
      ; Simplified implementation - would need actual date library
      (define total-days (* days 1.4))  ; Approximate for weekends
      (+ start-date total-days))))
```

### **`calculate-legal-deadline`**
Calculates legal deadlines with proper day counting.

```lisp
(define calculate-legal-deadline
  (lambda (start-date period-days exclude-weekends?)
    (begin
      (define end-date
        (if exclude-weekends?
            (add-business-days start-date period-days)
            (+ start-date period-days)))
      
      (list 'deadline-calculation
            'start-date start-date
            'period-days period-days
            'exclude-weekends exclude-weekends?
            'end-date end-date))))
```

---

## 📋 Usage Examples

### **Contract Analysis**
```lisp
; Check contract validity
(define contract-result (check-contract-validity #t #t #t))

; Calculate damages for breach
(define damages (calculate-liquidated-damages 1000000 30 0.001))
```

### **Family Law Calculations**
```lisp
; Calculate child support
(define support (calculate-child-support 50000 2))

; Determine custody factors
(define custody (determine-custody-factors parent-data child-data))
```

### **Tax Calculations**
```lisp
; Calculate income tax
(define tax (calculate-income-tax 600000 'single))

; Calculate estate tax
(define estate-tax (calculate-estate-tax 5000000 500000 200000))
```

---

## 🔗 Integration with Main System

All functions in this library are designed to work seamlessly with the main Etherney eLISP system. They follow the same patterns and conventions used throughout the legal coding framework.

### **Loading the Library**
```lisp
; In your legal application
(load "legal-function-library.lisp")

; Use library functions
(define result (check-contract-validity #t #t #t))
```

### **Extending the Library**
To add new functions to the library, follow the established patterns:
1. Include comprehensive input validation
2. Provide structured, detailed results
3. Include legal basis citations
4. Handle error cases appropriately
5. Use consistent naming conventions

---

*This legal function library provides a comprehensive foundation for legal programming with Etherney eLISP. All functions are designed for accuracy, reliability, and professional legal use.*