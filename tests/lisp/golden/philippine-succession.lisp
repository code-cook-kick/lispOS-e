(print
  "=== Golden Fixture: Philippine Succession Integration ===")

(load "src/lisp/domains/ph/intestate-succession.lisp")

(load "src/lisp/domains/ph/testate-succession.lisp")

(print "✓ Philippine succession modules loaded")

(print
  "--- Test Case 1: Intestate Succession (Spouse + Children) ---")

(define intestate-death-event
  (event
    'death
    '
    (juan-dela-cruz)
    ':properties
    (list
    ':person
    'juan-dela-cruz
    ':date
    "2024-01-15"
    ':spouse
    'maria-dela-cruz
    ':legitimate-children
    (list 'pedro-dela-cruz 'ana-dela-cruz)
    ':will
    #f
    ':jurisdiction
    'PH)))

(define intestate-context
  (list
    ':evaluation-date
    "2024-01-15"
    ':jurisdiction
    'PH
    ':temporal-mode
    'strict
    ':conflict-strategies
    (list 'priority 'specificity 'hierarchy)))

(define intestate-result
  (ph.resolve-intestate-succession
    intestate-death-event
    intestate-context))

(define intestate-validation
  (ph.validate-succession-result intestate-result))

(print "Intestate succession results:")

(print
  "  Final facts count:"
  (length (get-event-property intestate-result ':final-facts)))

(print "  Validation:" intestate-validation)

(define expected-intestate-heirs
  3)

(define expected-spouse-share
  0.25)

(define expected-child-share
  0.375)

(define intestate-test-passed
  (let
    ((final-facts
    (get-event-property intestate-result ':final-facts))
    (validation (ph.validate-succession-result intestate-result)))
    (and
    (=
    (length (ph.extract-heir-shares final-facts))
    expected-intestate-heirs)
    (get-event-property validation ':shares-valid))))

(print "✓ Intestate test passed:" intestate-test-passed)

(print "--- Test Case 2: Testate Succession (With Will) ---")

(define test-will
  (list
    ':id
    'will-juan-2024
    ':date
    "2023-12-01"
    ':revoked
    #f
    ':bequests
    (list
    (list
    ':id
    'bequest-1
    ':legatee
    'pedro-dela-cruz
    ':share
    0.4
    ':type
    'specific
    ':date
    "2023-12-01")
    (list
    ':id
    'bequest-2
    ':legatee
    'ana-dela-cruz
    ':share
    0.3
    ':type
    'general
    ':date
    "2023-12-01"))
    ':residue
    (list ':heirs (list 'maria-dela-cruz) ':share 0.3)))

(define testate-death-event
  (event
    'death
    '
    (juan-dela-cruz)
    ':properties
    (list
    ':person
    'juan-dela-cruz
    ':date
    "2024-01-15"
    ':will
    test-will
    ':spouse
    'maria-dela-cruz
    ':compulsory-heirs
    (list 'pedro-dela-cruz 'ana-dela-cruz)
    ':jurisdiction
    'PH)))

(define testate-context
  (list
    ':evaluation-date
    "2024-01-15"
    ':jurisdiction
    'PH
    ':temporal-mode
    'strict
    ':conflict-strategies
    (list 'priority 'specificity 'hierarchy)
    ':death-event
    testate-death-event))

(define testate-result
  (ph.resolve-testate-succession
    testate-death-event
    testate-context))

(define testate-validation
  (ph.validate-testate-result testate-result))

(print "Testate succession results:")

(print
  "  Final facts count:"
  (length (get-event-property testate-result ':final-facts)))

(print "  Validation:" testate-validation)

(define expected-testate-facts
  4)

(define testate-test-passed
  (let
    ((final-facts
    (get-event-property testate-result ':final-facts))
    (validation (ph.validate-testate-result testate-result)))
    (and
    (>= (length final-facts) expected-testate-facts)
    (get-event-property validation ':shares-valid))))

(print "✓ Testate test passed:" testate-test-passed)

(print "--- Test Case 3: Complete Succession Integration ---")

(define no-will-event
  (event
    'death
    '
    (maria-santos)
    ':properties
    (list
    ':person
    'maria-santos
    ':date
    "2024-02-01"
    ':will
    #f
    ':spouse
    'jose-santos
    ':legitimate-children
    (list 'luis-santos))))

(define no-will-context
  (list
    ':evaluation-date
    "2024-02-01"
    ':jurisdiction
    'PH
    ':temporal-mode
    'strict))

(define complete-result
  (ph.resolve-complete-succession no-will-event no-will-context))

(print "Complete succession (no will) results:")

(print
  "  Final facts count:"
  (length (get-event-property complete-result ':final-facts)))

(define simple-will
  (list
    ':id
    'will-simple
    ':date
    "2023-06-01"
    ':revoked
    #f
    ':bequests
    (list
    (list
    ':id
    'bequest-simple
    ':legatee
    'charity-org
    ':share
    0.2
    ':type
    'general))
    ':residue
    (list ':heirs (list 'jose-santos 'luis-santos) ':share 0.8)))

(define with-will-event
  (event
    'death
    '
    (maria-santos)
    ':properties
    (list
    ':person
    'maria-santos
    ':date
    "2024-02-01"
    ':will
    simple-will
    ':spouse
    'jose-santos
    ':compulsory-heirs
    (list 'luis-santos))))

(define with-will-context
  (list
    ':evaluation-date
    "2024-02-01"
    ':jurisdiction
    'PH
    ':temporal-mode
    'strict
    ':death-event
    with-will-event))

(define complete-will-result
  (ph.resolve-complete-succession
    with-will-event
    with-will-context))

(print "Complete succession (with will) results:")

(print
  "  Final facts count:"
  (length
  (get-event-property complete-will-result ':final-facts)))

(define integration-test-passed
  (and
    (>
    (length (get-event-property complete-result ':final-facts))
    0)
    (>
    (length
    (get-event-property complete-will-result ':final-facts))
    0)))

(print "✓ Integration test passed:" integration-test-passed)

(print "--- Test Case 4: Temporal Validity and Conflicts ---")

(define temporal-will
  (list
    ':id
    'will-temporal
    ':date
    "2023-01-01"
    ':revoked
    #f
    ':revocation-date
    "2023-06-01"
    ':bequests
    (list
    (list
    ':id
    'bequest-revoked
    ':legatee
    'old-beneficiary
    ':share
    1.0))))

(define temporal-death-event
  (event
    'death
    '
    (temporal-testator)
    ':properties
    (list
    ':person
    'temporal-testator
    ':date
    "2024-01-01"
    ':will
    temporal-will
    ':spouse
    'temporal-spouse
    ':legitimate-children
    (list 'temporal-child))))

(define temporal-context
  (list
    ':evaluation-date
    "2024-01-01"
    ':jurisdiction
    'PH
    ':temporal-mode
    'strict))

(define temporal-result
  (ph.resolve-complete-succession
    temporal-death-event
    temporal-context))

(print "Temporal validity test results:")

(print
  "  Final facts count:"
  (length (get-event-property temporal-result ':final-facts)))

(define temporal-test-passed
  (let
    ((final-facts
    (get-event-property temporal-result ':final-facts))
    )
    (and
    (> (length final-facts) 0)
    (eq?
    (length
    (filter
    (lambda (fact)
    (eq? (get-event-property fact ':predicate) 'will-status))
    final-facts))
    0))))

(print "✓ Temporal test passed:" temporal-test-passed)

(define all-ph-tests-passed
  (and
    intestate-test-passed
    testate-test-passed
    integration-test-passed
    temporal-test-passed))

(print "")

(print
  "=== PHILIPPINE SUCCESSION INTEGRATION TEST RESULTS ===")

(print
  "Intestate Succession: "
  (if intestate-test-passed
    "PASS"
    "FAIL"))

(print
  "Testate Succession:   "
  (if testate-test-passed
    "PASS"
    "FAIL"))

(print
  "Complete Integration: "
  (if integration-test-passed
    "PASS"
    "FAIL"))

(print
  "Temporal Validity:    "
  (if temporal-test-passed
    "PASS"
    "FAIL"))

(print "")

(print
  "OVERALL RESULT:       "
  (if all-ph-tests-passed
    "✅ PASS"
    "❌ FAIL"))

(print "")

all-ph-tests-passed
