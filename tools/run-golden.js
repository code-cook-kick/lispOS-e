#!/usr/bin/env node
// Run golden tests for legal knowledge packs

const fs = require('fs');
const path = require('path');

// Mock Etherney-LISP engine for testing
class MockEtherneyEngine {
    constructor() {
        this.facts = [];
        this.rules = [];
    }

    async evaluate({ program, env = {}, budget = 10000 }) {
        const startTime = Date.now();
        const trace = [];
        
        try {
            // Mock evaluation - in real implementation this would use actual engine
            trace.push(`Mock evaluation started with budget: ${budget}`);
            trace.push(`Program length: ${program.length} characters`);
            
            // Simple pattern matching for demo
            let value = null;
            
            if (program.includes('(run)')) {
                value = { status: 'completed', facts: this.facts.length, rules: this.rules.length };
                trace.push('Executed run command');
            } else {
                value = { status: 'parsed', program: program.substring(0, 50) + '...' };
                trace.push('Program parsed successfully');
            }
            
            const endTime = Date.now();
            const timeMs = endTime - startTime;
            
            trace.push(`Mock evaluation completed in ${timeMs}ms`);
            
            return {
                value: value,
                trace: trace,
                cost: {
                    steps: Math.min(100, budget),
                    timeMs: timeMs
                }
            };
            
        } catch (error) {
            const endTime = Date.now();
            const timeMs = endTime - startTime;
            
            return {
                value: { error: error.message },
                trace: [...trace, `Error: ${error.message}`],
                cost: {
                    steps: budget,
                    timeMs: timeMs
                }
            };
        }
    }

    loadPack(packPath) {
        const mainEtherPath = path.join(packPath, 'main.ether');
        if (fs.existsSync(mainEtherPath)) {
            const content = fs.readFileSync(mainEtherPath, 'utf8');
            // Mock rule loading
            const ruleMatches = content.match(/\(defrule\s+[\w-]+/g) || [];
            this.rules = ruleMatches.map(match => match.replace('(defrule ', ''));
        }
    }

    addFacts(facts) {
        this.facts.push(...facts);
    }
}

class GoldenTestRunner {
    constructor() {
        this.engine = new MockEtherneyEngine();
        this.results = [];
    }

    async runTest(testPath) {
        try {
            const testData = JSON.parse(fs.readFileSync(testPath, 'utf8'));
            const result = await this.executeTest(testData);
            
            this.results.push({
                testPath: testPath,
                testName: testData.name,
                ...result
            });
            
            return result;
            
        } catch (error) {
            const result = {
                success: false,
                error: error.message,
                duration: 0
            };
            
            this.results.push({
                testPath: testPath,
                testName: 'unknown',
                ...result
            });
            
            return result;
        }
    }

    async executeTest(testData) {
        const startTime = Date.now();
        
        try {
            // Load the pack
            const packPath = testData.pack;
            if (fs.existsSync(packPath)) {
                this.engine.loadPack(packPath);
            }
            
            // Build program from facts and query
            let program = '';
            
            // Add facts
            if (testData.facts) {
                for (const fact of testData.facts) {
                    program += fact.form + '\n';
                }
            }
            
            // Add query
            if (testData.query) {
                program += testData.query + '\n';
            }
            
            // Execute
            const result = await this.engine.evaluate({
                program: program,
                env: testData.env || {},
                budget: testData.budget || 10000
            });
            
            const endTime = Date.now();
            const duration = endTime - startTime;
            
            // Compare with expected result
            let success = true;
            let comparison = null;
            
            if (testData.expected && testData.expected !== 'TODO') {
                comparison = this.compareResults(result.value, testData.expected);
                success = comparison.matches;
            }
            
            return {
                success: success,
                duration: duration,
                result: result,
                expected: testData.expected,
                comparison: comparison
            };
            
        } catch (error) {
            const endTime = Date.now();
            const duration = endTime - startTime;
            
            return {
                success: false,
                error: error.message,
                duration: duration
            };
        }
    }

