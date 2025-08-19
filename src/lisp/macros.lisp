(load "src/lisp/common/utils.lisp")

(define kv->plist
  (lambda (pairs)
    pairs))

(defmacro
  event
  (type . kvs)
  (list 'event.make (list 'quote type) (kv 'list kvs)))

(defmacro
  make-fact
  (pred args . kvs)
  (list
  'fact.make
  (list 'quote pred)
  (kv 'list args)
  (kv 'list kvs)))

(defmacro
  statute
  (id title when-clause then-clause . props)
  (list
  'statute.make
  (list 'quote id)
  title
  (second when-clause)
  (second then-clause)
  (if (= (length props) 0)
    'nil
    (kv 'list props))))
