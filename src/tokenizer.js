/**
 * Etherney Lisp Machine - Tokenizer
 * 
 * Tokenizes Lisp source code into a stream of tokens for parsing.
 * Supports all Lisp data types: numbers, symbols, strings, lists, quotes, and comments.
 * 
 * Token Types:
 * - NUMBER: Integer and floating-point numbers
 * - SYMBOL: Identifiers and operators
 * - STRING: String literals with escape sequences
 * - LPAREN: Left parenthesis '('
 * - RPAREN: Right parenthesis ')'
 * - QUOTE: Quote character "'"
 * - EOF: End of file marker
 */

class Token {
    constructor(type, value, line, column, position) {
        this.type = type;
        this.value = value;
        this.line = line;
        this.column = column;
        this.position = position;
    }

    toString() {
        return `Token(${this.type}, ${JSON.stringify(this.value)}, ${this.line}:${this.column})`;
    }
}

class TokenizerError extends Error {
    constructor(message, line, column, position) {
        super(message);
        this.name = 'TokenizerError';
        this.line = line;
        this.column = column;
        this.position = position;
    }
}

class LispTokenizer {
    constructor(source) {
        this.source = source || '';
        this.position = 0;
        this.line = 1;
        this.column = 1;
        this.tokens = [];
        
        // Reserved words that have special meaning
        this.reservedWords = new Set([
            'if', 'cond', 'let', 'lambda', 'define', 'quote',
            'defrule', 'fact', 'query', 'and', 'or', 'not',
            'defun', 'defmacro', 'setq', 'progn', 'when', 'unless'
        ]);
    }

    /**
     * Tokenize the entire source code and return array of tokens
     */
    tokenize() {
        this.tokens = [];
        this.position = 0;
        this.line = 1;
        this.column = 1;

        while (!this.isAtEnd()) {
            try {
                const token = this.nextToken();
                if (token) {
                    this.tokens.push(token);
                }
            } catch (error) {
                if (error instanceof TokenizerError) {
                    throw error;
                }
                throw new TokenizerError(
                    `Unexpected error during tokenization: ${error.message}`,
                    this.line,
                    this.column,
                    this.position
                );
            }
        }

        // Add EOF token
        this.tokens.push(new Token('EOF', null, this.line, this.column, this.position));
        return this.tokens;
    }

    /**
     * Get the next token from the source
     */
    nextToken() {
        this.skipWhitespace();
        
        if (this.isAtEnd()) {
            return null;
        }

        const startLine = this.line;
        const startColumn = this.column;
        const startPosition = this.position;
        
        const char = this.peek();
        
        switch (char) {
            case '(':
                this.advance();
                return new Token('LPAREN', '(', startLine, startColumn, startPosition);
                
            case ')':
                this.advance();
                return new Token('RPAREN', ')', startLine, startColumn, startPosition);
                
            case '\'':
                this.advance();
                return new Token('QUOTE', '\'', startLine, startColumn, startPosition);
                
            case '"':
                return this.string(startLine, startColumn, startPosition);
                
            case ';':
                this.skipComment();
                return this.nextToken(); // Skip comment and get next token
                
            case '#':
                return this.boolean(startLine, startColumn, startPosition);
                
            default:
                // Try to parse as number first (digits or negative sign followed by digit)
                if (this.isDigit(char) || (char === '-' && this.isDigit(this.peekNext()))) {
                    // Look ahead to see if this looks like a number
                    if (this.looksLikeNumber()) {
                        return this.number(startLine, startColumn, startPosition);
                    }
                }
                
                // Try to parse as symbol
                if (this.isSymbolStart(char)) {
                    return this.symbol(startLine, startColumn, startPosition);
                }
                
                // Handle single dot - allow as DOT token for variadic parameters
                if (char === '.') {
                    this.advance();
                    return new Token('DOT', '.', startLine, startColumn, startPosition);
                }
                
                throw new TokenizerError(
                    `Unexpected character: '${char}' (${char.charCodeAt(0)})`,
                    this.line,
                    this.column,
                    this.position
                );
        }
    }

