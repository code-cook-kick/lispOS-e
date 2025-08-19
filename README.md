# Etherney-LISP Legal Knowledge Packs

A complete, production-quality monorepo for jurisdiction-aware legal knowledge packs designed for the Etherney-LISP symbolic reasoning engine. This repository provides comprehensive coverage of legal domains with maximum breadth and future extensibility.

## 🏛️ Overview

This monorepo organizes **jurisdiction-aware legal rulepacks** for symbolic reasoning applications. It includes:

- **Comprehensive Legal Taxonomy**: Complete coverage of legal fields for PH (Philippines) and GLOBAL jurisdictions
- **Production-Ready Tooling**: Validation, linting, building, and testing tools
- **Multiple Interfaces**: Browser demo and server-side evaluation interfaces
- **Extensible Architecture**: Template-based scaffolding for new jurisdictions and legal fields

## 📁 Repository Structure

```
etherney-lisp-legal-knowledgepacks/
├── packs/legal/           # Legal knowledge packs by jurisdiction
│   ├── PH/               # Philippines legal packs
│   └── GLOBAL/           # Cross-border/international law packs
├── tools/                # CLI tools and utilities
├── webapp/               # Browser-based demo interface
├── server/               # Server-side evaluation interface
├── docs/                 # Documentation
└── reports/              # Test and build reports
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18.0.0 or higher
- npm (comes with Node.js)
- bash (for scaffolding scripts)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd etherney-lisp-legal-knowledgepacks

# Install dependencies
npm run setup
```

### Basic Usage

```bash
# Validate all knowledge packs
npm run validate

# Lint .ether files
npm run lint

# Build packages
npm run build

# Run golden tests
npm run test

# Start server interface
npm run server

# Start browser demo
npm run webapp
```

## 📚 Legal Domain Coverage

### Philippines (PH)
- Constitutional Law
- Administrative Law
- Civil Law (Obligations, Contracts, Property, Family, Succession, Torts)
- Criminal Law
- Evidence & Procedure
- Labor & Employment
- Tax Law
- Commercial & Corporate
- And 25+ more specialized fields

### Global (GLOBAL)
- Public International Law
- Private International Law
- Human Rights
- Environmental Law
- Maritime & Admiralty
- And comprehensive international coverage

## 🛠️ Tools & Scripts

### Core Tools

- **`tools/scaffold.sh`** - Create new legal knowledge packs
- **`tools/validate.js`** - Validate pack structure and metadata
- **`tools/lint-ether.js`** - Lint .ether files for compliance
- **`tools/lint-cons.js`** - Detect unsafe cons usage patterns
- **`tools/codemod-cons.js`** - Automatically fix cons misuse
- **`tools/build-packs.js`** - Build and package knowledge packs
- **`tools/run-golden.js`** - Execute golden test suites

### Cons Safety Guidelines

**⚠️ IMPORTANT**: Our Etherney eLISP interpreter enforces strict cons usage. The second argument to `cons` must always be a list, never a scalar value.

#### Safe Patterns

```lisp
; ✅ GOOD: Second argument is a list
(cons 'item '())
(cons 'item '(1 2 3))
(cons 'item (list 1 2 3))

; ✅ GOOD: Use safe utilities
(list 'key 'value)           ; For 2-tuples
(kv 'key 'value)            ; For alist entries
(cons 'item (ensure-list x)) ; When x might not be a list
```

#### Unsafe Patterns

```lisp
; ❌ BAD: Will cause runtime error
(cons 'key 'value)    ; Second arg is scalar
(cons 'item 42)       ; Second arg is number
(cons 'a "string")    ; Second arg is string
```

#### Migration Tools

```bash
# Check for cons misuse
node tools/lint-cons.js

# Preview fixes (dry run)
node tools/codemod-cons.js --dry-run

# Apply fixes automatically
node tools/codemod-cons.js

# Run cons safety tests
node tests/cons_misuse_tests.lisp
```

### Lambda Arity Rule

**⚠️ IMPORTANT**: Our Etherney eLISP interpreter enforces strict lambda arity. Lambda expressions must have exactly 2 arguments: `(lambda <params> <single-body-expr>)`.

#### Safe Patterns

```lisp
; ✅ GOOD: Single body expression
(lambda (x) (+ x 1))
(lambda (x y) (* x y))

; ✅ GOOD: Multiple statements wrapped in begin
(lambda (x y)
  (begin
    (define temp (+ x y))
    (define result (* temp 2))
    result))

; ✅ GOOD: Explicit define form (preferred)
(define my-func (lambda (args) body))
```

#### Unsafe Patterns

```lisp
; ❌ BAD: Multiple body expressions without begin
(lambda (x y)
  (define temp (+ x y))
  (define result (* temp 2))
  result)

; ❌ BAD: Define sugar syntax (gets expanded)
(define (my-func args) body1 body2)
```

#### Migration Tools

