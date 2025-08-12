/**
 * Etherney Lisp Machine - Parser
 * 
 * Parses tokenized Lisp source code into Abstract Syntax Trees (ASTs).
 * Implements recursive descent parsing for S-expressions with comprehensive error handling.
 * 
 * Features:
 * - Recursive descent parsing for nested S-expressions
 * - Proper error handling for malformed syntax and unbalanced parentheses
 * - Support for quotes, comments, and all Lisp data types
 * - Source location tracking for debugging
 * - Special form recognition and validation
 */

const { LispTokenizer, Token, TokenizerError } = require('./tokenizer');

class ParseError extends Error {
    constructor(message, token = null, expected = null) {
        super(message);
        this.name = 'ParseError';
        this.token = token;
        this.expected = expected;
        
        if (token) {
            this.line = token.line;
            this.column = token.column;
            this.position = token.position;
        }
    }

    toString() {
        if (this.token) {
            return `ParseError at ${this.line}:${this.column}: ${this.message}`;
        }
        return `ParseError: ${this.message}`;
    }
}

class ASTNode {
    constructor(type, value, children = [], sourceInfo = null) {
        this.type = type;
        this.value = value;
        this.children = children;
        this.sourceInfo = sourceInfo; // { line, column, position }
    }

    toString() {
        return `${this.type}(${this.value})`;
    }

    toSExpression() {
        switch (this.type) {
            case 'NUMBER':
            case 'SYMBOL':
                return this.value;
            case 'STRING':
                return `"${this.value}"`;
            case 'BOOLEAN':
                return this.value ? '#t' : '#f';
            case 'LIST':
                return `(${this.children.map(child => child.toSExpression()).join(' ')})`;
            case 'QUOTE':
                return `'${this.children[0].toSExpression()}`;
            default:
                return this.value;
        }
    }
}

class LispParser {
    constructor(source) {
        this.source = source;
        this.tokenizer = new LispTokenizer(source);
        this.tokens = [];
        this.current = 0;
        this.parenStack = []; // Track parentheses for better error messages
        
        // Special forms that have unique parsing rules
        this.specialForms = new Set([
            'if', 'cond', 'let', 'lambda', 'define', 'quote',
            'defrule', 'fact', 'query', 'and', 'or', 'not',
            'defun', 'defmacro', 'setq', 'progn', 'when', 'unless'
        ]);
    }

    /**
     * Parse the source code into an AST
     */
    parse() {
        try {
            // Tokenize first
            this.tokens = this.tokenizer.tokenize();
            this.current = 0;
            this.parenStack = [];

            const expressions = [];
            
            while (!this.isAtEnd()) {
                if (this.peek().type === 'EOF') {
                    break;
                }
                
                const expr = this.parseExpression();
                if (expr) {
                    expressions.push(expr);
                }
            }

            // Check for unbalanced parentheses
            if (this.parenStack.length > 0) {
                const unclosed = this.parenStack[this.parenStack.length - 1];
                throw new ParseError(
                    `Unbalanced parentheses: unclosed '(' at line ${unclosed.line}:${unclosed.column}`,
                    unclosed
                );
            }

            return expressions;
            
        } catch (error) {
            if (error instanceof TokenizerError) {
                throw new ParseError(`Tokenization error: ${error.message}`, null);
            }
            throw error;
        }
    }

    /**
     * Parse a single expression
     */
    parseExpression() {
        const token = this.peek();
        
        switch (token.type) {
            case 'NUMBER':
                return this.parseNumber();
            case 'STRING':
                return this.parseString();
            case 'SYMBOL':
                return this.parseSymbol();
            case 'BOOLEAN':
                return this.parseBoolean();
            case 'LPAREN':
                return this.parseList();
            case 'QUOTE':
                return this.parseQuote();
            case 'EOF':
                return null;
            default:
                throw new ParseError(
                    `Unexpected token: ${token.type} '${token.value}'`,
                    token,
                    ['NUMBER', 'STRING', 'SYMBOL', 'BOOLEAN', 'LPAREN', 'QUOTE']
                );
        }
    }

    /**
     * Parse a number literal
     */
    parseNumber() {
        const token = this.advance();
        return new ASTNode(
            'NUMBER',
            token.value,
            [],
            { line: token.line, column: token.column, position: token.position }
        );
    }

    /**
     * Parse a string literal
     */
    parseString() {
        const token = this.advance();
        return new ASTNode(
            'STRING',
            token.value,
            [],
            { line: token.line, column: token.column, position: token.position }
        );
    }

