(print
  "=== Golden Fixture: Core Infrastructure Integration ===")

(load "src/lisp/core/macros.lisp")

(load "src/lisp/core/indexer.lisp")

(load "src/lisp/core/temporal.lisp")

(load "src/lisp/core/conflicts.lisp")

(load "src/lisp/core/decision-report.lisp")

(print "✓ All core infrastructure loaded")

(define test-facts
  (list
    (event
    'inherits
    '
    (john estate)
    ':properties
    (list
    ':share
    0.5
    ':basis
    'test-statute-1
    ':heir-type
    'child
    ':effective-date
    "2024-01-01"
    ':jurisdiction
    'TEST
    ':priority
    100))
    (event
    'inherits
    '
    (john estate)
    ':properties
    (list
    ':share
    0.3
    ':basis
    'test-statute-2
    ':heir-type
    'spouse
    ':effective-date
    "2024-01-01"
    ':jurisdiction
    'TEST
    ':priority
    200))
    (event
    'inherits
    '
    (mary estate)
    ':properties
    (list
    ':share
    0.7
    ':basis
    'test-statute-3
    ':heir-type
    'spouse
    ':effective-date
    "2023-12-01"
    ':expiry-date
    "2024-06-01"
    ':jurisdiction
    'TEST
    ':priority
    150))))

(define test-statutes
  (list
    (list
    ':id
    'test-statute-1
    ':title
    "Test Child Inheritance"
    ':properties
    (list
    ':jurisdiction
    'TEST
    ':priority
    100
    ':effective-date
    "2023-01-01"))
    (list
    ':id
    'test-statute-2
    ':title
    "Test Spouse Inheritance"
    ':properties
    (list
    ':jurisdiction
    'TEST
    ':priority
    200
    ':effective-date
    "2023-01-01"))
    (list
    ':id
    'test-statute-3
    ':title
    "Test Temporary Statute"
    ':properties
    (list
    ':jurisdiction
    'TEST
    ':priority
    150
    ':effective-date
    "2023-01-01"
    ':repeal-date
    "2024-06-01"))))

(define test-context
  (list
    ':evaluation-date
    "2024-01-15"
    ':jurisdiction
    'TEST
    ':temporal-mode
    'strict
    ':conflict-strategies
    (list 'priority 'specificity)))

(print "✓ Test data setup complete")

(define expected-fact-index-stats
  (list
    ':total-items
    3
    ':type-buckets
    1
    ':subject-buckets
    2
    ':jurisdiction-buckets
    1))

(define expected-temporal-valid-count
  3)

(define expected-conflicts-count
  1)

(define expected-final-facts-count
  2)

(print
  "--- Starting Core Infrastructure Integration Test ---")

(print "Step 1: Testing indexing system...")

(define fact-index
  (index.build-facts test-facts))

(define statute-index
  (index.build-statutes test-statutes))

(define fact-stats
  (index.stats fact-index))

(print "Fact index stats:" fact-stats)

(define indexing-test-passed
  (and
    (=
    (get-event-property fact-stats ':total-items)
    (get-event-property expected-fact-index-stats ':total-items))
    (=
    (get-event-property fact-stats ':subject-buckets)
    (get-event-property
    expected-fact-index-stats
    ':subject-buckets))))

(print "✓ Indexing test passed:" indexing-test-passed)

(print "Step 2: Testing temporal system...")

(define temporal-valid-facts
  (temporal.eligible test-facts test-context))

(define temporal-valid-statutes
  (temporal.eligible-statutes test-statutes test-context))

(print "Temporal filtering results:")

(print "  Valid facts:" (length temporal-valid-facts))

(print "  Valid statutes:" (length temporal-valid-statutes))

(define temporal-test-passed
  (=
    (length temporal-valid-facts)
    expected-temporal-valid-count))

(print "✓ Temporal test passed:" temporal-test-passed)

(print "Step 3: Testing conflict resolution...")

(define conflict-resolution
  (conflicts.resolve
    temporal-valid-facts
    temporal-valid-statutes
    test-context))

(define detected-conflicts
  (get-event-property conflict-resolution ':conflicts))

(define final-facts
  (get-event-property conflict-resolution ':final-items))

(print "Conflict resolution results:")

(print "  Detected conflicts:" (length detected-conflicts))

(print "  Final facts:" (length final-facts))

(define conflicts-test-passed
  (and
    (= (length detected-conflicts) expected-conflicts-count)
    (= (length final-facts) expected-final-facts-count)))

(print "✓ Conflicts test passed:" conflicts-test-passed)

(print "Step 4: Testing decision reporting...")

(define decision-report
  (decision.build
    test-context
    (list (event 'query ' (inheritance-test)))
    temporal-valid-statutes
    final-facts
    conflict-resolution
    (list)))

(define report-valid
  (decision.validate-report decision-report))

(print "Decision report valid:" report-valid)

(define reporting-test-passed
  report-valid)

(print "✓ Reporting test passed:" reporting-test-passed)

(define all-tests-passed
  (and
    indexing-test-passed
    temporal-test-passed
    conflicts-test-passed
    reporting-test-passed))

(print "")

(print "=== CORE INFRASTRUCTURE INTEGRATION TEST RESULTS ===")

(print
  "Indexing System:      "
  (if indexing-test-passed
    "PASS"
    "FAIL"))

(print
  "Temporal System:      "
  (if temporal-test-passed
    "PASS"
    "FAIL"))

(print
  "Conflict Resolution:  "
  (if conflicts-test-passed
    "PASS"
    "FAIL"))

(print
  "Decision Reporting:   "
  (if reporting-test-passed
    "PASS"
    "FAIL"))

(print "")

(print
  "OVERALL RESULT:       "
  (if all-tests-passed
    "✅ PASS"
    "❌ FAIL"))

(print "")

all-tests-passed
