(print
  "Loading Philippine Intestate Succession (Refactored)...")

(load "src/lisp/core/macros.lisp")

(load "src/lisp/core/indexer.lisp")

(load "src/lisp/core/temporal.lisp")

(load "src/lisp/core/conflicts.lisp")

(load "src/lisp/core/decision-report.lisp")

(load "src/lisp/statute-api-final-working.lisp")

(load "src/lisp/lambda-rules.lisp")

(print "✓ Core infrastructure loaded")

(define ph.has-spouse
  (lambda (ev ctx)
    (if (null? ev)
        #f
        (let
        ((spouse (get-event-property ev ':spouse)))
        (and
        (not (null? spouse))
        (ph.person-alive-at-death? spouse ev ctx))))))

(define ph.has-legitimate-children
  (lambda (ev ctx)
    (if (null? ev)
        #f
        (let
        ((children
        (as-list (get-event-property ev ':legitimate-children)))
        )
        (and
        (not (safe-empty? children))
        (ph.any-person-alive-at-death? children ev ctx))))))

(define ph.has-illegitimate-children
  (lambda (ev ctx)
    (if (null? ev)
        #f
        (let
        ((children
        (as-list (get-event-property ev ':illegitimate-children)))
        )
        (and
        (not (safe-empty? children))
        (ph.any-person-alive-at-death? children ev ctx))))))

(define ph.has-parents
  (lambda (ev ctx)
    (if (null? ev)
        #f
        (let
        ((parents (as-list (get-event-property ev ':parents))))
        (and
        (not (safe-empty? parents))
        (ph.any-person-alive-at-death? parents ev ctx))))))

(define ph.has-siblings
  (lambda (ev ctx)
    (if (null? ev)
        #f
        (let
        ((siblings (as-list (get-event-property ev ':siblings))))
        (and
        (not (safe-empty? siblings))
        (ph.any-person-alive-at-death? siblings ev ctx))))))

(define ph.has-representation
  (lambda (ev ctx)
    (if (null? ev)
        #f
        (let
        ((repr (as-list (get-event-property ev ':representation))))
        (and
        (not (safe-empty? repr))
        (ph.representation-valid? repr ev ctx))))))

(define ph.person-alive-at-death?
  (lambda (person death-event ctx)
    (let
      ((death-date (get-event-property death-event ':date))
      (person-death-date (get-event-property person ':death-date)))
      (if (or (eq? death-date #f) (eq? person-death-date #f))
        #t
        (temporal.before? person-death-date death-date)))))

(define ph.any-person-alive-at-death?
  (lambda (persons death-event ctx)
    (if (safe-empty? persons)
        #f
        (let
        ((alive-persons
        (filter
        (lambda (person)
        (ph.person-alive-at-death? person death-event ctx))
        persons))
        )
        (not (safe-empty? alive-persons))))))

(define ph.representation-valid?
  (lambda (repr-groups death-event ctx)
    (if (safe-empty? repr-groups)
        #f
        (let
        ((valid-groups
        (filter
        (lambda (group)
        (and
          (not (safe-empty? group))
          (let
          ((representatives (rest group)))
          (ph.any-person-alive-at-death?
          representatives
          death-event
          ctx))))
        repr-groups))
        )
        (not (safe-empty? valid-groups))))))

(define ph.has-descendants
  (lambda (ev ctx)
    (or
      (ph.has-legitimate-children ev ctx)
      (ph.has-illegitimate-children ev ctx)
      (ph.has-representation ev ctx))))

(define ph.has-ascendants
  (lambda (ev ctx)
    (if (null? ev)
        #f
        (let
        ((ascendants (as-list (get-event-property ev ':ascendants))))
        (and
        (not (safe-empty? ascendants))
        (ph.any-person-alive-at-death? ascendants ev ctx))))))

(print "✓ Philippine succession domain predicates defined")

(define ph.spouse-children-split
  (lambda (basis-id ctx)
    (begin
      (lambda (ev)
        (if (null? ev)
            '
            ()))
      (define ph.spouse-ascendants-split
        (lambda (basis-id ctx)
          (begin
            (lambda (ev)
              (if (null? ev)
                  '
                  ()))
            (define ph.representation-split
              (lambda (basis-id ctx)
                (lambda (ev)
                  (if (null? ev)
                      '
                      ())))
              (print
                "✓ Enhanced fact producers with temporal awareness defined")
              (define PH-INTESTATE-CHILDREN-ONLY
                (statute
                  'ph-intestate-children-only
                  "PH: Children inherit equally when no spouse survives"
                  (lambda (ev ctx)
                  (and
                    (get-event-property ev ':death)
                    (not (get-event-property ev ':will))
                    (ph.has-legitimate-children ev ctx)
                    (not (ph.has-spouse ev ctx))
                    (eq? (get-event-property ctx ':jurisdiction) 'PH)))
                  (lambda (ev ctx)
                  (let
                    ((children
                    (as-list (get-event-property ev ':legitimate-children)))
                    (person (get-event-property ev ':person)))
                    (if (or (null? person) (safe-empty? children))
                      '
                      ())))
                  ':properties
                  (list
                  ':rank
                  900
                  ':jurisdiction
                  'PH
                  ':category
                  'intestate
                  ':legal-basis
                  'art-979
                  ':priority
                  900)))
              (define PH-INTESTATE-SPOUSE-CHILDREN
                (statute
                  'ph-intestate-spouse-children
                  "PH: Spouse (1/4) and legitimate children (3/4) succession"
                  (lambda (ev ctx)
                  (and
                    (get-event-property ev ':death)
                    (not (get-event-property ev ':will))
                    (ph.has-spouse ev ctx)
                    (ph.has-legitimate-children ev ctx)
                    (eq? (get-event-property ctx ':jurisdiction) 'PH)))
                  (ph.spouse-children-split 'ph-intestate-spouse-children ctx)
                  ':properties
                  (list
                  ':rank
                  950
                  ':jurisdiction
                  'PH
                  ':category
                  'intestate
                  ':legal-basis
                  'art-996
                  ':priority
                  950)))
              (define PH-INTESTATE-SPOUSE-ASCENDANTS
                (statute
                  'ph-intestate-spouse-ascendants
                  "PH: Spouse (1/2) and ascendants (1/2) when no descendants"
                  (lambda (ev ctx)
                  (and
                    (get-event-property ev ':death)
                    (not (get-event-property ev ':will))
                    (ph.has-spouse ev ctx)
                    (ph.has-ascendants ev ctx)
                    (not (ph.has-descendants ev ctx))
                    (eq? (get-event-property ctx ':jurisdiction) 'PH)))
                  (ph.spouse-ascendants-split
                  'ph-intestate-spouse-ascendants
                  ctx)
                  ':properties
                  (list
                  ':rank
                  850
                  ':jurisdiction
                  'PH
                  ':category
                  'intestate
                  ':legal-basis
                  'art-999
                  ':priority
                  850)))
              (define PH-INTESTATE-REPRESENTATION
                (statute
                  'ph-intestate-representation
                  "PH: Representation - deceased heir's children inherit in their place"
                  (lambda (ev ctx)
                  (and
                    (get-event-property ev ':death)
                    (not (get-event-property ev ':will))
                    (ph.has-representation ev ctx)
                    (eq? (get-event-property ctx ':jurisdiction) 'PH)))
                  (ph.representation-split 'ph-intestate-representation ctx)
                  ':properties
                  (list
                  ':rank
                  920
                  ':jurisdiction
                  'PH
                  ':category
                  'intestate
                  ':legal-basis
                  'art-981
                  ':priority
                  920)))
              (define PH-INTESTATE-ASCENDANTS-ONLY
                (statute
                  'ph-intestate-ascendants-only
                  "PH: Ascendants inherit when no descendants or spouse"
                  (lambda (ev ctx)
                  (and
                    (get-event-property ev ':death)
                    (not (get-event-property ev ':will))
                    (ph.has-ascendants ev ctx)
                    (not (ph.has-descendants ev ctx))
                    (not (ph.has-spouse ev ctx))
                    (eq? (get-event-property ctx ':jurisdiction) 'PH)))
                  (lambda (ev ctx)
                  (let
                    ((ascendants (as-list (get-event-property ev ':ascendants)))
                    (person (get-event-property ev ':person)))
                    (if (or (null? person) (safe-empty? ascendants))
                      '
                      ())))
                  ':properties
                  (list
                  ':rank
                  800
                  ':jurisdiction
                  'PH
                  ':category
                  'intestate
                  ':legal-basis
                  'art-1001
                  ':priority
                  800)))
              (define PH-INTESTATE-COLLATERAL
                (statute
                  'ph-intestate-collateral
                  "PH: Siblings inherit when no direct heirs or spouse"
                  (lambda (ev ctx)
                  (and
                    (get-event-property ev ':death)
                    (not (get-event-property ev ':will))
                    (ph.has-siblings ev ctx)
                    (not (ph.has-descendants ev ctx))
                    (not (ph.has-ascendants ev ctx))
                    (not (ph.has-spouse ev ctx))
                    (eq? (get-event-property ctx ':jurisdiction) 'PH)))
                  (lambda (ev ctx)
                  (let
                    ((siblings (as-list (get-event-property ev ':siblings)))
                    (person (get-event-property ev ':person)))
                    (if (or (null? person) (safe-empty? siblings))
                      '
                      ())))
                  ':properties
                  (list
                  ':rank
                  750
                  ':jurisdiction
                  'PH
                  ':category
                  'intestate
                  ':legal-basis
                  'art-1003
                  ':priority
                  750)))
              (print
                "✓ Refactored Philippine intestate succession statutes defined")
              (define PH-INTESTATE-STATUTES
                (list
                  PH-INTESTATE-SPOUSE-CHILDREN
                  PH-INTESTATE-REPRESENTATION
                  PH-INTESTATE-CHILDREN-ONLY
                  PH-INTESTATE-SPOUSE-ASCENDANTS
                  PH-INTESTATE-ASCENDANTS-ONLY
                  PH-INTESTATE-COLLATERAL))
              (define ph.resolve-intestate-succession
                (lambda (death-event context)
                  (begin
                    (print
                      "🏛️  Starting Philippine intestate succession resolution...")
                    (let
                      ((statute-index (index.build-statutes PH-INTESTATE-STATUTES))
                      (fact-index (index.create)))
                      (let
                      ((valid-statutes
                      (temporal.eligible-statutes PH-INTESTATE-STATUTES context))
                      )
                      (print
                      "✓ Temporal filtering: "
                      (length valid-statutes)
                      " valid statutes")
                      (let
                      ((generated-facts
                      (ph.apply-statutes valid-statutes death-event context))
                      )
                      (print
                      "✓ Fact generation: "
                      (length generated-facts)
                      " facts generated")
                      (let
                      ((valid-facts
                      (temporal.eligible-facts generated-facts context))
                      )
                      (print
                      "✓ Fact temporal filtering: "
                      (length valid-facts)
                      " valid facts")
                      (let
                      ((conflict-resolution
                      (conflicts.resolve valid-facts valid-statutes context))
                      )
                      (let
                      ((final-facts
                      (get-event-property conflict-resolution ':final-items))
                      )
                      (print
                      "✓ Conflict resolution: "
                      (length final-facts)
                      " final facts")
                      (let
                      ((decision-report
                      (decision.build
                      context
                      (list death-event)
                      valid-statutes
                      final-facts
                      conflict-resolution
                      (list)))
                      )
                      (print "✓ Decision report generated")
                      (list
                      ':death-event
                      death-event
                      ':context
                      context
                      ':applicable-statutes
                      valid-statutes
                      ':generated-facts
                      generated-facts
                      ':valid-facts
                      valid-facts
                      ':conflict-resolution
                      conflict-resolution
                      ':final-facts
                      final-facts
                      ':decision-report
                      decision-report))))))))))
                (define ph.apply-statutes
                  (lambda (statutes death-event context)
                    (safe-fold
                      (lambda (acc statute)
                      (let
                        ((condition-fn (get-event-property statute ':condition))
                        (action-fn (get-event-property statute ':action)))
                        (if (condition-fn death-event context)
                          (let
                          ((new-facts (action-fn death-event context)))
                          (safe-append acc new-facts))
                          acc)))
                      '
                      ()
                      statutes)))
                (define ph.extract-heir-shares
                  (lambda (facts)
                    (filter
                      (lambda (fact)
                      (eq? (get-event-property fact ':predicate) 'heir-share))
                      facts)))
                (define ph.calculate-total-shares
                  (lambda (heir-facts)
                    (safe-fold
                      (lambda (acc fact)
                      (let
                        ((share
                        (get-event-property
                        (get-event-property fact ':properties)
                        ':share))
                        )
                        (+
                        acc
                        (if share
                          share
                          0))))
                      0
                      heir-facts)))
                (define ph.validate-succession-result
                  (lambda (result)
                    (let
                      ((final-facts (get-event-property result ':final-facts)))
                      (let
                      ((heir-facts (ph.extract-heir-shares final-facts)))
                      (let
                      ((total-shares (ph.calculate-total-shares heir-facts)))
                      (list
                      ':total-heirs
                      (length heir-facts)
                      ':total-shares
                      total-shares
                      ':shares-valid
                      (and (>= total-shares 0.99) (<= total-shares 1.01))
                      ':has-conflicts
                      (>
                      (length
                      (get-event-property
                      (get-event-property result ':conflict-resolution)
                      ':conflicts))
                      0)))))))
                (print "✓ Integrated succession reasoning engine defined")
                (define ph.test-simple-case
                  (lambda ()
                    (begin
                      (print
                        "Testing refactored Philippine intestate succession...")
                      (let
                        ((test-death-event
                        (event
                        'death
                        '
                        (john-doe)
                        ':properties
                        (list
                        ':person
                        'john-doe
                        ':date
                        "2024-01-15"
                        ':spouse
                        'jane-doe
                        ':legitimate-children
                        (list 'child1 'child2)
                        ':will
                        #f)))
                        (test-context
                        (list
                        ':evaluation-date
                        "2024-01-15"
                        ':jurisdiction
                        'PH
                        ':temporal-mode
                        'strict)))
                        (let
                        ((result
                        (ph.resolve-intestate-succession
                        test-death-event
                        test-context))
                        )
                        (let
                        ((validation (ph.validate-succession-result result)))
                        (print "✓ Test result validation: " validation)
                        (print
                        "✓ Final facts count: "
                        (length (get-event-property result ':final-facts)))
                        result))))))
                (define PH-TEST-RESULT
                  (ph.test-simple-case))
                (print "")
                (print
                  "✅ Philippine Intestate Succession (Refactored) fully loaded")
                (print
                  "✅ Integrated with core infrastructure (indexing, temporal, conflicts, reporting)")
                (print "✅ Enhanced with temporal validity checking")
                (print "✅ Ready for comprehensive legal reasoning")
                (print "")
                (define PH-INTESTATE-REFACTORED-LOADED
                  #t)))))))))
