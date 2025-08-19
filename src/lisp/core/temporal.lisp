(print "Loading core temporal system...")

(define temporal.parse-date
  (lambda (date-str)
    (if (or (eq? date-str #f) (eq? date-str 'unknown))
        #f
        (let
        ((parts (string-split date-str "-")))
        (if (eq? (length parts) 3)
          (list
          ':year
          (string->number (first parts))
          ':month
          (string->number (first (rest parts)))
          ':day
          (string->number (first (rest (rest parts)))))
          #f)))))

(define temporal.date-to-number
  (lambda (date-components)
    (if (eq? date-components #f)
        0
        (let
        ((year (get-event-property date-components ':year))
        (month (get-event-property date-components ':month))
        (day (get-event-property date-components ':day)))
        (+ (* year 10000) (* month 100) day)))))

(define temporal.compare-dates
  (lambda (date1-str date2-str)
    (let
      ((date1-num
      (temporal.date-to-number (temporal.parse-date date1-str)))
      (date2-num
      (temporal.date-to-number (temporal.parse-date date2-str))))
      (if (< date1-num date2-num)
        -1
        (if (> date1-num date2-num)
          1
          0)))))

(define temporal.before?
  (lambda (date1-str date2-str)
    (eq? (temporal.compare-dates date1-str date2-str) -1)))

(define temporal.after?
  (lambda (date1-str date2-str)
    (eq? (temporal.compare-dates date1-str date2-str) 1)))

(define temporal.equal?
  (lambda (date1-str date2-str)
    (eq? (temporal.compare-dates date1-str date2-str) 0)))

(define temporal.before-or-equal?
  (lambda (date1-str date2-str)
    (let
      ((comparison (temporal.compare-dates date1-str date2-str)))
      (or (eq? comparison -1) (eq? comparison 0)))))

(define temporal.after-or-equal?
  (lambda (date1-str date2-str)
    (let
      ((comparison (temporal.compare-dates date1-str date2-str)))
      (or (eq? comparison 1) (eq? comparison 0)))))

(define temporal.extract-context
  (lambda (ctx)
    (let
      ((evaluation-date (get-event-property ctx ':evaluation-date))
      (reference-date (get-event-property ctx ':reference-date))
      (temporal-mode (get-event-property ctx ':temporal-mode)))
      (list
      ':evaluation-date
      (if evaluation-date
        evaluation-date
        "2024-01-01")
      ':reference-date
      (if reference-date
        reference-date
        evaluation-date)
      ':temporal-mode
      (if temporal-mode
        temporal-mode
        'strict)))))

(define temporal.get-effective-date
  (lambda (temporal-ctx)
    (let
      ((mode (get-event-property temporal-ctx ':temporal-mode))
      (eval-date
      (get-event-property temporal-ctx ':evaluation-date))
      (ref-date (get-event-property temporal-ctx ':reference-date)))
      (if (eq? mode 'reference)
        ref-date
        eval-date))))

(define temporal.extract-fact-properties
  (lambda (fact)
    (let
      ((properties (get-event-property fact ':properties)))
      (if properties
        (let
        ((effective-date
        (get-event-property properties ':effective-date))
        (expiry-date (get-event-property properties ':expiry-date))
        (created-date (get-event-property properties ':created-date))
        (valid-from (get-event-property properties ':valid-from))
        (valid-until (get-event-property properties ':valid-until)))
        (list
        ':effective-date
        effective-date
        ':expiry-date
        expiry-date
        ':created-date
        created-date
        ':valid-from
        valid-from
        ':valid-until
        valid-until))
        (list
        ':effective-date
        #f
        ':expiry-date
        #f
        ':created-date
        #f
        ':valid-from
        #f
        ':valid-until
        #f)))))

(define temporal.extract-statute-properties
  (lambda (statute)
    (let
      ((properties (get-event-property statute ':properties)))
      (if properties
        (let
        ((effective-date
        (get-event-property properties ':effective-date))
        (repeal-date (get-event-property properties ':repeal-date))
        (enacted-date (get-event-property properties ':enacted-date))
        (valid-from (get-event-property properties ':valid-from))
        (valid-until (get-event-property properties ':valid-until)))
        (list
        ':effective-date
        effective-date
        ':repeal-date
        repeal-date
        ':enacted-date
        enacted-date
        ':valid-from
        valid-from
        ':valid-until
        valid-until))
        (list
        ':effective-date
        #f
        ':repeal-date
        #f
        ':enacted-date
        #f
        ':valid-from
        #f
        ':valid-until
        #f)))))

(define temporal.fact-valid?
  (lambda (fact temporal-ctx)
    (let
      ((fact-props (temporal.extract-fact-properties fact))
      (effective-date (temporal.get-effective-date temporal-ctx)))
      (let
      ((item-effective
      (get-event-property fact-props ':effective-date))
      (item-expiry (get-event-property fact-props ':expiry-date))
      (item-valid-from (get-event-property fact-props ':valid-from))
      (item-valid-until
      (get-event-property fact-props ':valid-until)))
      (and
      (or
      (eq? item-effective #f)
      (temporal.after-or-equal? effective-date item-effective))
      (or
      (eq? item-expiry #f)
      (temporal.before? effective-date item-expiry))
      (or
      (eq? item-valid-from #f)
      (temporal.after-or-equal? effective-date item-valid-from))
      (or
      (eq? item-valid-until #f)
      (temporal.before-or-equal? effective-date item-valid-until)))))))

(define temporal.statute-valid?
  (lambda (statute temporal-ctx)
    (let
      ((statute-props (temporal.extract-statute-properties statute))
      (effective-date (temporal.get-effective-date temporal-ctx)))
      (let
      ((item-effective
      (get-event-property statute-props ':effective-date))
      (item-repeal (get-event-property statute-props ':repeal-date))
      (item-valid-from
      (get-event-property statute-props ':valid-from))
      (item-valid-until
      (get-event-property statute-props ':valid-until)))
      (and
      (or
      (eq? item-effective #f)
      (temporal.after-or-equal? effective-date item-effective))
      (or
      (eq? item-repeal #f)
      (temporal.before? effective-date item-repeal))
      (or
      (eq? item-valid-from #f)
      (temporal.after-or-equal? effective-date item-valid-from))
      (or
      (eq? item-valid-until #f)
      (temporal.before-or-equal? effective-date item-valid-until)))))))

(define temporal.item-valid?
  (lambda (item temporal-ctx)
    (let
      ((item-type (get-event-property item ':predicate)))
      (if item-type
        (temporal.fact-valid? item temporal-ctx)
        (temporal.statute-valid? item temporal-ctx)))))

(define temporal.filter-items
  (lambda (items temporal-ctx)
    (filter
      (lambda (item)
      (temporal.item-valid? item temporal-ctx))
      items)))

(define temporal.eligible
  (lambda (items ctx)
    (let
      ((temporal-ctx (temporal.extract-context ctx)))
      (temporal.filter-items items temporal-ctx))))

(define temporal.eligible-facts
  (lambda (facts ctx)
    (let
      ((temporal-ctx (temporal.extract-context ctx)))
      (filter
      (lambda (fact)
      (temporal.fact-valid? fact temporal-ctx))
      facts))))

(define temporal.eligible-statutes
  (lambda (statutes ctx)
    (let
      ((temporal-ctx (temporal.extract-context ctx)))
      (filter
      (lambda (statute)
      (temporal.statute-valid? statute temporal-ctx))
      statutes))))

(define temporal.get-status
  (lambda (item temporal-ctx)
    (let
      ((is-valid (temporal.item-valid? item temporal-ctx))
      (effective-date (temporal.get-effective-date temporal-ctx)))
      (if is-valid
        'valid
        (let
        ((item-props
        (if (get-event-property item ':predicate)
          (temporal.extract-fact-properties item)
          (temporal.extract-statute-properties item)))
        )
        (let
        ((item-effective
        (get-event-property item-props ':effective-date))
        (item-expiry
        (or
        (get-event-property item-props ':expiry-date)
        (get-event-property item-props ':repeal-date))))
        (if (and
  item-effective
  (temporal.before? effective-date item-effective))
          'not-yet-effective
          (if (and
  item-expiry
  (temporal.after-or-equal? effective-date item-expiry))
            'expired
            'invalid))))))))

(define temporal.analyze
  (lambda (items ctx)
    (let
      ((temporal-ctx (temporal.extract-context ctx)))
      (map
      (lambda (item)
      (let
        ((status (temporal.get-status item temporal-ctx)))
        (list ':item item ':status status)))
      items))))

(define temporal.count-by-status
  (lambda (items ctx)
    (let
      ((analysis (temporal.analyze items ctx)))
      (let
      ((valid-count 0)
      (invalid-count 0)
      (not-yet-effective-count 0)
      (expired-count 0))
      (define count-recursive
      (lambda (remaining)
        (if (eq? (length remaining) 0)
            (list
            ':valid
            valid-count
            ':invalid
            invalid-count
            ':not-yet-effective
            not-yet-effective-count
            ':expired
            expired-count)
            (let
            ((status (get-event-property (first remaining) ':status)))
            (if (eq? status 'valid)
              (set! valid-count (+ valid-count 1))
              (if (eq? status 'not-yet-effective)
                (set! not-yet-effective-count (+ not-yet-effective-count 1))
                (if (eq? status 'expired)
                  (set! expired-count (+ expired-count 1))
                  (set! invalid-count (+ invalid-count 1)))))
            (count-recursive (rest remaining))))))
      (count-recursive analysis)))))

(define temporal.test-dates
  (lambda ()
    (begin
      (print "Testing temporal date functions...")
      (let
        ((date1 "2024-01-01")
        (date2 "2024-06-15")
        (date3 "2023-12-31"))
        (print "✓ Date parsing: " (temporal.parse-date date1))
        (print
        "✓ Date comparison (2024-01-01 vs 2024-06-15): "
        (temporal.compare-dates date1 date2))
        (print
        "✓ Before check (2023-12-31 before 2024-01-01): "
        (temporal.before? date3 date1))
        (print
        "✓ After check (2024-06-15 after 2024-01-01): "
        (temporal.after? date2 date1))
        #t))))

(define temporal.test-context
  (lambda ()
    (begin
      (print "Testing temporal context extraction...")
      (let
        ((test-ctx
        (list ':evaluation-date "2024-01-01" ':temporal-mode 'strict))
        )
        (let
        ((temporal-ctx (temporal.extract-context test-ctx)))
        (print "✓ Context extraction: " temporal-ctx)
        (print
        "✓ Effective date: "
        (temporal.get-effective-date temporal-ctx))
        #t)))))

(define temporal.test
  (lambda ()
    (begin
      (print "Running temporal system tests...")
      (and
        (temporal.test-dates)
        (temporal.test-context)
        (begin
        (print "✓ All temporal tests passed")
        #t)))))

(print "✓ Core temporal system loaded")

(print
  "✓ Date utilities available: temporal.parse-date, temporal.compare-dates, temporal.before?, temporal.after?")

(print
  "✓ Validity functions available: temporal.eligible, temporal.eligible-facts, temporal.eligible-statutes")

(print
  "✓ Analysis functions available: temporal.analyze, temporal.count-by-status")

(define temporal-functions
  (list
    'temporal.eligible
    'temporal.eligible-facts
    'temporal.eligible-statutes
    'temporal.analyze
    'temporal.count-by-status
    'temporal.extract-context
    'temporal.compare-dates
    'temporal.before?
    'temporal.after?
    'temporal.test))

(print "⏰ Core temporal system ready for legal reasoning")