    /**
     * Parse a string literal with escape sequences
     */
    string(startLine, startColumn, startPosition) {
        this.advance(); // Skip opening quote
        let value = '';
        
        while (!this.isAtEnd() && this.peek() !== '"') {
            const char = this.peek();
            
            if (char === '\\') {
                this.advance(); // Skip backslash
                if (this.isAtEnd()) {
                    throw new TokenizerError(
                        'Unterminated string: unexpected end of file after escape character',
                        this.line,
                        this.column,
                        this.position
                    );
                }
                
                const escaped = this.peek();
                switch (escaped) {
                    case 'n':
                        value += '\n';
                        break;
                    case 't':
                        value += '\t';
                        break;
                    case 'r':
                        value += '\r';
                        break;
                    case '\\':
                        value += '\\';
                        break;
                    case '"':
                        value += '"';
                        break;
                    case '\'':
                        value += '\'';
                        break;
                    default:
                        // For unknown escape sequences, include the backslash
                        value += '\\' + escaped;
                        break;
                }
                this.advance();
            } else {
                if (char === '\n') {
                    this.line++;
                    this.column = 0; // Will be incremented by advance()
                }
                value += char;
                this.advance();
            }
        }
        
        if (this.isAtEnd()) {
            throw new TokenizerError(
                'Unterminated string literal',
                startLine,
                startColumn,
                startPosition
            );
        }
        
        this.advance(); // Skip closing quote
        return new Token('STRING', value, startLine, startColumn, startPosition);
    }

    /**
     * Parse a number (integer or floating-point)
     */
    number(startLine, startColumn, startPosition) {
        let value = '';
        let hasDecimalPoint = false;
        
        // Handle negative sign
        if (this.peek() === '-') {
            value += this.advance();
        }
        
        // Parse digits and decimal point
        while (!this.isAtEnd() && (this.isDigit(this.peek()) || this.peek() === '.')) {
            const char = this.peek();
            
            if (char === '.') {
                if (hasDecimalPoint) {
                    throw new TokenizerError(
                        'Invalid number: multiple decimal points',
                        this.line,
                        this.column,
                        this.position
                    );
                }
                hasDecimalPoint = true;
            }
            
            value += this.advance();
        }
        
        // Validate number format
        if (value === '' || value === '-' || value === '.') {
            throw new TokenizerError(
                `Invalid number format: '${value}'`,
                startLine,
                startColumn,
                startPosition
            );
        }
        
        // Convert to appropriate JavaScript number type
        const numValue = hasDecimalPoint ? parseFloat(value) : parseInt(value, 10);
        
        if (isNaN(numValue)) {
            throw new TokenizerError(
                `Invalid number: '${value}'`,
                startLine,
                startColumn,
                startPosition
            );
        }
        
        return new Token('NUMBER', numValue, startLine, startColumn, startPosition);
    }

    /**
     * Parse a symbol (identifier)
     */
    symbol(startLine, startColumn, startPosition) {
        let value = '';
        
        while (!this.isAtEnd() && this.isSymbolChar(this.peek())) {
            value += this.advance();
        }
        
        if (value === '') {
            throw new TokenizerError(
                'Empty symbol',
                startLine,
                startColumn,
                startPosition
            );
        }
        
        // Validate symbol
        if (!this.isValidSymbol(value)) {
            throw new TokenizerError(
                `Invalid symbol: '${value}'`,
                startLine,
                startColumn,
                startPosition
            );
        }
        
        return new Token('SYMBOL', value, startLine, startColumn, startPosition);
    }

    /**
     * Parse a boolean literal (#t or #f)
     */
    boolean(startLine, startColumn, startPosition) {
        this.advance(); // Skip '#'
        
        if (this.isAtEnd()) {
            throw new TokenizerError(
                'Incomplete boolean literal',
                this.line,
                this.column,
                this.position
            );
        }
        
        const char = this.peek();
        if (char === 't') {
            this.advance();
            return new Token('BOOLEAN', true, startLine, startColumn, startPosition);
        } else if (char === 'f') {
            this.advance();
            return new Token('BOOLEAN', false, startLine, startColumn, startPosition);
        } else {
            throw new TokenizerError(
                `Invalid boolean literal: #${char}`,
                this.line,
                this.column,
                this.position
            );
        }
    }

    /**
     * Skip whitespace characters
     */
    skipWhitespace() {
        while (!this.isAtEnd()) {
            const char = this.peek();
            if (char === ' ' || char === '\t' || char === '\r') {
                this.advance();
            } else if (char === '\n') {
                this.line++;
                this.column = 0; // Will be incremented by advance()
                this.advance();
            } else {
                break;
            }
        }
    }

    /**
     * Skip comment (from ; to end of line)
     */
    skipComment() {
        while (!this.isAtEnd() && this.peek() !== '\n') {
            this.advance();
        }
    }

