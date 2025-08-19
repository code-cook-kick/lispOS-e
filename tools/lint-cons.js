#!/usr/bin/env node

/**
 * Etherney eLisp Cons Misuse Linter
 * Detects potentially unsafe cons usage patterns in LISP and ether files
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

class ConsLinter {
    constructor() {
        this.violations = [];
        this.fileCount = 0;
        this.totalConsCount = 0;
    }

    // Simple tokenizer for LISP expressions
    tokenize(content) {
        const tokens = [];
        let current = '';
        let inString = false;
        let inComment = false;
        
        for (let i = 0; i < content.length; i++) {
            const char = content[i];
            const nextChar = content[i + 1];
            
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

    // Parse tokens into S-expressions
    parse(tokens) {
        let index = 0;
        
        function parseExpr() {
            if (index >= tokens.length) return null;
            
            const token = tokens[index];
            
            if (token.type === 'open') {
                index++; // consume '('
                const expr = [];
                
                while (index < tokens.length && tokens[index].type !== 'close') {
                    const subExpr = parseExpr();
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
                return token.value;
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

    // Check if a value looks like a scalar (number, symbol, string)
    isScalarLiteral(value) {
        if (typeof value !== 'string') return false;
        
        // Numbers
        if (/^-?\d+(\.\d+)?$/.test(value)) return true;
        
        // Strings
        if (value.startsWith('"') && value.endsWith('"')) return true;
        
        // Common scalar symbols that are likely not lists
        const scalarSymbols = ['#t', '#f', 'nil', 'null'];
        if (scalarSymbols.includes(value)) return true;
        
        // Single quoted symbols
        if (value.startsWith("'") && !value.includes(' ')) return true;
        
        return false;
    }

    // Check if an expression is likely to return a list
    isListExpression(expr) {
        if (!Array.isArray(expr) || expr.length === 0) return false;
        
        const head = expr[0];
        
        // Known list-returning functions
        const listFunctions = [
            'list', 'cons', 'append', 'map', 'filter', 'rest', 'cdr',
            'reverse', 'sort', 'take', 'drop', 'zip', 'range',
            'plist-get', 'assoc', 'member'
        ];
        
        return listFunctions.includes(head);
    }

    // Analyze a cons expression for potential misuse
    analyzeConsExpression(expr, filePath, lineNumber) {
        if (!Array.isArray(expr) || expr.length < 3 || expr[0] !== 'cons') {
            return;
        }

        this.totalConsCount++;
        
        const firstArg = expr[1];
        const secondArg = expr[2];
        
        // Rule R1: Second argument is a scalar literal
        if (this.isScalarLiteral(secondArg)) {
            this.violations.push({
                file: filePath,
                line: lineNumber,
                rule: 'R1',
                severity: 'error',
                message: `cons with scalar literal as second argument: ${secondArg}`,
                suggestion: `Replace with (list ${firstArg} ${secondArg})`,
                original: `(cons ${firstArg} ${secondArg})`,
                fixed: `(list ${firstArg} ${secondArg})`
            });
            return;
        }
        
        // Rule R2: Second argument is unknown expression that might not be a list
        if (!this.isListExpression(secondArg) && typeof secondArg === 'string') {
            // Skip if it's clearly a list-like variable name
            if (secondArg.includes('list') || secondArg.includes('lst') || 
                secondArg.endsWith('s') || secondArg === 'rest' || 
                secondArg === 'tail' || secondArg === 'plist') {
                return;
            }
            
            this.violations.push({
                file: filePath,
                line: lineNumber,
                rule: 'R2',
                severity: 'warning',
                message: `cons with potentially non-list second argument: ${secondArg}`,
                suggestion: `Consider (cons ${firstArg} (ensure-list ${secondArg})) or (list ${firstArg} ${secondArg})`,
                original: `(cons ${firstArg} ${secondArg})`,
                fixed: `(cons ${firstArg} (ensure-list ${secondArg}))`
            });
        }
    }

    // Recursively analyze expressions
    analyzeExpression(expr, filePath, lineNumber) {
        if (!Array.isArray(expr)) return;
        
        // Check if this is a cons expression
        if (expr[0] === 'cons') {
            this.analyzeConsExpression(expr, filePath, lineNumber);
        }
        
        // Recursively analyze sub-expressions
        for (let i = 1; i < expr.length; i++) {
            if (Array.isArray(expr[i])) {
                this.analyzeExpression(expr[i], filePath, lineNumber);
            }
        }
    }

    // Lint a single file
    lintFile(filePath) {
        try {
            const content = fs.readFileSync(filePath, 'utf8');
            const lines = content.split('\n');
            
            this.fileCount++;
            
            const tokens = this.tokenize(content);
            const expressions = this.parse(tokens);
            
            // For line number tracking, we'll do a simple approach
            // Find cons expressions in the original content
            lines.forEach((line, index) => {
                const lineNumber = index + 1;
                const consMatches = line.match(/\(cons\s+/g);
                if (consMatches) {
                    // Re-parse just this line for analysis
                    try {
                        const lineTokens = this.tokenize(line);
                        const lineExpressions = this.parse(lineTokens);
                        
                        lineExpressions.forEach(expr => {
                            this.analyzeExpression(expr, filePath, lineNumber);
                        });
                    } catch (e) {
                        // Skip malformed lines
                    }
                }
            });
            
        } catch (error) {
            console.error(`Error processing ${filePath}: ${error.message}`);
        }
    }

    // Run the linter on all LISP and ether files
    run() {
        console.log('🔍 Etherney eLisp Cons Misuse Linter');
        console.log('=====================================\n');
        
        // Find all LISP and ether files
        const lispFiles = glob.sync('**/*.lisp', { ignore: ['node_modules/**', '.git/**'] });
        const etherFiles = glob.sync('**/*.ether', { ignore: ['node_modules/**', '.git/**'] });
        const allFiles = [...lispFiles, ...etherFiles];
        
        console.log(`Scanning ${allFiles.length} files...\n`);
        
        allFiles.forEach(file => {
            this.lintFile(file);
        });
        
        // Report results
        this.reportResults();
        
        // Exit with error code if violations found
        return this.violations.filter(v => v.severity === 'error').length > 0 ? 1 : 0;
    }

    // Generate report
    reportResults() {
        const errors = this.violations.filter(v => v.severity === 'error');
        const warnings = this.violations.filter(v => v.severity === 'warning');
        
        console.log(`📊 Scan Results:`);
        console.log(`   Files scanned: ${this.fileCount}`);
        console.log(`   Total cons expressions: ${this.totalConsCount}`);
        console.log(`   Errors: ${errors.length}`);
        console.log(`   Warnings: ${warnings.length}\n`);
        
        if (this.violations.length === 0) {
            console.log('✅ No cons misuse detected!');
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
                const icon = violation.severity === 'error' ? '❌' : '⚠️';
                console.log(`   ${icon} Line ${violation.line}: ${violation.message}`);
                console.log(`      Suggestion: ${violation.suggestion}`);
                console.log('');
            });
        });
        
        if (errors.length > 0) {
            console.log('❌ Cons misuse errors detected! Please fix before proceeding.');
        } else {
            console.log('⚠️  Warnings detected. Consider reviewing these patterns.');
        }
    }
}

// CLI execution
if (require.main === module) {
    const linter = new ConsLinter();
    const exitCode = linter.run();
    process.exit(exitCode);
}

module.exports = ConsLinter;