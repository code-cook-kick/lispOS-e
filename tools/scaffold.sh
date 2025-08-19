#!/bin/bash
# Scaffold a new legal knowledge pack

set -e

usage() {
    echo "Usage: $0 <jurisdiction> <field> [pack-name]"
    echo "Example: $0 PH civil-law/contracts"
    echo "Example: $0 GLOBAL human-rights"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

JURISDICTION="$1"
FIELD="$2"
PACK_NAME="${3:-$(basename "$FIELD")}"

# Validate jurisdiction
if [[ "$JURISDICTION" != "PH" && "$JURISDICTION" != "GLOBAL" ]]; then
    echo "Error: Jurisdiction must be PH or GLOBAL"
    exit 1
fi

PACK_DIR="packs/legal/$JURISDICTION/$FIELD"

if [ -d "$PACK_DIR" ]; then
    echo "Error: Pack directory already exists: $PACK_DIR"
    exit 1
fi

echo "Creating pack: $PACK_DIR"
mkdir -p "$PACK_DIR/tests/golden"
mkdir -p "$PACK_DIR/tests/unit"

# Generate manifest.json
cat > "$PACK_DIR/manifest.json" << EOF
{
  "id": "legal.$(echo $JURISDICTION | tr '[:upper:]' '[:lower:]').$(echo $FIELD | tr '/' '.')",
  "version": "0.1.0",
  "entry": "main.ether",
  "exports": [],
  "jurisdiction": "$JURISDICTION",
  "field": "$FIELD",
  "description": "Stub rules and structure for $JURISDICTION $FIELD.",
  "sources": [
    { "title": "TODO", "citation": "", "url": "" }
  ],
  "maintainers": [
    { "name": "TODO", "email": "", "role": "domain-owner" }
  ],
  "review": {
    "lastReviewed": "$(date +%Y-%m-%d)",
    "status": "draft"
  },
  "engine": {
    "minVersion": "2.0.0",
    "features": ["defrule", "typed-vars", "priority", "cf"]
  },
  "integrity": {
    "hash": "",
    "algo": "sha256"
  }
}
EOF

# Generate README.md
cat > "$PACK_DIR/README.md" << EOF
# $JURISDICTION $(echo $FIELD | tr '/' ' - ' | sed 's/\b\w/\U&/g')

## Purpose and Scope

This pack contains stub rules and structure for $JURISDICTION $FIELD. This is a **non-normative stub** for demonstration and testing purposes only.

## Coverage Checklist (TODOs)

- [ ] TODO: Add coverage items

## Sources (TODOs)

- [ ] TODO: Add source references

## Disclaimer

This pack contains only structural stubs and placeholders. No actual statutory text, case law, or normative legal content is included. All rules are generic examples for testing the knowledge representation system only.

## Usage

Load this pack into the Etherney-LISP engine along with appropriate fact assertions to test $FIELD scenarios.

## Maintainer Notes

- All rules require proper source citations before production use
- Test cases need review by qualified legal practitioners
EOF

# Generate main.ether
cat > "$PACK_DIR/main.ether" << EOF
; Etherney-LISP Legal Knowledge Pack: $JURISDICTION $(echo $FIELD | tr '/' ' - ')
; Non-normative stub rules for demonstration purposes only

; sources: TODO
; owner: TODO
; last-reviewed: $(date +%Y-%m-%d)
; jurisdiction: $JURISDICTION
; notes: Generic stub rule for $PACK_NAME
(defrule example-rule :priority 100 :cf 0.8
  (and (example-predicate ?x:symbol) (example-condition ?x ?y:symbol))
  (example-conclusion ?x ?y))

; Example predicates for testing
(defpred example-predicate (symbol))
(defpred example-condition (symbol symbol))
EOF

# Generate golden test
cat > "$PACK_DIR/tests/golden/basic-test.json" << EOF
{
  "name": "basic-$PACK_NAME-test",
  "pack": "$PACK_DIR",
  "facts": [
    { "form": "(example-predicate test-item)" },
    { "form": "(example-condition test-item test-value)" }
  ],
  "query": "(begin (run))",
  "expected": "TODO"
}
EOF

# Generate unit test
cat > "$PACK_DIR/tests/unit/unit-test.ether" << EOF
; Unit tests for $JURISDICTION $FIELD rules
; Uses deftest macro for structured testing

(deftest test-example-rule
  "Test basic example rule"
  (given
    (example-predicate sample)
    (example-condition sample value))
  (expect
    (example-conclusion sample value)))
EOF

# Generate CHANGELOG.md
cat > "$PACK_DIR/CHANGELOG.md" << EOF
# Changelog

All notable changes to this pack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - $(date +%Y-%m-%d)

### Added
- Initial pack structure
- Basic stub rules for $FIELD
- Documentation and README
- Test framework

### Notes
- All rules are non-normative stubs
- Requires proper source citations before production use
- Test cases need legal practitioner review
EOF

echo "Pack created successfully at: $PACK_DIR"
echo "Next steps:"
echo "1. Update manifest.json with proper metadata"
echo "2. Add actual rules to main.ether"
echo "3. Create meaningful test cases"
echo "4. Update README.md with coverage checklist"