    /**
     * Parse a symbol
     */
    parseSymbol() {
        const token = this.advance();
        
        // Validate symbol if it's a special form
        if (this.specialForms.has(token.value)) {
            // Special forms are valid symbols but may have special parsing rules
            // when they appear as the first element of a list
        }
        
        return new ASTNode(
            'SYMBOL',
            token.value,
            [],
            { line: token.line, column: token.column, position: token.position }
        );
    }

    /**
     * Parse a boolean literal
     */
    parseBoolean() {
        const token = this.advance();
        return new ASTNode(
            'BOOLEAN',
            token.value,
            [],
            { line: token.line, column: token.column, position: token.position }
        );
    }

    /**
     * Parse a list (S-expression)
     */
    parseList() {
        const openParen = this.advance(); // Consume '('
        this.parenStack.push(openParen);
        
        const children = [];
        let isSpecialForm = false;
        let specialFormName = null;
        
        // Parse list elements
        while (!this.isAtEnd() && this.peek().type !== 'RPAREN') {
            const expr = this.parseExpression();
            if (expr) {
                children.push(expr);
                
                // Check if first element is a special form
                if (children.length === 1 && expr.type === 'SYMBOL' && this.specialForms.has(expr.value)) {
                    isSpecialForm = true;
                    specialFormName = expr.value;
                }
            }
        }
        
        // Expect closing parenthesis
        if (this.isAtEnd() || this.peek().type !== 'RPAREN') {
            throw new ParseError(
                `Expected ')' to close list started at line ${openParen.line}:${openParen.column}`,
                this.peek(),
                ['RPAREN']
            );
        }
        
        const closeParen = this.advance(); // Consume ')'
        this.parenStack.pop();
        
        // Validate special forms
        if (isSpecialForm) {
            this.validateSpecialForm(specialFormName, children, openParen);
        }
        
        return new ASTNode(
            'LIST',
            null,
            children,
            { line: openParen.line, column: openParen.column, position: openParen.position }
        );
    }

    /**
     * Parse a quoted expression
     */
    parseQuote() {
        const quoteToken = this.advance(); // Consume '
        
        const quotedExpr = this.parseExpression();
        if (!quotedExpr) {
            throw new ParseError(
                'Expected expression after quote',
                this.peek(),
                ['NUMBER', 'STRING', 'SYMBOL', 'LPAREN']
            );
        }
        
        return new ASTNode(
            'QUOTE',
            null,
            [quotedExpr],
            { line: quoteToken.line, column: quoteToken.column, position: quoteToken.position }
        );
    }

    /**
     * Validate special form syntax
     */
    validateSpecialForm(formName, children, sourceToken) {
        const argCount = children.length - 1; // Subtract 1 for the form name itself
        
        switch (formName) {
            case 'if':
                if (argCount < 2 || argCount > 3) {
                    throw new ParseError(
                        `'if' requires 2 or 3 arguments, got ${argCount}`,
                        sourceToken
                    );
                }
                break;
                
            case 'cond':
                if (argCount === 0) {
                    throw new ParseError(
                        `'cond' requires at least one clause`,
                        sourceToken
                    );
                }
                // Validate that each clause is a list
                for (let i = 1; i < children.length; i++) {
                    if (children[i].type !== 'LIST') {
                        throw new ParseError(
                            `'cond' clause must be a list, got ${children[i].type}`,
                            sourceToken
                        );
                    }
                }
                break;
                
            case 'let':
                if (argCount < 2) {
                    throw new ParseError(
                        `'let' requires at least 2 arguments (bindings and body), got ${argCount}`,
                        sourceToken
                    );
                }
                // First argument should be a list of bindings
                if (children[1].type !== 'LIST') {
                    throw new ParseError(
                        `'let' bindings must be a list, got ${children[1].type}`,
                        sourceToken
                    );
                }
                break;
                
            case 'lambda':
                if (argCount < 2) {
                    throw new ParseError(
                        `'lambda' requires at least 2 arguments (parameters and body), got ${argCount}`,
                        sourceToken
                    );
                }
                // First argument should be a list of parameters
                if (children[1].type !== 'LIST') {
                    throw new ParseError(
                        `'lambda' parameters must be a list, got ${children[1].type}`,
                        sourceToken
                    );
                }
                break;
                
            case 'define':
            case 'defun':
                if (argCount < 2) {
                    throw new ParseError(
                        `'${formName}' requires at least 2 arguments, got ${argCount}`,
                        sourceToken
                    );
                }
                break;
                
            case 'quote':
                if (argCount !== 1) {
                    throw new ParseError(
                        `'quote' requires exactly 1 argument, got ${argCount}`,
                        sourceToken
                    );
                }
                break;
                
            case 'defrule':
                if (argCount < 3) {
                    throw new ParseError(
                        `'defrule' requires at least 3 arguments (name, condition, result), got ${argCount}`,
                        sourceToken
                    );
                }
                // Rule name should be a symbol
                if (children[1].type !== 'SYMBOL') {
                    throw new ParseError(
                        `'defrule' name must be a symbol, got ${children[1].type}`,
                        sourceToken
                    );
                }
                break;
                
            case 'fact':
                if (argCount !== 1) {
                    throw new ParseError(
                        `'fact' requires exactly 1 argument, got ${argCount}`,
                        sourceToken
                    );
                }
                break;
                
            case 'query':
                if (argCount !== 1) {
                    throw new ParseError(
                        `'query' requires exactly 1 argument, got ${argCount}`,
                        sourceToken
                    );
                }
                break;
                
            case 'and':
            case 'or':
                // and/or can have zero or more arguments
                break;
                
            case 'not':
                if (argCount !== 1) {
                    throw new ParseError(
                        `'not' requires exactly 1 argument, got ${argCount}`,
                        sourceToken
                    );
                }
                break;
        }
    }

