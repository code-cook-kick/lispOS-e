(print "=== Self-Modifying LISP Demo ===")

(lambda generate-rule
  (begin
    (price)
    (if (< price 4000000)
        '
        (defrule
        donation-check
        (and (sale ?seller ?buyer ?item ?price) (< ?price 4000000))
        =>
        (requires_donation_analysis ?seller ?buyer ?item)))))

(set rule-code (generate-rule 3000000))

(print "Generated Rule Code:")

(print rule-code)

(eval rule-code)

(print "=== Self-Modifying Demo Complete ===")
