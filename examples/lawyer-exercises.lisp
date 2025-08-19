; Legal Coding Exercises for Lawyers
; Practice problems to build your legal programming skills

; =============================================================================
; EXERCISE 1: BASIC LEGAL CONDITIONS
; =============================================================================

; TODO: Complete this function to determine voting eligibility
; Legal rule: Must be 18+ years old and a Filipino citizen
(define can-vote?
  (lambda (age is-filipino-citizen?)
    ; YOUR CODE HERE
    ; Return #t if eligible to vote, #f otherwise
    #f))

; Test your solution:
; (print (can-vote? 17 #t))  ; Should be #f
; (print (can-vote? 18 #t))  ; Should be #t
; (print (can-vote? 25 #f))  ; Should be #f

; =============================================================================
; EXERCISE 2: CONTRACT LAW
; =============================================================================

; TODO: Complete this function to check if a contract is voidable
; Legal rule: Contract is voidable if any party lacks capacity OR there's fraud/mistake/duress
(define is-contract-voidable?
  (lambda (all-parties-have-capacity? has-fraud? has-mistake? has-duress?)
    ; YOUR CODE HERE
    ; Return #t if contract is voidable, #f if valid
    #f))

; Test your solution:
; (print (is-contract-voidable? #t #f #f #f))  ; Should be #f (valid)
; (print (is-contract-voidable? #f #f #f #f))  ; Should be #t (voidable - no capacity)
; (print (is-contract-voidable? #t #t #f #f))  ; Should be #t (voidable - fraud)

; =============================================================================
; EXERCISE 3: PROPERTY LAW - USUFRUCT CALCULATION
; =============================================================================

; TODO: Complete this function to calculate usufruct duration
; Legal rule: Usufruct on persons lasts for life of usufructuary (max 30 years)
;            Usufruct on juridical persons lasts max 50 years
(define calculate-usufruct-duration
  (lambda (usufructuary-type usufructuary-age specified-years)
    ; usufructuary-type: 'natural-person or 'juridical-person
    ; usufructuary-age: age if natural person, 0 if juridical
    ; specified-years: years specified in the contract
    ; YOUR CODE HERE
    ; Return the actual duration in years
    0))

; Test your solution:
; (print (calculate-usufruct-duration 'natural-person 40 20))  ; Should be 20
; (print (calculate-usufruct-duration 'natural-person 40 40))  ; Should be 30 (max for natural)
; (print (calculate-usufruct-duration 'juridical-person 0 60)) ; Should be 50 (max for juridical)

; =============================================================================
; EXERCISE 4: FAMILY LAW - SUPPORT OBLIGATION
; =============================================================================

; TODO: Complete this function to determine support obligation
; Legal rule: Support is owed to spouse, children, parents, siblings (in that order)
;            Amount depends on means of obligor and needs of obligee
(define calculate-support-obligation
  (lambda (obligor-income obligee-relationship obligee-needs)
    ; obligor-income: monthly income of person obligated to give support
    ; obligee-relationship: 'spouse, 'child, 'parent, 'sibling
    ; obligee-needs: monthly needs of person entitled to support
    ; YOUR CODE HERE
    ; Return support amount (consider relationship priority and ability to pay)
    0))

; Test your solution:
; (print (calculate-support-obligation 50000 'spouse 20000))   ; Should consider full needs
; (print (calculate-support-obligation 30000 'child 15000))    ; Should consider child priority
; (print (calculate-support-obligation 20000 'sibling 25000)) ; Should consider limited ability

; =============================================================================
; EXERCISE 5: CRIMINAL LAW - PRESCRIPTION PERIODS
; =============================================================================

; TODO: Complete this function to check if a crime has prescribed
; Legal rule: Different crimes have different prescription periods
;            Light felonies: 2 months, Correctional penalties: 10 years, Afflictive penalties: 20 years
(define has-crime-prescribed?
  (lambda (crime-type years-since-commission)
    ; crime-type: 'light-felony, 'correctional-penalty, 'afflictive-penalty
    ; years-since-commission: years since the crime was committed
    ; YOUR CODE HERE
    ; Return #t if prescribed, #f if still prosecutable
    #f))

; Test your solution:
; (print (has-crime-prescribed? 'light-felony 0.5))      ; Should be #t (6 months > 2 months)
; (print (has-crime-prescribed? 'correctional-penalty 5)) ; Should be #f (5 years < 10 years)
; (print (has-crime-prescribed? 'afflictive-penalty 25))  ; Should be #t (25 years > 20 years)

; =============================================================================
; EXERCISE 6: TAX LAW - ESTATE TAX CALCULATION
; =============================================================================

; TODO: Complete this function to calculate estate tax
; Legal rule: Estate tax is 6% of net estate exceeding ₱200,000
;            Net estate = Gross estate - Deductions - Exemptions
(define calculate-estate-tax
  (lambda (gross-estate deductions exemptions)
    ; gross-estate: total value of estate
    ; deductions: funeral expenses, debts, etc.
    ; exemptions: family home, etc.
    ; YOUR CODE HERE
    ; Return estate tax due
    0))

; Test your solution:
; (print (calculate-estate-tax 1000000 100000 200000)) ; Net: 700K, Taxable: 500K, Tax: 30K
; (print (calculate-estate-tax 300000 50000 200000))   ; Net: 50K, Taxable: 0, Tax: 0

; =============================================================================
; EXERCISE 7: LABOR LAW - SEPARATION PAY
; =============================================================================

; TODO: Complete this function to calculate separation pay
; Legal rule: Separation pay = 1/2 month salary per year of service (minimum)
;            For authorized causes: 1 month per year
;            For just causes: no separation pay
(define calculate-separation-pay
  (lambda (monthly-salary years-of-service termination-cause)
    ; monthly-salary: employee's monthly salary
    ; years-of-service: number of years worked
    ; termination-cause: 'just-cause, 'authorized-cause, 'illegal-dismissal
    ; YOUR CODE HERE
    ; Return separation pay amount
    0))

; Test your solution:
; (print (calculate-separation-pay 30000 5 'just-cause))        ; Should be 0
; (print (calculate-separation-pay 30000 5 'authorized-cause))  ; Should be 150000 (5 months)
; (print (calculate-separation-pay 30000 5 'illegal-dismissal)) ; Should be 75000 (2.5 months)

; =============================================================================
; EXERCISE 8: CORPORATE LAW - QUORUM CALCULATION
; =============================================================================

; TODO: Complete this function to check if there's a quorum
; Legal rule: Quorum for stockholders = majority of outstanding shares
;            Quorum for board = majority of directors
(define has-quorum?
  (lambda (meeting-type total-eligible attendees)
    ; meeting-type: 'stockholders or 'board
    ; total-eligible: total outstanding shares or total directors
    ; attendees: shares represented or directors present
    ; YOUR CODE HERE
    ; Return #t if quorum is present, #f otherwise
    #f))

; Test your solution:
; (print (has-quorum? 'stockholders 1000000 600000)) ; Should be #t (60% > 50%)
; (print (has-quorum? 'board 9 4))                   ; Should be #f (4 < 5 majority)
; (print (has-quorum? 'board 9 5))                   ; Should be #t (5 = majority)

; =============================================================================
; EXERCISE 9: REAL ESTATE LAW - MORTGAGE CALCULATION
; =============================================================================

; TODO: Complete this function to calculate monthly mortgage payment
; Legal rule: Use standard amortization formula
;            Monthly payment = P * [r(1+r)^n] / [(1+r)^n - 1]
;            Where P = principal, r = monthly rate, n = number of payments
(define calculate-monthly-mortgage
  (lambda (principal annual-rate years)
    ; principal: loan amount
    ; annual-rate: annual interest rate (as decimal, e.g., 0.06 for 6%)
    ; years: loan term in years
    ; YOUR CODE HERE
    ; Return monthly payment amount
    0))

; Test your solution:
; (print (calculate-monthly-mortgage 1000000 0.06 20)) ; Should be around ₱7,164

; =============================================================================
; EXERCISE 10: INSURANCE LAW - PREMIUM CALCULATION
; =============================================================================

; TODO: Complete this function to calculate insurance premium
; Legal rule: Premium = (Sum Insured × Base Rate × Risk Factor) + Fixed Costs
;            Risk factors: Low = 0.8, Medium = 1.0, High = 1.5
(define calculate-insurance-premium
  (lambda (sum-insured base-rate risk-level fixed-costs)
    ; sum-insured: amount of insurance coverage
    ; base-rate: base premium rate (as decimal)
    ; risk-level: 'low, 'medium, 'high
    ; fixed-costs: fixed administrative costs
    ; YOUR CODE HERE
    ; Return total premium amount
    0))

; Test your solution:
; (print (calculate-insurance-premium 1000000 0.02 'medium 5000)) ; Should be 25000
; (print (calculate-insurance-premium 1000000 0.02 'high 5000))   ; Should be 35000

; =============================================================================
; SOLUTIONS (Don't peek until you've tried!)
; =============================================================================

; Uncomment these solutions after attempting the exercises:

; SOLUTION 1:
; (define can-vote?
;   (lambda (age is-filipino-citizen?)
;     (and (>= age 18) is-filipino-citizen?)))

; SOLUTION 2:
; (define is-contract-voidable?
;   (lambda (all-parties-have-capacity? has-fraud? has-mistake? has-duress?)
;     (or (not all-parties-have-capacity?) has-fraud? has-mistake? has-duress?)))

; SOLUTION 3:
; (define calculate-usufruct-duration
;   (lambda (usufructuary-type usufructuary-age specified-years)
;     (if (eq? usufructuary-type 'natural-person)
;         (min specified-years 30)
;         (min specified-years 50))))

; SOLUTION 4:
; (define calculate-support-obligation
;   (lambda (obligor-income obligee-relationship obligee-needs)
;     (begin
;       (define max-support (* obligor-income 0.5))  ; Max 50% of income
;       (define priority-multiplier
;         (cond ((eq? obligee-relationship 'spouse) 1.0)
;               ((eq? obligee-relationship 'child) 1.0)
;               ((eq? obligee-relationship 'parent) 0.8)
;               ((eq? obligee-relationship 'sibling) 0.5)
;               (else 0.3)))
;       (define calculated-support (* obligee-needs priority-multiplier))
;       (min calculated-support max-support))))

; SOLUTION 5:
; (define has-crime-prescribed?
;   (lambda (crime-type years-since-commission)
;     (define prescription-period
;       (cond ((eq? crime-type 'light-felony) (/ 2.0 12))  ; 2 months in years
;             ((eq? crime-type 'correctional-penalty) 10)
;             ((eq? crime-type 'afflictive-penalty) 20)
;             (else 0)))
;     (> years-since-commission prescription-period)))

; Continue with other solutions...

; =============================================================================
; PRACTICE INSTRUCTIONS
; =============================================================================

(print "")
(print "=== LEGAL CODING EXERCISES ===")
(print "")
(print "Instructions:")
(print "1. Read each exercise carefully")
(print "2. Understand the legal rule being implemented")
(print "3. Write your code in the designated area")
(print "4. Test your solution with the provided test cases")
(print "5. Compare with the solutions at the bottom (after trying!)")
(print "")
(print "Tips for success:")
(print "- Break complex legal rules into simple conditions")
(print "- Use descriptive variable names")
(print "- Test edge cases and boundary conditions")
(print "- Think about what inputs could cause errors")
(print "")
(print "Remember: Legal coding is about precision and accuracy!")
(print "Every condition matters, every calculation must be correct.")