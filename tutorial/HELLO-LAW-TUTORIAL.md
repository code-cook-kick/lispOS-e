# Hello Law - Your First Legal Programming Tutorial

*A Complete Beginner's Guide to Legal Coding*

## 🎯 Welcome, Future Lawyer-Programmer!

This tutorial will teach you how to write your very first legal code. You don't need any programming experience - we'll start from the absolute basics and build up to creating real legal functions.

### **What You'll Learn**
- How to write your first legal program
- How to run legal code on your computer
- How to create functions that implement legal rules
- How to test legal logic with different scenarios

### **What You'll Build**
A simple "Hello Law" program that demonstrates:
- Basic legal greetings
- Age verification for contracts
- Legal status checking
- Simple legal advice system

---

## 📋 Before We Start

### **What You Need**
- [ ] A computer with Node.js installed
- [ ] The lispOS-e legal coding system
- [ ] A text editor (any will work, but VS Code is recommended)
- [ ] 15 minutes of your time
- [ ] No programming experience required!

### **Check If You're Ready**
Open a terminal/command prompt and type:
```bash
node --version
```
If you see a version number (like `v18.0.0` or higher), you're ready to go!

---

## 🚀 Step 1: Find Your Hello Law File

The "Hello Law" example is already created for you! It's located at:
```
tutorial/hello-law.lisp
```

This file contains your first legal program. Let's see what's inside by opening it in your text editor.

---

## 💻 Step 2: Run Your First Legal Code

### **Method 1: Using the Terminal**

1. **Open your terminal/command prompt**
2. **Navigate to the lispOS-e directory**:
   ```bash
   cd /path/to/lispOS-e
   ```
3. **Run the Hello Law program**:
   ```bash
   node src/evaluator.js tutorial/hello-law.lisp
   ```

### **Method 2: Using VS Code Terminal**

1. **Open VS Code in the lispOS-e folder**
2. **Open the integrated terminal** (Terminal → New Terminal)
3. **Run the command**:
   ```bash
   node src/evaluator.js tutorial/hello-law.lisp
   ```

### **What You Should See**

When you run the program, you'll see output like this:

```
=== MY FIRST LEGAL CODE ===
Hello, Legal World! Welcome to legal programming!

=== LEGAL GREETING ===
Hello, Attorney Smith! Ready to code some law?
Hello, Attorney Johnson! Ready to code some law?

=== CONTRACT AGE CHECKER ===
Age 17:
NO - Cannot enter contracts (minor, needs guardian consent)
Age 18:
YES - Can enter into contracts (age of majority reached)
Age 25:
YES - Can enter into contracts (age of majority reached)

=== LEGAL STATUS CHECKER ===
17 years old, no guardian consent:
MINOR WITHOUT CONSENT - Cannot enter contracts
17 years old, with guardian consent:
MINOR WITH CONSENT - Can enter limited contracts with guardian approval
25 years old:
ADULT - Can enter contracts independently

=== SIMPLE LEGAL ADVICE SYSTEM ===
Situation: contract
ADVICE: Ensure all parties have capacity, there's consideration, and terms are clear.
Situation: dispute
ADVICE: Document everything, attempt negotiation first, consider mediation.
Situation: compliance
ADVICE: Review applicable laws, create compliance checklist, monitor regularly.
Situation: unknown
ADVICE: Consult with a qualified attorney for specific legal guidance.

=== CONGRATULATIONS! ===
You have successfully run your first legal programming code!
You've learned:
- How to write functions that implement legal rules
- How to test legal logic with different scenarios
- How to create simple legal decision-making systems
- The basics of legal programming!

Next steps: Try modifying the age limit, add new legal situations,
or create your own legal functions!
```

**🎉 Congratulations! You just ran your first legal program!**

---

## 🔍 Step 3: Understanding What You Just Ran

Let's break down what happened in your "Hello Law" program:

### **Part 1: Simple Legal Greeting**
```lisp
(define say-hello-law
  (lambda ()
    "Hello, Legal World! Welcome to legal programming!"))
```
**What this does:** Creates a function that says hello to the legal world.
**Legal concept:** Basic function creation - the foundation of all legal coding.

