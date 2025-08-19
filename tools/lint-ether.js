#!/usr/bin/env node
// Lint .ether files for legal knowledge packs

const fs = require('fs');
const path = require('path');

class EtherLinter {
    constructor() {
        this.errors = [];
        this.warnings = [];
    }

    lint(filePath) {
        this.errors = [];
        this.warnings = [];
        
        try {
            const content = fs.readFileSync(filePath, 'utf8');
            this.lintContent(content, filePath);
        } catch (error) {
            this.errors.push(`Cannot read file: ${error.message}`);
        }
        
        return {
            errors: this.errors,
            warnings: this.warnings
        };
    }

    lintContent(content, filePath) {
        const lines = content.split('\n');
        
        // Check file header
        this.checkFileHeader(content);
        
        // Check rules
        this.checkRules(content);
        
        // Check for dangerous constructs
        this.checkDangerousConstructs(content);
        
        // Check formatting
        this.checkFormatting(lines);
        
        // Check metadata consistency
        this.checkMetadata(content, filePath);
    }

    checkFileHeader(content) {
        const headerPattern = /^;\s*Etherney-LISP Legal Knowledge Pack:/;
        if (!headerPattern.test(content)) {
            this.warnings.push('Missing standard file header');
        }
        
        if (!content.includes('Non-normative stub rules')) {
            this.warnings.push('Missing non-normative disclaimer in header');
        }
    }

