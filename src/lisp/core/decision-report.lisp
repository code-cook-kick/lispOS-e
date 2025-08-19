(load "src/lisp/common/utils.lisp")

(print "Loading core decision report system...")

(define decision.create-report
  (lambda ()
    (list
      ':type
      'decision-report
      ':version
      "1.0"
      ':timestamp
      (decision.get-timestamp)
      ':context
      (list)
      ':inputs
      (list)
      ':statutes
      (list)
      ':facts
      (list)
      ':conflicts
      (list)
      ':trace
      (list)
      ':conclusions
      (list)
      ':metadata
      (list))))

(define decision.get-timestamp
  (lambda ()
    "2024-01-01T00:00:00Z"))

(define decision.set-property
  (lambda (report property value)
    (begin
      (define update-props
        (lambda (props)
          (if (eq? (length props) 0)
              (list property value)
              (if (eq? (first props) property)
                (cons property (ensure-list (cons value (rest (rest props)))))
                (cons
                (first props)
                (cons
                (first (ensure-list (rest props)))
                (update-props (rest (rest props)))))))))
      (cons
        (first (ensure-list report))
        (update-props (rest report))))))

(define decision.get-property
  (lambda (report property)
    (begin
      (define search-props
        (lambda (props)
          (if (eq? (length props) 0)
              #f
              (if (eq? (first props) property)
                (first (rest props))
                (search-props (rest (rest props)))))))
      (search-props (rest report)))))

