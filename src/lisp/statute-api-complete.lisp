(load "src/lisp/common/utils.lisp")

(print "=== Etherney eLisp Statute/Rule API ===")

(print "Loading statute processing system...")

(print "")

(define first
  (lambda (lst)
    (nth lst 0)))

(define second
  (lambda (lst)
    (nth lst 1)))

(define starts-with?
  (lambda (lst symbol)
    (if (< (length lst) 1)
        #f
        (eq? (first lst) symbol))))

(define event.make
  (lambda (type props)
    (kv 'event (cons ':type (cons type props)))))

(define event.type
  (lambda (ev)
    (if (event.valid? ev)
        (nth ev 2)
        #f)))

(define event.get
  (lambda (ev key)
    (event.get-helper (rest (rest (rest ev))) key)))

(define event.get-helper
  (lambda (props key)
    (if (< (length props) 2)
        #f
        (if (eq? (first props) key)
          (second props)
          (event.get-helper (rest (rest props)) key)))))

(define event.valid?
  (lambda (ev)
    (if (< (length ev) 3)
        #f
        (if (starts-with? ev 'event)
          (if (eq? (nth ev 1) ':type)
            #t
            #f)
          #f))))

(define fact.make
  (lambda (pred args props)
    (list 'fact ':pred pred ':args args ':props props)))

(define fact.pred
  (lambda (f)
    (if (fact.valid? f)
        (nth f 2)
        #f)))

(define fact.args
  (lambda (f)
    (if (fact.valid? f)
        (nth f 4)
        #f)))

(define fact.get
  (lambda (f key)
    (if (fact.valid? f)
        (fact.get-helper (nth f 6) key)
        #f)))

(define fact.get-helper
  (lambda (props key)
    (if (< (length props) 2)
        #f
        (if (eq? (first props) key)
          (second props)
          (fact.get-helper (rest (rest props)) key)))))

(define fact.valid?
  (lambda (f)
    (if (< (length f) 7)
        #f
        (if (starts-with? f 'fact)
          (if (eq? (nth f 1) ':pred)
            (if (eq? (nth f 3) ':args)
              (if (eq? (nth f 5) ':props)
                #t
                #f)
              #f)
            #f)
          #f))))

(define append2
  (lambda (list1 list2)
    (if (eq? (length list1) 0)
        list2
        (cons
        (first (ensure-list list1))
        (append2 (rest list1) list2)))))

(define map2
  (lambda (fn lst)
    (if (eq? (length lst) 0)
        (list)
        (cons (fn (first lst)) (map2 fn (rest lst))))))

(define foldl
  (lambda (fn init lst)
    (if (eq? (length lst) 0)
        init
        (foldl fn (fn init (first lst)) (rest lst)))))

(define contains?
  (lambda (lst elem)
    (if (eq? (length lst) 0)
        #f
        (if (eq? (first lst) elem)
          #t
          (contains? (rest lst) elem)))))

(define statute.make
  (lambda (id title props)
    (list 'statute id title 0 props)))

(define statute.id
  (lambda (s)
    (nth s 1)))

(define statute.title
  (lambda (s)
    (nth s 2)))

(define statute.weight
  (lambda (s)
    (nth s 3)))

(define statute.props
  (lambda (s)
    (nth s 4)))

(define statute.with-weight
  (lambda (s w)
    (list
      'statute
      (statute.id s)
      (statute.title s)
      w
      (statute.props s))))

(define s774.when
  (lambda (ev)
    (if (eq? (event.type ev) 'death)
        (contains? (event.get ev ':flags) 'no-will)
        #f)))

(define s774.when.debug
  (lambda (ev)
    (if (print "Debug - Checking S774 conditions...")
        (if (print (event.type ev))
          (if (print (eq? (event.type ev) 'death))
            (if (print (event.get ev ':flags))
              (if (print (contains? (event.get ev ':flags) 'no-will))
                (s774.when ev)
                (s774.when ev))
              (s774.when ev))
            (s774.when ev))
          (s774.when ev))
        (s774.when ev))))

(define s774.then
  (lambda (ev)
    (map2
      (lambda (heir)
      (fact.make
        'heir-share
        (list (event.get ev ':person) heir)
        (list
        ':share
        (/ 1 (length (event.get ev ':heirs)))
        ':basis
        'S774)))
      (event.get ev ':heirs))))

(define s774.eval
  (lambda (s ev)
    (if (s774.when.debug ev)
        (list
        (s774.then ev)
        (statute.with-weight s (+ (statute.weight s) 1)))
        (list (list) s))))

(define statute.eval-by-id
  (lambda (s ev)
    (if (eq? (statute.id s) 'S774)
        (s774.eval s ev)
        (list (list) s))))

(define registry.apply
  (lambda (registry ev)
    (if (eq? (length registry) 0)
        (list (list) (list))
        (list
        (append2
        (first (statute.eval-by-id (first registry) ev))
        (first (registry.apply (rest registry) ev)))
        (cons
        (second (statute.eval-by-id (first registry) ev))
        (second (registry.apply (rest registry) ev)))))))

(print "=== STATUTE API DEMO ===")

(print "")

(define S774
  (statute.make 'S774 "Intestate (equal split demo)" (list)))

(print "Debug - S774 structure:")

(print S774)

(print "Debug - S774 ID:")

(print (statute.id S774))

(print "Debug - S774 weight:")

(print (statute.weight S774))

(print "")

(define REG1
  (list S774))

(define EV
  (event.make
    'death
    (list
    ':person
    'Pedro
    ':flags
    (list 'no-will)
    ':heirs
    (list 'Maria 'Juan 'Jose))))

(print "Sample Event:")

(print EV)

(print "")

(print "Applying registry to event...")

(define result
  (registry.apply REG1 EV))

(define facts-out
  (first result))

(define REG2
  (second result))

(print "Derived facts:")

(print facts-out)

(print "")

(print "Registry weights before:")

(print (map2 statute.weight REG1))

(print "Registry weights after:")

(print (map2 statute.weight REG2))

(print "")

(define assert=
  (lambda (label expected actual)
    (if (eq? expected actual)
        (print "PASS:" label)
        (print "FAIL:" label "Expected:" expected "Actual:" actual))))

(print "=== RUNNING ASSERTIONS ===")

(assert=
  "Weight increments correctly"
  1
  (statute.weight (first REG2)))

(assert=
  "Facts count equals heirs count"
  3
  (length facts-out))

(if (> (length facts-out) 0)
    (assert=
    "Share calculation correct"
    (/ 1 3)
    (fact.get (first facts-out) ':share))
    (print "No facts generated to test share calculation"))

(print "")

(print "=== STATUTE API COMPLETE ===")

(print "Ready for legal reasoning in Etherney eLisp!")

(print "")

(print "Demonstrated features:")

(print "- Statute definition and evaluation")

(print "- Registry application")

(print "- Fact derivation from events")

(print "- Statute weight tracking")

(print "- Pure functional approach (no mutation)")