    checkRules(content) {
        const rulePattern = /\(defrule\s+([\w-]+)(?:\s+:priority\s+\d+)?(?:\s+:cf\s+[\d.]+)?\s*\n/g;
        let match;
        
        while ((match = rulePattern.exec(content)) !== null) {
            const ruleName = match[1];
            const ruleStart = match.index;
            
            // Check for metadata block before rule
            const beforeRule = content.substring(0, ruleStart);
            const lastCommentIndex = beforeRule.lastIndexOf(';');
            
            if (lastCommentIndex === -1) {
                this.errors.push(`Rule '${ruleName}' missing metadata comment block`);
                continue;
            }
            
            const commentBlock = content.substring(lastCommentIndex, ruleStart);
            this.checkRuleMetadata(ruleName, commentBlock);
            
            // Check rule structure
            this.checkRuleStructure(ruleName, content, ruleStart);
        }
    }

    checkRuleMetadata(ruleName, commentBlock) {
        const requiredFields = [
            'sources:',
            'owner:',
            'last-reviewed:',
            'jurisdiction:',
            'notes:'
        ];
        
        for (const field of requiredFields) {
            if (!commentBlock.includes(field)) {
                this.errors.push(`Rule '${ruleName}' missing metadata field: ${field}`);
            }
        }
        
        // Check date format in last-reviewed
        const dateMatch = commentBlock.match(/last-reviewed:\s*(\d{4}-\d{2}-\d{2})/);
        if (dateMatch) {
            const date = new Date(dateMatch[1]);
            if (isNaN(date.getTime())) {
                this.errors.push(`Rule '${ruleName}' has invalid date format in last-reviewed`);
            }
        }
        
        // Check jurisdiction format
        const jurisdictionMatch = commentBlock.match(/jurisdiction:\s*(\w+)/);
        if (jurisdictionMatch && !['PH', 'GLOBAL'].includes(jurisdictionMatch[1])) {
            this.errors.push(`Rule '${ruleName}' has invalid jurisdiction: ${jurisdictionMatch[1]}`);
        }
    }

    checkRuleStructure(ruleName, content, ruleStart) {
        // Find the complete rule
        let parenCount = 0;
        let ruleEnd = ruleStart;
        let inRule = false;
        
        for (let i = ruleStart; i < content.length; i++) {
            const char = content[i];
            if (char === '(') {
                parenCount++;
                inRule = true;
            } else if (char === ')') {
                parenCount--;
                if (inRule && parenCount === 0) {
                    ruleEnd = i;
                    break;
                }
            }
        }
        
        const ruleContent = content.substring(ruleStart, ruleEnd + 1);
        
        // Check for proper priority and confidence factor
        if (!ruleContent.includes(':priority')) {
            this.warnings.push(`Rule '${ruleName}' missing priority specification`);
        }
        
        if (!ruleContent.includes(':cf')) {
            this.warnings.push(`Rule '${ruleName}' missing confidence factor`);
        }
        
        // Check for typed variables
        const varPattern = /\?(\w+):(\w+)/g;
        let varMatch;
        const usedTypes = new Set();
        
        while ((varMatch = varPattern.exec(ruleContent)) !== null) {
            usedTypes.add(varMatch[2]);
        }
        
        const validTypes = ['symbol', 'int', 'float', 'string', 'boolean', 'list'];
        for (const type of usedTypes) {
            if (!validTypes.includes(type)) {
                this.warnings.push(`Rule '${ruleName}' uses unknown type: ${type}`);
            }
        }
    }

    checkDangerousConstructs(content) {
        const dangerousPatterns = [
            { pattern: /\(eval\s/, message: 'Use of eval() is dangerous' },
            { pattern: /\(load-file\s/, message: 'Use of load-file() should be avoided' },
            { pattern: /\(system\s/, message: 'Use of system() is dangerous' },
            { pattern: /\(exec\s/, message: 'Use of exec() is dangerous' },
            { pattern: /\(shell\s/, message: 'Use of shell() is dangerous' },
            { pattern: /\(read-file\s/, message: 'Use of read-file() should be controlled' }
        ];
        
        for (const { pattern, message } of dangerousPatterns) {
            if (pattern.test(content)) {
                this.errors.push(message);
            }
        }
        
        // Check for hardcoded paths
        if (/\/[a-zA-Z0-9_/-]+\.[a-zA-Z]+/.test(content)) {
            this.warnings.push('Hardcoded file paths detected');
        }
        
        // Check for TODO placeholders in critical places
        if (content.includes('sources: TODO')) {
            this.warnings.push('Rules have TODO placeholders for sources');
        }
    }

    checkFormatting(lines) {
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const lineNum = i + 1;
            
            // Check for trailing whitespace
            if (line.endsWith(' ') || line.endsWith('\t')) {
                this.warnings.push(`Line ${lineNum}: trailing whitespace`);
            }
            
            // Check for very long lines
            if (line.length > 120) {
                this.warnings.push(`Line ${lineNum}: line too long (${line.length} chars)`);
            }
            
            // Check comment formatting
            if (line.trim().startsWith(';') && !line.match(/^;\s/)) {
                this.warnings.push(`Line ${lineNum}: comment should have space after semicolon`);
            }
        }
    }

    checkMetadata(content, filePath) {
        // Extract pack info from file path
        const pathParts = filePath.split(path.sep);
        const jurisdictionIndex = pathParts.findIndex(p => ['PH', 'GLOBAL'].includes(p));
        
        if (jurisdictionIndex !== -1) {
            const jurisdiction = pathParts[jurisdictionIndex];
            
            // Check if jurisdiction in metadata matches path
            const jurisdictionPattern = new RegExp(`jurisdiction:\\s*${jurisdiction}`, 'g');
            const matches = content.match(jurisdictionPattern);
            
            if (!matches) {
                this.warnings.push(`No rules specify jurisdiction '${jurisdiction}' (from path)`);
            }
        }
    }
}

function lintFile(filePath) {
    const linter = new EtherLinter();
    return linter.lint(filePath);
}

function findEtherFiles(dir) {
    const files = [];
    
    function traverse(currentDir) {
        const entries = fs.readdirSync(currentDir, { withFileTypes: true });
        
        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            
            if (entry.isDirectory()) {
                traverse(fullPath);
            } else if (entry.name.endsWith('.ether')) {
                files.push(fullPath);
            }
        }
    }
    
    if (fs.existsSync(dir)) {
        traverse(dir);
    }
    
    return files;
}

function main() {
    const args = process.argv.slice(2);
    let targetPath = 'packs/legal';
    
    if (args.length > 0) {
        targetPath = args[0];
    }
    
    console.log(`Linting .ether files in: ${targetPath}`);
    
    let files = [];
    
    if (fs.statSync(targetPath).isFile()) {
        files = [targetPath];
    } else {
        files = findEtherFiles(targetPath);
    }
    
    let totalErrors = 0;
    let totalWarnings = 0;
    
    for (const file of files) {
        const result = lintFile(file);
        const relativePath = path.relative(process.cwd(), file);
        
        if (result.errors.length > 0 || result.warnings.length > 0) {
            console.log(`\n📄 ${relativePath}:`);
            
            for (const error of result.errors) {
                console.log(`  ❌ ${error}`);
            }
            
            for (const warning of result.warnings) {
                console.log(`  ⚠️  ${warning}`);
            }
            
            totalErrors += result.errors.length;
            totalWarnings += result.warnings.length;
        } else {
            console.log(`✅ ${relativePath}`);
        }
    }
    
    console.log(`\nLinting complete. Found ${totalErrors} errors and ${totalWarnings} warnings across ${files.length} files.`);
    
    if (totalErrors > 0) {
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = { EtherLinter, lintFile };