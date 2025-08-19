#!/usr/bin/env node

/**
 * Etherney eLisp Lambda Arity Codemod
 * Fixes lambda expressions that violate the arity rule: (lambda <params> <single-body-expr>)
 * 
 * Transformations:
 * 1. (define (f args) body1 ... bodyN) → (define f (lambda (args) (begin body1 ... bodyN)))
 * 2. (lambda (args) body1 ... bodyN) → (lambda (args) (begin body1 ... bodyN)) where N > 1
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

class LambdaCodemod {
    constructor(options = {}) {
        this.dryRun = options.dryRun || false;
        this.verbose = options.verbose || false;
        this.changes = [];
        this.fileCount = 0;
        this.totalLambdas = 0;
        this.fixedLambdas = 0;
        this.fixedDefines = 0;
    }

    // Simple tokenizer for LISP expressions
    tokenize(content) {
        const tokens = [];
        let current = '';
        let inString = false;
        let inComment = false;
        let parenDepth = 0;
        
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
                parenDepth += char === '(' ? 1 : -1;
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

    // Convert S-expression back to string
    stringify(expr, indent = 0) {
        if (Array.isArray(expr)) {
            if (expr.length === 0) return '()';
            
            const head = expr[0];
            const indentStr = '  '.repeat(indent);
            
            // Special formatting for common forms
            if (head === 'lambda' && expr.length >= 3) {
                const params = this.stringify(expr[1]);
                const body = expr.slice(2).map(e => this.stringify(e, indent + 1)).join('\n' + '  '.repeat(indent + 1));
                return `(lambda ${params}\n${indentStr}  ${body})`;
            }
            
            if (head === 'define' && expr.length >= 3) {
                const name = this.stringify(expr[1]);
                const value = expr.slice(2).map(e => this.stringify(e, indent + 1)).join('\n' + '  '.repeat(indent + 1));
                return `(define ${name}\n${indentStr}  ${value})`;
            }
            
            if (head === 'begin') {
                const body = expr.slice(1).map(e => this.stringify(e, indent + 1)).join('\n' + '  '.repeat(indent + 1));
                return `(begin\n${indentStr}  ${body})`;
            }
            
            if (head === 'if' && expr.length >= 4) {
                const condition = this.stringify(expr[1]);
                const thenClause = this.stringify(expr[2], indent + 1);
                const elseClause = this.stringify(expr[3], indent + 1);
                return `(if ${condition}\n${indentStr}    ${thenClause}\n${indentStr}    ${elseClause})`;
            }
            
            // Default formatting
            const parts = expr.map(e => this.stringify(e, indent));
            if (parts.join(' ').length <= 60) {
                return `(${parts.join(' ')})`;
            } else {
                const head = parts[0];
                const rest = parts.slice(1).join('\n' + '  '.repeat(indent + 1));
                return `(${head}\n${indentStr}  ${rest})`;
            }
        } else {
            return String(expr);
        }
    }

    // Check if a lambda needs fixing (has multiple body expressions)
    needsLambdaFix(expr) {
        if (!Array.isArray(expr) || expr.length < 3 || expr[0] !== 'lambda') {
            return false;
        }
        
        // Lambda should have exactly 3 parts: 'lambda', params, single-body
        // If it has more than 3 parts, it needs fixing
        return expr.length > 3;
    }

    // Check if a define form uses sugar syntax that needs expansion
    needsDefineFix(expr) {
        if (!Array.isArray(expr) || expr.length < 3 || expr[0] !== 'define') {
            return false;
        }
        
        // Check if second element is a list (function definition sugar)
        const nameOrParams = expr[1];
        if (Array.isArray(nameOrParams)) {
            // This is (define (name params) body...) syntax
            return true;
        }
        
        return false;
    }

    // Fix a lambda expression by wrapping multiple body expressions in begin
    fixLambda(expr) {
        if (!this.needsLambdaFix(expr)) {
            return expr;
        }
        
        const [lambda, params, ...bodyExprs] = expr;
        
        if (bodyExprs.length === 1) {
            return expr; // Already correct
        }
        
        // Wrap multiple body expressions in begin
        return [lambda, params, ['begin', ...bodyExprs]];
    }

    // Fix a define form by expanding sugar syntax
    fixDefine(expr) {
        if (!this.needsDefineFix(expr)) {
            return expr;
        }
        
        const [define, nameAndParams, ...bodyExprs] = expr;
        const [name, ...params] = nameAndParams;
        
        // Create lambda with proper body wrapping if needed
        let lambdaBody;
        if (bodyExprs.length === 1) {
            lambdaBody = bodyExprs[0];
        } else {
            lambdaBody = ['begin', ...bodyExprs];
        }
        
        return [define, name, ['lambda', params, lambdaBody]];
    }

    // Recursively process expressions
    processExpression(expr) {
        if (!Array.isArray(expr)) {
            return expr;
        }
        
        // First, recursively process sub-expressions
        const processedExpr = expr.map(subExpr => this.processExpression(subExpr));
        
        // Then apply fixes to this expression
        if (this.needsDefineFix(processedExpr)) {
            this.fixedDefines++;
            return this.fixDefine(processedExpr);
        }
        
        if (this.needsLambdaFix(processedExpr)) {
            this.fixedLambdas++;
            return this.fixLambda(processedExpr);
        }
        
        return processedExpr;
    }

    // Process a single file
    processFile(filePath) {
        try {
            const originalContent = fs.readFileSync(filePath, 'utf8');
            
            this.fileCount++;
            
            const tokens = this.tokenize(originalContent);
            const expressions = this.parse(tokens);
            
            // Count total lambdas for statistics
            this.countLambdas(expressions);
            
            // Process expressions
            const processedExpressions = expressions.map(expr => this.processExpression(expr));
            
            // Convert back to string
            const newContent = processedExpressions.map(expr => this.stringify(expr)).join('\n\n') + '\n';
            
            // Check if content changed
            if (originalContent !== newContent) {
                this.changes.push({
                    file: filePath,
                    originalContent,
                    newContent,
                    lambdaFixes: this.countLambdaFixes(expressions, processedExpressions),
                    defineFixes: this.countDefineFixes(expressions, processedExpressions)
                });
                
                // Write the file if not in dry-run mode
                if (!this.dryRun) {
                    fs.writeFileSync(filePath, newContent, 'utf8');
                }
                
                if (this.verbose) {
                    console.log(`  ${filePath}: Fixed lambda expressions`);
                }
            }
            
        } catch (error) {
            console.error(`Error processing ${filePath}: ${error.message}`);
        }
    }

    // Count lambdas in expressions for statistics
    countLambdas(expressions) {
        const countInExpr = (expr) => {
            if (!Array.isArray(expr)) return 0;
            
            let count = 0;
            if (expr[0] === 'lambda') {
                count = 1;
            }
            
            // Recursively count in sub-expressions
            for (let i = 1; i < expr.length; i++) {
                count += countInExpr(expr[i]);
            }
            
            return count;
        };
        
        expressions.forEach(expr => {
            this.totalLambdas += countInExpr(expr);
        });
    }

    // Count lambda fixes between original and processed expressions
    countLambdaFixes(original, processed) {
        // This is a simplified count - in practice, we track during processing
        return 0;
    }

    // Count define fixes between original and processed expressions
    countDefineFixes(original, processed) {
        // This is a simplified count - in practice, we track during processing
        return 0;
    }

    // Run the codemod
    run() {
        console.log('🔧 Etherney eLisp Lambda Arity Codemod');
        console.log('=====================================\n');
        
        if (this.dryRun) {
            console.log('🔍 DRY RUN MODE - No files will be modified\n');
        }
        
        // Find all LISP and ether files
        const lispFiles = glob.sync('**/*.lisp', { ignore: ['node_modules/**', '.git/**', 'vendor/**', 'third_party/**'] });
        const etherFiles = glob.sync('**/*.ether', { ignore: ['node_modules/**', '.git/**', 'vendor/**', 'third_party/**'] });
        const allFiles = [...lispFiles, ...etherFiles];
        
        console.log(`Processing ${allFiles.length} files...\n`);
        
        // Reset counters for this run
        this.fixedLambdas = 0;
        this.fixedDefines = 0;
        
        // Process each file
        allFiles.forEach(file => {
            this.processFile(file);
        });
        
        // Generate reports
        this.generateReport();
        this.generateMigrationReport();
        
        return 0;
    }

    // Generate summary report
    generateReport() {
        console.log(`📊 Codemod Results:`);
        console.log(`   Files processed: ${this.fileCount}`);
        console.log(`   Total lambda expressions: ${this.totalLambdas}`);
        console.log(`   Fixed lambda expressions: ${this.fixedLambdas}`);
        console.log(`   Fixed define sugar: ${this.fixedDefines}`);
        console.log(`   Files modified: ${this.changes.length}\n`);
        
        if (this.changes.length === 0) {
            console.log('✅ No lambda arity violations found!');
            return;
        }
        
        if (this.dryRun) {
            console.log('🔍 Run without --dry-run to apply these changes.');
        } else {
            console.log('✅ All lambda arity fixes applied successfully!');
        }
    }

    // Generate detailed migration report
    generateMigrationReport() {
        if (this.changes.length === 0) return;
        
        const reportPath = 'reports/lambda-migration.txt';
        
        // Ensure reports directory exists
        if (!fs.existsSync('reports')) {
            fs.mkdirSync('reports', { recursive: true });
        }
        
        let report = 'Etherney eLisp Lambda Arity Migration Report\n';
        report += '===========================================\n\n';
        report += `Generated: ${new Date().toISOString()}\n`;
        report += `Mode: ${this.dryRun ? 'DRY RUN' : 'APPLIED'}\n`;
        report += `Files processed: ${this.fileCount}\n`;
        report += `Files modified: ${this.changes.length}\n`;
        report += `Lambda expressions fixed: ${this.fixedLambdas}\n`;
        report += `Define sugar expanded: ${this.fixedDefines}\n\n`;
        
        this.changes.forEach(change => {
            report += `File: ${change.file}\n`;
            report += `${'='.repeat(change.file.length + 6)}\n\n`;
            
            // Show before/after diff (simplified)
            const originalLines = change.originalContent.split('\n');
            const newLines = change.newContent.split('\n');
            
            // Find differences and show context
            for (let i = 0; i < Math.max(originalLines.length, newLines.length); i++) {
                const origLine = originalLines[i] || '';
                const newLine = newLines[i] || '';
                
                if (origLine !== newLine) {
                    report += `Line ${i + 1}:\n`;
                    if (origLine) report += `- ${origLine}\n`;
                    if (newLine) report += `+ ${newLine}\n`;
                    report += '\n';
                }
            }
            
            report += '-'.repeat(50) + '\n\n';
        });
        
        fs.writeFileSync(reportPath, report, 'utf8');
        console.log(`📄 Detailed migration report saved to: ${reportPath}`);
    }
}

// CLI execution
if (require.main === module) {
    const args = process.argv.slice(2);
    const options = {
        dryRun: args.includes('--dry-run') || args.includes('--check'),
        verbose: args.includes('--verbose') || args.includes('-v')
    };
    
    const codemod = new LambdaCodemod(options);
    const exitCode = codemod.run();
    process.exit(exitCode);
}

module.exports = LambdaCodemod;