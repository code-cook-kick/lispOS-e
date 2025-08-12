# User Guide

This guide provides comprehensive documentation for using the Etherney Lisp Machine, including language syntax, built-in functions, and programming examples.

## Table of Contents

- [Getting Started](#getting-started)
- [Language Syntax](#language-syntax)
- [Data Types](#data-types)
- [Built-in Functions](#built-in-functions)
- [Special Forms](#special-forms)
- [Programming Concepts](#programming-concepts)
- [Error Messages](#error-messages)
- [Tips and Best Practices](#tips-and-best-practices)

## Getting Started

### Starting the REPL

```bash
node index.js
```

You'll see the interactive prompt:
```
elisp> 
```

### Your First Expressions

```lisp
elisp> 42
42

elisp> "Hello, World!"
"Hello, World!"

elisp> (+ 1 2 3)
6

elisp> (print "Welcome to Lisp!")
Welcome to Lisp!
"Welcome to Lisp!"
```

### Exiting the REPL

Press `Ctrl+C` or `Ctrl+D` to exit the REPL.

## Language Syntax

### S-Expressions

Lisp uses S-expressions (symbolic expressions) as its primary syntax. Everything is either an atom or a list:

```lisp
; Atoms
42
"hello"
symbol

; Lists (parenthesized expressions)
(+ 1 2)
(print "Hello")
(list 1 2 3)
```

### Comments

Use semicolons for comments:

```lisp
; This is a comment
(+ 1 2) ; This is also a comment
```

### Whitespace

Whitespace (spaces, tabs, newlines) is used to separate tokens but is otherwise ignored:

```lisp
(+ 1 2)
(+
  1
  2)
(+    1    2    )
```

All of these are equivalent.

## Data Types

### Numbers

The interpreter supports both integers and floating-point numbers:

```lisp
elisp> 42
42

elisp> -17
-17

elisp> 3.14159
3.14159

elisp> -2.5
-2.5
```

### Strings

String literals are enclosed in double quotes and support escape sequences:

```lisp
elisp> "Hello, World!"
"Hello, World!"

elisp> "Line 1\nLine 2"
"Line 1
Line 2"

elisp> "Quote: \"Hello\""
"Quote: "Hello""

elisp> "Tab\tSeparated\tValues"
"Tab	Separated	Values"
```

**Supported Escape Sequences:**
- `\n` - Newline
- `\t` - Tab
- `\r` - Carriage return
- `\\` - Backslash
- `\"` - Double quote
- `\'` - Single quote

### Symbols

Symbols are identifiers used for variables and function names:

```lisp
elisp> 'hello
SYMBOL("hello")

elisp> 'my-variable
SYMBOL("my-variable")

elisp> '+
SYMBOL("+")
```

**Valid Symbol Characters:**
- Letters: `a-z`, `A-Z`
- Digits: `0-9` (not at the beginning)
- Special characters: `+ - * / < > = ! ? _ $ % & ^ ~ | . -`

### Lists

Lists are the fundamental data structure in Lisp:

```lisp
elisp> '(1 2 3)
LIST(null)

elisp> '(hello world)
LIST(null)

elisp> '(+ 1 2)
LIST(null)

elisp> '((nested list) here)
LIST(null)
```

### Booleans

Boolean values are represented as `#t` (true) and `#f` (false):

```lisp
elisp> #t
true

elisp> #f
false
```

### Quotes

The quote character `'` prevents evaluation:

```lisp
elisp> (+ 1 2)
3

elisp> '(+ 1 2)
LIST(null)

elisp> 'symbol
SYMBOL("symbol")
```

## Built-in Functions

### Arithmetic Functions

#### Addition (`+`)
Adds all arguments together. With no arguments, returns 0.

```lisp
elisp> (+)
0

elisp> (+ 5)
5

elisp> (+ 1 2 3 4)
10

elisp> (+ 1.5 2.5)
4
```

#### Subtraction (`-`)
Subtracts subsequent arguments from the first argument.

```lisp
elisp> (- 10 3)
7

elisp> (- 10 3 2)
5

elisp> (- 5)
5
```

#### Multiplication (`*`)
Multiplies all arguments together. With no arguments, returns 1.

```lisp
elisp> (*)
1

elisp> (* 3)
3

elisp> (* 2 3 4)
24

elisp> (* 2.5 4)
10
```

#### Division (`/`)
Divides the first argument by subsequent arguments.

```lisp
elisp> (/ 10 2)
5

elisp> (/ 20 4 2)
2.5

elisp> (/ 7 2)
3.5
```

### I/O Functions

#### Print (`print`)
Prints all arguments to the console and returns the last argument.

```lisp
elisp> (print "Hello")
Hello
"Hello"

elisp> (print 1 2 3)
1 2 3
3

elisp> (print "The answer is" 42)
The answer is 42
42
```

## Special Forms

Special forms are expressions that have special evaluation rules and are recognized by the parser.

### Conditional Forms

#### `if`
Conditional expression with optional else clause.

**Syntax:** `(if condition then-expr [else-expr])`

```lisp
; Note: Full if implementation not yet available in evaluator
; This shows the expected syntax
(if #t "true branch" "false branch")
(if (> 5 3) "yes" "no")
```

#### `cond`
Multi-way conditional expression.

**Syntax:** `(cond (condition1 result1) (condition2 result2) ...)`

```lisp
; Note: Full cond implementation not yet available in evaluator
; This shows the expected syntax
(cond
  ((< x 0) "negative")
  ((> x 0) "positive")
  (#t "zero"))
```

### Variable Binding

#### `let`
Creates local variable bindings.

**Syntax:** `(let ((var1 value1) (var2 value2) ...) body...)`

```lisp
; Note: Full let implementation not yet available in evaluator
; This shows the expected syntax
(let ((x 10) (y 20))
  (+ x y))
```

#### `define`
Defines a global variable or function.

**Syntax:** 
- `(define variable value)`
- `(define (function-name params...) body...)`

```lisp
; Note: Full define implementation not yet available in evaluator
; This shows the expected syntax
(define pi 3.14159)
(define (square x) (* x x))
```

### Function Definition

#### `lambda`
Creates anonymous functions.

**Syntax:** `(lambda (params...) body...)`

```lisp
; Note: Full lambda implementation not yet available in evaluator
; This shows the expected syntax
(lambda (x) (* x x))
(lambda (x y) (+ x y))
```

#### `defun`
Defines named functions (alternative to define).

**Syntax:** `(defun name (params...) body...)`

```lisp
; Note: Full defun implementation not yet available in evaluator
; This shows the expected syntax
(defun factorial (n)
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))
```

### Quotation

#### `quote`
Prevents evaluation of its argument.

**Syntax:** `(quote expr)` or `'expr`

```lisp
elisp> (quote (+ 1 2))
LIST(null)

elisp> '(+ 1 2)
LIST(null)

elisp> (quote hello)
SYMBOL("hello")

elisp> 'hello
SYMBOL("hello")
```

### Logical Operations

#### `and`
Logical AND operation.

```lisp
; Note: Full and implementation not yet available in evaluator
; This shows the expected syntax
(and #t #t)     ; => #t
(and #t #f)     ; => #f
(and)           ; => #t
```

#### `or`
Logical OR operation.

```lisp
; Note: Full or implementation not yet available in evaluator
; This shows the expected syntax
(or #f #t)      ; => #t
(or #f #f)      ; => #f
(or)            ; => #f
```

#### `not`
Logical NOT operation.

```lisp
; Note: Full not implementation not yet available in evaluator
; This shows the expected syntax
(not #t)        ; => #f
(not #f)        ; => #t
```

## Programming Concepts

### Expression Evaluation

In Lisp, everything is an expression that evaluates to a value:

```lisp
elisp> 42                    ; Number evaluates to itself
42

elisp> "hello"               ; String evaluates to itself
"hello"

elisp> (+ 1 2)              ; List evaluates by applying function
3

elisp> '(+ 1 2)             ; Quoted list evaluates to the list itself
LIST(null)
```

### Function Application

Function application follows the pattern `(function arg1 arg2 ...)`:

```lisp
elisp> (+ 1 2 3)            ; Apply + to arguments 1, 2, 3
6

elisp> (print "Hello" "World")  ; Apply print to two string arguments
Hello World
"World"

elisp> (* (+ 1 2) (+ 3 4))  ; Nested function applications
21
```

### Nested Expressions

Expressions can be nested to arbitrary depth:

```lisp
elisp> (+ (* 2 3) (/ 8 2))
10

elisp> (print (+ 1 2) (* 3 4))
3 12
12
```

## Error Messages

### Tokenizer Errors

**Unterminated String:**
```lisp
elisp> "hello
Error: Unterminated string literal
```

**Invalid Character:**
```lisp
elisp> @invalid
Error: Unexpected character: '@' (64)
```

**Invalid Number:**
```lisp
elisp> 3.14.15
Error: Invalid number: multiple decimal points
```

### Parser Errors

**Unbalanced Parentheses:**
```lisp
elisp> (+ 1 2
Error: Expected ')' to close list started at line 1:1

elisp> (+ 1 2))
Error: Unexpected token: RPAREN ')'
```

**Invalid Special Form:**
```lisp
elisp> (if 1)
Error: 'if' requires 2 or 3 arguments, got 1
```

### Runtime Errors

**Undefined Variable:**
```lisp
elisp> undefined-var
Error: Undefined variable undefined-var
```

**Not a Function:**
```lisp
elisp> (42 1 2)
Error: Not a function: {"type":"NUMBER","value":42,"children":[],"sourceInfo":{"line":1,"column":2,"position":1}}
```

## Tips and Best Practices

### 1. Use Meaningful Names

```lisp
; Good
(define radius 5)
(define (circle-area r) (* pi r r))

; Less clear
(define r 5)
(define (f x) (* 3.14 x x))
```

### 2. Consistent Indentation

```lisp
; Good
(if (> x 0)
    (print "positive")
    (print "not positive"))

; Less readable
(if (> x 0) (print "positive") (print "not positive"))
```

### 3. Use Comments

```lisp
; Calculate the factorial of n
(defun factorial (n)
  (if (<= n 1)
      1                    ; Base case
      (* n (factorial (- n 1)))))  ; Recursive case
```

### 4. Break Down Complex Expressions

```lisp
; Instead of:
(+ (* (+ 1 2) (+ 3 4)) (/ (+ 5 6) (+ 7 8)))

; Consider:
(let ((first-part (* (+ 1 2) (+ 3 4)))
      (second-part (/ (+ 5 6) (+ 7 8))))
  (+ first-part second-part))
```

### 5. Test Incrementally

Build and test your programs incrementally in the REPL:

```lisp
elisp> (+ 1 2)              ; Test basic operations first
3

elisp> (* (+ 1 2) 4)        ; Then build complexity
12

elisp> (print (* (+ 1 2) 4)) ; Add side effects
12
12
```

### 6. Understand Evaluation Order

Remember that Lisp evaluates arguments before applying functions:

```lisp
elisp> (print (+ 1 2) (* 3 4))
; First evaluates (+ 1 2) => 3
; Then evaluates (* 3 4) => 12
; Finally applies print to 3 and 12
3 12
12
```

This guide covers the current functionality of the Etherney Lisp Machine. As new features are added, this documentation will be updated accordingly.