const { LispTokenizer } = require('./src/tokenizer.js');

console.log("=== Testing Tokenizer with Dots in Symbols ===\n");

const testCases = [
    // Dotted symbols
    { input: 'event.make', expected: [['SYMBOL', 'event.make']] },
    { input: '(statute.with-weight S774.v1)', expected: [['LPAREN', '('], ['SYMBOL', 'statute.with-weight'], ['SYMBOL', 'S774.v1'], ['RPAREN', ')']] },
    
    // Numbers remain numbers
    { input: '3.14', expected: [['NUMBER', 3.14]] },
    { input: '-12.5', expected: [['NUMBER', -12.5]] },
    { input: '0.0', expected: [['NUMBER', 0.0]] },
    
    // Mixed
    { input: '(call event.make 3.14)', expected: [['LPAREN', '('], ['SYMBOL', 'call'], ['SYMBOL', 'event.make'], ['NUMBER', 3.14], ['RPAREN', ')']] },
    
    // Invalid cases
    { input: '.', shouldError: true, errorMessage: 'Invalid token: single dot' },
    { input: '..', shouldError: true },
    { input: '...', shouldError: true },
];

let passed = 0;
let failed = 0;

testCases.forEach((testCase, index) => {
    console.log(`Test ${index + 1}: ${testCase.input}`);
    
    try {
        const tokenizer = new LispTokenizer(testCase.input);
        const tokens = tokenizer.tokenize();
        
        if (testCase.shouldError) {
            console.log(`  ❌ FAIL: Expected error but got tokens: ${tokens.map(t => `${t.type}:${t.value}`).join(', ')}`);
            failed++;
            return;
        }
        
        // Filter out EOF token for comparison
        const actualTokens = tokens.filter(t => t.type !== 'EOF').map(t => [t.type, t.value]);
        
        // Compare with expected
        const expectedStr = JSON.stringify(testCase.expected);
        const actualStr = JSON.stringify(actualTokens);
        
        if (expectedStr === actualStr) {
            console.log(`  ✅ PASS: ${actualTokens.map(([type, value]) => `${type}:${value}`).join(', ')}`);
            passed++;
        } else {
            console.log(`  ❌ FAIL: Expected ${expectedStr}, got ${actualStr}`);
            failed++;
        }
        
    } catch (error) {
        if (testCase.shouldError) {
            if (testCase.errorMessage && error.message.includes(testCase.errorMessage)) {
                console.log(`  ✅ PASS: Correctly threw error: ${error.message}`);
                passed++;
            } else if (!testCase.errorMessage) {
                console.log(`  ✅ PASS: Correctly threw error: ${error.message}`);
                passed++;
            } else {
                console.log(`  ❌ FAIL: Wrong error message. Expected to contain "${testCase.errorMessage}", got: ${error.message}`);
                failed++;
            }
        } else {
            console.log(`  ❌ FAIL: Unexpected error: ${error.message}`);
            failed++;
        }
    }
    
    console.log();
});

console.log(`=== Results: ${passed} passed, ${failed} failed ===`);

if (failed === 0) {
    console.log("🎉 All tokenizer tests passed! Dots in symbols are working correctly.");
} else {
    console.log("❌ Some tests failed. Tokenizer needs more work.");
}