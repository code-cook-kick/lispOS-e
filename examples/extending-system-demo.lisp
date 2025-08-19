; Demonstration: Extending the Legal System with New Rules
; This file shows lawyers how to add their own legal rules to the system

; =============================================================================
; EXAMPLE: ADDING CONTRACT LAW RULES
; =============================================================================

; Legal basis: Article 1318, Civil Code - Essential Elements of Contracts
; "There is no contract unless the following requisites concur:
; (1) Consent of the contracting parties;
; (2) Object certain which is the subject matter of the contract;
; (3) Cause of the obligation which is established."

(define check-contract-validity
  (lambda (has-consent? has-object? has-cause?)
    (begin
      ; Input validation
      (define inputs-valid (and (boolean? has-consent?)
                               (boolean? has-object?)
                               (boolean? has-cause?)))
      
      (if (not inputs-valid)
          (list 'error "Invalid inputs: all parameters must be boolean")
          (begin
            ; Apply Article 1318 requirements
            (define all-elements-present (and has-consent? has-object? has-cause?))
            
            ; Determine missing elements
            (define missing-elements
              (filter (lambda (element) (not (cdr element)))
                      (list (cons 'consent has-consent?)
                            (cons 'object has-object?)
                            (cons 'cause has-cause?))))
            
            ; Return structured result
            (list 'contract-validity-check
                  'article 1318
                  'valid all-elements-present
                  'consent has-consent?
                  'object has-object?
                  'cause has-cause?
                  'missing-elements (if all-elements-present
                                       'none
                                       (map car missing-elements))
                  'legal-effect (if all-elements-present
                                   'valid-and-enforceable
                                   'invalid-no-contract)))))))

; Test the new contract validity rule
(print "=== CONTRACT VALIDITY EXAMPLES ===")
(print (list "All elements present:" (check-contract-validity #t #t #t)))
(print (list "Missing consent:" (check-contract-validity #f #t #t)))
(print (list "Missing object:" (check-contract-validity #t #f #t)))
(print (list "Missing cause:" (check-contract-validity #t #t #f)))
(print (list "Multiple missing:" (check-contract-validity #f #f #t)))

; =============================================================================
; EXAMPLE: ADDING LABOR LAW RULES
; =============================================================================

; Legal basis: Article 279, Labor Code - Security of Tenure
; Regular employees can only be terminated for just or authorized causes

(define check-termination-validity
  (lambda (employee-status termination-reason due-process-followed?)
    (begin
      ; Define valid termination reasons
      (define just-causes '(serious-misconduct willful-disobedience gross-neglect
                           fraud breach-of-trust commission-of-crime analogous-causes))
      (define authorized-causes '(redundancy retrenchment closure disease
                                 installation-of-labor-saving-devices))
      
      ; Check if employee is regular
      (define is-regular (eq? employee-status 'regular))
      
      ; Check if reason is valid
      (define is-just-cause (member termination-reason just-causes))
      (define is-authorized-cause (member termination-reason authorized-causes))
      (define valid-reason (or is-just-cause is-authorized-cause))
      
      ; Determine termination validity
      (define termination-valid
        (if is-regular
            (and valid-reason due-process-followed?)
            #t))  ; Non-regular employees have different rules
      
      ; Determine separation pay entitlement
      (define separation-pay-due
        (if (and is-regular is-authorized-cause termination-valid)
            #t
            #f))
      
      (list 'termination-validity-check
            'employee-status employee-status
            'termination-reason termination-reason
            'due-process-followed due-process-followed?
            'valid-termination termination-valid
            'separation-pay-due separation-pay-due
            'legal-basis "Article 279, Labor Code"))))

; Test the labor law rule
(print "")
(print "=== LABOR LAW TERMINATION EXAMPLES ===")
(print (list "Valid just cause:" (check-termination-validity 'regular 'serious-misconduct #t)))
(print (list "Valid authorized cause:" (check-termination-validity 'regular 'redundancy #t)))
(print (list "Invalid reason:" (check-termination-validity 'regular 'personal-dislike #t)))
(print (list "No due process:" (check-termination-validity 'regular 'serious-misconduct #f)))

; =============================================================================
; EXAMPLE: ADDING TAX LAW RULES
; =============================================================================

; Legal basis: Section 24(A), NIRC - Individual Income Tax
; Progressive tax rates for individual taxpayers

(define calculate-income-tax
  (lambda (annual-income filing-status)
    (begin
      ; Tax brackets for 2023 (simplified)
      (define tax-brackets
        (list (list 0 250000 0.00)        ; ₱0 - ₱250K: 0%
              (list 250000 400000 0.20)   ; ₱250K - ₱400K: 20%
              (list 400000 800000 0.25)   ; ₱400K - ₱800K: 25%
              (list 800000 2000000 0.30)  ; ₱800K - ₱2M: 30%
              (list 2000000 8000000 0.32) ; ₱2M - ₱8M: 32%
              (list 8000000 999999999 0.35))) ; Above ₱8M: 35%
      
      ; Calculate tax using brackets
      (define tax-due (calculate-progressive-tax annual-income tax-brackets))
      
      ; Apply filing status adjustment (married gets 5% reduction)
      (define adjusted-tax (if (eq? filing-status 'married)
                              (* tax-due 0.95)
                              tax-due))
      
      ; Calculate effective rate
      (define effective-rate (if (> annual-income 0)
                                (/ adjusted-tax annual-income)
                                0))
      
      (list 'income-tax-calculation
            'annual-income annual-income
            'filing-status filing-status
            'gross-tax tax-due
            'adjusted-tax adjusted-tax
            'effective-rate effective-rate
            'net-income (- annual-income adjusted-tax)
            'legal-basis "Section 24(A), NIRC"))))

; Helper function for progressive tax calculation
(define calculate-progressive-tax
  (lambda (income brackets)
    (begin
      (define calculate-bracket-tax
        (lambda (income bracket)
          (begin
            (define bracket-min (car bracket))
            (define bracket-max (cadr bracket))
            (define bracket-rate (caddr bracket))
            
            (if (<= income bracket-min)
                0
                (begin
                  (define taxable-in-bracket (min (- income bracket-min)
                                                 (- bracket-max bracket-min)))
                  (* taxable-in-bracket bracket-rate))))))
      
      ; Sum tax from all applicable brackets
      (apply + (map (lambda (bracket) (calculate-bracket-tax income bracket))
                    brackets)))))

; Test the tax calculation rule
(print "")
(print "=== TAX LAW EXAMPLES ===")
(print (list "₱300K income, single:" (calculate-income-tax 300000 'single)))
(print (list "₱500K income, married:" (calculate-income-tax 500000 'married)))
(print (list "₱1M income, single:" (calculate-income-tax 1000000 'single)))

; =============================================================================
; EXAMPLE: ADDING PROPERTY LAW RULES
; =============================================================================

; Legal basis: Article 1544, Civil Code - Double Sale of Immovable Property
; "If the same thing should have been sold to different vendees, the ownership
; shall be transferred to the person who may have first taken possession thereof
; in good faith, if it should be movable property."

(define resolve-double-sale
  (lambda (property-type sales-data)
    (begin
      ; sales-data format: list of (buyer registration-date possession-date good-faith?)
      
      (define is-immovable (eq? property-type 'immovable))
      
      (if is-immovable
          ; For immovable property: first to register in good faith wins
          (resolve-immovable-double-sale sales-data)
          ; For movable property: first to possess in good faith wins
          (resolve-movable-double-sale sales-data))))

(define resolve-immovable-double-sale
  (lambda (sales-data)
    (begin
      ; Filter sales with good faith and valid registration
      (define valid-sales
        (filter (lambda (sale)
                  (and (cadddr sale)  ; good faith
                       (cadr sale)))  ; has registration date
                sales-data))
      
      (if (null? valid-sales)
          (list 'resolution 'no-valid-buyer
                'reason "No buyer in good faith with registration")
          (begin
            ; Find earliest registration date
            (define earliest-sale
              (car (sort valid-sales
                        (lambda (sale1 sale2)
                          (< (cadr sale1) (cadr sale2))))))
            
            (list 'resolution 'ownership-determined
                  'winning-buyer (car earliest-sale)
                  'basis 'first-registration-good-faith
                  'legal-basis "Article 1544, Civil Code"))))))

(define resolve-movable-double-sale
  (lambda (sales-data)
    (begin
      ; Filter sales with good faith and valid possession
      (define valid-sales
        (filter (lambda (sale)
                  (and (cadddr sale)  ; good faith
                       (caddr sale)))  ; has possession date
                sales-data))
      
      (if (null? valid-sales)
          (list 'resolution 'no-valid-buyer
                'reason "No buyer in good faith with possession")
          (begin
            ; Find earliest possession date
            (define earliest-sale
              (car (sort valid-sales
                        (lambda (sale1 sale2)
                          (< (caddr sale1) (caddr sale2))))))
            
            (list 'resolution 'ownership-determined
                  'winning-buyer (car earliest-sale)
                  'basis 'first-possession-good-faith
                  'legal-basis "Article 1544, Civil Code"))))))

; Test the property law rule
(print "")
(print "=== PROPERTY LAW DOUBLE SALE EXAMPLES ===")

; Example: Double sale of house (immovable)
(define house-sales
  (list (list 'buyer-A 20230115 20230120 #t)  ; registered Jan 15, possessed Jan 20, good faith
        (list 'buyer-B 20230110 20230125 #t)  ; registered Jan 10, possessed Jan 25, good faith
        (list 'buyer-C 20230105 20230130 #f))) ; registered Jan 5, possessed Jan 30, bad faith

(print (list "House double sale:" (resolve-double-sale 'immovable house-sales)))

; Example: Double sale of car (movable)
(define car-sales
  (list (list 'buyer-X 20230115 20230112 #t)  ; registered Jan 15, possessed Jan 12, good faith
        (list 'buyer-Y 20230110 20230118 #t)  ; registered Jan 10, possessed Jan 18, good faith
        (list 'buyer-Z 20230105 20230108 #f))) ; registered Jan 5, possessed Jan 8, bad faith

(print (list "Car double sale:" (resolve-double-sale 'movable car-sales)))

; =============================================================================
; EXAMPLE: COMBINING MULTIPLE LEGAL AREAS
; =============================================================================

; Comprehensive legal analysis combining multiple areas of law
(define comprehensive-legal-analysis
  (lambda (case-type case-data)
    (begin
      (define results (list))
      
      ; Apply relevant legal rules based on case type
      (if (member 'contract case-type)
          (begin
            (define contract-result (check-contract-validity
                                    (get case-data 'has-consent)
                                    (get case-data 'has-object)
                                    (get case-data 'has-cause)))
            (set! results (cons (cons 'contract-law contract-result) results))))
      
      (if (member 'employment case-type)
          (begin
            (define employment-result (check-termination-validity
                                      (get case-data 'employee-status)
                                      (get case-data 'termination-reason)
                                      (get case-data 'due-process)))
            (set! results (cons (cons 'labor-law employment-result) results))))
      
      (if (member 'tax case-type)
          (begin
            (define tax-result (calculate-income-tax
                               (get case-data 'annual-income)
                               (get case-data 'filing-status)))
            (set! results (cons (cons 'tax-law tax-result) results))))
      
      ; Return comprehensive analysis
      (list 'comprehensive-analysis
            'case-type case-type
            'legal-areas-analyzed (map car results)
            'detailed-results results
            'analysis-complete #t))))

; Test comprehensive analysis
(print "")
(print "=== COMPREHENSIVE LEGAL ANALYSIS EXAMPLE ===")

(define complex-case-data
  (list (cons 'has-consent #t)
        (cons 'has-object #t)
        (cons 'has-cause #t)
        (cons 'employee-status 'regular)
        (cons 'termination-reason 'redundancy)
        (cons 'due-process #t)
        (cons 'annual-income 600000)
        (cons 'filing-status 'married)))

(define analysis-result
  (comprehensive-legal-analysis '(contract employment tax) complex-case-data))

(print (list "Complex case analysis:" analysis-result))

; =============================================================================
; SUMMARY AND NEXT STEPS
; =============================================================================

(print "")
(print "=== EXTENDING THE LEGAL SYSTEM - SUMMARY ===")
(print "")
(print "This demonstration shows how lawyers can extend the system by:")
(print "1. Adding new legal rules from any area of law")
(print "2. Following the standard pattern: validate inputs → apply legal logic → return structured results")
(print "3. Testing rules with realistic legal scenarios")
(print "4. Combining multiple legal areas for comprehensive analysis")
(print "")
(print "Key benefits of extending the system:")
(print "- Reusable legal logic across cases")
(print "- Consistent application of legal rules")
(print "- Automated legal calculations and determinations")
(print "- Comprehensive multi-area legal analysis")
(print "- Testable and verifiable legal reasoning")
(print "")
(print "Next steps for lawyers:")
(print "1. Identify legal rules from your practice area")
(print "2. Follow the patterns shown in this demonstration")
(print "3. Create comprehensive tests for your rules")
(print "4. Integrate with existing legal applications")
(print "5. Share your legal rule libraries with other lawyers")
(print "")
(print "Remember: Every legal rule you code becomes a reusable asset")
(print "that can help you and other lawyers provide better legal services!")