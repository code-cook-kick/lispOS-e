(load "src/lisp/common/utils.lisp")

(print "Loading core macros with hygienic bindings...")

(defmacro
  let*
  (bindings body)
  (if (eq? (length bindings) 0)
    body
    (let
    ((first-binding (first bindings))
    (rest-bindings (rest bindings)))
    (let
    ((var (first first-binding))
    (val (first (rest first-binding)))
    (temp-var (gensym "let*")))
    (list
    'let
    (list (list temp-var val))
    (list
    'let
    (list (list var temp-var))
    (if (eq? (length rest-bindings) 0)
      body
      (list 'let* rest-bindings body))))))))

(defmacro
  when
  (condition . body)
  (let
  ((test-var (gensym "when-test")))
  (list
  'let
  (list (list test-var condition))
  (list 'if test-var (kv 'begin body) 'nil))))

(defmacro
  unless
  (condition . body)
  (let
  ((test-var (gensym "unless-test")))
  (list
  'let
  (list (list test-var condition))
  (list 'if test-var 'nil (kv 'begin body)))))

(defmacro
  begin
  body
  (if (eq? (length body) 0)
    'nil
    (if (eq? (length body) 1)
      (first body)
      (let
      ((first-expr (first body))
      (rest-exprs (rest body))
      (temp-var (gensym "begin")))
      (list
      'let
      (list (list temp-var first-expr))
      (kv 'begin rest-exprs))))))

(defmacro
  event
  (type . kvs)
  (let
  ((type-var (gensym "event-type"))
  (kvs-var (gensym "event-kvs")))
  (list
  'let
  (list
  (list type-var (list 'quote type))
  (list kvs-var (kv 'list kvs)))
  (list 'event.make type-var kvs-var))))

(defmacro
  make-fact
  (pred args . kvs)
  (let
  ((pred-var (gensym "fact-pred"))
  (args-var (gensym "fact-args"))
  (kvs-var (gensym "fact-kvs")))
  (list
  'let
  (list
  (list pred-var (list 'quote pred))
  (list args-var (kv 'list args))
  (list kvs-var (kv 'list kvs)))
  (list 'fact.make pred-var args-var kvs-var))))

(defmacro
  statute
  (id title when-clause then-clause . props)
  (let
  ((id-var (gensym "statute-id"))
  (title-var (gensym "statute-title"))
  (when-var (gensym "statute-when"))
  (then-var (gensym "statute-then"))
  (props-var (gensym "statute-props")))
  (list
  'let
  (list
  (list id-var (list 'quote id))
  (list title-var title)
  (list when-var (first (rest when-clause)))
  (list then-var (first (rest then-clause)))
  (list
  props-var
  (if (eq? (length props) 0)
    'nil
    (kv 'list props))))
  (list
  'statute.make
  id-var
  title-var
  when-var
  then-var
  props-var))))

(defmacro
  query-facts
  query-spec
  (let
  ((spec-var (gensym "query-spec")))
  (list
  'let
  (list (list spec-var (kv 'list query-spec)))
  (list 'index.query 'fact-index spec-var))))

(defmacro
  query-statutes
  query-spec
  (let
  ((spec-var (gensym "statute-spec")))
  (list
  'let
  (list (list spec-var (kv 'list query-spec)))
  (list 'index.query 'statute-index spec-var))))

(defmacro
  with-temporal-context
  (context . body)
  (let
  ((ctx-var (gensym "temporal-ctx"))
  (result-var (gensym "temporal-result")))
  (list
  'let
  (list (list ctx-var (kv 'list context)))
  (list
  'let
  (list (list result-var (kv 'begin body)))
  (list 'temporal.filter result-var ctx-var)))))

(defmacro
  resolve-conflicts
  (facts statutes . options)
  (let
  ((facts-var (gensym "conflict-facts"))
  (statutes-var (gensym "conflict-statutes"))
  (options-var (gensym "conflict-options"))
  (context-var (gensym "conflict-context")))
  (list
  'let
  (list
  (list facts-var facts)
  (list statutes-var statutes)
  (list options-var (kv 'list options))
  (list context-var (list 'conflicts.make-context options-var)))
  (list 'conflicts.resolve facts-var statutes-var context-var))))

(defmacro
  generate-decision-report
  report-spec
  (let
  ((spec-var (gensym "report-spec"))
  (context-var (gensym "report-context")))
  (list
  'let
  (list
  (list spec-var (kv 'list report-spec))
  (list context-var (list 'decision.extract-context spec-var)))
  (list 'decision.build context-var))))

(defmacro
  legal-pipeline
  (input . stages)
  (let
  ((input-var (gensym "pipeline-input"))
  (result-var (gensym "pipeline-result")))
  (list
  'let
  (list (list input-var input) (list result-var input-var))
  (cons
  'begin
  (map
  (lambda (stage)
  (let
    ((stage-var (gensym "pipeline-stage")))
    (list
    'let
    (list (list stage-var stage))
    (list
    'set!
    result-var
    (list 'pipeline.apply-stage result-var stage-var)))))
  stages)))))

(defmacro
  test-hygiene
  (var-name)
  (let
  ((test-var (gensym "hygiene-test"))
  (user-var (gensym var-name)))
  (list
  'let
  (list (list test-var 42) (list user-var 24))
  (list 'list test-var user-var))))

(print "✓ Core macros loaded with hygienic bindings")

(print
  "✓ All macros use gensym for variable capture prevention")

(print
  "✓ Legal DSL macros available: event, make-fact, statute")

(print
  "✓ Query macros available: query-facts, query-statutes")

(print "✓ Temporal macros available: with-temporal-context")

(print
  "✓ Conflict resolution macros available: resolve-conflicts")

(print
  "✓ Decision reporting macros available: generate-decision-report")

(print "✓ Pipeline macros available: legal-pipeline")

(define core-macros
  (list
    'let*
    'when
    'unless
    'begin
    'event
    'make-fact
    'statute
    'query-facts
    'query-statutes
    'with-temporal-context
    'resolve-conflicts
    'generate-decision-report
    'legal-pipeline
    'test-hygiene))

(print "📚 Core macro system ready for legal reasoning")
