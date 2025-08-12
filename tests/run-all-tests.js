/**
 * Test Runner - Runs all test suites
 * Execute with: node tests/run-all-tests.js
 */

const TokenizerTests = require('./tokenizer.test.js');
const ParserTests = require('./parser.test.js');
const EvaluatorTests = require('./evaluator.test.js');
const IntegrationTests = require('./integration.test.js');

function runAllTests() {
    console.log('🧪 Etherney Lisp Machine - Test Suite');
    console.log('=====================================');
    
    const startTime = Date.now();
    let totalPassed = 0;
    let totalFailed = 0;
    let allTestsPassed = true;

    // Run each test suite
    const testSuites = [
        { name: 'Tokenizer', runner: TokenizerTests },
        { name: 'Parser', runner: ParserTests },
        { name: 'Evaluator', runner: EvaluatorTests },
        { name: 'Integration', runner: IntegrationTests }
    ];

    for (const suite of testSuites) {
        console.log(`\n📋 Running ${suite.name} Tests...`);
        const runner = new suite.runner();
        const success = runner.run();
        
        totalPassed += runner.passed;
        totalFailed += runner.failed;
        
        if (!success) {
            allTestsPassed = false;
        }
    }

    // Final summary
    const endTime = Date.now();
    const duration = endTime - startTime;
    
    console.log('\n' + '='.repeat(50));
    console.log('📊 FINAL TEST SUMMARY');
    console.log('='.repeat(50));
    console.log(`Total Tests: ${totalPassed + totalFailed}`);
    console.log(`✅ Passed: ${totalPassed}`);
    console.log(`❌ Failed: ${totalFailed}`);
    console.log(`⏱️  Duration: ${duration}ms`);
    console.log(`📈 Success Rate: ${((totalPassed / (totalPassed + totalFailed)) * 100).toFixed(1)}%`);
    
    if (allTestsPassed) {
        console.log('\n🎉 ALL TESTS PASSED! 🎉');
        console.log('The Etherney Lisp Machine is working correctly.');
    } else {
        console.log('\n💥 SOME TESTS FAILED 💥');
        console.log('Please review the failed tests above.');
    }
    
    console.log('\n' + '='.repeat(50));
    
    return allTestsPassed;
}

// Run tests if this file is executed directly
if (require.main === module) {
    const success = runAllTests();
    process.exit(success ? 0 : 1);
}

module.exports = runAllTests;