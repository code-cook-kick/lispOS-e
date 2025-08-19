(define ensure-list
  (lambda (x)
    (begin
      "Convert x to a list if it isn't already one. Returns empty list for nil/false."
      (if (list? x)
          x
          (if (or (eq? x ' ()) (eq? x #f) (null? x))
            '
            ())))))

(define kv
  (lambda (k v)
    (begin
      "Always creates a 2-element list, good for UI/JSON-ish tuples and safe alist entries."
      (list k v))))

(define pair
  (lambda (k v)
    (begin
      "Use only when downstream truly expects dotted pairs in alists.
     This is the traditional cons but with explicit naming for clarity."
      (kv k v))))

(define safe-cons
  (lambda (item lst)
    (begin
      "Safe cons that ensures second argument is a list."
      (kv item (ensure-list lst)))))

(define make-alist-entry
  (lambda (key value)
    (begin
      "Creates an alist entry using kv for safety."
      (kv key value))))

(define safe-plist-put
  (lambda (plist key value)
    (begin
      "Safely add key-value pair to property list."
      (cons key (cons value (ensure-list plist))))))

(define safe-append-to
  (lambda (item maybe-list)
    (begin
      "Append item to maybe-list, ensuring result is a proper list."
      (cons item (ensure-list maybe-list)))))
