(print "=== Self-Modifying LISP Demo ===")

; Step 1: Define a generator lambda
(lambda generate-rule (price)
  (if (< price 4000000)
      '(defrule donation-check
         (and (sale ?seller ?buyer ?item ?price)
              (< ?price 4000000))
         =>
         (requires_donation_analysis ?seller ?buyer ?item))
      '(print "No donation rule needed")))

; Step 2: Generate new rule code
(set rule-code (generate-rule 3000000))
(print "Generated Rule Code:")
(print rule-code)

; Step 3: Evaluate to insert rule into warm memory
(eval rule-code)

(print "=== Self-Modifying Demo Complete ===")
