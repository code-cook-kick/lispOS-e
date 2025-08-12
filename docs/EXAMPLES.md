# Examples

This document provides comprehensive examples of using the Etherney Lisp Machine, from basic operations to advanced programming concepts.

## Table of Contents

- [Basic Operations](#basic-operations)
- [Data Types](#data-types)
- [Arithmetic Operations](#arithmetic-operations)
- [String Operations](#string-operations)
- [List Operations](#list-operations)
- [Working with Quotes](#working-with-quotes)
- [Interactive REPL Sessions](#interactive-repl-sessions)
- [Error Handling Examples](#error-handling-examples)
- [Programming Patterns](#programming-patterns)
- [Advanced Examples](#advanced-examples)

## Basic Operations

### Starting the REPL

```bash
$ node index.js
elisp> 
```

### Simple Expressions

```lisp
elisp> 42
42

elisp> "Hello, World!"
"Hello, World!"

elisp> 'hello
SYMBOL("hello")

elisp> #t
true

elisp> #f
false
```

### Basic Arithmetic

```lisp
elisp> (+ 1 2)
3

elisp> (- 10 3)
7

elisp> (* 4 5)
20

elisp> (/ 15 3)
5
```

## Data Types

### Numbers

```lisp
; Integers
elisp> 42
42

elisp> -17
-17

elisp> 0
0

; Floating-point numbers
elisp> 3.14159
3.14159

elisp> -2.5
-2.5

elisp> 0.0
0
```

### Strings

```lisp
; Basic strings
elisp> "Hello"
"Hello"

elisp> "Lisp is awesome!"
"Lisp is awesome!"

; Strings with escape sequences
elisp> "Line 1\nLine 2"
"Line 1
Line 2"

elisp> "Tab\tSeparated\tValues"
"Tab	Separated	Values"

elisp> "Quote: \"Hello\""
"Quote: "Hello""

elisp> "Backslash: \\"
"Backslash: \"

; Multi-line strings
elisp> "This is a
very long
string"
"This is a
very long
string"
```

### Symbols

```lisp
elisp> 'symbol
SYMBOL("symbol")

elisp> 'my-variable
SYMBOL("my-variable")

elisp> 'hello-world
SYMBOL("hello-world")

elisp> '+
SYMBOL("+")

elisp> 'special-chars-123
SYMBOL("special-chars-123")
```

### Booleans

```lisp
elisp> #t
true

elisp> #f
false
```

### Lists

```lisp
; Empty list
elisp> '()
LIST(null)

; Simple lists
elisp> '(1 2 3)
LIST(null)

elisp> '(hello world)
LIST(null)

elisp> '(a b c d e)
LIST(null)

; Mixed-type lists
elisp> '(1 "hello" symbol #t)
LIST(null)

; Nested lists
elisp> '((1 2) (3 4))
LIST(null)

elisp> '(outer (inner (deeply nested)))
LIST(null)
```

## Arithmetic Operations

### Addition

```lisp
; No arguments - returns 0
elisp> (+)
0

; Single argument
elisp> (+ 5)
5

; Multiple arguments
elisp> (+ 1 2 3 4 5)
15

; Mixed integers and floats
elisp> (+ 1 2.5 3)
6.5

; Negative numbers
elisp> (+ -1 -2 -3)
-6
```

### Subtraction

```lisp
; Two arguments
elisp> (- 10 3)
7

; Multiple arguments (left-associative)
elisp> (- 20 5 3 2)
10

; Single argument (identity)
elisp> (- 5)
5

; With floats
elisp> (- 10.5 2.3)
8.2
```

### Multiplication

```lisp
; No arguments - returns 1
elisp> (*)
1

; Single argument
elisp> (* 7)
7

; Multiple arguments
elisp> (* 2 3 4)
24

; With floats
elisp> (* 2.5 4)
10

; Zero multiplication
elisp> (* 5 0 10)
0
```

### Division

```lisp
; Two arguments
elisp> (/ 12 3)
4

; Multiple arguments (left-associative)
elisp> (/ 24 2 3)
4

; Floating-point division
elisp> (/ 7 2)
3.5

; Single argument (identity)
elisp> (/ 8)
8
```

### Complex Arithmetic

```lisp
; Nested operations
elisp> (+ (* 2 3) (/ 8 2))
10

elisp> (- (* 5 4) (+ 3 2))
15

elisp> (* (+ 1 2) (+ 3 4))
21

; Order of operations
elisp> (+ 1 (* 2 3) 4)
11

elisp> (/ (+ 10 5) (- 8 3))
3
```

## String Operations

### Basic String Usage

```lisp
elisp> "Simple string"
"Simple string"

elisp> "String with spaces"
"String with spaces"

elisp> "String with numbers 123"
"String with numbers 123"
```

### Escape Sequences

```lisp
; Newline
elisp> "First line\nSecond line"
"First line
Second line"

; Tab
elisp> "Column1\tColumn2\tColumn3"
"Column1	Column2	Column3"

; Carriage return
elisp> "Before\rAfter"
"Before
After"

; Quotes
elisp> "He said \"Hello\""
"He said "Hello""

; Backslash
elisp> "Path: C:\\Users\\Name"
"Path: C:\Users\Name"
```

### String Printing

```lisp
elisp> (print "Hello, World!")
Hello, World!
"Hello, World!"

elisp> (print "Line 1" "Line 2")
Line 1 Line 2
"Line 2"

elisp> (print "The answer is" 42)
The answer is 42
42
```

## List Operations

### Creating Lists

```lisp
; Quoted lists (not evaluated)
elisp> '(1 2 3)
LIST(null)

elisp> '(+ 1 2)
LIST(null)

elisp> '((nested) (lists) (here))
LIST(null)
```

### List Evaluation vs. Quotation

```lisp
; Evaluated list (function call)
elisp> (+ 1 2 3)
6

; Quoted list (data structure)
elisp> '(+ 1 2 3)
LIST(null)

; Nested evaluation
elisp> (+ (* 2 3) 4)
10

; Nested quotation
elisp> '(+ (* 2 3) 4)
LIST(null)
```

## Working with Quotes

### Quote Character

```lisp
; Quote symbol
elisp> 'hello
SYMBOL("hello")

; Quote number (returns the number)
elisp> '42
42

; Quote string (returns the string)
elisp> '"hello"
"hello"

; Quote list
elisp> '(1 2 3)
LIST(null)
```

### Quote vs. Evaluation

```lisp
; Without quote - evaluation
elisp> (+ 1 2)
3

; With quote - no evaluation
elisp> '(+ 1 2)
LIST(null)

; Nested quotes
elisp> ''hello
QUOTE(null)

; Quote complex expressions
elisp> '(if (> x 0) "positive" "negative")
LIST(null)
```

## Interactive REPL Sessions

### Basic Calculator Session

```lisp
elisp> (+ 10 5)
15

elisp> (- 20 7)
13

elisp> (* 6 8)
48

elisp> (/ 100 4)
25

elisp> (+ (* 3 4) (/ 20 5))
16
```

### Working with Variables (Conceptual)

```lisp
; Note: Variable definition not yet implemented in evaluator
; These show the expected syntax for future implementation

elisp> (define pi 3.14159)
; Would define pi as 3.14159

elisp> (define radius 5)
; Would define radius as 5

elisp> (* pi radius radius)
; Would calculate area: 78.53975
```

### String Processing Session

```lisp
elisp> (print "Starting calculation...")
Starting calculation...
"Starting calculation..."

elisp> (print "Result:" (+ 10 20))
Result: 30
30

elisp> (print "Done!")
Done!
"Done!"
```

### List Exploration Session

```lisp
elisp> '(apple banana cherry)
LIST(null)

elisp> '((fruits (apple banana)) (colors (red yellow)))
LIST(null)

elisp> '(1 (2 (3 (4 5))))
LIST(null)

elisp> (print "List created:" '(a b c))
List created: LIST(null)
LIST(null)
```

## Error Handling Examples

### Tokenizer Errors

```lisp
; Unterminated string
elisp> "hello world
Error: Unterminated string literal

; Invalid character
elisp> @symbol
Error: Unexpected character: '@' (64)

; Invalid number format
elisp> 3.14.15
Error: Invalid number: multiple decimal points
```

### Parser Errors

```lisp
; Unbalanced parentheses
elisp> (+ 1 2
Error: Expected ')' to close list started at line 1:1

elisp> (+ 1 2))
Error: Unexpected token: RPAREN ')'

; Empty input after quote
elisp> '
Error: Expected expression after quote
```

### Runtime Errors

```lisp
; Undefined variable
elisp> undefined-variable
Error: Undefined variable undefined-variable

; Non-function application
elisp> (42 1 2)
Error: Not a function: {"type":"NUMBER","value":42,"children":[],"sourceInfo":{"line":1,"column":2,"position":1}}

; Wrong number of arguments (for future special forms)
elisp> (if 1)
Error: 'if' requires 2 or 3 arguments, got 1
```

## Programming Patterns

### Nested Function Calls

```lisp
; Simple nesting
elisp> (+ (+ 1 2) (+ 3 4))
10

; Deep nesting
elisp> (+ (* (+ 1 2) (+ 3 4)) (/ (+ 10 5) (+ 2 3)))
24

; Mixed operations
elisp> (print (+ (* 2 3) (/ 8 2)))
10
10
```

### Data Structure Patterns

```lisp
; Representing coordinates
elisp> '(point (x 10) (y 20))
LIST(null)

; Representing a person
elisp> '(person (name "John") (age 30) (city "New York"))
LIST(null)

; Representing a tree structure
elisp> '(tree (value 1) (left (value 2)) (right (value 3)))
LIST(null)
```

### Mathematical Expressions

```lisp
; Quadratic formula components
elisp> (+ (* -1 4) (* 2 3))
2

; Distance formula (conceptual)
elisp> '(sqrt (+ (* (- x2 x1) (- x2 x1)) (* (- y2 y1) (- y2 y1))))
LIST(null)

; Factorial (conceptual recursive definition)
elisp> '(define factorial (lambda (n) (if (<= n 1) 1 (* n (factorial (- n 1))))))
LIST(null)
```

## Advanced Examples

### Complex Data Structures

```lisp
; Configuration object
elisp> '(config
          (database (host "localhost") (port 5432) (name "mydb"))
          (server (port 8080) (host "0.0.0.0"))
          (logging (level "info") (file "app.log")))
LIST(null)

; Abstract syntax tree representation
elisp> '(function-call
          (name "add")
          (arguments
            (number 1)
            (number 2)
            (variable "x")))
LIST(null)
```

### Lisp Code as Data

```lisp
; Representing Lisp code as data structures
elisp> '(defun square (x) (* x x))
LIST(null)

elisp> '(let ((x 10) (y 20)) (+ x y))
LIST(null)

elisp> '(cond
          ((< x 0) "negative")
          ((> x 0) "positive")
          (t "zero"))
LIST(null)
```

### Mathematical Computations

```lisp
; Complex arithmetic expressions
elisp> (+ (* 3 (+ 2 4)) (/ (* 5 6) 2))
33

; Percentage calculations
elisp> (/ (* 85 100) 200)
42.5

; Compound calculations
elisp> (* (+ 1 2 3) (- 10 4) (/ 8 2))
72
```

### String and Symbol Combinations

```lisp
; Mixed data types in lists
elisp> '("name" john "age" 25 "active" #t)
LIST(null)

; Symbolic expressions
elisp> '(and (> x 0) (< x 100))
LIST(null)

; Template-like structures
elisp> '(html
          (head (title "My Page"))
          (body
            (h1 "Welcome")
            (p "This is a paragraph")))
LIST(null)
```

### Debugging and Inspection

```lisp
; Using print for debugging
elisp> (print "Debug: calculating" (+ 5 3))
Debug: calculating 8
8

; Inspecting intermediate results
elisp> (print "Step 1:" (* 2 3))
Step 1: 6
6

elisp> (print "Step 2:" (+ 6 4))
Step 2: 10
10

; Tracing complex expressions
elisp> (print "Inner:" (+ 1 2) "Outer:" (* 3 4))
Inner: 3 Outer: 12
12
```

### Future Programming Constructs (Conceptual)

These examples show how future language features might be used:

```lisp
; Conditional expressions
elisp> (if (> 5 3) "yes" "no")
; Would return: "yes"

; Local variable binding
elisp> (let ((x 10) (y 20)) (+ x y))
; Would return: 30

; Function definition and application
elisp> (define square (lambda (x) (* x x)))
elisp> (square 5)
; Would return: 25

; Recursive functions
elisp> (define factorial
         (lambda (n)
           (if (<= n 1)
               1
               (* n (factorial (- n 1))))))
elisp> (factorial 5)
; Would return: 120

; List processing
elisp> (define length
         (lambda (lst)
           (if (null? lst)
               0
               (+ 1 (length (cdr lst))))))
elisp> (length '(a b c d))
; Would return: 4
```

## Tips for Effective Usage

### 1. Start Simple

Begin with basic expressions and gradually build complexity:

```lisp
elisp> 5
5
elisp> (+ 5 3)
8
elisp> (+ (* 2 3) 4)
10
```

### 2. Use Print for Debugging

```lisp
elisp> (print "Calculating:" (+ 10 (* 2 5)))
Calculating: 20
20
```

### 3. Experiment with Data Structures

```lisp
elisp> '(person "John" 30)
LIST(null)
elisp> '((x 1) (y 2) (z 3))
LIST(null)
```

### 4. Understand Evaluation vs. Quotation

```lisp
elisp> (+ 1 2)        ; Evaluates to 3
3
elisp> '(+ 1 2)       ; Returns the list structure
LIST(null)
```

### 5. Practice with Nested Expressions

```lisp
elisp> (+ (+ 1 2) (+ 3 4))
10
elisp> (* (+ 2 3) (- 8 3))
25
```

This examples document provides a comprehensive guide to using the Etherney Lisp Machine effectively, from basic operations to advanced programming patterns.