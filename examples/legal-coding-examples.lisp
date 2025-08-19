; Legal Coding Examples for Lawyers
; Practical examples showing how to translate legal concepts into code

; =============================================================================
; EXAMPLE 1: BASIC LEGAL CONDITIONS
; =============================================================================

; Legal concept: Age of majority (18 years old in Philippines)
(define is-adult?
  (lambda (age)
    (>= age 18)))

; Legal concept: Senior citizen benefits (60+ years old)
(define qualifies-for-senior-benefits?
  (lambda (age)
    (>= age 60)))

; Legal concept: Legal capacity assessment
(define assess-legal-capacity
  (lambda (age)
    (if (is-adult? age)
        (if (qualifies-for-senior-benefits? age)
            'full-capacity-with-senior-benefits
            'full-capacity)
        'limited-capacity-minor)))

; Test the functions
(print "Legal capacity examples:")
(print (list "Age 16:" (assess-legal-capacity 16)))
(print (list "Age 25:" (assess-legal-capacity 25)))
(print (list "Age 65:" (assess-legal-capacity 65)))

; =============================================================================
; EXAMPLE 2: CONTRACT LAW - ESSENTIAL ELEMENTS
; =============================================================================

; Legal concept: Essential elements of a valid contract (Art. 1318, Civil Code)
(define check-contract-validity
  (lambda (has-consent? has-object? has-cause?)
    (begin
      (define all-elements-present (and has-consent? has-object? has-cause?))
      (if all-elements-present
          (list 'status 'valid 'enforceable #t)
          (list 'status 'invalid 'missing-elements 
                (filter (lambda (element) (not (cdr element)))
                        (list (cons 'consent has-consent?)
                              (cons 'object has-object?)
                              (cons 'cause has-cause?))))))))

; Test contract validity
(print "Contract validity examples:")
(print (list "All elements present:" (check-contract-validity #t #t #t)))
(print (list "Missing consent:" (check-contract-validity #f #t #t)))
(print (list "Missing object and cause:" (check-contract-validity #t #f #f)))

; =============================================================================
; EXAMPLE 3: PROPERTY LAW - OWNERSHIP TYPES
; =============================================================================

; Legal concept: Types of ownership (sole, joint, community property)
(define determine-ownership-type
  (lambda (owners-count married-owners?)
    (if (= owners-count 1)
        'sole-ownership
        (if married-owners?
            'community-property
            'joint-ownership))))

; Legal concept: Property rights calculation
(define calculate-ownership-share
  (lambda (ownership-type owners-count)
    (if (eq? ownership-type 'sole-ownership)
        1.0
        (if (eq? ownership-type 'community-property)
            0.5  ; Each spouse owns 50%
            (/ 1.0 owners-count)))))  ; Equal shares for joint ownership

; Test property ownership
(print "Property ownership examples:")
(print (list "Single owner:" (determine-ownership-type 1 #f)))
(print (list "Married couple:" (determine-ownership-type 2 #t)))
(print (list "Three joint owners:" (determine-ownership-type 3 #f)))

; =============================================================================
; EXAMPLE 4: FAMILY LAW - CHILD SUPPORT CALCULATION
; =============================================================================

; Legal concept: Child support based on income percentage
(define calculate-child-support
  (lambda (gross-monthly-income children-count)
    (begin
      ; Basic support: 20% of gross income for first child, 
      ; additional 10% for each additional child, max 50%
      (define base-percentage 0.20)
      (define additional-percentage 0.10)
      (define max-percentage 0.50)
      
      (define total-percentage 
        (min max-percentage 
             (+ base-percentage 
                (* additional-percentage (- children-count 1)))))
      
      (define support-amount (* gross-monthly-income total-percentage))
      
      (list 'monthly-support support-amount
            'percentage total-percentage
            'per-child (/ support-amount children-count)))))

; Test child support calculation
(print "Child support examples:")
(print (list "₱50K income, 1 child:" (calculate-child-support 50000 1)))
(print (list "₱50K income, 3 children:" (calculate-child-support 50000 3)))
(print (list "₱100K income, 5 children:" (calculate-child-support 100000 5)))

; =============================================================================
; EXAMPLE 5: CRIMINAL LAW - PENALTY CALCULATION
; =============================================================================

; Legal concept: Penalty calculation with mitigating/aggravating circumstances
(define calculate-penalty
  (lambda (base-penalty mitigating-circumstances aggravating-circumstances)
    (begin
      ; Each mitigating circumstance reduces penalty by 10%
      ; Each aggravating circumstance increases penalty by 15%
      (define mitigating-reduction (* mitigating-circumstances 0.10))
      (define aggravating-increase (* aggravating-circumstances 0.15))
      
      (define net-adjustment (- aggravating-increase mitigating-reduction))
      (define adjusted-penalty (* base-penalty (+ 1.0 net-adjustment)))
      
      ; Ensure penalty doesn't go below minimum (50% of base) or above maximum (200% of base)
      (define final-penalty 
        (max (* base-penalty 0.50)
             (min (* base-penalty 2.00) adjusted-penalty)))
      
      (list 'base-penalty base-penalty
            'mitigating-reduction mitigating-reduction
            'aggravating-increase aggravating-increase
            'final-penalty final-penalty))))

; Test penalty calculation
(print "Penalty calculation examples:")
(print (list "Base 6 months, 1 mitigating:" (calculate-penalty 6 1 0)))
(print (list "Base 6 months, 2 aggravating:" (calculate-penalty 6 0 2)))
(print (list "Base 6 months, 1 each:" (calculate-penalty 6 1 1)))

; =============================================================================
; EXAMPLE 6: TAX LAW - PROGRESSIVE INCOME TAX
; =============================================================================

; Legal concept: Progressive tax brackets (simplified Philippine BIR rates)
(define calculate-income-tax
  (lambda (annual-income)
    (begin
      ; Tax brackets (simplified)
      ; ₱0 - ₱250,000: 0%
      ; ₱250,001 - ₱400,000: 20%
      ; ₱400,001 - ₱800,000: 25%
      ; ₱800,001 and above: 30%
      
      (define tax
        (if (<= annual-income 250000)
            0
            (if (<= annual-income 400000)
                (* (- annual-income 250000) 0.20)
                (if (<= annual-income 800000)
                    (+ (* 150000 0.20)  ; First bracket: ₱30,000
                       (* (- annual-income 400000) 0.25))
                    (+ (* 150000 0.20)  ; First bracket: ₱30,000
                       (* 400000 0.25)  ; Second bracket: ₱100,000
                       (* (- annual-income 800000) 0.30))))))
      
      (define effective-rate (if (> annual-income 0) (/ tax annual-income) 0))
      
      (list 'annual-income annual-income
            'tax-due tax
            'effective-rate effective-rate
            'net-income (- annual-income tax)))))

; Test tax calculation
(print "Income tax examples:")
(print (list "₱200K income:" (calculate-income-tax 200000)))
(print (list "₱500K income:" (calculate-income-tax 500000)))
(print (list "₱1M income:" (calculate-income-tax 1000000)))

; =============================================================================
; EXAMPLE 7: LABOR LAW - OVERTIME PAY CALCULATION
; =============================================================================

; Legal concept: Overtime pay calculation (Labor Code)
(define calculate-overtime-pay
  (lambda (regular-hourly-rate hours-worked)
    (begin
      (define regular-hours 8)
      (define overtime-hours (max 0 (- hours-worked regular-hours)))
      
      ; Regular pay for first 8 hours
      (define regular-pay (* regular-hourly-rate (min hours-worked regular-hours)))
      
      ; Overtime pay: 125% of regular rate for hours 9-10, 130% for hours beyond 10
      (define overtime-pay
        (if (<= overtime-hours 0)
            0
            (if (<= overtime-hours 2)
                (* overtime-hours regular-hourly-rate 1.25)
                (+ (* 2 regular-hourly-rate 1.25)  ; First 2 OT hours at 125%
                   (* (- overtime-hours 2) regular-hourly-rate 1.30)))))  ; Rest at 130%
      
      (define total-pay (+ regular-pay overtime-pay))
      
      (list 'regular-hours (min hours-worked regular-hours)
            'overtime-hours overtime-hours
            'regular-pay regular-pay
            'overtime-pay overtime-pay
            'total-pay total-pay))))

; Test overtime calculation
(print "Overtime pay examples:")
(print (list "₱100/hr, 8 hours:" (calculate-overtime-pay 100 8)))
(print (list "₱100/hr, 10 hours:" (calculate-overtime-pay 100 10)))
(print (list "₱100/hr, 12 hours:" (calculate-overtime-pay 100 12)))

; =============================================================================
; EXAMPLE 8: REAL ESTATE LAW - CAPITAL GAINS TAX
; =============================================================================

; Legal concept: Capital gains tax on real estate sale
(define calculate-capital-gains-tax
  (lambda (selling-price acquisition-cost holding-period-years)
    (begin
      (define capital-gain (- selling-price acquisition-cost))
      
      ; Tax rate depends on holding period
      ; Less than 3 years: 30% (short-term)
      ; 3 years or more: 15% (long-term)
      (define tax-rate (if (< holding-period-years 3) 0.30 0.15))
      
      (define tax-due (* capital-gain tax-rate))
      (define net-proceeds (- selling-price tax-due))
      
      (list 'selling-price selling-price
            'acquisition-cost acquisition-cost
            'capital-gain capital-gain
            'holding-period holding-period-years
            'tax-rate tax-rate
            'tax-due tax-due
            'net-proceeds net-proceeds))))

; Test capital gains tax
(print "Capital gains tax examples:")
(print (list "₱5M sale, ₱3M cost, 2 years:" (calculate-capital-gains-tax 5000000 3000000 2)))
(print (list "₱5M sale, ₱3M cost, 5 years:" (calculate-capital-gains-tax 5000000 3000000 5)))

; =============================================================================
; EXAMPLE 9: CORPORATE LAW - DIVIDEND DISTRIBUTION
; =============================================================================

; Legal concept: Dividend distribution among shareholders
(define calculate-dividend-distribution
  (lambda (total-dividends shareholder-info)
    (begin
      ; shareholder-info is a list of (name shares) pairs
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
      
      (list 'total-dividends total-dividends
            'total-shares total-shares
            'dividend-per-share dividend-per-share
            'distributions distributions))))

; Test dividend distribution
(define shareholders (list (list 'Juan 1000) (list 'Maria 1500) (list 'Pedro 500)))
(print "Dividend distribution example:")
(print (calculate-dividend-distribution 300000 shareholders))

; =============================================================================
; EXAMPLE 10: INSURANCE LAW - CLAIM SETTLEMENT
; =============================================================================

; Legal concept: Insurance claim settlement with deductibles and limits
(define calculate-insurance-settlement
  (lambda (claim-amount policy-limit deductible coverage-percentage)
    (begin
      ; Amount after deductible
      (define amount-after-deductible (max 0 (- claim-amount deductible)))
      
      ; Apply coverage percentage
      (define covered-amount (* amount-after-deductible coverage-percentage))
      
      ; Apply policy limit
      (define settlement-amount (min covered-amount policy-limit))
      
      ; Calculate what insured pays out of pocket
      (define out-of-pocket (- claim-amount settlement-amount))
      
      (list 'claim-amount claim-amount
            'deductible deductible
            'amount-after-deductible amount-after-deductible
            'coverage-percentage coverage-percentage
            'policy-limit policy-limit
            'settlement-amount settlement-amount
            'out-of-pocket out-of-pocket))))

; Test insurance settlement
(print "Insurance settlement examples:")
(print (list "₱100K claim, ₱1M limit, ₱10K deductible, 80%:" 
             (calculate-insurance-settlement 100000 1000000 10000 0.80)))
(print (list "₱2M claim, ₱1M limit, ₱50K deductible, 90%:" 
             (calculate-insurance-settlement 2000000 1000000 50000 0.90)))

; =============================================================================
; SUMMARY MESSAGE
; =============================================================================

(print "")
(print "=== LEGAL CODING EXAMPLES COMPLETE ===")
(print "These examples show how to translate common legal concepts into code:")
(print "1. Age and capacity determinations")
(print "2. Contract validity checks")
(print "3. Property ownership calculations")
(print "4. Child support computations")
(print "5. Criminal penalty adjustments")
(print "6. Progressive tax calculations")
(print "7. Labor law overtime pay")
(print "8. Capital gains tax on real estate")
(print "9. Corporate dividend distributions")
(print "10. Insurance claim settlements")
(print "")
(print "Each example demonstrates:")
(print "- How legal rules become functions")
(print "- How legal conditions become if-statements")
(print "- How legal calculations become mathematical expressions")
(print "- How legal outcomes become return values")
(print "")
(print "Practice modifying these examples with different legal scenarios!")