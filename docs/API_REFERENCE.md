# API Reference

This document provides comprehensive API documentation for all modules in the Etherney Lisp Machine.

## Table of Contents

- [Overview](#overview)
- [Tokenizer Module](#tokenizer-module)
- [Parser Module](#parser-module)
- [Evaluator Module](#evaluator-module)
- [Environment Module](#environment-module)
- [REPL Module](#repl-module)
- [Error Classes](#error-classes)
- [Utility Functions](#utility-functions)

## Overview

The Etherney Lisp Machine is organized into five core modules, each with specific responsibilities:

- **Tokenizer**: Lexical analysis and token generation
- **Parser**: Syntax analysis and AST construction
- **Evaluator**: Expression evaluation and execution
- **Environment**: Variable scope and binding management
- **REPL**: Interactive Read-Eval-Print Loop

## Tokenizer Module

**File**: [`src/tokenizer.js`](../src/tokenizer.js)

### Classes

#### `Token`

Represents a single token in the source code.

**Constructor**: `new Token(type, value, line, column, position)`

**Parameters**:
- `type` (string): Token type (`'NUMBER'`, `'STRING'`, `'SYMBOL'`, `'LPAREN'`, `'RPAREN'`, `'QUOTE'`, `'BOOLEAN'`, `'EOF'`)
- `value` (any): Token value
- `line` (number): Line number (1-based)
- `column` (number): Column number (1-based)
- `position` (number): Character position (0-based)

**Properties**:
- `type`: Token type
- `value`: Token value
- `line`: Source line number
- `column`: Source column number
- `position`: Character position in source

**Methods**:
- `toString()`: Returns string representation of token

**Example**:
```javascript
const token = new Token('NUMBER', 42, 1, 1, 0);
console.log(token.toString()); // "Token(NUMBER, 42, 1:1)"
```

#### `TokenizerError`

Error class for tokenization errors.

**Constructor**: `new TokenizerError(message, line, column, position)`

**Parameters**:
- `message` (string): Error message
- `line` (number): Line number where error occurred
- `column` (number): Column number where error occurred
- `position` (number): Character position where error occurred

**Properties**:
- `name`: Always `'TokenizerError'`
- `message`: Error message
- `line`: Source line number
- `column`: Source column number
- `position`: Character position

#### `LispTokenizer`

Main tokenizer class for converting source code into tokens.

**Constructor**: `new LispTokenizer(source)`

**Parameters**:
- `source` (string): Lisp source code to tokenize

**Properties**:
- `source`: Source code string
- `position`: Current character position
- `line`: Current line number
- `column`: Current column number
- `tokens`: Array of generated tokens
- `reservedWords`: Set of reserved Lisp keywords

**Methods**:

##### `tokenize()`
Tokenizes the entire source code and returns array of tokens.

**Returns**: `Token[]` - Array of tokens including EOF token

**Throws**: `TokenizerError` - On invalid syntax

**Example**:
```javascript
const tokenizer = new LispTokenizer('(+ 1 2)');
const tokens = tokenizer.tokenize();
// Returns: [LPAREN, SYMBOL(+), NUMBER(1), NUMBER(2), RPAREN, EOF]
```

##### `nextToken()`
Gets the next token from the source.

**Returns**: `Token | null` - Next token or null if at end

**Throws**: `TokenizerError` - On invalid syntax

##### `getTokensAsString()`
Returns string representation of all tokens.

**Returns**: `string` - Formatted token list

##### `getSourceLocation(position)`
Gets line and column for a character position.

**Parameters**:
- `position` (number): Character position

**Returns**: `{line: number, column: number}` - Source location

**Static Methods**:

##### `LispTokenizer.isReservedWord(symbol)`
Checks if a symbol is a reserved word.

**Parameters**:
- `symbol` (string): Symbol to check

**Returns**: `boolean` - True if reserved word

##### `LispTokenizer.tokenTypeToString(type)`
Converts token type to human-readable string.

**Parameters**:
- `type` (string): Token type

**Returns**: `string` - Human-readable type name

### Token Types

| Type | Description | Example |
|------|-------------|---------|
| `NUMBER` | Integer or floating-point number | `42`, `3.14`, `-17` |
| `STRING` | String literal with escape sequences | `"hello"`, `"line\n"` |
| `SYMBOL` | Identifier or operator | `foo`, `+`, `my-var` |
| `LPAREN` | Left parenthesis | `(` |
| `RPAREN` | Right parenthesis | `)` |
| `QUOTE` | Quote character | `'` |
| `BOOLEAN` | Boolean literal | `#t`, `#f` |
| `EOF` | End of file marker | (automatic) |

## Parser Module

**File**: [`src/parser.js`](../src/parser.js)

### Classes

#### `ParseError`

Error class for parsing errors.

**Constructor**: `new ParseError(message, token, expected)`

**Parameters**:
- `message` (string): Error message
- `token` (Token, optional): Token where error occurred
- `expected` (string[], optional): Expected token types

**Properties**:
- `name`: Always `'ParseError'`
- `message`: Error message
- `token`: Token where error occurred
- `expected`: Array of expected token types
- `line`: Source line number (from token)
- `column`: Source column number (from token)
- `position`: Character position (from token)

**Methods**:
- `toString()`: Returns formatted error message with location

#### `ASTNode`

Represents a node in the Abstract Syntax Tree.

**Constructor**: `new ASTNode(type, value, children, sourceInfo)`

**Parameters**:
- `type` (string): Node type (`'NUMBER'`, `'STRING'`, `'SYMBOL'`, `'LIST'`, `'QUOTE'`, `'BOOLEAN'`)
- `value` (any): Node value
- `children` (ASTNode[], optional): Child nodes (default: `[]`)
- `sourceInfo` (object, optional): Source location info `{line, column, position}`

**Properties**:
- `type`: Node type
- `value`: Node value
- `children`: Array of child nodes
- `sourceInfo`: Source location information

**Methods**:

##### `toString()`
Returns string representation of node.

**Returns**: `string` - Node description

##### `toSExpression()`
Converts AST node back to Lisp S-expression string.

**Returns**: `string` - S-expression representation

**Example**:
```javascript
const node = new ASTNode('NUMBER', 42, [], {line: 1, column: 1, position: 0});
console.log(node.toSExpression()); // "42"
```

#### `LispParser`

Main parser class for converting tokens into Abstract Syntax Trees.

**Constructor**: `new LispParser(source)`

**Parameters**:
- `source` (string): Lisp source code to parse

**Properties**:
- `source`: Source code string
- `tokenizer`: LispTokenizer instance
- `tokens`: Array of tokens
- `current`: Current token index
- `parenStack`: Stack for tracking parentheses
- `specialForms`: Set of special form names

**Methods**:

##### `parse()`
Parses the source code into an AST.

**Returns**: `ASTNode[]` - Array of top-level AST nodes

**Throws**: `ParseError` - On invalid syntax

**Example**:
```javascript
const parser = new LispParser('(+ 1 2)');
const ast = parser.parse();
// Returns array with one LIST node containing SYMBOL(+), NUMBER(1), NUMBER(2)
```

##### `parseExpression()`
Parses a single expression.

**Returns**: `ASTNode | null` - AST node or null if at end

**Throws**: `ParseError` - On invalid syntax

##### `getParseTree(expressions)`
Returns formatted string representation of AST.

**Parameters**:
- `expressions` (ASTNode[]): Array of AST nodes

**Returns**: `string` - Formatted parse tree

##### `astToString(node, depth)`
Converts AST node to indented string representation.

**Parameters**:
- `node` (ASTNode): AST node to convert
- `depth` (number, optional): Indentation depth (default: 0)

**Returns**: `string` - Formatted node representation

**Static Methods**:

##### `LispParser.parseString(source)`
Convenience method to parse source code.

**Parameters**:
- `source` (string): Source code to parse

**Returns**: `ASTNode[]` - Array of AST nodes

##### `LispParser.validateSyntax(source)`
Validates source code syntax without full parsing.

**Parameters**:
- `source` (string): Source code to validate

**Returns**: `{valid: boolean, errors: string[], error?: Error}` - Validation result

##### `LispParser.astToLisp(expressions)`
Converts AST back to Lisp source code.

**Parameters**:
- `expressions` (ASTNode | ASTNode[]): AST nodes to convert

**Returns**: `string` - Lisp source code

##### `LispParser.extractSymbols(expressions)`
Extracts all symbols from AST.

**Parameters**:
- `expressions` (ASTNode | ASTNode[]): AST nodes to analyze

**Returns**: `string[]` - Array of symbol names

##### `LispParser.extractFunctionDefinitions(expressions)`
Finds all function definitions in AST.

**Parameters**:
- `expressions` (ASTNode | ASTNode[]): AST nodes to analyze

**Returns**: `Array<{name: string, type: string, node: ASTNode, sourceInfo: object}>` - Function definitions

### AST Node Types

| Type | Description | Value | Children |
|------|-------------|-------|----------|
| `NUMBER` | Numeric literal | Number value | None |
| `STRING` | String literal | String value | None |
| `SYMBOL` | Symbol/identifier | Symbol name | None |
| `BOOLEAN` | Boolean literal | Boolean value | None |
| `LIST` | S-expression | `null` | Expression elements |
| `QUOTE` | Quoted expression | `null` | Single quoted element |

## Evaluator Module

**File**: [`src/evaluator.js`](../src/evaluator.js)

### Functions

#### `evalNode(node, env)`
Evaluates an AST node in the given environment.

**Parameters**:
- `node` (ASTNode): AST node to evaluate
- `env` (Environment): Evaluation environment

**Returns**: `any` - Evaluation result

**Throws**: `Error` - On evaluation errors

**Example**:
```javascript
const env = createGlobalEnv();
const result = evalNode(numberNode, env); // Returns the number value
```

#### `evalList(list, env)`
Evaluates a list as a function application.

**Parameters**:
- `list` (ASTNode[]): Array of AST nodes representing function and arguments
- `env` (Environment): Evaluation environment

**Returns**: `any` - Function application result

**Throws**: `Error` - If first element is not a function

#### `createGlobalEnv()`
Creates the global environment with built-in functions.

**Returns**: `Environment` - Global environment with built-ins

**Built-in Functions**:
- `+`: Addition (variadic)
- `-`: Subtraction (variadic)
- `*`: Multiplication (variadic)
- `/`: Division (variadic)
- `print`: Print values and return last argument

**Example**:
```javascript
const env = createGlobalEnv();
// env now contains +, -, *, /, print functions
```

#### `isList(node)`
Checks if an AST node represents a list.

**Parameters**:
- `node` (ASTNode): Node to check

**Returns**: `boolean` - True if node is a list

## Environment Module

**File**: [`src/environment.js`](../src/environment.js)

### Classes

#### `Environment`

Manages variable bindings and lexical scoping.

**Constructor**: `new Environment(parent)`

**Parameters**:
- `parent` (Environment, optional): Parent environment for scoping

**Properties**:
- `vars`: Map of variable names to values
- `parent`: Parent environment (for lexical scoping)

**Methods**:

##### `define(name, value)`
Defines a new variable in this environment.

**Parameters**:
- `name` (string): Variable name
- `value` (any): Variable value

**Example**:
```javascript
const env = new Environment();
env.define('x', 42);
```

##### `set(name, value)`
Sets the value of an existing variable.

**Parameters**:
- `name` (string): Variable name
- `value` (any): New variable value

**Throws**: `ReferenceError` - If variable is not defined

**Example**:
```javascript
env.define('x', 42);
env.set('x', 100); // Changes x to 100
```

##### `get(name)`
Gets the value of a variable.

**Parameters**:
- `name` (string): Variable name

**Returns**: `any` - Variable value

**Throws**: `ReferenceError` - If variable is not defined

**Example**:
```javascript
env.define('x', 42);
const value = env.get('x'); // Returns 42
```

### Scoping Rules

The Environment class implements lexical scoping:

1. Variable lookup starts in the current environment
2. If not found, searches parent environments
3. Continues up the chain until found or root is reached
4. Throws `ReferenceError` if variable is not found

**Example**:
```javascript
const global = new Environment();
global.define('x', 'global');

const local = new Environment(global);
local.define('y', 'local');

console.log(local.get('x')); // 'global' (from parent)
console.log(local.get('y')); // 'local' (from current)
```

## REPL Module

**File**: [`src/repl.js`](../src/repl.js)

### Overview

The REPL module provides an interactive Read-Eval-Print Loop interface using Node.js's `readline` module.

### Components

#### Global Environment
```javascript
const env = createGlobalEnv();
```
Creates a global environment with built-in functions.

#### Readline Interface
```javascript
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "elisp> "
});
```
Sets up interactive input/output with custom prompt.

#### Main Loop
The REPL processes each line of input through the complete interpretation pipeline:

1. **Tokenization**: `new LispTokenizer(line).tokenize()`
2. **Parsing**: `parseTokens(tokens)`
3. **Evaluation**: `ast.map(node => evalNode(node, env))`
4. **Output**: Displays the result of the last expression

#### Error Handling
All errors are caught and displayed with descriptive messages:
```javascript
try {
    // Interpretation pipeline
} catch (err) {
    console.error("Error:", err.message);
}
```

### Usage

Start the REPL:
```bash
node index.js
```

Interactive session:
```
elisp> (+ 1 2 3)
6
elisp> (print "Hello, World!")
Hello, World!
"Hello, World!"
elisp> (* (+ 2 3) 4)
20
```

Exit with `Ctrl+C` or `Ctrl+D`.

## Error Classes

### Error Hierarchy

```
Error
├── TokenizerError    (Lexical analysis errors)
├── ParseError        (Syntax analysis errors)
├── ReferenceError    (Variable lookup errors)
└── TypeError         (Type-related errors)
```

### Common Error Scenarios

#### Tokenizer Errors
- Unterminated strings: `"hello`
- Invalid characters: `@invalid`
- Malformed numbers: `3.14.15`

#### Parser Errors
- Unbalanced parentheses: `(+ 1 2`
- Invalid special forms: `(if 1)`
- Unexpected tokens: `(+ 1 2))`

#### Runtime Errors
- Undefined variables: `undefined-var`
- Non-function application: `(42 1 2)`
- Type mismatches: Function-specific errors

## Utility Functions

### Token Utilities

#### `parseTokens(tokens)`
**File**: [`src/parser.js`](../src/parser.js)

Parses an array of tokens into AST nodes.

**Parameters**:
- `tokens` (Token[]): Array of tokens to parse

**Returns**: `ASTNode[]` - Array of AST nodes

**Example**:
```javascript
const tokenizer = new LispTokenizer('(+ 1 2)');
const tokens = tokenizer.tokenize();
const ast = parseTokens(tokens);
```

### Type Checking

#### `isList(node)`
**File**: [`src/evaluator.js`](../src/evaluator.js)

Checks if an AST node represents a list.

**Parameters**:
- `node` (ASTNode): Node to check

**Returns**: `boolean` - True if node is a LIST type

### Static Analysis

The parser provides several static analysis utilities:

- `extractSymbols()`: Find all symbols in AST
- `extractFunctionDefinitions()`: Find function definitions
- `validateSyntax()`: Validate syntax without evaluation

These utilities are useful for:
- Code analysis tools
- Syntax highlighting
- Refactoring tools
- Educational purposes

## Module Exports

### Tokenizer Module
```javascript
module.exports = {
    LispTokenizer,
    Token,
    TokenizerError
};
```

### Parser Module
```javascript
module.exports = {
    LispParser,
    ParseError,
    ASTNode
};
```

### Evaluator Module
```javascript
module.exports = { 
    evalNode, 
    createGlobalEnv 
};
```

### Environment Module
```javascript
module.exports = Environment;
```

This API reference provides complete documentation for integrating with and extending the Etherney Lisp Machine.