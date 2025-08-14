# Philippine Testate Succession Module - Legal Documentation

## Executive Summary for Legal Practitioners

The Etherney eLisp Philippine Testate Succession Module provides comprehensive computational support for will-based inheritance cases under Philippine law. This system integrates seamlessly with the existing intestate succession module to handle complex succession scenarios involving both testamentary dispositions and intestate remainders.

## Legal Framework Implementation

### Philippine Civil Code Provisions Implemented

#### **Will Validity and Revocation (Art. 783-809)**
- **Statute**: `S-PH-WILL-VALIDITY` (Rank 1000)
- **Function**: Validates will existence and checks revocation status
- **Legal Basis**: Articles 783-809 of the Civil Code
- **Output**: Will status facts indicating validity

#### **Compulsory Heir Protection - Legitime (Art. 886-906)**
- **Statute**: `S-PH-WILL-LEGITIME` (Rank 950)
- **Function**: Protects compulsory heirs' minimum shares (legitime)
- **Legal Basis**: Articles 886-906 of the Civil Code
- **Protection**: Ensures 1/2 of estate reserved for compulsory heirs
- **Priority**: Second highest rank to ensure legitime cannot be violated

#### **Testamentary Dispositions - Legacies and Bequests (Art. 904-906)**
- **Statute**: `S-PH-WILL-LEGACIES` (Rank 900)
- **Function**: Applies specific and general legacies as directed by will
- **Legal Basis**: Articles 904-906 of the Civil Code
- **Features**: 
  - Conditional bequest evaluation
  - Missing legatee handling
  - Specific vs. general legacy distinction

#### **Residue Distribution (Art. 906)**
- **Statute**: `S-PH-WILL-RESIDUE` (Rank 850)
- **Function**: Distributes residual estate per will instructions
- **Legal Basis**: Article 906 of the Civil Code
- **Application**: After specific legacies are satisfied

#### **Partial Intestacy (Art. 960)**
- **Statute**: `S-PH-PARTIAL-INTESTACY` (Rank 800)
- **Function**: Handles portions of estate not covered by will
- **Legal Basis**: Article 960 of the Civil Code
- **Integration**: Automatically invokes intestate succession rules for uncovered portions

## Practical Application Guide

### Case Types Supported

#### **1. Complete Testamentary Disposition**
**Scenario**: Will covers entire estate with specific bequests and residue clause
```
Estate: 100%
- Specific legacies: 40%
- Residue clause: 60%
- Intestate portion: 0%
```
**System Response**: Applies legacies and residue distribution only

#### **2. Partial Testamentary Disposition**
**Scenario**: Will covers only portion of estate
```
Estate: 100%
- Specific legacies: 30%
- No residue clause
- Intestate portion: 70%
```
**System Response**: Applies legacies, then intestate succession for remainder

#### **3. Legitime Violation Scenario**
**Scenario**: Will attempts to give away more than allowed, violating compulsory heirs' rights
```
Estate: 100%
- Attempted bequest to non-compulsory heir: 80%
- Compulsory heirs (2): Should receive 50% minimum
```
**System Response**: Protects legitime first, then applies remaining dispositions

#### **4. Conditional Bequests**
**Scenario**: Will contains conditions that may or may not be met
```
"I leave 30% to John if he graduates from law school"
```
**System Response**: Evaluates conditions and applies bequests accordingly

### Precedence and Conflict Resolution

#### **Statute Ranking System**
1. **Will Validity** (Rank 1000) - Must be valid and not revoked
2. **Legitime Protection** (Rank 950) - Compulsory heirs' minimum shares
3. **Legacies** (Rank 900) - Specific testamentary dispositions
4. **Residue** (Rank 850) - Residual estate distribution
5. **Partial Intestacy** (Rank 800) - Intestate rules for remainder

#### **Conflict Resolution Process**
- Higher-ranked statutes take precedence
- Conflicting facts are marked with `:conflict-with` metadata
- Losing facts are preserved for audit purposes
- Legal basis is documented for each decision

### Provenance and Audit Trail

