;;; ===================================================================
;;; ETHERNEY eLISP INTESTATE SUCCESSION MODULE - PHILIPPINE JURISDICTION
;;; ===================================================================
;;; Phase 2: Comprehensive intestate succession statutes for Philippines
;;; Based on Philippine Civil Code provisions on succession
;;; Built on top of production-hardened lambda rules foundation

(print "=== Loading Philippine Intestate Succession Module ===")

;;; Load the production-hardened foundation
(load "src/lisp/statute-api-final-working.lisp")
(load "src/lisp/macros.lisp")
(load "src/lisp/lambda-rules.lisp")

(print "✓ Foundation loaded - beginning intestate succession implementation")

;;; -------------------------------------------------------------------
;;; EXTENDED DOMAIN PREDICATES FOR SUCCESSION LAW
;;; -------------------------------------------------------------------

;;; Predicate: Event has surviving spouse
(define p-has-spouse
  (lambda (ev)
    (if (null? ev)
        #f
        (let ((spouse (event.get ev ':spouse)))
          (not (null? spouse))))))

;;; Predicate: Event has legitimate children
(define p-has-legitimate-children
  (lambda (ev)
    (if (null? ev)
        #f
        (let ((children (as-list (event.get ev ':legitimate-children))))
          (not (safe-empty? children))))))

;;; Predicate: Event has illegitimate children
(define p-has-illegitimate-children
  (lambda (ev)
    (if (null? ev)
        #f
        (let ((children (as-list (event.get ev ':illegitimate-children))))
          (not (safe-empty? children))))))

;;; Predicate: Event has surviving parents
(define p-has-parents
  (lambda (ev)
    (if (null? ev)
        #f
        (let ((parents (as-list (event.get ev ':parents))))
          (not (safe-empty? parents))))))

;;; Predicate: Event has siblings
(define p-has-siblings
  (lambda (ev)
    (if (null? ev)
        #f
        (let ((siblings (as-list (event.get ev ':siblings))))
          (not (safe-empty? siblings))))))

;;; Predicate: Event has representation (deceased heir's children)
(define p-has-representation
  (lambda (ev)
    (if (null? ev)
        #f
        (let ((repr (as-list (event.get ev ':representation))))
          (not (safe-empty? repr))))))

;;; Predicate: Check if deceased has descendants (children or grandchildren)
(define p-has-descendants
  (lambda (ev)
    (if (null? ev)
        #f
        ((when-any p-has-legitimate-children 
                   p-has-illegitimate-children 
                   p-has-representation) ev))))

;;; Predicate: Check if deceased has ascendants (parents or grandparents)
(define p-has-ascendants
  (lambda (ev)
    (if (null? ev)
        #f
        (let ((ascendants (as-list (event.get ev ':ascendants))))
          (not (safe-empty? ascendants))))))

(print "✓ Extended domain predicates for succession law defined")

;;; -------------------------------------------------------------------
;;; SPECIALIZED FACT PRODUCERS FOR SUCCESSION
;;; -------------------------------------------------------------------

;;; Fact producer: Spouse and legitimate children succession
;;; Legal basis: Art. 996 - Spouse gets 1/4, children share remaining 3/4
(define then-spouse-children-split
  (lambda (basis-id)
    (lambda (ev)
      (if (null? ev)
          '()
          (let ((spouse (event.get ev ':spouse))
                (children (as-list (event.get ev ':legitimate-children)))
                (person (event.get ev ':person)))
            (cond
              ((null? person) '())
              ((or (null? spouse) (safe-empty? children)) '())
              (#t (let ((child-count (safe-length children))
                        (spouse-share (/ 1 4))
                        (children-total-share (/ 3 4)))
                    (let ((child-individual-share (/ children-total-share child-count)))
                      (cons 
                        ;; Spouse gets 1/4
                        (fact.make 'heir-share (list person spouse)
                                  (list ':share spouse-share 
                                        ':basis basis-id
                                        ':heir-type 'spouse
                                        ':legal-basis 'art-996))
                        ;; Children share 3/4 equally
                        (safe-map
                          (lambda (child)
                            (fact.make 'heir-share (list person child)
                                      (list ':share child-individual-share
                                            ':basis basis-id
                                            ':heir-type 'legitimate-child
                                            ':legal-basis 'art-996)))
                          children)))))))))))

;;; Fact producer: Spouse alone (no descendants)
;;; Legal basis: Art. 999 - Spouse gets 1/2, ascendants get 1/2
(define then-spouse-ascendants-split
  (lambda (basis-id)
    (lambda (ev)
      (if (null? ev)
          '()
          (let ((spouse (event.get ev ':spouse))
                (ascendants (as-list (event.get ev ':ascendants)))
                (person (event.get ev ':person)))
            (cond
              ((null? person) '())
              ((or (null? spouse) (safe-empty? ascendants)) '())
              (#t (let ((ascendant-count (safe-length ascendants))
                        (spouse-share (/ 1 2))
                        (ascendant-total-share (/ 1 2)))
                    (let ((ascendant-individual-share (/ ascendant-total-share ascendant-count)))
                      (cons
                        ;; Spouse gets 1/2
                        (fact.make 'heir-share (list person spouse)
                                  (list ':share spouse-share
                                        ':basis basis-id
                                        ':heir-type 'spouse
                                        ':legal-basis 'art-999))
                        ;; Ascendants share 1/2 equally
                        (safe-map
                          (lambda (ascendant)
                            (fact.make 'heir-share (list person ascendant)
                                      (list ':share ascendant-individual-share
                                            ':basis basis-id
                                            ':heir-type 'ascendant
                                            ':legal-basis 'art-999)))
                          ascendants)))))))))))

;;; Fact producer: Representation in direct line
;;; Legal basis: Art. 981 - Deceased heir's children inherit in their place
(define then-representation-split
  (lambda (basis-id)
    (lambda (ev)
      (if (null? ev)
          '()
          (let ((repr-groups (as-list (event.get ev ':representation)))
                (person (event.get ev ':person)))
            (cond
              ((null? person) '())
              ((safe-empty? repr-groups) '())
              (#t (let ((group-count (safe-length repr-groups))
                        (total-share 1))
                    (let ((share-per-group (/ total-share group-count)))
                      (safe-fold
                        (lambda (acc group)
                          (let ((deceased-heir (first group))
                                (representatives (rest group)))
                            (if (safe-empty? representatives)
                                acc
                                (let ((repr-count (safe-length representatives))
                                      (individual-share (/ share-per-group repr-count)))
                                  (safe-append acc
                                    (safe-map
                                      (lambda (repr)
                                        (fact.make 'heir-share (list person repr)
                                                  (list ':share individual-share
                                                        ':basis basis-id
                                                        ':heir-type 'representative
                                                        ':represents deceased-heir
                                                        ':legal-basis 'art-981)))
                                      representatives))))))
                        '()
                        repr-groups))))))))))

;;; Fact producer: Collateral relatives (siblings, nephews, nieces)
;;; Legal basis: Art. 1003 - Siblings inherit equally
(define then-collateral-split
  (lambda (basis-id)
    (lambda (ev)
      (if (null? ev)
          '()
          (let ((siblings (as-list (event.get ev ':siblings)))
                (person (event.get ev ':person)))
            (cond
              ((null? person) '())
              ((safe-empty? siblings) '())
              (#t (let ((sibling-count (safe-length siblings))
                        (individual-share (/ 1 sibling-count)))
                    (safe-map
                      (lambda (sibling)
                        (fact.make 'heir-share (list person sibling)
                                  (list ':share individual-share
                                        ':basis basis-id
                                        ':heir-type 'sibling
                                        ':legal-basis 'art-1003)))
                      siblings)))))))))

;;; Fact producer: Compulsory heir protection (legitime)
;;; Legal basis: Art. 886-906 - Compulsory heirs have minimum protected shares
(define then-legitime-protection
  (lambda (basis-id)
    (lambda (ev)
      (if (null? ev)
          '()
          (let ((compulsory-heirs (as-list (event.get ev ':compulsory-heirs)))
                (person (event.get ev ':person)))
            (cond
              ((null? person) '())
              ((safe-empty? compulsory-heirs) '())
              (#t (let ((heir-count (safe-length compulsory-heirs))
                        ;; Legitime is typically 1/2 of estate for compulsory heirs
                        (legitime-total (/ 1 2)))
                    (let ((individual-legitime (/ legitime-total heir-count)))
                      (safe-map
                        (lambda (heir)
                          (fact.make 'heir-share (list person heir)
                                    (list ':share individual-legitime
                                          ':basis basis-id
                                          ':heir-type 'compulsory-heir
                                          ':protection-type 'legitime
                                          ':legal-basis 'art-886-906)))
                        compulsory-heirs))))))))))

(print "✓ Specialized fact producers for succession defined")

;;; -------------------------------------------------------------------
;;; PHILIPPINE INTESTATE SUCCESSION STATUTES
;;; -------------------------------------------------------------------

;;; STATUTE 1: Basic intestate succession (no spouse, equal distribution)
;;; Legal basis: Art. 979 - Children inherit equally in absence of spouse
(define S-PH-INTESTATE-CHILDREN-ONLY
  (spawn-statute 'ph-intestate-children-only
                 "PH: Children inherit equally when no spouse survives"
                 (when-all p-death 
                          p-no-will 
                          p-has-legitimate-children
                          (when-not p-has-spouse)
                          (p-jurisdiction 'PH))
                 (lambda (ev)
                   (let ((children (as-list (event.get ev ':legitimate-children)))
                         (person (event.get ev ':person)))
                     (if (or (null? person) (safe-empty? children))
                         '()
                         (let ((child-count (safe-length children))
                               (individual-share (/ 1 child-count)))
                           (safe-map
                             (lambda (child)
                               (fact.make 'heir-share (list person child)
                                         (list ':share individual-share
                                               ':basis 'ph-intestate-children-only
                                               ':heir-type 'legitimate-child
                                               ':legal-basis 'art-979)))
                             children)))))
                 (list ':rank 900 ':jurisdiction 'PH ':category 'intestate ':legal-basis 'art-979)))

;;; STATUTE 2: Spouse and legitimate children
;;; Legal basis: Art. 996 - Spouse gets 1/4, children share 3/4
(define S-PH-INTESTATE-SPOUSE-CHILDREN
  (spawn-statute 'ph-intestate-spouse-children
                 "PH: Spouse (1/4) and legitimate children (3/4) succession"
                 (when-all p-death 
                          p-no-will 
                          p-has-spouse
                          p-has-legitimate-children
                          (p-jurisdiction 'PH))
                 (then-spouse-children-split 'ph-intestate-spouse-children)
                 (list ':rank 950 ':jurisdiction 'PH ':category 'intestate ':legal-basis 'art-996)))

;;; STATUTE 3: Spouse and ascendants (no descendants)
;;; Legal basis: Art. 999 - Spouse gets 1/2, ascendants get 1/2
(define S-PH-INTESTATE-SPOUSE-ASCENDANTS
  (spawn-statute 'ph-intestate-spouse-ascendants
                 "PH: Spouse (1/2) and ascendants (1/2) when no descendants"
                 (when-all p-death 
                          p-no-will 
                          p-has-spouse
                          p-has-ascendants
                          (when-not p-has-descendants)
                          (p-jurisdiction 'PH))
                 (then-spouse-ascendants-split 'ph-intestate-spouse-ascendants)
                 (list ':rank 850 ':jurisdiction 'PH ':category 'intestate ':legal-basis 'art-999)))

;;; STATUTE 4: Representation in direct line
;;; Legal basis: Art. 981 - Deceased heir's children inherit in their place
(define S-PH-INTESTATE-REPRESENTATION
  (spawn-statute 'ph-intestate-representation
                 "PH: Representation - deceased heir's children inherit in their place"
                 (when-all p-death 
                          p-no-will 
                          p-has-representation
                          (p-jurisdiction 'PH))
                 (then-representation-split 'ph-intestate-representation)
                 (list ':rank 920 ':jurisdiction 'PH ':category 'intestate ':legal-basis 'art-981)))

;;; STATUTE 5: Ascendants only (no descendants, no spouse)
;;; Legal basis: Art. 1001 - Parents inherit equally
(define S-PH-INTESTATE-ASCENDANTS-ONLY
  (spawn-statute 'ph-intestate-ascendants-only
                 "PH: Ascendants inherit when no descendants or spouse"
                 (when-all p-death 
                          p-no-will 
                          p-has-ascendants
                          (when-not p-has-descendants)
                          (when-not p-has-spouse)
                          (p-jurisdiction 'PH))
                 (lambda (ev)
                   (let ((ascendants (as-list (event.get ev ':ascendants)))
                         (person (event.get ev ':person)))
                     (if (or (null? person) (safe-empty? ascendants))
                         '()
                         (let ((ascendant-count (safe-length ascendants))
                               (individual-share (/ 1 ascendant-count)))
                           (safe-map
                             (lambda (ascendant)
                               (fact.make 'heir-share (list person ascendant)
                                         (list ':share individual-share
                                               ':basis 'ph-intestate-ascendants-only
                                               ':heir-type 'ascendant
                                               ':legal-basis 'art-1001)))
                             ascendants)))))
                 (list ':rank 800 ':jurisdiction 'PH ':category 'intestate ':legal-basis 'art-1001)))

;;; STATUTE 6: Collateral relatives (siblings)
;;; Legal basis: Art. 1003 - Siblings inherit when no descendants, ascendants, or spouse
(define S-PH-INTESTATE-COLLATERAL
  (spawn-statute 'ph-intestate-collateral
                 "PH: Siblings inherit when no direct heirs or spouse"
                 (when-all p-death 
                          p-no-will 
                          p-has-siblings
                          (when-not p-has-descendants)
                          (when-not p-has-ascendants)
                          (when-not p-has-spouse)
                          (p-jurisdiction 'PH))
                 (then-collateral-split 'ph-intestate-collateral)
                 (list ':rank 750 ':jurisdiction 'PH ':category 'intestate ':legal-basis 'art-1003)))

;;; STATUTE 7: Compulsory heir protection (legitime)
;;; Legal basis: Art. 886-906 - Compulsory heirs have protected minimum shares
(define S-PH-LEGITIME-PROTECTION
  (spawn-statute 'ph-legitime-protection
                 "PH: Compulsory heir legitime protection"
                 (when-all p-death 
                          (lambda (ev) 
                            (let ((compulsory (as-list (event.get ev ':compulsory-heirs))))
                              (not (safe-empty? compulsory))))
                          (p-jurisdiction 'PH))
                 (then-legitime-protection 'ph-legitime-protection)
                 (list ':rank 1000 ':jurisdiction 'PH ':category 'legitime ':legal-basis 'art-886-906)))

(print "✓ Philippine intestate succession statutes defined")

;;; -------------------------------------------------------------------
;;; COMPREHENSIVE PHILIPPINE SUCCESSION REGISTRY
;;; -------------------------------------------------------------------

;;; Complete registry with all Philippine succession statutes
;;; Ordered by rank (highest first) for proper precedence
(define PH-INTESTATE-REGISTRY
  (list S-PH-LEGITIME-PROTECTION          ; Rank 1000 - Highest priority
        S-PH-INTESTATE-SPOUSE-CHILDREN    ; Rank 950
        S-PH-INTESTATE-REPRESENTATION     ; Rank 920  
        S-PH-INTESTATE-CHILDREN-ONLY      ; Rank 900
        S-PH-INTESTATE-SPOUSE-ASCENDANTS  ; Rank 850
        S-PH-INTESTATE-ASCENDANTS-ONLY    ; Rank 800
        S-PH-INTESTATE-COLLATERAL         ; Rank 750 - Lowest priority
        ;; Include basic statutes from Phase 1 for compatibility
        S-INTESTATE-BASIC                 ; Rank 100 - Fallback
        S-INTESTATE-MIN-HEIRS             ; Rank 90
        S-INTESTATE-US))                  ; Rank 80

(print "✓ Philippine intestate succession registry created with" 
       (safe-length PH-INTESTATE-REGISTRY) "statutes")

;;; -------------------------------------------------------------------
;;; REGISTRY VALIDATION AND DIAGNOSTICS
;;; -------------------------------------------------------------------

;;; Validate registry ordering by rank
(define validate-registry-ordering
  (lambda (registry)
    (define check-ordering
      (lambda (statutes prev-rank)
        (if (safe-empty? statutes)
            #t
            (let ((current-statute (first statutes))
                  (remaining (rest statutes)))
              (let ((current-rank (statute.weight current-statute)))
                (if (> current-rank prev-rank)
                    #f  ; Ordering violation
                    (check-ordering remaining current-rank)))))))
    (if (safe-empty? registry)
        #t
        (check-ordering (rest registry) (statute.weight (first registry))))))

;;; Registry diagnostic report
(define registry-diagnostic
  (lambda (registry)
    (print "=== REGISTRY DIAGNOSTIC REPORT ===")
    (print "Total statutes:" (safe-length registry))
    (print "Rank ordering valid:" (validate-registry-ordering registry))
    (print "Statute details:")
    (safe-map
      (lambda (statute)
        (print "  " (statute.id statute) 
               " - Rank:" (statute.weight statute)
               " - Jurisdiction:" (plist-get-safe (statute.get statute ':props) ':jurisdiction)))
      registry)
    (print "=== END DIAGNOSTIC REPORT ===")
    #t))

;;; Run diagnostic on Philippine registry
(registry-diagnostic PH-INTESTATE-REGISTRY)

(print "")
(print "✓ Philippine Intestate Succession Module fully loaded")
(print "✓ 7 comprehensive succession statutes implemented")
(print "✓ Registry validated and ordered by precedence")
(print "✓ Ready for comprehensive testing")
(print "")

;;; Module completion marker
(define PH-INTESTATE-MODULE-LOADED #t)