### **Part 2: Personalized Legal Greeting**
```lisp
(define legal-greeting
  (lambda (lawyer-name)
    (string-append "Hello, Attorney " lawyer-name "! Ready to code some law?")))
```
**What this does:** Creates a personalized greeting for any lawyer.
**Legal concept:** Functions can take inputs (like a lawyer's name) and customize outputs.

### **Part 3: Contract Age Checker**
```lisp
(define can-enter-contract?
  (lambda (age)
    (if (>= age 18)
        "YES - Can enter into contracts (age of majority reached)"
        "NO - Cannot enter contracts (minor, needs guardian consent)")))
```
**What this does:** Implements the legal rule that you must be 18+ to enter contracts.
**Legal concept:** Age of majority - a fundamental legal principle coded as a simple rule.

### **Part 4: Advanced Legal Status Checker**
```lisp
(define legal-status-checker
  (lambda (age has-guardian-consent?)
    (cond 
      ((>= age 18) 
       "ADULT - Can enter contracts independently")
      ((and (< age 18) has-guardian-consent?)
       "MINOR WITH CONSENT - Can enter limited contracts with guardian approval")
      (else 
       "MINOR WITHOUT CONSENT - Cannot enter contracts"))))
```
**What this does:** Handles more complex legal scenarios with multiple conditions.
**Legal concept:** Legal capacity with exceptions - showing how law has nuances that code can handle.

### **Part 5: Legal Advice System**
```lisp
(define simple-legal-advice
  (lambda (situation)
    (cond
      ((equal? situation "contract")
       "ADVICE: Ensure all parties have capacity, there's consideration, and terms are clear.")
      ((equal? situation "dispute")
       "ADVICE: Document everything, attempt negotiation first, consider mediation.")
      ; ... more situations
      )))
```
**What this does:** Provides basic legal advice based on the situation type.
**Legal concept:** Decision trees - how lawyers think through different scenarios.

---

## 🛠️ Step 4: Modify Your First Legal Code

Now let's make some changes to see how legal coding works:

### **Exercise 1: Change the Age of Majority**

1. **Open** `tutorial/hello-law.lisp` in your text editor
2. **Find** the line with `(>= age 18)`
3. **Change** `18` to `21` (some jurisdictions use 21)
4. **Save** the file
5. **Run** the program again: `node src/file-runner.js tutorial/hello-law.lisp`

**What changed?** Now the program treats 21 as the age of majority instead of 18.

### **Exercise 2: Add a New Legal Situation**

1. **Find** the `simple-legal-advice` function
2. **Add** a new situation before the `else` clause:
   ```lisp
   ((equal? situation "employment")
    "ADVICE: Review employment contracts, ensure compliance with labor laws, document everything.")
   ```
3. **Add** a test for your new situation at the bottom:
   ```lisp
   (print "Situation: employment")
   (print (simple-legal-advice "employment"))
   ```
4. **Save** and **run** the program again

**What happened?** You just added new legal knowledge to your program!

### **Exercise 3: Create Your Own Legal Function**

Add this new function to the end of your file (before the congratulations section):

```lisp
; Your own legal function - statute of limitations checker
(define check-statute-of-limitations
  (lambda (years-since-incident claim-type)
    (begin
      (define time-limit
        (cond
          ((equal? claim-type "contract") 10)
          ((equal? claim-type "tort") 4)
          ((equal? claim-type "personal-injury") 2)
          (else 6)))  ; Default limitation period
      
      (if (<= years-since-incident time-limit)
          (list "WITHIN STATUTE" claim-type "Time remaining:" (- time-limit years-since-incident) "years")
          (list "STATUTE EXPIRED" claim-type "Expired by:" (- years-since-incident time-limit) "years")))))

; Test your new function
(print "")
(print "=== YOUR STATUTE OF LIMITATIONS CHECKER ===")
(print "Contract claim after 5 years:")
(print (check-statute-of-limitations 5 "contract"))
(print "Tort claim after 5 years:")
(print (check-statute-of-limitations 5 "tort"))
(print "Personal injury after 3 years:")
(print (check-statute-of-limitations 3 "personal-injury"))
```

**Save and run** - you've just created your own legal function!

---

## 🎓 Step 5: Understanding Legal Programming Concepts

### **What You've Learned**

1. **Functions are Legal Rules**: Each function implements a specific legal principle
2. **Inputs are Facts**: The information you give to functions (age, situation, etc.)
3. **Outputs are Legal Conclusions**: What the law says about those facts
4. **Conditions are Legal Tests**: The `if` statements check legal requirements
5. **Testing is Validation**: Running different scenarios ensures accuracy

### **Legal Programming Patterns You've Seen**

| Legal Concept | Programming Pattern | Example |
|---------------|-------------------|---------|
| Age Requirements | Comparison operators (`>=`, `<`) | `(>= age 18)` |
| Multiple Conditions | `cond` statements | Different contract types |
| Yes/No Decisions | `if` statements | Can enter contract? |
| Legal Categories | String matching | Contract vs. tort vs. employment |
| Complex Rules | Nested conditions | Minor with/without consent |

### **Why This Matters for Lawyers**

- **Consistency**: Code applies legal rules the same way every time
- **Speed**: Instant legal analysis instead of manual research
- **Accuracy**: Reduces human error in applying complex rules
- **Scalability**: Handle hundreds of cases with the same logic
- **Documentation**: Code serves as precise legal rule documentation

---

## 🚀 Step 6: Next Steps in Your Legal Coding Journey

### **Immediate Next Steps**

1. **Experiment More**: Try changing other values in the hello-law.lisp file
2. **Add More Functions**: Create functions for other legal areas you know
3. **Test Edge Cases**: What happens with unusual inputs?
4. **Read Other Examples**: Look at `examples/legal-coding-examples.lisp` for more complex examples

### **Suggested Practice Exercises**

1. **Create a Legal Holiday Checker**: Function that determines if courts are open
2. **Build a Simple Fee Calculator**: Calculate legal fees based on hours and rates
3. **Make a Jurisdiction Checker**: Determine which court has jurisdiction
4. **Design a Document Deadline Tracker**: Calculate filing deadlines

### **Advanced Tutorials to Try Next**

- **Contract Validity Checker**: Full implementation of Article 1318 (Civil Code)
- **Child Support Calculator**: Family law calculations
- **Tax Calculator**: Progressive tax computation
- **Property Division**: Asset distribution in divorce cases

### **Resources for Continued Learning**

- **Step-by-Step Legal Coding Tutorial**: More comprehensive examples
- **Legal Function Library**: Pre-built legal functions you can use
- **Programmer Reference Guide**: Technical details for advanced users
- **Legal Coding Examples**: 10+ real-world legal coding examples

---

## 🎉 Congratulations - You're Now a Legal Programmer!

### **What You've Accomplished**

✅ **Ran your first legal program** successfully  
✅ **Understood basic legal programming concepts**  
✅ **Modified legal code** to see how changes work  
✅ **Created your own legal function**  
✅ **Learned the connection** between legal rules and code  

### **You Now Know How To**

- Write functions that implement legal rules
- Test legal logic with different scenarios
- Modify existing legal code for new requirements
- Create simple legal decision-making systems
- Apply programming concepts to legal problems

### **Your Legal Coding Superpowers**

- **Automate Legal Analysis**: Turn repetitive legal tasks into instant calculations
- **Ensure Consistency**: Apply legal rules the same way every time
- **Handle Complexity**: Manage multiple legal conditions and exceptions
- **Scale Your Practice**: Handle more cases with the same accuracy
- **Innovate Legal Services**: Create new tools that help clients

### **Welcome to the Future of Legal Practice**

You're now part of a growing community of lawyer-programmers who are transforming legal practice through technology. Every legal rule you code becomes a reusable asset that can help you and other lawyers provide better legal services.

**Keep coding, keep learning, and keep innovating!**

---

## 🆘 Troubleshooting

### **Common Issues and Solutions**

**Problem**: "node: command not found"  
**Solution**: Install Node.js from nodejs.org

**Problem**: "Cannot find module"  
**Solution**: Make sure you're in the correct directory (lispOS-e folder)

**Problem**: "Syntax error in LISP code"  
**Solution**: Check that all parentheses are balanced - every `(` needs a matching `)`

**Problem**: "No output when running the program"  
**Solution**: The program ran successfully! The output might not be visible in some terminals, but if there's no error message, it worked.

**Problem**: "Permission denied"  
**Solution**: Make sure you have read/write permissions in the directory

### **Getting Help**

- Check the existing documentation files in the project
- Look at other example files for reference
- Make sure your syntax matches the examples exactly
- Remember: every opening parenthesis `(` needs a closing parenthesis `)`

---

## 📚 Appendix: Quick Reference

### **Basic LISP Syntax for Legal Programming**

```lisp
; This is a comment

; Define a function
(define function-name
  (lambda (parameter1 parameter2)
    ; function body
    ))

; Call a function
(function-name value1 value2)

; If statement
(if condition
    "true result"
    "false result")

; Multiple conditions
(cond
  ((condition1) "result1")
  ((condition2) "result2")
  (else "default result"))

; Print output
(print "Hello World")

; Boolean values
#t  ; true
#f  ; false

; Comparison operators
(= a b)    ; equal
(< a b)    ; less than
(> a b)    ; greater than
(<= a b)   ; less than or equal
(>= a b)   ; greater than or equal
```

### **Legal Programming Best Practices**

1. **Always comment your legal basis**: Cite the law or rule you're implementing
2. **Use descriptive function names**: `check-contract-validity` not `check-cv`
3. **Test with multiple scenarios**: Include edge cases and unusual situations
4. **Handle invalid inputs**: Check for errors and provide helpful messages
5. **Document your assumptions**: Note any legal interpretations you've made

---

*This tutorial is your first step into the exciting world of legal programming. Every legal rule you code makes the law more accessible, consistent, and efficient. Welcome to the future of legal practice!*