#### **Complete Fact Metadata**
Every inheritance fact includes:
- **`:basis`** - Statute that generated the fact
- **`:will-id`** - Identifier of the will document
- **`:bequest-id`** - Specific bequest reference (where applicable)
- **`:legal-basis`** - Civil Code article reference
- **`:heir-type`** - Classification (legatee, residue-heir, compulsory-heir)

#### **Audit Capabilities**
- Track all decisions back to specific will provisions
- Identify conflicts and their resolution
- Verify mathematical accuracy of share calculations
- Ensure legal compliance with Civil Code requirements

## Technical Integration Points

### Dynamic Lambda-Based Statutes

The system supports dynamic statute expansion through lambda functions, allowing for:
- **Runtime fact computation** based on specific case circumstances
- **Conditional logic** that adapts to different will structures
- **Interoperability** between testate and intestate succession modules

### Intestate Succession Integration

#### **Automatic Fallback Mechanism**
```lisp
;; If will is revoked or invalid, system automatically applies intestate rules
(define computed-facts-from
  (lambda (ev)
    (if (p-has-will ev)
        (apply-testate-succession ev)    ; Use testate rules
        (apply-intestate-succession ev)))) ; Fall back to intestate
```

#### **Partial Intestacy Scaling**
```lisp
;; Remaining estate portion is distributed per intestate rules
(define intestate-resolve
  (lambda (ev remainder)
    ;; Scales intestate shares by remainder fraction
    ;; Example: If 40% goes to intestate, each heir gets 40% of normal share
```

## Practical Examples

### Example 1: Simple Will with Residue
**Will Provisions**:
- "I leave 20% to my friend Maria"
- "I leave the residue to my children Pedro and Juan equally"

**System Processing**:
1. Validates will (not revoked)
2. Applies 20% legacy to Maria
3. Distributes remaining 80% equally between Pedro (40%) and Juan (40%)
4. **Total**: Maria 20%, Pedro 40%, Juan 40% = 100%

### Example 2: Will with Legitime Violation
**Will Provisions**:
- "I leave 90% to my friend Carlos"
- **Compulsory Heirs**: Two legitimate children

**System Processing**:
1. Validates will
2. **Legitime Protection**: Reserves 50% for compulsory heirs (25% each)
3. Applies remaining 50% to Carlos (not the intended 90%)
4. **Total**: Child1 25%, Child2 25%, Carlos 50% = 100%

### Example 3: Partial Intestacy
**Will Provisions**:
- "I leave 30% to my nephew Luis"
- No residue clause

**System Processing**:
1. Validates will
2. Applies 30% legacy to Luis
3. **Partial Intestacy**: Remaining 70% distributed per intestate rules
4. If deceased has spouse and 2 children: Spouse gets 17.5% (70% × 1/4), each child gets 26.25% (70% × 3/8)
5. **Total**: Luis 30%, Spouse 17.5%, Child1 26.25%, Child2 26.25% = 100%

## Error Handling and Edge Cases

### Common Scenarios Handled
- **Revoked Wills**: Automatic fallback to intestate succession
- **Missing Legatees**: Bequests to non-existent persons are ignored
- **Invalid Conditions**: Failed conditions result in bequest non-execution
- **Mathematical Errors**: Share totals are validated to sum to 1.0
- **Conflicting Provisions**: Higher-ranked statutes take precedence

### System Safeguards
- **Input Validation**: All will structures are validated before processing
- **Mathematical Verification**: Share calculations are checked for accuracy
- **Legal Compliance**: All outputs comply with Civil Code requirements
- **Audit Trail**: Complete provenance tracking for all decisions

## Conclusion

The Philippine Testate Succession Module provides a comprehensive, legally compliant system for processing will-based inheritance cases. The system's integration with intestate succession rules ensures complete coverage of all succession scenarios while maintaining strict adherence to Philippine Civil Code provisions.

The dynamic lambda-based architecture allows for flexible adaptation to complex will structures while preserving the mathematical precision and legal accuracy required for inheritance law practice.

---

**Legal Disclaimer**: This system is designed to assist legal practitioners in succession law analysis. All outputs should be reviewed by qualified legal professionals before use in actual legal proceedings. The system implements current Philippine Civil Code provisions as of the implementation date.

**Technical Support**: For technical questions about system operation, consult the comprehensive test suite and implementation documentation provided with the module.