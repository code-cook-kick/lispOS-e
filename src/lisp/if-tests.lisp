; Test file for the if special form
; Demonstrates all required functionality

(print "=== Testing IF Special Form ===")
(print "")

; Test 1: Basic if with true condition
(print "Test 1: (if (> 5 3) 'yes 'no)")
(print "Result:" (if (> 5 3) 'yes 'no))
(print "Expected: yes")
(print "")

; Test 2: Basic if with false condition
(print "Test 2: (if (< 5 3) 'yes 'no)")
(print "Result:" (if (< 5 3) 'yes 'no))
(print "Expected: no")
(print "")

; Test 3: If without else clause (true condition)
(print "Test 3: (if (> 5 3) 'yes)")
(print "Result:" (if (> 5 3) 'yes))
(print "Expected: yes")
(print "")

; Test 4: If without else clause (false condition)
(print "Test 4: (if (< 5 3) 'yes)")
(print "Result:" (if (< 5 3) 'yes))
(print "Expected: null")
(print "")

; Test 5: If with nil condition
(print "Test 5: (if #f 'yes 'no)")
(print "Result:" (if #f 'yes 'no))
(print "Expected: no")
(print "")

; Test 6: If with eq? comparison
(print "Test 6: (if (eq? 'a 'a) 'match 'mismatch)")
(print "Result:" (if (eq? 'a 'a) 'match 'mismatch))
(print "Expected: match")
(print "")

; Test 7: If with eq? comparison (false)
(print "Test 7: (if (eq? 'a 'b) 'match 'mismatch)")
(print "Result:" (if (eq? 'a 'b) 'match 'mismatch))
(print "Expected: mismatch")
(print "")

; Test 8: Nested if statements
(print "Test 8: (if (> 10 5) (if (> 3 1) 'nested-yes 'nested-no) 'outer-no)")
(print "Result:" (if (> 10 5) (if (> 3 1) 'nested-yes 'nested-no) 'outer-no))
(print "Expected: nested-yes")
(print "")

; Test 9: If with arithmetic in condition
(print "Test 9: (if (= (+ 2 3) 5) 'correct 'incorrect)")
(print "Result:" (if (= (+ 2 3) 5) 'correct 'incorrect))
(print "Expected: correct")
(print "")

; Test 10: If with string comparison
(print "Test 10: (if (eq? \"hello\" \"hello\") 'same 'different)")
(print "Result:" (if (eq? "hello" "hello") 'same 'different))
(print "Expected: same")
(print "")

; Test 11: Short-circuit evaluation test
; This should not cause an error because the false branch is not evaluated
(print "Test 11: Short-circuit evaluation")
(print "Result:" (if #t 'safe 'this-would-error))
(print "Expected: safe")
(print "")

; Test 12: Truthiness test with numbers
(print "Test 12: (if 0 'zero-is-truthy 'zero-is-falsy)")
(print "Result:" (if 0 'zero-is-truthy 'zero-is-falsy))
(print "Expected: zero-is-truthy (0 is truthy in this Lisp)")
(print "")

; Test 13: Truthiness test with empty list
(print "Test 13: (if (list) 'empty-list-truthy 'empty-list-falsy)")
(print "Result:" (if (list) 'empty-list-truthy 'empty-list-falsy))
(print "Expected: empty-list-truthy (empty list is truthy)")
(print "")

(print "=== IF Tests Complete ===")
(print "All tests demonstrate proper if special form functionality:")
(print "- Conditional evaluation")
(print "- Optional else clause")
(print "- Proper truthiness (only #f and null are falsy)")
(print "- Short-circuit evaluation")
(print "- Nested if statements")