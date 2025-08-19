#!/usr/bin/env node
// Validate legal knowledge packs

const fs = require('fs');
const path = require('path');

const REQUIRED_FILES = [
    'manifest.json',
    'README.md',
    'main.ether',
    'CHANGELOG.md'
];

const REQUIRED_DIRS = [
    'tests/golden',
    'tests/unit'
];

const MANIFEST_SCHEMA = {
    id: 'string',
    version: 'string',
    entry: 'string',
    exports: 'array',
    jurisdiction: 'string',
    field: 'string',
    description: 'string',
    sources: 'array',
    maintainers: 'array',
    review: 'object',
    engine: 'object',
    integrity: 'object'
};

function validateManifest(manifestPath) {
    const errors = [];
    
    try {
        const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
        
        // Check required fields
        for (const [field, type] of Object.entries(MANIFEST_SCHEMA)) {
            if (!(field in manifest)) {
                errors.push(`Missing required field: ${field}`);
                continue;
            }
            
            const actualType = Array.isArray(manifest[field]) ? 'array' : typeof manifest[field];
            if (actualType !== type) {
                errors.push(`Field ${field} should be ${type}, got ${actualType}`);
            }
        }
        
        // Validate jurisdiction
        if (manifest.jurisdiction && !['PH', 'GLOBAL'].includes(manifest.jurisdiction)) {
            errors.push(`Invalid jurisdiction: ${manifest.jurisdiction}. Must be PH or GLOBAL`);
        }
        
        // Validate version format
        if (manifest.version && !/^\d+\.\d+\.\d+$/.test(manifest.version)) {
            errors.push(`Invalid version format: ${manifest.version}. Must be semver (x.y.z)`);
        }
        
        // Validate ID format
        if (manifest.id && !/^legal\.[a-z]+(\.[a-z-]+)*$/.test(manifest.id)) {
            errors.push(`Invalid ID format: ${manifest.id}. Must start with 'legal.' and use lowercase`);
        }
        
    } catch (error) {
        errors.push(`Invalid JSON: ${error.message}`);
    }
    
    return errors;
}

function validateEtherFile(etherPath) {
    const errors = [];
    
    try {
        const content = fs.readFileSync(etherPath, 'utf8');
        
        // Check for rule metadata headers
        const rules = content.match(/\(defrule\s+[\w-]+/g) || [];
        for (const rule of rules) {
            const ruleName = rule.match(/\(defrule\s+([\w-]+)/)[1];
            const ruleIndex = content.indexOf(rule);
            const beforeRule = content.substring(0, ruleIndex);
            const lastComment = beforeRule.lastIndexOf(';');
            
            if (lastComment === -1) {
                errors.push(`Rule ${ruleName} missing metadata comment block`);
                continue;
            }
            
            const commentBlock = content.substring(lastComment, ruleIndex);
            const requiredFields = ['sources:', 'owner:', 'last-reviewed:', 'jurisdiction:', 'notes:'];
            
            for (const field of requiredFields) {
                if (!commentBlock.includes(field)) {
                    errors.push(`Rule ${ruleName} missing metadata field: ${field}`);
                }
            }
        }
        
        // Check for non-pure calls (basic check)
        const dangerousCalls = ['eval', 'load-file', 'system', 'exec'];
        for (const call of dangerousCalls) {
            if (content.includes(`(${call}`)) {
                errors.push(`Potentially dangerous call found: ${call}`);
            }
        }
        
    } catch (error) {
        errors.push(`Cannot read file: ${error.message}`);
    }
    
    return errors;
}

function validatePack(packDir) {
    const errors = [];
    const packName = path.relative('packs/legal', packDir);
    
    console.log(`Validating pack: ${packName}`);
    
    // Check required files
    for (const file of REQUIRED_FILES) {
        const filePath = path.join(packDir, file);
        if (!fs.existsSync(filePath)) {
            errors.push(`Missing required file: ${file}`);
        }
    }
    
    // Check required directories
    for (const dir of REQUIRED_DIRS) {
        const dirPath = path.join(packDir, dir);
        if (!fs.existsSync(dirPath)) {
            errors.push(`Missing required directory: ${dir}`);
        }
    }
    
    // Validate manifest
    const manifestPath = path.join(packDir, 'manifest.json');
    if (fs.existsSync(manifestPath)) {
        const manifestErrors = validateManifest(manifestPath);
        errors.push(...manifestErrors.map(e => `manifest.json: ${e}`));
    }
    
    // Validate main.ether
    const etherPath = path.join(packDir, 'main.ether');
    if (fs.existsSync(etherPath)) {
        const etherErrors = validateEtherFile(etherPath);
        errors.push(...etherErrors.map(e => `main.ether: ${e}`));
    }
    
    // Check for test files
    const goldenDir = path.join(packDir, 'tests/golden');
    const unitDir = path.join(packDir, 'tests/unit');
    
    if (fs.existsSync(goldenDir)) {
        const goldenFiles = fs.readdirSync(goldenDir).filter(f => f.endsWith('.json'));
        if (goldenFiles.length === 0) {
            errors.push('No golden test files found');
        }
    }
    
    if (fs.existsSync(unitDir)) {
        const unitFiles = fs.readdirSync(unitDir).filter(f => f.endsWith('.ether'));
        if (unitFiles.length === 0) {
            errors.push('No unit test files found');
        }
    }
    
    return errors;
}

function findPacks(baseDir) {
    const packs = [];
    
    function traverse(dir) {
        const entries = fs.readdirSync(dir, { withFileTypes: true });
        
        // Check if this directory is a pack (has manifest.json)
        if (entries.some(e => e.name === 'manifest.json')) {
            packs.push(dir);
            return;
        }
        
        // Recurse into subdirectories
        for (const entry of entries) {
            if (entry.isDirectory()) {
                traverse(path.join(dir, entry.name));
            }
        }
    }
    
    if (fs.existsSync(baseDir)) {
        traverse(baseDir);
    }
    
    return packs;
}

function main() {
    const args = process.argv.slice(2);
    let targetDir = 'packs/legal';
    
    if (args.length > 0) {
        targetDir = args[0];
    }
    
    console.log(`Validating packs in: ${targetDir}`);
    
    const packs = findPacks(targetDir);
    let totalErrors = 0;
    
    for (const pack of packs) {
        const errors = validatePack(pack);
        
        if (errors.length > 0) {
            console.error(`\n❌ ${path.relative('packs/legal', pack)}:`);
            for (const error of errors) {
                console.error(`  - ${error}`);
            }
            totalErrors += errors.length;
        } else {
            console.log(`✅ ${path.relative('packs/legal', pack)}`);
        }
    }
    
    console.log(`\nValidation complete. Found ${totalErrors} errors across ${packs.length} packs.`);
    
    if (totalErrors > 0) {
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = { validatePack, validateManifest, validateEtherFile };