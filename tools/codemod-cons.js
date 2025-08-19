#!/usr/bin/env node

/**
 * Etherney eLisp Cons Misuse Codemod
 * Automatically fixes unsafe cons usage patterns in LISP and ether files
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

class ConsCodemod {
    constructor(options = {}) {
        this.dryRun = options.dryRun || false;
        this.verbose = options.verbose || false;
        this.changes = [];
        this.fileCount = 0;
        this.totalConsCount = 0;
        this.fixedCount = 0;
    }

    // Simple tokenizer for LISP expressions (same as linter)
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

    // Check if a value looks like a scalar (number, symbol, string)
    isScalarLiteral(value) {
        if (typeof value !== 'string') return false;
        
        // Numbers
        if (/^-?\d+(\.\d+)?$/.test(value)) return true;
        
        // Strings
        if (value.startsWith('"') && value.endsWith('"')) return true;
        
        // Common scalar symbols
        const scalarSymbols = ['#t', '#f', 'nil', 'null'];
        if (scalarSymbols.includes(value)) return true;
        
        // Single quoted symbols
        if (value.startsWith("'") && !value.includes(' ')) return true;
        
        return false;
    }

    // Check if an expression is likely to return a list
    isListExpression(expr) {
        if (typeof expr !== 'string') return false;
        
        // Known list-returning variable patterns
        const listPatterns = [
            /list$/i, /lst$/i, /^rest$/, /^tail$/, /^plist$/,
            /children$/i, /heirs$/i, /items$/i, /args$/i,
            /^props$/, /^kvs$/, /registry$/i
        ];
        
        return listPatterns.some(pattern => pattern.test(expr));
    }

    // Determine the appropriate fix for a cons expression
    determineFix(firstArg, secondArg, context = '') {
        // Rule R1: Second argument is scalar literal -> use list
        if (this.isScalarLiteral(secondArg)) {
            return {
                rule: 'R1',
                type: 'list',
                fixed: `(list ${firstArg} ${secondArg})`,
                reason: 'scalar literal as second argument'
            };
        }
        
        // Rule R2: Check context for alist building
        if (context.includes('alist') || context.includes('assoc') || 
            (typeof firstArg === 'string' && firstArg.startsWith("'"))) {
            // For alist entries, prefer kv for safety
            return {
                rule: 'R2-alist',
                type: 'kv',
                fixed: `(kv ${firstArg} ${secondArg})`,
                reason: 'alist entry - using kv for safety'
            };
        }
        
        // Rule R2: Unknown expression that might not be a list
        if (!this.isListExpression(secondArg) && typeof secondArg === 'string') {
            // Heuristic: if it looks like tuple building, use list
            if (context.includes('pair') || context.includes('tuple') || 
                context.includes('event.make') || context.includes('fact.make')) {
                return {
                    rule: 'R2-tuple',
                    type: 'list',
                    fixed: `(list ${firstArg} ${secondArg})`,
                    reason: 'tuple-like usage'
                };
            }
            
            // Otherwise, use ensure-list for safety
            return {
                rule: 'R2-ensure',
                type: 'ensure-list',
                fixed: `(cons ${firstArg} (ensure-list ${secondArg}))`,
                reason: 'potentially non-list second argument'
            };
        }
        
        return null; // No fix needed
    }

    // Apply fixes to file content
    processFile(filePath) {
        try {
            const originalContent = fs.readFileSync(filePath, 'utf8');
            let content = originalContent;
            const lines = content.split('\n');
            const fileChanges = [];
            
            this.fileCount++;
            
            // Process line by line to maintain line numbers
            for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
                const line = lines[lineIndex];
                const lineNumber = lineIndex + 1;
                
                // Find cons expressions in this line
                const consRegex = /\(cons\s+([^)]+?)\s+([^)]+?)\)/g;
                let match;
                let modifiedLine = line;
                let lineChanged = false;
                
                while ((match = consRegex.exec(line)) !== null) {
                    this.totalConsCount++;
                    
                    const fullMatch = match[0];
                    const firstArg = match[1].trim();
                    const secondArg = match[2].trim();
                    
                    // Get some context from surrounding lines
                    const contextStart = Math.max(0, lineIndex - 2);
                    const contextEnd = Math.min(lines.length, lineIndex + 3);
                    const context = lines.slice(contextStart, contextEnd).join(' ').toLowerCase();
                    
                    const fix = this.determineFix(firstArg, secondArg, context);
                    
                    if (fix) {
                        modifiedLine = modifiedLine.replace(fullMatch, fix.fixed);
                        lineChanged = true;
                        this.fixedCount++;
                        
                        fileChanges.push({
                            line: lineNumber,
                            rule: fix.rule,
                            type: fix.type,
                            reason: fix.reason,
                            original: fullMatch,
                            fixed: fix.fixed
                        });
                        
                        if (this.verbose) {
                            console.log(`  ${filePath}:${lineNumber} [${fix.rule}] ${fullMatch} → ${fix.fixed}`);
                        }
                    }
                }
                
                if (lineChanged) {
                    lines[lineIndex] = modifiedLine;
                }
            }
            
            if (fileChanges.length > 0) {
                const newContent = lines.join('\n');
                
                this.changes.push({
                    file: filePath,
                    changes: fileChanges,
                    originalContent,
                    newContent
                });
                
                // Write the file if not in dry-run mode
                if (!this.dryRun) {
                    fs.writeFileSync(filePath, newContent, 'utf8');
                }
            }
            
        } catch (error) {
            console.error(`Error processing ${filePath}: ${error.message}`);
        }
    }

    // Check if utils.lisp is loaded in a file
    needsUtilsImport(content) {
        return content.includes('ensure-list') || content.includes('kv ') || 
               content.includes('(kv ') || content.includes('safe-cons');
    }

    // Add utils import to files that need it
    addUtilsImport(filePath, content) {
        const importLine = '; Load safe cons utilities\n(load "src/lisp/common/utils.lisp")\n\n';
        
        // Check if already imported
        if (content.includes('utils.lisp') || content.includes('ensure-list') && content.includes('define ensure-list')) {
            return content;
        }
        
        // Add after any existing loads or at the beginning
        const lines = content.split('\n');
        let insertIndex = 0;
        
        // Find the last load statement or first non-comment line
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.startsWith('(load ')) {
                insertIndex = i + 1;
            } else if (line && !line.startsWith(';') && insertIndex === 0) {
                insertIndex = i;
                break;
            }
        }
        
        lines.splice(insertIndex, 0, importLine);
        return lines.join('\n');
    }

    // Run the codemod
    run() {
        console.log('🔧 Etherney eLisp Cons Misuse Codemod');
        console.log('====================================\n');
        
        if (this.dryRun) {
            console.log('🔍 DRY RUN MODE - No files will be modified\n');
        }
        
        // Find all LISP and ether files
        const lispFiles = glob.sync('**/*.lisp', { ignore: ['node_modules/**', '.git/**'] });
        const etherFiles = glob.sync('**/*.ether', { ignore: ['node_modules/**', '.git/**'] });
        const allFiles = [...lispFiles, ...etherFiles];
        
        console.log(`Processing ${allFiles.length} files...\n`);
        
        // Process each file
        allFiles.forEach(file => {
            this.processFile(file);
        });
        
        // Add utils imports where needed
        this.changes.forEach(change => {
            if (this.needsUtilsImport(change.newContent)) {
                const withImport = this.addUtilsImport(change.file, change.newContent);
                change.newContent = withImport;
                change.addedImport = true;
                
                if (!this.dryRun) {
                    fs.writeFileSync(change.file, withImport, 'utf8');
                }
            }
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
        console.log(`   Total cons expressions: ${this.totalConsCount}`);
        console.log(`   Fixed expressions: ${this.fixedCount}`);
        console.log(`   Files modified: ${this.changes.length}\n`);
        
        if (this.changes.length === 0) {
            console.log('✅ No cons misuse patterns found!');
            return;
        }
        
        // Summary by rule
        const ruleStats = {};
        this.changes.forEach(change => {
            change.changes.forEach(c => {
                ruleStats[c.rule] = (ruleStats[c.rule] || 0) + 1;
            });
        });
        
        console.log('📈 Fixes by rule:');
        Object.keys(ruleStats).sort().forEach(rule => {
            console.log(`   ${rule}: ${ruleStats[rule]} fixes`);
        });
        console.log('');
        
        if (this.dryRun) {
            console.log('🔍 Run without --dry-run to apply these changes.');
        } else {
            console.log('✅ All fixes applied successfully!');
        }
    }

    // Generate detailed migration report
    generateMigrationReport() {
        if (this.changes.length === 0) return;
        
        const reportPath = 'reports/cons-migration.txt';
        
        // Ensure reports directory exists
        if (!fs.existsSync('reports')) {
            fs.mkdirSync('reports', { recursive: true });
        }
        
        let report = 'Etherney eLisp Cons Misuse Migration Report\n';
        report += '==========================================\n\n';
        report += `Generated: ${new Date().toISOString()}\n`;
        report += `Mode: ${this.dryRun ? 'DRY RUN' : 'APPLIED'}\n`;
        report += `Files processed: ${this.fileCount}\n`;
        report += `Files modified: ${this.changes.length}\n`;
        report += `Total fixes: ${this.fixedCount}\n\n`;
        
        this.changes.forEach(change => {
            report += `File: ${change.file}\n`;
            report += `${'='.repeat(change.file.length + 6)}\n`;
            
            if (change.addedImport) {
                report += `+ Added utils.lisp import\n`;
            }
            
            change.changes.forEach(c => {
                report += `\nLine ${c.line} [${c.rule}]: ${c.reason}\n`;
                report += `- ${c.original}\n`;
                report += `+ ${c.fixed}\n`;
            });
            
            report += '\n' + '-'.repeat(50) + '\n\n';
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
    
    const codemod = new ConsCodemod(options);
    const exitCode = codemod.run();
    process.exit(exitCode);
}

module.exports = ConsCodemod;