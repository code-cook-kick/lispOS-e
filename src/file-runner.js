/**
 * File Runner for Etherney Lisp Machine
 * Executes Lisp files from the filesystem
 */

const fs = require('fs');
const path = require('path');
const { LispTokenizer } = require('./tokenizer');
const { LispParser } = require('./parser');
const { evalNode, createGlobalEnv } = require('./evaluator');

class LispFileRunner {
    constructor() {
        this.env = createGlobalEnv();
    }

    /**
     * Execute a Lisp file
     * @param {string} filePath - Path to the Lisp file
     * @returns {Array} - Array of evaluation results
     */
    executeFile(filePath) {
        try {
            // Read the file
            const absolutePath = path.resolve(filePath);
            if (!fs.existsSync(absolutePath)) {
                throw new Error(`File not found: ${filePath}`);
            }

            const source = fs.readFileSync(absolutePath, 'utf8');
            console.log(`📄 Executing Lisp file: ${filePath}`);
            console.log('=' .repeat(50));

            // Tokenize
            const tokenizer = new LispTokenizer(source);
            const tokens = tokenizer.tokenize();

            // Parse
            const parser = new LispParser(source);
            const ast = parser.parse();

            // Evaluate all expressions
            const results = [];
            for (const node of ast) {
                const result = evalNode(node, this.env);
                results.push(result);
            }

            console.log('=' .repeat(50));
            console.log(`✅ File execution completed successfully`);
            console.log(`📊 Executed ${ast.length} expressions`);
            
            return results;

        } catch (error) {
            console.error('❌ Error executing file:', error.message);
            if (error.line && error.column) {
                console.error(`   at line ${error.line}, column ${error.column}`);
            }
            throw error;
        }
    }

    /**
     * Execute multiple files in sequence
     * @param {string[]} filePaths - Array of file paths
     */
    executeFiles(filePaths) {
        const results = [];
        for (const filePath of filePaths) {
            console.log(`\n🚀 Starting execution of: ${filePath}`);
            try {
                const fileResults = this.executeFile(filePath);
                results.push({ file: filePath, results: fileResults, success: true });
            } catch (error) {
                results.push({ file: filePath, error: error.message, success: false });
                console.error(`💥 Failed to execute: ${filePath}`);
            }
        }
        return results;
    }

    /**
     * Get the current environment (for inspection)
     */
    getEnvironment() {
        return this.env;
    }

    /**
     * Reset the environment to initial state
     */
    resetEnvironment() {
        this.env = createGlobalEnv();
    }
}

/**
 * Command-line interface for file execution
 */
function runFromCommandLine() {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.log('Usage: node src/file-runner.js <lisp-file> [additional-files...]');
        console.log('');
        console.log('Examples:');
        console.log('  node src/file-runner.js src/lisp/initial-test.lisp');
        console.log('  node src/file-runner.js file1.lisp file2.lisp file3.lisp');
        process.exit(1);
    }

    const runner = new LispFileRunner();
    
    console.log('🧠 Etherney Lisp Machine - File Runner');
    console.log('=====================================');
    
    if (args.length === 1) {
        // Single file execution
        try {
            runner.executeFile(args[0]);
        } catch (error) {
            process.exit(1);
        }
    } else {
        // Multiple file execution
        const results = runner.executeFiles(args);
        
        // Summary
        console.log('\n📋 EXECUTION SUMMARY');
        console.log('===================');
        const successful = results.filter(r => r.success).length;
        const failed = results.filter(r => !r.success).length;
        
        console.log(`✅ Successful: ${successful}`);
        console.log(`❌ Failed: ${failed}`);
        console.log(`📁 Total files: ${results.length}`);
        
        if (failed > 0) {
            console.log('\n💥 Failed files:');
            results.filter(r => !r.success).forEach(r => {
                console.log(`  - ${r.file}: ${r.error}`);
            });
            process.exit(1);
        }
    }
}

// Export for use as module
module.exports = LispFileRunner;

// Run from command line if this file is executed directly
if (require.main === module) {
    runFromCommandLine();
}