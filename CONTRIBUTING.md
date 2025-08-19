# Contributing to Etherney-LISP Legal Knowledge Packs

Thank you for your interest in contributing to this legal knowledge representation project! This document provides guidelines for contributing to the monorepo.

## 🚨 Critical Guidelines

### NO NORMATIVE TEXT WITHOUT SOURCES

**⚠️ ABSOLUTE REQUIREMENT**: Never include actual statutory text, case law, regulations, or any normative legal content without proper source citations and verification. All contributions must use placeholder text and TODO markers for normative content.

### Legal Disclaimer

This project is for knowledge representation research and development only. Contributors must not:
- Include actual legal advice
- Copy copyrighted legal materials without permission
- Create content that could be construed as legal counsel
- Include jurisdiction-specific legal interpretations without expert review

## 📋 Contribution Types

### 1. New Knowledge Packs

Use the scaffolding tool to create new packs:

```bash
./tools/scaffold.sh <JURISDICTION> <field> [pack-name]
```

**Requirements:**
- Complete manifest.json with proper metadata
- README.md with coverage checklist
- Stub rules with metadata headers
- Test cases (golden and unit)
- CHANGELOG.md initialization

### 2. Pack Enhancements

When enhancing existing packs:
- Update CHANGELOG.md with changes
- Increment version in manifest.json
- Add/update test cases
- Review and update coverage checklist
- Ensure all rules have proper metadata

### 3. Tooling Improvements

For tools and infrastructure:
- Maintain backward compatibility
- Add comprehensive error handling
- Include usage documentation
- Add test cases where applicable

### 4. Documentation

- Keep documentation current with code changes
- Use clear, professional language
- Include examples where helpful
- Maintain consistent formatting

## 🔧 Development Workflow

### Setup

```bash
# Fork and clone the repository
git clone <your-fork-url>
cd etherney-lisp-legal-knowledgepacks

# Install dependencies
npm run setup

# Create feature branch
git checkout -b feature/your-feature-name
```

### Before Committing

```bash
# Validate all packs
npm run validate

# Lint .ether files
npm run lint

# Run tests
npm run test

# Build packages (optional)
npm run build
```

### Commit Guidelines

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature or pack
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Examples:
```
feat(packs): add PH labor law employment contracts pack

fix(tools): correct manifest validation for optional fields

docs(readme): update installation instructions
```

## 📝 Code Style

### .ether Files

```lisp
; Etherney-LISP Legal Knowledge Pack: [Jurisdiction] [Field]
; Non-normative stub rules for demonstration purposes only

; sources: TODO
; owner: TODO
; last-reviewed: YYYY-MM-DD
; jurisdiction: [PH|GLOBAL]
; notes: [Description of rule purpose]
(defrule rule-name :priority [1-100] :cf [0.0-1.0]
  (and (condition1 ?var1:type) (condition2 ?var2:type))
  (conclusion ?var1 ?var2))
```

### JavaScript/Node.js

- Use ES6+ features appropriately
- Include comprehensive error handling
- Add JSDoc comments for functions
- Follow consistent naming conventions
- Use meaningful variable names

### JSON

- Use 2-space indentation
- Sort object keys alphabetically where logical
- Include all required fields
- Use consistent date formats (YYYY-MM-DD)

## 🧪 Testing Requirements

### Golden Tests

Every pack must include at least 2 golden tests:

```json
{
  "name": "descriptive-test-name",
  "pack": "packs/legal/JURISDICTION/field",
  "facts": [
    { "form": "(predicate arg1 arg2)" }
  ],
  "query": "(begin (run))",
  "expected": "TODO"
}
```

### Unit Tests

Every pack must include at least 1 unit test:

```lisp
(deftest test-rule-name
  "Test description"
  (given
    (fact1 value1)
    (fact2 value2))
  (expect
    (conclusion value1 value2)))
```

## 📊 Metadata Requirements

### Rule Metadata

Every rule must have a complete metadata block:

```lisp
; sources: TODO - [Specific statute/case/regulation]
; owner: TODO - [Domain expert or maintainer]
; last-reviewed: YYYY-MM-DD
; jurisdiction: [PH|GLOBAL]
; notes: TODO - [Rule purpose and context]
```

### Manifest Completeness

All manifest.json files must include:
- Proper semantic versioning
- Complete source placeholders
- Maintainer information (can be TODO)
- Review status and date
- Engine requirements

## 🔍 Review Process

### Self-Review Checklist

Before submitting:
- [ ] No normative legal content included
- [ ] All rules have complete metadata
- [ ] Tests pass (`npm run test`)
- [ ] Validation passes (`npm run validate`)
- [ ] Linting passes (`npm run lint`)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (for pack changes)

### Pull Request Requirements

Include in PR description:
- Clear description of changes
- Rationale for modifications
- Testing performed
- Any breaking changes
- Related issues (if applicable)

### Review Criteria

Reviewers will check:
- Compliance with non-normative content policy
- Code quality and consistency
- Test coverage and quality
- Documentation completeness
- Metadata accuracy

## 🏗️ Architecture Guidelines

### Pack Organization

```
packs/legal/JURISDICTION/field/
├── manifest.json          # Required
├── README.md             # Required
├── main.ether            # Required
├── CHANGELOG.md          # Required
├── facts.example.ether   # Optional
└── tests/
    ├── golden/           # Required (≥2 tests)
    └── unit/             # Required (≥1 test)
```

### Naming Conventions

- **Jurisdictions**: Use ISO-style codes (PH, GLOBAL, US, EU)
- **Fields**: Use kebab-case (civil-law, criminal-law)
- **Subfields**: Use path notation (civil-law/succession)
- **Rules**: Use kebab-case (identify-heir, assess-liability)
- **Files**: Use kebab-case for consistency

### Extensibility

Design for future expansion:
- Use generic rule patterns where possible
- Avoid hardcoded jurisdiction-specific values
- Include extension points in rule hierarchies
- Document assumptions and limitations

## 🚀 Release Process

### Version Management

- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update manifest.json version for pack changes
- Document changes in CHANGELOG.md
- Tag releases appropriately

### Quality Gates

All releases must pass:
1. Validation (`npm run validate`)
2. Linting (`npm run lint`)
3. Testing (`npm run test`)
4. Building (`npm run build`)
5. Manual review

## 🤝 Community

### Getting Help

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Documentation**: Check docs/ directory first

### Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). Please read and follow it in all interactions.

## 📚 Resources

### Legal Knowledge Representation

- Focus on structural representation, not content
- Use generic predicates and relationships
- Model legal reasoning patterns, not specific laws
- Emphasize reusability across jurisdictions

### Technical Resources

- [Etherney-LISP Documentation](docs/)
- [JSON Schema Validation](tools/validate.js)
- [Linting Rules](tools/lint-ether.js)
- [Testing Framework](tools/test-macros.ether)

---

**Remember**: This project is about building tools and frameworks for legal knowledge representation, not providing legal content or advice. Always maintain this distinction in your contributions.