    /**
     * Navigation and utility methods
     */
    isAtEnd() {
        return this.current >= this.tokens.length || this.peek().type === 'EOF';
    }

    peek() {
        if (this.current >= this.tokens.length) {
            return new Token('EOF', null, 0, 0, 0);
        }
        return this.tokens[this.current];
    }

    peekNext() {
        if (this.current + 1 >= this.tokens.length) {
            return new Token('EOF', null, 0, 0, 0);
        }
        return this.tokens[this.current + 1];
    }

    advance() {
        if (!this.isAtEnd()) {
            this.current++;
        }
        return this.tokens[this.current - 1];
    }

    previous() {
        return this.tokens[this.current - 1];
    }

    /**
     * Utility methods for debugging and analysis
     */
    getParseTree(expressions) {
        return expressions.map(expr => this.astToString(expr, 0)).join('\n\n');
    }

    astToString(node, depth = 0) {
        const indent = '  '.repeat(depth);
        let result = `${indent}${node.type}`;
        
        if (node.value !== null && node.value !== undefined) {
            result += `: ${JSON.stringify(node.value)}`;
        }
        
        if (node.sourceInfo) {
            result += ` [${node.sourceInfo.line}:${node.sourceInfo.column}]`;
        }
        
        if (node.children.length > 0) {
            result += '\n' + node.children.map(child => this.astToString(child, depth + 1)).join('\n');
        }
        
        return result;
    }

    /**
     * Static utility methods
     */
    static parseString(source) {
        const parser = new LispParser(source);
        return parser.parse();
    }

    static validateSyntax(source) {
        try {
            const parser = new LispParser(source);
            parser.parse();
            return { valid: true, errors: [] };
        } catch (error) {
            return { 
                valid: false, 
                errors: [error.message],
                error: error
            };
        }
    }

    /**
     * Convert AST back to Lisp source code
     */
    static astToLisp(expressions) {
        if (!Array.isArray(expressions)) {
            expressions = [expressions];
        }
        return expressions.map(expr => expr.toSExpression()).join('\n');
    }

    /**
     * Extract all symbols from an AST
     */
    static extractSymbols(expressions) {
        const symbols = new Set();
        
        function traverse(node) {
            if (node.type === 'SYMBOL') {
                symbols.add(node.value);
            }
            for (const child of node.children) {
                traverse(child);
            }
        }
        
        if (!Array.isArray(expressions)) {
            expressions = [expressions];
        }
        
        for (const expr of expressions) {
            traverse(expr);
        }
        
        return Array.from(symbols);
    }

    /**
     * Find all function definitions in the AST
     */
    static extractFunctionDefinitions(expressions) {
        const functions = [];
        
        function traverse(node) {
            if (node.type === 'LIST' && node.children.length > 0) {
                const first = node.children[0];
                if (first.type === 'SYMBOL' && (first.value === 'defun' || first.value === 'define')) {
                    if (node.children.length >= 3) {
                        const name = node.children[1];
                        if (name.type === 'SYMBOL') {
                            functions.push({
                                name: name.value,
                                type: first.value,
                                node: node,
                                sourceInfo: node.sourceInfo
                            });
                        }
                    }
                }
            }
            
            for (const child of node.children) {
                traverse(child);
            }
        }
        
        if (!Array.isArray(expressions)) {
            expressions = [expressions];
        }
        
        for (const expr of expressions) {
            traverse(expr);
        }
        
        return functions;
    }
}

module.exports = {
    LispParser,
    ParseError,
    ASTNode
};