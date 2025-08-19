(load "src/lisp/common/utils.lisp")

(print "Loading core indexer system...")

(define index.create
  (lambda ()
    (list
      ':type
      'index
      ':by-type
      (list)
      ':by-subject
      (list)
      ':by-jurisdiction
      (list)
      ':by-priority
      (list)
      ':by-id
      (list)
      ':all-items
      (list))))

(define index.get-property
  (lambda (index property)
    (begin
      (define search-props
        (lambda (props)
          (if (eq? (length props) 0)
              #f
              (if (eq? (first props) property)
                (first (rest props))
                (search-props (rest (rest props)))))))
      (search-props (rest index)))))

(define index.set-property
  (lambda (index property value)
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
      (cons (first (ensure-list index)) (update-props (rest index))))))

(define fact.extract-properties
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
      (jurisdiction (get-event-property properties ':jurisdiction))
      (basis (get-event-property properties ':basis))
      (id (get-event-property properties ':id)))
      (list
      ':type
      predicate
      ':subject
      subject
      ':jurisdiction
      jurisdiction
      ':basis
      basis
      ':id
      id
      ':item
      fact)))))

(define statute.extract-properties
  (lambda (statute)
    (let
      ((id (get-event-property statute ':id))
      (title (get-event-property statute ':title))
      (properties (get-event-property statute ':properties)))
      (let
      ((jurisdiction (get-event-property properties ':jurisdiction))
      (priority (get-event-property properties ':priority))
      (category (get-event-property properties ':category)))
      (list
      ':type
      'statute
      ':subject
      id
      ':jurisdiction
      jurisdiction
      ':priority
      priority
      ':category
      category
      ':id
      id
      ':item
      statute)))))

(define index.add-to-bucket
  (lambda (bucket key item)
    (let
      ((existing-entry (index.find-bucket-entry bucket key)))
      (if existing-entry
        (map
        (lambda (entry)
        (if (eq? (first entry) key)
            (list key (cons item (ensure-list (first (rest entry)))))
            entry))
        bucket)
        (cons (list (ensure-list key (list item))) bucket)))))

(define index.find-bucket-entry
  (lambda (bucket key)
    (if (eq? (length bucket) 0)
        #f
        (if (eq? (first (first bucket)) key)
          (first bucket)
          (index.find-bucket-entry (rest bucket) key)))))

(define index.add-item
  (lambda (index item-props)
    (let
      ((item-type (get-event-property item-props ':type))
      (subject (get-event-property item-props ':subject))
      (jurisdiction (get-event-property item-props ':jurisdiction))
      (priority (get-event-property item-props ':priority))
      (id (get-event-property item-props ':id))
      (item (get-event-property item-props ':item)))
      (let
      ((updated-by-type
      (index.add-to-bucket
      (index.get-property index ':by-type)
      item-type
      item))
      (updated-by-subject
      (index.add-to-bucket
      (index.get-property index ':by-subject)
      subject
      item))
      (updated-by-jurisdiction
      (if jurisdiction
        (index.add-to-bucket
        (index.get-property index ':by-jurisdiction)
        jurisdiction
        item)
        (index.get-property index ':by-jurisdiction)))
      (updated-by-priority
      (if priority
        (index.add-to-bucket
        (index.get-property index ':by-priority)
        priority
        item)
        (index.get-property index ':by-priority)))
      (updated-by-id
      (if id
        (index.add-to-bucket
        (index.get-property index ':by-id)
        id
        item)
        (index.get-property index ':by-id)))
      (updated-all
      (cons item (index.get-property index ':all-items))))
      (list
      ':type
      'index
      ':by-type
      updated-by-type
      ':by-subject
      updated-by-subject
      ':by-jurisdiction
      updated-by-jurisdiction
      ':by-priority
      updated-by-priority
      ':by-id
      updated-by-id
      ':all-items
      updated-all)))))

(define index.build-facts
  (lambda (facts)
    (begin
      (define build-recursive
        (lambda (remaining-facts current-index)
          (if (eq? (length remaining-facts) 0)
              current-index
              (let
              ((fact (first remaining-facts))
              (rest-facts (rest remaining-facts)))
              (let
              ((fact-props (fact.extract-properties fact)))
              (build-recursive
              rest-facts
              (index.add-item current-index fact-props)))))))
      (build-recursive facts (index.create)))))

(define index.build-statutes
  (lambda (statutes)
    (begin
      (define build-recursive
        (lambda (remaining-statutes current-index)
          (if (eq? (length remaining-statutes) 0)
              current-index
              (let
              ((statute (first remaining-statutes))
              (rest-statutes (rest remaining-statutes)))
              (let
              ((statute-props (statute.extract-properties statute)))
              (build-recursive
              rest-statutes
              (index.add-item current-index statute-props)))))))
      (build-recursive statutes (index.create)))))

(define index.build
  (lambda (facts statutes)
    (let
      ((fact-index (index.build-facts facts))
      (statute-index (index.build-statutes statutes)))
      (list ':fact-index fact-index ':statute-index statute-index))))

(define index.get-from-bucket
  (lambda (bucket key)
    (let
      ((entry (index.find-bucket-entry bucket key)))
      (if entry
        (first (rest entry))
        (list)))))

(define index.query-single
  (lambda (index criterion value)
    (let
      ((bucket-name
      (if (eq? criterion ':type)
        ':by-type
        (if (eq? criterion ':subject)
          ':by-subject
          (if (eq? criterion ':jurisdiction)
            ':by-jurisdiction
            (if (eq? criterion ':priority)
              ':by-priority
              (if (eq? criterion ':id)
                ':by-id
                ':all-items))))))
      )
      (if (eq? bucket-name ':all-items)
        (index.get-property index ':all-items)
        (let
        ((bucket (index.get-property index bucket-name)))
        (index.get-from-bucket bucket value))))))

(define index.query
  (lambda (index . criteria)
    (if (eq? (length criteria) 0)
        (index.get-property index ':all-items)
        (let
        ((first-criterion (first criteria))
        (first-value (first (rest criteria)))
        (rest-criteria (rest (rest criteria))))
        (let
        ((initial-results
        (index.query-single index first-criterion first-value))
        )
        (index.filter-by-criteria initial-results rest-criteria))))))

(define index.filter-by-criteria
  (lambda (items criteria)
    (if (eq? (length criteria) 0)
        items
        (let
        ((criterion (first criteria))
        (value (first (rest criteria)))
        (rest-criteria (rest (rest criteria))))
        (let
        ((filtered
        (filter
        (lambda (item)
        (index.item-matches-criterion item criterion value))
        items))
        )
        (index.filter-by-criteria filtered rest-criteria))))))

(define index.item-matches-criterion
  (lambda (item criterion value)
    (let
      ((item-props
      (if (eq? (get-event-property item ':predicate) #f)
        (statute.extract-properties item)
        (fact.extract-properties item)))
      )
      (let
      ((item-value (get-event-property item-props criterion)))
      (eq? item-value value)))))

(define index.stats
  (lambda (index)
    (let
      ((total-items (length (index.get-property index ':all-items)))
      (by-type-count (length (index.get-property index ':by-type)))
      (by-subject-count
      (length (index.get-property index ':by-subject)))
      (by-jurisdiction-count
      (length (index.get-property index ':by-jurisdiction)))
      (by-priority-count
      (length (index.get-property index ':by-priority)))
      (by-id-count (length (index.get-property index ':by-id))))
      (list
      ':total-items
      total-items
      ':type-buckets
      by-type-count
      ':subject-buckets
      by-subject-count
      ':jurisdiction-buckets
      by-jurisdiction-count
      ':priority-buckets
      by-priority-count
      ':id-buckets
      by-id-count))))

(define index.print-stats
  (lambda (index)
    (let
      ((stats (index.stats index)))
      (print "Index Statistics:")
      (print
      "  Total items: "
      (get-event-property stats ':total-items))
      (print
      "  Type buckets: "
      (get-event-property stats ':type-buckets))
      (print
      "  Subject buckets: "
      (get-event-property stats ':subject-buckets))
      (print
      "  Jurisdiction buckets: "
      (get-event-property stats ':jurisdiction-buckets))
      (print
      "  Priority buckets: "
      (get-event-property stats ':priority-buckets))
      (print
      "  ID buckets: "
      (get-event-property stats ':id-buckets)))))

(define index.validate
  (lambda (index)
    (and
      (eq? (get-event-property index ':type) 'index)
      (not (eq? (index.get-property index ':by-type) #f))
      (not (eq? (index.get-property index ':by-subject) #f))
      (not (eq? (index.get-property index ':all-items) #f)))))

(define index.test
  (lambda ()
    (begin
      (print "Testing index functionality...")
      (let
        ((empty-index (index.create)))
        (print "✓ Empty index created")
        (print "✓ Index validation: " (index.validate empty-index))
        (index.print-stats empty-index)
        empty-index))))

(print "✓ Core indexer system loaded")

(print
  "✓ Index building functions available: index.build, index.build-facts, index.build-statutes")

(print
  "✓ Query functions available: index.query, index.query-single")

(print
  "✓ Utility functions available: index.stats, index.validate, index.test")

(define indexer-functions
  (list
    'index.create
    'index.build
    'index.build-facts
    'index.build-statutes
    'index.query
    'index.query-single
    'index.stats
    'index.validate
    'index.print-stats
    'index.test))

(print "📊 Core indexer system ready for legal reasoning")
