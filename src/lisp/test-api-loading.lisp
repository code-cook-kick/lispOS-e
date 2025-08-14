;;; Minimal test to verify API loading

(print "=== Testing API Loading ===")

; Load just the statute API
(load "src/lisp/statute-api-final-working.lisp")

(print "✓ Statute API loaded")

; Test if statute.make is available
(print "Testing statute.make availability...")

; Try to create a simple statute
(define test-statute (statute.make 'test "Test Statute" (lambda (ev) #t) (lambda (ev) '()) '()))

(print "✓ statute.make works!")
(print "Test statute ID:" (statute.id test-statute))
(print "Test statute title:" (statute.title test-statute))

(print "🎉 API Loading Test Successful!")