    compareResults(actual, expected) {
        // Simple comparison - in real implementation this would be more sophisticated
        try {
            const actualStr = JSON.stringify(actual, null, 2);
            const expectedStr = typeof expected === 'string' ? expected : JSON.stringify(expected, null, 2);
            
            return {
                matches: actualStr === expectedStr,
                actual: actualStr,
                expected: expectedStr,
                diff: actualStr !== expectedStr ? this.generateDiff(actualStr, expectedStr) : null
            };
        } catch (error) {
            return {
                matches: false,
                actual: String(actual),
                expected: String(expected),
                error: error.message
            };
        }
    }

    generateDiff(actual, expected) {
        // Simple diff - just show both values
        return {
            type: 'simple',
            actual: actual,
            expected: expected
        };
    }

    async runAllTests(baseDir = 'packs/legal') {
        const testFiles = this.findGoldenTests(baseDir);
        
        console.log(`Found ${testFiles.length} golden tests`);
        
        for (const testFile of testFiles) {
            const relativePath = path.relative(process.cwd(), testFile);
            console.log(`Running: ${relativePath}`);
            
            const result = await this.runTest(testFile);
            
            if (result.success) {
                console.log(`  ✅ PASS (${result.duration}ms)`);
            } else {
                console.log(`  ❌ FAIL (${result.duration}ms)`);
                if (result.error) {
                    console.log(`     Error: ${result.error}`);
                }
                if (result.comparison && !result.comparison.matches) {
                    console.log(`     Expected: ${result.comparison.expected}`);
                    console.log(`     Actual: ${result.comparison.actual}`);
                }
            }
        }
        
        return this.generateReport();
    }

    findGoldenTests(baseDir) {
        const testFiles = [];
        
        function traverse(dir) {
            if (!fs.existsSync(dir)) return;
            
            const entries = fs.readdirSync(dir, { withFileTypes: true });
            
            for (const entry of entries) {
                const fullPath = path.join(dir, entry.name);
                
                if (entry.isDirectory()) {
                    traverse(fullPath);
                } else if (entry.name.endsWith('.json') && fullPath.includes('tests/golden/')) {
                    testFiles.push(fullPath);
                }
            }
        }
        
        traverse(baseDir);
        return testFiles;
    }

    generateReport() {
        const totalTests = this.results.length;
        const passedTests = this.results.filter(r => r.success).length;
        const failedTests = totalTests - passedTests;
        const totalDuration = this.results.reduce((sum, r) => sum + r.duration, 0);
        
        const report = {
            summary: {
                total: totalTests,
                passed: passedTests,
                failed: failedTests,
                passRate: totalTests > 0 ? (passedTests / totalTests * 100).toFixed(1) : 0,
                totalDuration: totalDuration
            },
            tests: this.results
        };
        
        // Write report to file
        const reportsDir = 'reports';
        if (!fs.existsSync(reportsDir)) {
            fs.mkdirSync(reportsDir, { recursive: true });
        }
        
        const reportPath = path.join(reportsDir, `golden-tests-${Date.now()}.json`);
        fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
        
        console.log(`\nTest Summary:`);
        console.log(`  Total: ${totalTests}`);
        console.log(`  Passed: ${passedTests}`);
        console.log(`  Failed: ${failedTests}`);
        console.log(`  Pass Rate: ${report.summary.passRate}%`);
        console.log(`  Duration: ${totalDuration}ms`);
        console.log(`  Report: ${reportPath}`);
        
        return report;
    }
}

function main() {
    const args = process.argv.slice(2);
    const runner = new GoldenTestRunner();
    
    if (args.length === 0) {
        // Run all tests
        runner.runAllTests().then(report => {
            if (report.summary.failed > 0) {
                process.exit(1);
            }
        }).catch(error => {
            console.error('Test run failed:', error);
            process.exit(1);
        });
    } else {
        // Run specific test
        const testPath = args[0];
        runner.runTest(testPath).then(result => {
            if (!result.success) {
                process.exit(1);
            }
        }).catch(error => {
            console.error('Test failed:', error);
            process.exit(1);
        });
    }
}

if (require.main === module) {
    main();
}

module.exports = { GoldenTestRunner, MockEtherneyEngine };