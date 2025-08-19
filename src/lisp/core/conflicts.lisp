(load "src/lisp/common/utils.lisp")

(print "Loading core conflicts system...")

(define conflicts.extract-fact-properties
  (lambda (fact)
    (let
      ((predicate (get-event-property fact ':predicate))
      (args (get-event-property fact ':args))
      (properties (get-event-property fact ':properties)))
      (let
      ((subject
      (if (and args (not (eq? (length args) 0)))
        (first args)
        'unknown))
      (priority (get-event-property properties ':priority))
      (basis (get-event-property properties ':basis))
      (specificity (get-event-property properties ':specificity))
      (source (get-event-property properties ':source)))
      (list
      ':type
      'fact
      ':predicate
      predicate
      ':subject
      subject
      ':priority
      (if priority
        priority
        0)
      ':basis
      basis
      ':specificity
      (if specificity
        specificity
        0)
      ':source
      source
      ':item
      fact)))))

(define conflicts.extract-statute-properties
  (lambda (statute)
    (let
      ((id (get-event-property statute ':id))
      (properties (get-event-property statute ':properties)))
      (let
      ((priority (get-event-property properties ':priority))
      (specificity (get-event-property properties ':specificity))
      (hierarchy-level
      (get-event-property properties ':hierarchy-level))
      (source (get-event-property properties ':source)))
      (list
      ':type
      'statute
      ':id
      id
      ':priority
      (if priority
        priority
        0)
      ':specificity
      (if specificity
        specificity
        0)
      ':hierarchy-level
      (if hierarchy-level
        hierarchy-level
        0)
      ':source
      source
      ':item
      statute)))))

(define conflicts.predicates-conflict?
  (lambda (item1-props item2-props)
    (let
      ((pred1 (get-event-property item1-props ':predicate))
      (pred2 (get-event-property item2-props ':predicate))
      (subj1 (get-event-property item1-props ':subject))
      (subj2 (get-event-property item2-props ':subject)))
      (and
      (eq? subj1 subj2)
      (not (eq? pred1 pred2))
      (conflicts.are-opposite-predicates? pred1 pred2)))))

(define conflicts.are-opposite-predicates?
  (lambda (pred1 pred2)
    (or
      (and (eq? pred1 'inherits) (eq? pred2 'does-not-inherit))
      (and (eq? pred1 'does-not-inherit) (eq? pred2 'inherits))
      (and (eq? pred1 'valid) (eq? pred2 'invalid))
      (and (eq? pred1 'invalid) (eq? pred2 'valid))
      (and (eq? pred1 'eligible) (eq? pred2 'ineligible))
      (and (eq? pred1 'ineligible) (eq? pred2 'eligible))
      (and (eq? pred1 'has-capacity) (eq? pred2 'lacks-capacity))
      (and (eq? pred1 'lacks-capacity) (eq? pred2 'has-capacity))
      (and
      (conflicts.is-positive-predicate? pred1)
      (conflicts.is-negative-predicate? pred2))
      (and
      (conflicts.is-negative-predicate? pred1)
      (conflicts.is-positive-predicate? pred2)))))

(define conflicts.is-positive-predicate?
  (lambda (predicate)
    (or
      (eq? predicate 'inherits)
      (eq? predicate 'valid)
      (eq? predicate 'eligible)
      (eq? predicate 'has-capacity)
      (eq? predicate 'entitled)
      (eq? predicate 'applies))))

(define conflicts.is-negative-predicate?
  (lambda (predicate)
    (or
      (eq? predicate 'does-not-inherit)
      (eq? predicate 'invalid)
      (eq? predicate 'ineligible)
      (eq? predicate 'lacks-capacity)
      (eq? predicate 'not-entitled)
      (eq? predicate 'does-not-apply))))

(define conflicts.detect-between
  (lambda (item1 item2)
    (let
      ((props1
      (if (get-event-property item1 ':predicate)
        (conflicts.extract-fact-properties item1)
        (conflicts.extract-statute-properties item1)))
      (props2
      (if (get-event-property item2 ':predicate)
        (conflicts.extract-fact-properties item2)
        (conflicts.extract-statute-properties item2))))
      (if (conflicts.predicates-conflict? props1 props2)
        (list
        ':conflict-type
        'predicate-conflict
        ':item1
        item1
        ':item2
        item2
        ':item1-props
        props1
        ':item2-props
        props2)
        #f))))

(define conflicts.detect-all
  (lambda (items)
    (begin
      (define detect-recursive
        (lambda (remaining-items conflicts-found)
          (if (eq? (length remaining-items) 0)
              conflicts-found
              (let
              ((current-item (first remaining-items))
              (rest-items (rest remaining-items)))
              (let
              ((new-conflicts
              (conflicts.find-conflicts-for-item current-item rest-items))
              )
              (detect-recursive
              rest-items
              (append conflicts-found new-conflicts)))))))
      (detect-recursive items (list)))))

(define conflicts.find-conflicts-for-item
  (lambda (item other-items)
    (begin
      (define find-recursive
        (lambda (remaining-items conflicts-found)
          (if (eq? (length remaining-items) 0)
              conflicts-found
              (let
              ((other-item (first remaining-items))
              (rest-items (rest remaining-items)))
              (let
              ((conflict (conflicts.detect-between item other-item)))
              (if conflict
                (find-recursive
                rest-items
                (cons conflict (ensure-list conflicts-found)))
                (find-recursive rest-items conflicts-found)))))))
      (find-recursive other-items (list)))))

(define conflicts.resolve-by-priority
  (lambda (conflict)
    (let
      ((props1 (get-event-property conflict ':item1-props))
      (props2 (get-event-property conflict ':item2-props)))
      (let
      ((priority1 (get-event-property props1 ':priority))
      (priority2 (get-event-property props2 ':priority)))
      (if (> priority1 priority2)
        (get-event-property conflict ':item1)
        (if (> priority2 priority1)
          (get-event-property conflict ':item2)
          #f))))))

(define conflicts.resolve-by-specificity
  (lambda (conflict)
    (let
      ((props1 (get-event-property conflict ':item1-props))
      (props2 (get-event-property conflict ':item2-props)))
      (let
      ((spec1 (get-event-property props1 ':specificity))
      (spec2 (get-event-property props2 ':specificity)))
      (if (> spec1 spec2)
        (get-event-property conflict ':item1)
        (if (> spec2 spec1)
          (get-event-property conflict ':item2)
          #f))))))

(define conflicts.resolve-by-hierarchy
  (lambda (conflict)
    (let
      ((props1 (get-event-property conflict ':item1-props))
      (props2 (get-event-property conflict ':item2-props)))
      (let
      ((level1 (get-event-property props1 ':hierarchy-level))
      (level2 (get-event-property props2 ':hierarchy-level)))
      (if (and level1 level2)
        (if (> level1 level2)
          (get-event-property conflict ':item1)
          (if (> level2 level1)
            (get-event-property conflict ':item2)
            #f))
        #f)))))

(define conflicts.resolve-by-source
  (lambda (conflict)
    (let
      ((props1 (get-event-property conflict ':item1-props))
      (props2 (get-event-property conflict ':item2-props)))
      (let
      ((source1 (get-event-property props1 ':source))
      (source2 (get-event-property props2 ':source)))
      (let
      ((authority1 (conflicts.get-source-authority source1))
      (authority2 (conflicts.get-source-authority source2)))
      (if (> authority1 authority2)
        (get-event-property conflict ':item1)
        (if (> authority2 authority1)
          (get-event-property conflict ':item2)
          #f)))))))

(define conflicts.get-source-authority
  (lambda (source)
    (if (eq? source 'constitution)
        10
        (if (eq? source 'statute)
          8
          (if (eq? source 'regulation)
            6
            (if (eq? source 'case-law)
              4
              (if (eq? source 'custom)
                2
                1)))))))

(define conflicts.apply-strategy
  (lambda (conflict strategy)
    (if (eq? strategy 'priority)
        (conflicts.resolve-by-priority conflict)
        (if (eq? strategy 'specificity)
          (conflicts.resolve-by-specificity conflict)
          (if (eq? strategy 'hierarchy)
            (conflicts.resolve-by-hierarchy conflict)
            (if (eq? strategy 'source)
              (conflicts.resolve-by-source conflict)
              #f))))))

(define conflicts.resolve-single
  (lambda (conflict strategies)
    (begin
      (define try-strategies
        (lambda (remaining-strategies)
          (if (eq? (length remaining-strategies) 0)
              #f
              (let
              ((strategy (first remaining-strategies))
              (rest-strategies (rest remaining-strategies)))
              (let
              ((resolution (conflicts.apply-strategy conflict strategy)))
              (if resolution
                (list ':winner resolution ':strategy strategy)
                (try-strategies rest-strategies)))))))
      (try-strategies strategies))))

(define conflicts.default-strategies
  (list 'hierarchy 'priority 'specificity 'source))

(define conflicts.resolve-all
  (lambda (conflicts strategies)
    (map
      (lambda (conflict)
      (let
        ((resolution (conflicts.resolve-single conflict strategies)))
        (list ':conflict conflict ':resolution resolution)))
      conflicts)))

(define conflicts.resolve
  (lambda (facts rules ctx)
    (let
      ((all-items (append facts rules))
      (strategies
      (let
      ((ctx-strategies
      (get-event-property ctx ':conflict-strategies))
      )
      (if ctx-strategies
        ctx-strategies
        conflicts.default-strategies))))
      (let
      ((detected-conflicts (conflicts.detect-all all-items)))
      (if (eq? (length detected-conflicts) 0)
        (list
        ':conflicts
        (list)
        ':resolutions
        (list)
        ':final-items
        all-items)
        (let
        ((resolutions
        (conflicts.resolve-all detected-conflicts strategies))
        )
        (let
        ((final-items
        (conflicts.apply-resolutions all-items resolutions))
        )
        (list
        ':conflicts
        detected-conflicts
        ':resolutions
        resolutions
        ':final-items
        final-items))))))))

(define conflicts.apply-resolutions
  (lambda (original-items resolutions)
    (let
      ((items-to-remove (conflicts.get-losing-items resolutions)))
      (filter
      (lambda (item)
      (not (conflicts.item-in-list? item items-to-remove)))
      original-items))))

(define conflicts.get-losing-items
  (lambda (resolutions)
    (begin
      (define collect-losers
        (lambda (remaining-resolutions losers)
          (if (eq? (length remaining-resolutions) 0)
              losers
              (let
              ((resolution (first remaining-resolutions))
              (rest-resolutions (rest remaining-resolutions)))
              (let
              ((conflict (get-event-property resolution ':conflict))
              (winner-info (get-event-property resolution ':resolution)))
              (if winner-info
                (let
                ((winner (get-event-property winner-info ':winner))
                (item1 (get-event-property conflict ':item1))
                (item2 (get-event-property conflict ':item2)))
                (let
                ((loser
                (if (eq? winner item1)
                  item2
                  item1))
                )
                (collect-losers
                rest-resolutions
                (cons loser (ensure-list losers)))))
                (collect-losers rest-resolutions losers)))))))
      (collect-losers resolutions (list)))))

(define conflicts.item-in-list?
  (lambda (item item-list)
    (if (eq? (length item-list) 0)
        #f
        (if (eq? item (first item-list))
          #t
          (conflicts.item-in-list? item (rest item-list))))))

(define conflicts.analyze-results
  (lambda (resolution-result)
    (let
      ((conflicts (get-event-property resolution-result ':conflicts))
      (resolutions
      (get-event-property resolution-result ':resolutions))
      (final-items
      (get-event-property resolution-result ':final-items)))
      (let
      ((total-conflicts (length conflicts))
      (resolved-conflicts
      (length
      (filter
      (lambda (res)
      (not (eq? (get-event-property res ':resolution) #f)))
      resolutions)))
      (unresolved-conflicts
      (length
      (filter
      (lambda (res)
      (eq? (get-event-property res ':resolution) #f))
      resolutions))))
      (list
      ':total-conflicts
      total-conflicts
      ':resolved-conflicts
      resolved-conflicts
      ':unresolved-conflicts
      unresolved-conflicts
      ':final-item-count
      (length final-items))))))

(define conflicts.test-detection
  (lambda ()
    (begin
      (print "Testing conflict detection...")
      (let
        ((fact1
        (event
        'inherits
        '
        (john estate)
        ':properties
        (list ':priority 5)))
        (fact2
        (event
        'does-not-inherit
        '
        (john estate)
        ':properties
        (list ':priority 3))))
        (let
        ((conflict (conflicts.detect-between fact1 fact2)))
        (print "✓ Conflict detected: " (not (eq? conflict #f)))
        (not (eq? conflict #f)))))))

(define conflicts.test-resolution
  (lambda ()
    (begin
      (print "Testing conflict resolution...")
      (let
        ((facts
        (list
        (event
        'inherits
        '
        (john estate)
        ':properties
        (list ':priority 5))
        (event
        'does-not-inherit
        '
        (john estate)
        ':properties
        (list ':priority 3))))
        (rules (list))
        (ctx (list ':conflict-strategies (list 'priority))))
        (let
        ((result (conflicts.resolve facts rules ctx)))
        (let
        ((analysis (conflicts.analyze-results result)))
        (print "✓ Resolution analysis: " analysis)
        (> (get-event-property analysis ':resolved-conflicts) 0)))))))

(define conflicts.test
  (lambda ()
    (begin
      (print "Running conflict system tests...")
      (and
        (conflicts.test-detection)
        (conflicts.test-resolution)
        (begin
        (print "✓ All conflict tests passed")
        #t)))))

(print "✓ Core conflicts system loaded")

(print
  "✓ Detection functions available: conflicts.detect-all, conflicts.detect-between")

(print
  "✓ Resolution functions available: conflicts.resolve, conflicts.resolve-single")

(print
  "✓ Analysis functions available: conflicts.analyze-results")

(define conflicts-functions
  (list
    'conflicts.resolve
    'conflicts.detect-all
    'conflicts.resolve-single
    'conflicts.analyze-results
    'conflicts.test))

(print "⚖️  Core conflicts system ready for legal reasoning")