(define decision.format-context
  (lambda (ctx)
    (list
      ':evaluation-date
      (get-event-property ctx ':evaluation-date)
      ':reference-date
      (get-event-property ctx ':reference-date)
      ':temporal-mode
      (get-event-property ctx ':temporal-mode)
      ':conflict-strategies
      (get-event-property ctx ':conflict-strategies)
      ':jurisdiction
      (get-event-property ctx ':jurisdiction)
      ':case-id
      (get-event-property ctx ':case-id)
      ':query-type
      (get-event-property ctx ':query-type))))

(define decision.format-inputs
  (lambda (inputs)
    (map
      (lambda (input)
      (list
        ':type
        (decision.get-input-type input)
        ':content
        (decision.format-input-content input)
        ':metadata
        (decision.extract-input-metadata input)))
      inputs)))

(define decision.get-input-type
  (lambda (input)
    (let
      ((predicate (get-event-property input ':predicate)))
      (if predicate
        'fact
        'query))))

(define decision.format-input-content
  (lambda (input)
    (let
      ((predicate (get-event-property input ':predicate))
      (args (get-event-property input ':args)))
      (if predicate
        (list ':predicate predicate ':arguments args)
        input))))

(define decision.extract-input-metadata
  (lambda (input)
    (let
      ((properties (get-event-property input ':properties)))
      (if properties
        properties
        (list)))))

(define decision.format-statutes
  (lambda (statutes)
    (map
      (lambda (statute)
      (list
        ':id
        (get-event-property statute ':id)
        ':title
        (get-event-property statute ':title)
        ':content
        (get-event-property statute ':content)
        ':properties
        (get-event-property statute ':properties)
        ':applicable
        #t))
      statutes)))

(define decision.format-facts
  (lambda (facts)
    (map
      (lambda (fact)
      (list
        ':predicate
        (get-event-property fact ':predicate)
        ':arguments
        (get-event-property fact ':args)
        ':properties
        (get-event-property fact ':properties)
        ':source
        (decision.get-fact-source fact)
        ':confidence
        (decision.get-fact-confidence fact)))
      facts)))

(define decision.get-fact-source
  (lambda (fact)
    (let
      ((properties (get-event-property fact ':properties)))
      (if properties
        (get-event-property properties ':source)
        'derived))))

(define decision.get-fact-confidence
  (lambda (fact)
    (let
      ((properties (get-event-property fact ':properties)))
      (if properties
        (let
        ((confidence (get-event-property properties ':confidence)))
        (if confidence
          confidence
          1.0))
        1.0))))

(define decision.format-conflicts
  (lambda (conflicts-result)
    (let
      ((conflicts (get-event-property conflicts-result ':conflicts))
      (resolutions
      (get-event-property conflicts-result ':resolutions)))
      (list
      ':detected-conflicts
      (decision.format-detected-conflicts conflicts)
      ':resolutions
      (decision.format-conflict-resolutions resolutions)
      ':summary
      (decision.create-conflict-summary conflicts resolutions)))))

(define decision.format-detected-conflicts
  (lambda (conflicts)
    (map
      (lambda (conflict)
      (list
        ':type
        (get-event-property conflict ':conflict-type)
        ':item1
        (decision.format-conflict-item
        (get-event-property conflict ':item1))
        ':item2
        (decision.format-conflict-item
        (get-event-property conflict ':item2))
        ':description
        (decision.describe-conflict conflict)))
      conflicts)))

(define decision.format-conflict-item
  (lambda (item)
    (let
      ((predicate (get-event-property item ':predicate)))
      (if predicate
        (list
        ':type
        'fact
        ':predicate
        predicate
        ':arguments
        (get-event-property item ':args))
        (list
        ':type
        'statute
        ':id
        (get-event-property item ':id)
        ':title
        (get-event-property item ':title))))))

(define decision.describe-conflict
  (lambda (conflict)
    (let
      ((type (get-event-property conflict ':conflict-type)))
      (if (eq? type 'predicate-conflict)
        "Conflicting predicates for the same subject"
        "Unknown conflict type"))))

(define decision.format-conflict-resolutions
  (lambda (resolutions)
    (map
      (lambda (resolution)
      (let
        ((resolution-info (get-event-property resolution ':resolution))
        )
        (if resolution-info
          (list
          ':winner
          (decision.format-conflict-item
          (get-event-property resolution-info ':winner))
          ':strategy
          (get-event-property resolution-info ':strategy)
          ':reason
          (decision.get-resolution-reason resolution-info))
          (list
          ':status
          'unresolved
          ':reason
          "No applicable resolution strategy"))))
      resolutions)))

(define decision.get-resolution-reason
  (lambda (resolution-info)
    (let
      ((strategy (get-event-property resolution-info ':strategy)))
      (if (eq? strategy 'priority)
        "Resolved by priority comparison"
        (if (eq? strategy 'specificity)
          "Resolved by specificity analysis"
          (if (eq? strategy 'hierarchy)
            "Resolved by hierarchical authority"
            (if (eq? strategy 'source)
              "Resolved by source authority"
              "Resolved by unknown strategy")))))))

(define decision.create-conflict-summary
  (lambda (conflicts resolutions)
    (let
      ((total-conflicts (length conflicts))
      (resolved-count
      (length
      (filter
      (lambda (res)
      (not (eq? (get-event-property res ':resolution) #f)))
      resolutions))))
      (list
      ':total-conflicts
      total-conflicts
      ':resolved-conflicts
      resolved-count
      ':unresolved-conflicts
      (- total-conflicts resolved-count)))))

(define decision.format-trace
  (lambda (trace)
    (map
      (lambda (trace-entry)
      (list
        ':step
        (get-event-property trace-entry ':step)
        ':operation
        (get-event-property trace-entry ':operation)
        ':inputs
        (get-event-property trace-entry ':inputs)
        ':outputs
        (get-event-property trace-entry ':outputs)
        ':timestamp
        (get-event-property trace-entry ':timestamp)
        ':duration
        (get-event-property trace-entry ':duration)))
      trace)))

(define decision.add-trace-entry
  (lambda (report step operation inputs outputs)
    (let
      ((current-trace (decision.get-property report ':trace))
      (new-entry
      (list
      ':step
      step
      ':operation
      operation
      ':inputs
      inputs
      ':outputs
      outputs
      ':timestamp
      (decision.get-timestamp)
      ':duration
      0)))
      (decision.set-property
      report
      ':trace
      (append current-trace (list new-entry))))))

(define decision.format-conclusions
  (lambda (conclusions)
    (map
      (lambda (conclusion)
      (list
        ':type
        (get-event-property conclusion ':type)
        ':predicate
        (get-event-property conclusion ':predicate)
        ':arguments
        (get-event-property conclusion ':arguments)
        ':confidence
        (get-event-property conclusion ':confidence)
        ':basis
        (get-event-property conclusion ':basis)
        ':supporting-facts
        (get-event-property conclusion ':supporting-facts)
        ':applicable-statutes
        (get-event-property conclusion ':applicable-statutes)))
      conclusions)))

(define decision.add-conclusion
  (lambda (report conclusion)
    (let
      ((current-conclusions
      (decision.get-property report ':conclusions))
      (formatted-conclusion
      (decision.format-single-conclusion conclusion)))
      (decision.set-property
      report
      ':conclusions
      (append current-conclusions (list formatted-conclusion))))))

(define decision.format-single-conclusion
  (lambda (conclusion)
    (list
      ':type
      (get-event-property conclusion ':type)
      ':predicate
      (get-event-property conclusion ':predicate)
      ':arguments
      (get-event-property conclusion ':arguments)
      ':confidence
      (get-event-property conclusion ':confidence)
      ':basis
      (get-event-property conclusion ':basis))))

(define decision.generate-metadata
  (lambda (report)
    (let
      ((facts (decision.get-property report ':facts))
      (statutes (decision.get-property report ':statutes))
      (conflicts (decision.get-property report ':conflicts))
      (conclusions (decision.get-property report ':conclusions)))
      (list
      ':fact-count
      (length facts)
      ':statute-count
      (length statutes)
      ':conflict-count
      (if conflicts
        (get-event-property conflicts ':total-conflicts)
        0)
      ':conclusion-count
      (length conclusions)
      ':processing-time
      0
      ':memory-usage
      0)))
  (define decision.update-metadata
    (lambda (report)
      (let
        ((metadata (decision.generate-metadata report)))
        (decision.set-property report ':metadata metadata))))
  (define decision.build
    (lambda (ctx inputs statutes facts conflicts trace)
      (let
        ((report (decision.create-report)))
        (let
        ((report-with-context
        (decision.set-property
        report
        ':context
        (decision.format-context ctx)))
        (report-with-inputs
        (decision.set-property
        report-with-context
        ':inputs
        (decision.format-inputs inputs)))
        (report-with-statutes
        (decision.set-property
        report-with-inputs
        ':statutes
        (decision.format-statutes statutes)))
        (report-with-facts
        (decision.set-property
        report-with-statutes
        ':facts
        (decision.format-facts facts)))
        (report-with-conflicts
        (decision.set-property
        report-with-facts
        ':conflicts
        (decision.format-conflicts conflicts)))
        (report-with-trace
        (decision.set-property
        report-with-conflicts
        ':trace
        (decision.format-trace trace))))
        (decision.update-metadata report-with-trace)))))
  (define decision.to-json-structure
    (lambda (report)
      (list
        "type"
        "decision-report"
        "version"
        (decision.get-property report ':version)
        "timestamp"
        (decision.get-property report ':timestamp)
        "context"
        (decision.convert-to-json
        (decision.get-property report ':context))
        "inputs"
        (decision.convert-to-json
        (decision.get-property report ':inputs))
        "statutes"
        (decision.convert-to-json
        (decision.get-property report ':statutes))
        "facts"
        (decision.convert-to-json
        (decision.get-property report ':facts))
        "conflicts"
        (decision.convert-to-json
        (decision.get-property report ':conflicts))
        "trace"
        (decision.convert-to-json
        (decision.get-property report ':trace))
        "conclusions"
        (decision.convert-to-json
        (decision.get-property report ':conclusions))
        "metadata"
        (decision.convert-to-json
        (decision.get-property report ':metadata)))))
  (define decision.convert-to-json
    (lambda (data)
      (if (eq? data #f)
          "null"
          (if (eq? data #t)
            "true"
            (if (number? data)
              data
              (if (string? data)
                data
                (if (symbol? data)
                  (symbol->string data)
                  (if (list? data)
                    (decision.convert-list-to-json data)
                    data))))))))
  (define decision.convert-list-to-json
    (lambda (lst)
      (if (eq? (length lst) 0)
          (list)
          (if (decision.is-property-list? lst)
            (decision.convert-property-list-to-json lst)
            (map decision.convert-to-json lst)))))
  (define decision.is-property-list?
    (lambda (lst)
      (and
        (> (length lst) 0)
        (eq? (remainder (length lst) 2) 0)
        (symbol? (first lst))
        (decision.starts-with-colon? (symbol->string (first lst))))))
  (define decision.starts-with-colon?
    (lambda (str)
      (and (> (string-length str) 0) (eq? (string-ref str 0) #\:))))
  (define decision.convert-property-list-to-json
    (lambda (lst)
      (begin
        (define convert-pairs
          (lambda (remaining result)
            (if (eq? (length remaining) 0)
                result
                (let
                ((key (first remaining))
                (value (first (rest remaining)))
                (rest-pairs (rest (rest remaining))))
                (let
                ((json-key (decision.keyword-to-json-key key))
                (json-value (decision.convert-to-json value)))
                (convert-pairs
                rest-pairs
                (append result (list json-key json-value))))))))
        (convert-pairs lst (list)))))
  (define decision.keyword-to-json-key
    (lambda (keyword)
      (let
        ((str (symbol->string keyword)))
        (if (decision.starts-with-colon? str)
          (substring str 1 (string-length str))
          str))))
  (define decision.validate-report
    (lambda (report)
      (and
        (eq? (decision.get-property report ':type) 'decision-report)
        (not (eq? (decision.get-property report ':version) #f))
        (not (eq? (decision.get-property report ':timestamp) #f))
        (list? (decision.get-property report ':context))
        (list? (decision.get-property report ':inputs))
        (list? (decision.get-property report ':facts))
        (list? (decision.get-property report ':statutes)))))
  (define decision.test
    (lambda ()
      (begin
        (print "Testing decision report system...")
        (let
          ((test-ctx
          (list ':evaluation-date "2024-01-01" ':jurisdiction "PH"))
          (test-inputs (list (event 'query ' (inheritance john))))
          (test-statutes (list))
          (test-facts (list (event 'inherits ' (john estate))))
          (test-conflicts
          (list ':conflicts (list) ':resolutions (list)))
          (test-trace (list)))
          (let
          ((report
          (decision.build
          test-ctx
          test-inputs
          test-statutes
          test-facts
          test-conflicts
          test-trace))
          )
          (print "✓ Report created: " (decision.validate-report report))
          (print
          "✓ JSON structure: "
          (not (eq? (decision.to-json-structure report) #f)))
          (decision.validate-report report))))))
  (print "✓ Core decision report system loaded")
  (print
    "✓ Report building functions available: decision.build, decision.create-report")
  (print
    "✓ Formatting functions available: decision.to-json-structure, decision.format-*")
  (print
    "✓ Validation functions available: decision.validate-report, decision.test")
  (define decision-functions
    (list
      'decision.build
      'decision.create-report
      'decision.to-json-structure
      'decision.validate-report
      'decision.add-conclusion
      'decision.add-trace-entry
      'decision.test))
  (print
    "📋 Core decision report system ready for legal reasoning"))
