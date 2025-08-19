#!/usr/bin/env node

/**
 * Etherney eLisp Lambda Arity Linter
 * Detects lambda expressions that violate the arity rule: (lambda <params> <single-body-expr>)
 * 
 * Fails on any (lambda ...) list whose arity != 3 (symbol + params + body)
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

class LambdaLinter {
    constructor() {
        this.violations = [];
        this.fileCount = 0;
        this.totalLambdas = 0;
    }

    // Simple tokenizer for LISP expressions
    tokenize(content) {
        const tokens = [];
        let current = '';
        let inString = false;
        let inComment = false;
        
        for (let i = 0; i < content.length; i++) {
            const char = content[i];
            
            if (inComment) {
                if (char === '\n') {
                    inComment = false;
                }
                continue;
            }
            
            if (char === ';' && !inString) {
                inComment = true;
                continue;
            }
            
            if (char === '"' && !inString) {
                inString = true;
                current += char;
                continue;
            }
            
            if (char === '"' && inString) {
                inString = false;
                current += char;
                continue;
            }
            
            if (inString) {
                current += char;
                continue;
            }
            
            if (char === '(' || char === ')') {
                if (current.trim()) {
                    tokens.push({ type: 'atom', value: current.trim() });
                    current = '';
                }
                tokens.push({ type: char === '(' ? 'open' : 'close', value: char });
            } else if (char === ' ' || char === '\t' || char === '\n' || char === '\r') {
                if (current.trim()) {
                    tokens.push({ type: 'atom', value: current.trim() });
                    current = '';
                }
            } else {
                current += char;
            }
        }
        
        if (current.trim()) {
            tokens.push({ type: 'atom', value: current.trim() });
        }
        
        return tokens;
    }

    // Parse tokens into S-expressions with position tracking
    parse(tokens) {
        let index = 0;
        
        function parseExpr(startPos = 0) {
            if (index >= tokens.length) return null;
            
            const token = tokens[index];
            const position = startPos + index;
            
            if (token.type === 'open') {
                index++; // consume '('
                const expr = [];
                expr._position = position;
                
                while (index < tokens.length && tokens[index].type !== 'close') {
                    const subExpr = parseExpr(startPos);
                    if (subExpr !== null) {
                        expr.push(subExpr);
                    }
                }
                
                if (index < tokens.length) {
                    index++; // consume ')'
                }
                
                return expr;
            } else if (token.type === 'atom') {
                index++;
                const atom = token.value;
                atom._position = position;
                return atom;
            }
            
            return null;
        }
        
        const expressions = [];
        while (index < tokens.length) {
            const expr = parseExpr();
            if (expr !== null) {
                expressions.push(expr);
            }
        }
        
        return expressions;
    }

    // Find line number from content and position
    findLineNumber(content, position) {
        const lines = content.split('\n');
        let charCount = 0;
        
        for (let i = 0; i < lines.length; i++) {
            charCount += lines[i].length + 1; // +1 for newline
            if (charCount > position) {
                return i + 1;
            }
        }
        
        return lines.length;
    }

    // Check if a lambda expression violates arity rules
    checkLambdaArity(expr, filePath, content) {
        if (!Array.isArray(expr) || expr.length === 0 || expr[0] !== 'lambda') {
            return;
        }
        
        this.totalLambdas++;
        
        // Lambda should have exactly 3 parts: 'lambda', params, single-body
        if (expr.length !== 3) {
            const lineNumber = this.findLineNumber(content, expr._position || 0);
            const exprStr = this.stringifyForError(expr);
            
            this.violations.push({
                file: filePath,
                line: lineNumber,
                severity: 'error',
                message: `Lambda has ${expr.length} parts, expected exactly 3 (lambda params body)`,
                expression: exprStr,
                suggestion: expr.length > 3 
                    ? 'Wrap multiple body expressions in (begin ...)'
                    : 'Lambda must have parameters and body'
            });
        }
    }

    // Convert expression to string for error reporting (simplified)
    stringifyForError(expr, maxLength = 100) {
        if (!Array.isArray(expr)) {
            return String(expr);
        }
        
        const str = `(${expr.map(e => this.stringifyForError(e, 20)).join(' ')})`;
        if (str.length > maxLength) {
            return str.substring(0, maxLength - 3) + '...';
        }
        return str;
    }

    // Recursively analyze expressions for lambda violations
    analyzeExpression(expr, filePath, content) {
        if (!Array.isArray(expr)) {
            return;
        }
        
        // Check if this is a lambda expression
        this.checkLambdaArity(expr, filePath, content);
        
        // Recursively analyze sub-expressions
        for (let i = 1; i < expr.length; i++) {
            if (Array.isArray(expr[i])) {
                this.analyzeExpression(expr[i], filePath, content);
            }
        }
    }

    // Lint a single file
    lintFile(filePath) {
        try {
            const content = fs.readFileSync(filePath, 'utf8');
            
            this.fileCount++;
            
            const tokens = this.tokenize(content);
            const expressions = this.parse(tokens);
            
            // Analyze each top-level expression
            expressions.forEach(expr => {
                this.analyzeExpression(expr, filePath, content);
            });
            
        } catch (error) {
            console.error(`Error processing ${filePath}: ${error.message}`);
        }
    }

    // Run the linter on all LISP and ether files
    run() {
        console.log('🔍 Etherney eLisp Lambda Arity Linter');
        console.log('====================================\n');
        
        // Find all LISP and ether files
        const lispFiles = glob.sync('**/*.lisp', { ignore: ['node_modules/**', '.git/**', 'vendor/**', 'third_party/**'] });
        const etherFiles = glob.sync('**/*.ether', { ignore: ['node_modules/**', '.git/**', 'vendor/**', 'third_party/**'] });
        const allFiles = [...lispFiles, ...etherFiles];
        
        console.log(`Scanning ${allFiles.length} files...\n`);
        
        allFiles.forEach(file => {
            this.lintFile(file);
        });
        
        // Report results
        this.reportResults();
        
        // Exit with error code if violations found
        return this.violations.length > 0 ? 1 : 0;
    }

    // Generate report
    reportResults() {
        console.log(`📊 Scan Results:`);
        console.log(`   Files scanned: ${this.fileCount}`);
        console.log(`   Total lambda expressions: ${this.totalLambdas}`);
        console.log(`   Arity violations: ${this.violations.length}\n`);
        
        if (this.violations.length === 0) {
            console.log('✅ No lambda arity violations detected!');
            return;
        }
        
        // Group violations by file
        const byFile = {};
        this.violations.forEach(v => {
            if (!byFile[v.file]) byFile[v.file] = [];
            byFile[v.file].push(v);
        });
        
        Object.keys(byFile).sort().forEach(file => {
            console.log(`📄 ${file}:`);
            byFile[file].forEach(violation => {
                console.log(`   ❌ Line ${violation.line}: ${violation.message}`);
                console.log(`      Expression: ${violation.expression}`);
                console.log(`      Suggestion: ${violation.suggestion}`);
                console.log('');
            });
        });
        
        console.log('❌ Lambda arity violations detected! Please fix before proceeding.');
        console.log('💡 Use tools/codemod-lambda.js to automatically fix these issues.');
    }
}

// CLI execution
if (require.main === module) {
    const linter = new LambdaLinter();
    const exitCode = linter.run();
    process.exit(exitCode);
}

module.exports = LambdaLinter;