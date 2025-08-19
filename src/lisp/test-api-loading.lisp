(print "=== Testing API Loading ===")

(load "src/lisp/statute-api-final-working.lisp")

(print "✓ Statute API loaded")

(print "Testing statute.make availability...")

(define test-statute
  (statute.make
    'test
    "Test Statute"
    (lambda (ev)
    #t)
    (lambda (ev)
    (begin
      '
      ()))
    '
    ()))

(print "✓ statute.make works!")

(print "Test statute ID:" (statute.id test-statute))

(print "Test statute title:" (statute.title test-statute))

(print "🎉 API Loading Test Successful!")
