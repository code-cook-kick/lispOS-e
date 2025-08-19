# 🏠 Family Estate Calculator - Practical Application

A real-world demonstration of the Etherney eLISP Legal Reasoning System for inheritance calculations.

## Overview

The Family Estate Calculator is a practical command-line application that helps families understand how estates will be distributed according to Philippine succession law. It demonstrates the power of our Etherney eLISP system for real-world legal calculations.

## Features

### 🧮 Inheritance Calculations
- **Intestate Succession** (no will): Automatic distribution according to law
- **Testate Succession** (with will): Handles partial wills and remainder distribution
- **Mixed Scenarios**: Combines will provisions with intestate rules
- **Mathematical Precision**: All shares sum to exactly 100%

### 👥 Family Structures Supported
- Spouse only
- Children only  
- Spouse + children (spouse gets 25%, children share 75%)
- Complex families with multiple heirs
- Single-parent scenarios

### ⚖️ Legal Compliance
- Based on Philippine Civil Code Articles 979-996
- Follows Article 996 for spouse and children distributions
- Handles partial intestacy (Article 960)
- Provides legal basis citations for all calculations

## Usage

### Interactive Calculator
```bash
npm run estate-calculator
```

The interactive calculator will ask you:
- Name of deceased person
- Total estate value (PHP)
- Whether there's a will and coverage percentage
- Family structure (spouse, children count)

### Demo Mode
```bash
npm run demo-calculator
```

Runs automated demonstrations with 5 different family scenarios:
1. **Young couple with 2 children** - Typical family (5M PHP estate)
2. **Widow with 3 adult children** - No spouse scenario (10M PHP estate)
3. **Childless couple** - Spouse inherits all (2M PHP estate)
4. **Single parent with 1 child** - Simple inheritance (3M PHP estate)
5. **Large family** - Spouse + 5 children (15M PHP estate)

## Example Output

```
📊 SCENARIO: Young couple with 2 children
Estate Value: 5,000,000 PHP
Distribution:
  - spouse: 25% (calculated: 5,000,000 × 0.25 = 1,250,000 PHP)
  - child: 37.5% (calculated: 5,000,000 × 0.375 = 1,875,000 PHP)
  - child: 37.5% (calculated: 5,000,000 × 0.375 = 1,875,000 PHP)

⚖️ Legal Basis: Articles 979-996 (Intestate succession)
   Article 996 (Spouse gets 1/4, children share 3/4)

Note: All amounts are dynamically calculated by the eLISP system
```

## Technical Implementation

### Architecture
- **Frontend**: Node.js command-line interface with readline
- **Backend**: Etherney eLISP legal reasoning engine
- **Logic**: Pure functional programming in eLISP
- **Calculations**: Dynamic mathematical computations (no hardcoded results)

### Key eLISP Functions
```lisp
; Calculate intestate succession
(define calculate-intestate
  (lambda (spouse? children-count)
    ; Returns list of (role share) pairs
    ))

; Calculate testate succession  
(define calculate-testate
  (lambda (bequests-total spouse? children-count)
    ; Handles partial wills + remainder distribution
    ))

; Validate mathematical correctness
(define validate-shares
  (lambda (shares)
    ; Ensures shares sum to 1.0
    ))
```

### Lambda Arity Compliance
All lambda expressions follow the Etherney eLISP rule of exactly 2 arguments:
- `(lambda (params) (single-body-expression))`
- Multi-statement bodies use `(begin ...)` construct
- Recursive functions properly structured
- Higher-order functions supported

## Real-World Applications

### 🏛️ Legal Practice
- **Estate Planning**: Help clients understand inheritance distributions
- **Probate Cases**: Calculate legal shares for court proceedings  
- **Family Mediation**: Provide objective calculations for disputes
- **Legal Education**: Teach succession law with interactive examples

### 👨‍👩‍👧‍👦 Family Use
- **Estate Planning**: Understand how assets will be distributed
- **Financial Planning**: Plan for inheritance scenarios
- **Education**: Learn about Philippine succession law
- **Decision Making**: Make informed choices about wills

### 🏢 Professional Services
- **Law Firms**: Automate routine inheritance calculations
- **Financial Advisors**: Provide estate planning insights
- **Notaries**: Assist with will preparation
- **Insurance**: Calculate beneficiary distributions

## Advantages of eLISP Implementation

### 🔍 Transparency
- All calculations are visible and auditable
- Legal reasoning is explicit in the code
- No "black box" algorithms

### 🎯 Accuracy
- Mathematical precision guaranteed
- Based directly on legal statutes
- Comprehensive test coverage

### 🔧 Maintainability
- Pure functional programming
- Easy to modify for law changes
- Comprehensive documentation

### 🚀 Extensibility
- Can add new legal domains
- Supports complex legal scenarios
- Modular architecture

## Future Enhancements

### 📋 Planned Features
- **Legitime Protection**: Automatic correction of invalid wills
- **Web Interface**: Browser-based calculator
- **Multiple Jurisdictions**: Support for other countries' laws
- **Complex Wills**: Conditional bequests and trusts
- **Reporting**: PDF generation of inheritance reports

### 🌐 Integration Possibilities
- **Legal Software**: Plugin for case management systems
- **Government Systems**: Integration with civil registry
- **Banking**: Estate settlement automation
- **Insurance**: Beneficiary calculation systems

## Testing

The application includes comprehensive testing:
- **Unit Tests**: Individual function testing
- **Integration Tests**: End-to-end scenario testing  
- **Legal Compliance Tests**: Verification against Civil Code
- **Mathematical Tests**: Precision and accuracy validation

Run tests:
```bash
npm run test-comprehensive  # Full test suite
npm run test-lambda        # Lambda-specific tests
npm run demo-calculator    # Live demonstration
```

## Legal Disclaimer

This calculator is for educational and informational purposes only. While based on Philippine Civil Code provisions, actual legal cases may involve additional complexities not covered by this simplified implementation. Always consult qualified legal professionals for official legal advice.

## Technical Support

For technical issues or feature requests:
- Check the comprehensive test suite for examples
- Review `src/lisp/practical-usage-example.lisp` for detailed scenarios
- Run `npm run demo-calculator` for working examples
- Examine the eLISP source code for implementation details

---

**Powered by Etherney eLISP Legal Reasoning System**  
*Demonstrating practical applications of functional legal programming*