; =============================================================================
; HELLO LAW - Your First Legal Code
; A Simple Introduction to Legal Programming for Lawyers
; =============================================================================

; This is a comment - it explains what the code does but doesn't run
; Comments in LISP start with a semicolon (;)

; Let's start with the simplest possible legal function
; This function just says "Hello" to the legal world

(define say-hello-law
  (lambda ()
    "Hello, Legal World! Welcome to legal programming!"))

; Let's test our first function
(print "=== MY FIRST LEGAL CODE ===")
(print (say-hello-law))

; Now let's make it more legal - a simple legal greeting
(define legal-greeting
  (lambda (lawyer-name)
    (list "Hello, Attorney" lawyer-name "! Ready to code some law?")))

; Test the legal greeting
(print "")
(print "=== LEGAL GREETING ===")
(print (legal-greeting "Smith"))
(print (legal-greeting "Johnson"))

; Let's create our first REAL legal function
; This checks if someone is old enough to enter a contract
; Legal basis: Age of majority (18 years old in most jurisdictions)

(define can-enter-contract?
  (lambda (age)
    (if (>= age 18)
        "YES - Can enter into contracts (age of majority reached)"
        "NO - Cannot enter contracts (minor, needs guardian consent)")))

; Test the contract age checker
(print "")
(print "=== CONTRACT AGE CHECKER ===")
(print "Age 17:")
(print (can-enter-contract? 17))
(print "Age 18:")
(print (can-enter-contract? 18))
(print "Age 25:")
(print (can-enter-contract? 25))

; Let's make it even more legal - a simple legal status checker
(define legal-status-checker
  (lambda (age has-guardian-consent?)
    (if (>= age 18)
        ; If 18 or older, can contract independently
        "ADULT - Can enter contracts independently"
        ; If minor, check for guardian consent
        (if (and (< age 18) has-guardian-consent?)
            "MINOR WITH CONSENT - Can enter limited contracts with guardian approval"
            "MINOR WITHOUT CONSENT - Cannot enter contracts"))))

; Test the legal status checker
(print "")
(print "=== LEGAL STATUS CHECKER ===")
(print "17 years old, no guardian consent:")
(print (legal-status-checker 17 #f))
(print "17 years old, with guardian consent:")
(print (legal-status-checker 17 #t))
(print "25 years old:")
(print (legal-status-checker 25 #f))

; Finally, let's create a simple legal advice function
; This demonstrates how legal rules can be coded
(define simple-legal-advice
  (lambda (situation)
    (if (eq? situation 'contract)
        "ADVICE: Ensure all parties have capacity, there's consideration, and terms are clear."
        (if (eq? situation 'dispute)
            "ADVICE: Document everything, attempt negotiation first, consider mediation."
            (if (eq? situation 'compliance)
                "ADVICE: Review applicable laws, create compliance checklist, monitor regularly."
                "ADVICE: Consult with a qualified attorney for specific legal guidance.")))))

; Test the legal advice function
(print "")
(print "=== SIMPLE LEGAL ADVICE SYSTEM ===")
(print "Situation: contract")
(print (simple-legal-advice 'contract))
(print "Situation: dispute")
(print (simple-legal-advice 'dispute))
(print "Situation: compliance")
(print (simple-legal-advice 'compliance))
(print "Situation: unknown")
(print (simple-legal-advice 'unknown))

; Congratulations! You've written your first legal code!
(print "")
(print "=== CONGRATULATIONS! ===")
(print "You have successfully run your first legal programming code!")
(print "You've learned:")
(print "- How to write functions that implement legal rules")
(print "- How to test legal logic with different scenarios")
(print "- How to create simple legal decision-making systems")
(print "- The basics of legal programming!")
(print "")
(print "Next steps: Try modifying the age limit, add new legal situations,")
(print "or create your own legal functions!")