```bash
# Check for lambda arity violations
node tools/lint-lambda.js

# Preview fixes (dry run)
node tools/codemod-lambda.js --dry-run

# Apply fixes automatically
node tools/codemod-lambda.js

# Run lambda arity tests
node tests/lambda_arity_tests.lisp
```

### Usage Examples

```bash
# Create a new pack
./tools/scaffold.sh PH labor-law/employment-contracts

# Validate specific pack
node tools/validate.js packs/legal/PH/civil-law/succession

# Lint all .ether files
node tools/lint-ether.js packs/legal

# Build all packs
node tools/build-packs.js

# Run tests for specific pack
node tools/run-golden.js packs/legal/PH/criminal-law/tests/golden/criminal-basic.json
```

## 🌐 Interfaces

### Browser Demo (`webapp/`)

A client-side interface for testing knowledge packs:

```bash
npm run webapp
# Visit http://localhost:8080
```

Features:
- Load predefined or custom knowledge packs
- Interactive program evaluation
- Real-time results with trace visualization
- No server dependencies

### Server Interface (`server/`)

A server-side rendered interface with enhanced features:

```bash
npm run server
# Visit http://localhost:3000
```

Features:
- Knowledge pack auto-discovery
- File upload support
- Deterministic run hashing
- Production-ready security headers

## 📋 Knowledge Pack Structure

Each knowledge pack contains:

```
pack-name/
├── manifest.json         # Pack metadata and configuration
├── README.md            # Documentation and coverage checklist
├── main.ether           # Primary rule definitions
├── CHANGELOG.md         # Version history
├── facts.example.ether  # Optional example facts
└── tests/
    ├── golden/          # Integration test cases
    └── unit/            # Unit test cases
```

### Manifest Schema

```json
{
  "id": "legal.ph.civil-law.succession",
  "version": "0.1.0",
  "jurisdiction": "PH",
  "field": "civil-law/succession",
  "description": "Stub rules for PH succession law",
  "sources": [{"title": "TODO", "citation": "", "url": ""}],
  "maintainers": [{"name": "TODO", "email": "", "role": "domain-owner"}],
  "review": {"lastReviewed": "2025-08-15", "status": "draft"},
  "engine": {"minVersion": "2.0.0", "features": ["defrule", "typed-vars"]},
  "integrity": {"hash": "", "algo": "sha256"}
}
```

## 🔒 Security & Compliance

### Non-Normative Content

**⚠️ IMPORTANT**: All knowledge packs contain only structural stubs and placeholders. No actual statutory text, case law, or normative legal content is included. All rules are generic examples for testing the knowledge representation system only.

### Rule Metadata Requirements

Every rule must include metadata headers:

```lisp
; sources: TODO
; owner: TODO
; last-reviewed: 2025-08-15
; jurisdiction: PH
; notes: Generic stub rule description
(defrule example-rule :priority 50 :cf 0.8
  (and (condition ?x) (constraint ?x ?y))
  (conclusion ?x ?y))
```

## 🧪 Testing

### Golden Tests

Integration tests that verify end-to-end behavior:

```json
{
  "name": "basic-succession-test",
  "pack": "packs/legal/PH/civil-law/succession",
  "facts": [{"form": "(heir spouse)"}],
  "query": "(begin (run))",
  "expected": "TODO"
}
```

### Unit Tests

Rule-level tests using the `deftest` macro:

```lisp
(deftest test-heir-identification
  "Test basic heir identification rule"
  (given (person alice) (deceased bob))
  (expect (potential-heir alice bob spouse)))
```

## 🔄 CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/ci.yml`):

1. **Validate** - Check pack structure and metadata
2. **Lint** - Verify .ether file compliance
3. **Build** - Package knowledge packs
4. **Test** - Execute golden test suites
5. **Report** - Generate and upload artifacts

## 📖 Contributing

### Guidelines

1. **No Normative Content**: Never include actual legal text without proper sources
2. **Metadata Required**: All rules must have complete metadata headers
3. **Test Coverage**: Include both golden and unit tests
4. **Documentation**: Update README and coverage checklists

### Adding New Packs

```bash
# Use the scaffolding tool
./tools/scaffold.sh JURISDICTION field/subfield [pack-name]

# Example: Create US constitutional law pack
./tools/scaffold.sh US constitutional-law
```

### Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## 🤝 Support

- **Issues**: Report bugs and request features via GitHub Issues
- **Documentation**: Comprehensive guides available in `docs/`
- **Community**: Join discussions in GitHub Discussions

## 🗺️ Roadmap

- [ ] Additional jurisdictions (US, EU, UK, etc.)
- [ ] Enhanced rule conflict detection
- [ ] Integration with external legal databases
- [ ] Advanced reasoning capabilities
- [ ] Multi-language support

---

**Disclaimer**: This is a knowledge representation system for legal reasoning research and development. It is not intended to provide legal advice or replace qualified legal counsel.