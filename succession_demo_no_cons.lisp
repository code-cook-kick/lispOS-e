; succession_demo_no_cons.lisp — cons-free, non-normative demo (basic evaluator compatible)

(print "=== Succession Demo (Non-Normative, Cons-Free) ===")

; helper: tuple
(define kv
  (lambda (k v)
    (list k v)))  ; always a 2-element list

; spouse only: 100% to spouse
(define alloc-spouse-only
  (lambda ()
    (list (kv 'spouse 1.0))))

; children only: equal split (simplified for basic evaluator)
(define alloc-children-only
  (lambda (n)
    (begin
      (define share (if (> n 0) (/ 1.0 n) 0.0))
      (if (<= n 0)
          '()
          (if (= n 1)
              (list (kv 'child share))
              (if (= n 2)
                  (list (kv 'child share) (kv 'child share))
                  (if (= n 3)
                      (list (kv 'child share) (kv 'child share) (kv 'child share))
                      (list (kv 'child share)))))))))

; spouse + children: 50% to spouse, rest split equally among children
(define alloc-spouse-and-children
  (lambda (n)
    (begin
      (define share (if (> n 0) (/ 0.5 n) 0.0))
      (if (<= n 0)
          (list (kv 'spouse 0.5))
          (if (= n 1)
              (list (kv 'spouse 0.5) (kv 'child share))
              (if (= n 2)
                  (list (kv 'spouse 0.5) (kv 'child share) (kv 'child share))
                  (if (= n 3)
                      (list (kv 'spouse 0.5) (kv 'child share) (kv 'child share) (kv 'child share))
                      (list (kv 'spouse 0.5) (kv 'child share)))))))))

; main solver
(define demo-solve
  (lambda (spouse? kids)
    (if spouse?
        (if (= kids 0)
            (alloc-spouse-only)
            (alloc-spouse-and-children kids))
        (alloc-children-only kids))))

; Test scenarios
(define scenario1 (demo-solve #t 0))    ; spouse only
(define scenario2 (demo-solve #t 2))    ; spouse + 2 children
(define scenario3 (demo-solve #f 3))    ; 3 children only

(print "Scenario 1 (spouse only):" scenario1)
(print "Scenario 2 (spouse + 2 children):" scenario2)
(print "Scenario 3 (3 children only):" scenario3)

; final value for the UI
(list
  (kv 'spouse_only         scenario1)
  (kv 'spouse_children_2   scenario2)
  (kv 'children_3          scenario3))