    /**
     * Character classification methods
     */
    isDigit(char) {
        return char >= '0' && char <= '9';
    }

    isAlpha(char) {
        return (char >= 'a' && char <= 'z') || 
               (char >= 'A' && char <= 'Z');
    }

    isSymbolStart(char) {
        return this.isAlpha(char) ||
               '+-*/<>=!?_$%&^~|:'.includes(char);
    }

    isSymbolChar(char) {
        return this.isAlpha(char) ||
               this.isDigit(char) ||
               '+-*/<>=!?_$%&^~|.-:'.includes(char);
    }

    isValidSymbol(symbol) {
        // Symbol cannot be empty
        if (symbol.length === 0) return false;
        
        // Symbol cannot be just a dot or multiple dots
        if (/^\.+$/.test(symbol)) return false;
        
        // Symbol cannot start with a digit (unless it's a special operator like +, -, etc.)
        if (this.isDigit(symbol[0]) && symbol.length > 1) return false;
        
        // Symbol cannot be just a number (including decimals)
        if (/^-?\d+(\.\d+)?$/.test(symbol)) return false;
        
        // Symbol cannot start with a dot (keep it simple, avoid ambiguity)
        if (symbol[0] === '.') return false;
        
        // All characters must be valid symbol characters
        for (const char of symbol) {
            if (!this.isSymbolChar(char)) return false;
        }
        
        return true;
    }

    /**
     * Look ahead to determine if the current position starts a number
     * This helps distinguish between numbers and symbols that start with - or digits
     */
    looksLikeNumber() {
        let pos = this.position;
        
        // Handle negative sign
        if (pos < this.source.length && this.source[pos] === '-') {
            pos++;
        }
        
        // Must have at least one digit
        if (pos >= this.source.length || !this.isDigit(this.source[pos])) {
            return false;
        }
        
        // Skip digits
        while (pos < this.source.length && this.isDigit(this.source[pos])) {
            pos++;
        }
        
        // Check for decimal point
        if (pos < this.source.length && this.source[pos] === '.') {
            pos++;
            // Must have digits after decimal point
            if (pos >= this.source.length || !this.isDigit(this.source[pos])) {
                return false;
            }
            // Skip remaining digits
            while (pos < this.source.length && this.isDigit(this.source[pos])) {
                pos++;
            }
        }
        
        // Check that the number ends with a delimiter (whitespace, paren, etc.)
        if (pos < this.source.length) {
            const nextChar = this.source[pos];
            return nextChar === ' ' || nextChar === '\t' || nextChar === '\n' ||
                   nextChar === '\r' || nextChar === '(' || nextChar === ')' ||
                   nextChar === ';' || nextChar === '"' || nextChar === '\'';
        }
        
        return true; // End of input
    }

    /**
     * Navigation methods
     */
    isAtEnd() {
        return this.position >= this.source.length;
    }

    peek() {
        if (this.isAtEnd()) return '\0';
        return this.source[this.position];
    }

    peekNext() {
        if (this.position + 1 >= this.source.length) return '\0';
        return this.source[this.position + 1];
    }

    advance() {
        if (this.isAtEnd()) return '\0';
        const char = this.source[this.position];
        this.position++;
        this.column++;
        return char;
    }

    /**
     * Utility methods for debugging and inspection
     */
    getTokensAsString() {
        return this.tokens.map(token => token.toString()).join('\n');
    }

    getSourceLocation(position) {
        let line = 1;
        let column = 1;
        
        for (let i = 0; i < position && i < this.source.length; i++) {
            if (this.source[i] === '\n') {
                line++;
                column = 1;
            } else {
                column++;
            }
        }
        
        return { line, column };
    }

    /**
     * Static utility methods
     */
    static isReservedWord(symbol) {
        const reserved = new Set([
            'if', 'cond', 'let', 'lambda', 'define', 'quote',
            'defrule', 'fact', 'query', 'and', 'or', 'not',
            'defun', 'defmacro', 'setq', 'progn', 'when', 'unless'
        ]);
        return reserved.has(symbol);
    }

    static tokenTypeToString(type) {
        const typeNames = {
            'NUMBER': 'Number',
            'SYMBOL': 'Symbol',
            'STRING': 'String',
            'LPAREN': 'Left Parenthesis',
            'RPAREN': 'Right Parenthesis',
            'QUOTE': 'Quote',
            'EOF': 'End of File'
        };
        return typeNames[type] || type;
    }
}

module.exports = {
    LispTokenizer,
    Token,
    TokenizerError
};