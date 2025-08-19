# Etherney-LISP Legal Knowledgepacks Repository Structure

```
etherney-lisp-legal-knowledgepacks/
├── README.md
├── package.json
├── .gitignore
├── LICENSE
├── CONTRIBUTING.md
├── packs/
│   └── legal/
│       ├── PH/
│       │   ├── constitutional-law/
│       │   │   ├── manifest.json
│       │   │   ├── README.md
│       │   │   ├── main.ether
│       │   │   ├── facts.example.ether
│       │   │   ├── CHANGELOG.md
│       │   │   └── tests/
│       │   │       ├── golden/
│       │   │       │   ├── basic-rights.json
│       │   │       │   ├── separation-powers.json
│       │   │       │   └── due-process.json
│       │   │       └── unit/
│       │   │           ├── constitutional-test.ether
│       │   │           └── rights-test.ether
│       │   ├── administrative-law/
│       │   │   ├── manifest.json
│       │   │   ├── README.md
│       │   │   ├── main.ether
│       │   │   ├── CHANGELOG.md
│       │   │   └── tests/
│       │   │       ├── golden/
│       │   │       └── unit/
│       │   ├── civil-law/
│       │   │   ├── obligations/
│       │   │   ├── contracts/
│       │   │   ├── property/
│       │   │   ├── family/
│       │   │   ├── succession/
│       │   │   │   ├── manifest.json
│       │   │   │   ├── README.md
│       │   │   │   ├── main.ether
│       │   │   │   ├── facts.example.ether
│       │   │   │   ├── CHANGELOG.md
│       │   │   │   └── tests/
│       │   │   │       ├── golden/
│       │   │   │       │   ├── intestate-succession.json
│       │   │   │       │   ├── testate-succession.json
│       │   │   │       │   └── legitime-calculation.json
│       │   │   │       └── unit/
│       │   │   │           ├── succession-test.ether
│       │   │   │           └── inheritance-test.ether
│       │   │   └── torts-and-damages/
│       │   ├── criminal-law/
│       │   │   ├── manifest.json
│       │   │   ├── README.md
│       │   │   ├── main.ether
│       │   │   ├── facts.example.ether
│       │   │   ├── CHANGELOG.md
│       │   │   └── tests/
│       │   │       ├── golden/
│       │   │       │   ├── felony-classification.json
│       │   │       │   ├── criminal-liability.json
│       │   │       │   └── penalties.json
│       │   │       └── unit/
│       │   │           ├── criminal-test.ether
│       │   │           └── liability-test.ether
│       │   ├── evidence/
│       │   ├── civil-procedure/
│       │   ├── criminal-procedure/
│       │   ├── labor-and-employment/
│       │   ├── tax-law/
│       │   ├── commercial-and-corporate/
│       │   ├── banking-finance-securities/
│       │   ├── intellectual-property/
│       │   ├── environmental-law/
│       │   ├── energy-and-utilities/
│       │   ├── land-and-real-estate/
│       │   ├── data-privacy-and-protection/
│       │   ├── human-rights/
│       │   ├── public-international-law/
│       │   ├── private-international-law/
│       │   ├── maritime-and-admiralty/
│       │   ├── transportation-and-aviation/
│       │   ├── health-law/
│       │   ├── education-law/
│       │   ├── election-law/
│       │   ├── local-government-law/
│       │   ├── government-procurement/
│       │   ├── anti-corruption-and-ethics/
│       │   ├── consumer-protection/
│       │   ├── insurance-law/
│       │   ├── immigration-law/
│       │   ├── telecommunications-and-ict/
│       │   ├── competition-and-antitrust/
│       │   ├── customs-and-trade/
│       │   └── mining-and-natural-resources/
│       └── GLOBAL/
│           ├── cross-border-transactions/
│           ├── international-arbitration/
│           ├── treaty-law/
│           └── comparative-law/
├── tools/
│   ├── scaffold.sh
│   ├── validate.js
│   ├── lint-ether.js
│   ├── run-golden.js
│   └── templates/
│       ├── manifest.template.json
│       ├── README.template.md
│       ├── main.template.ether
│       └── CHANGELOG.template.md
├── reports/
│   └── .gitkeep
├── docs/
│   ├── ARCHITECTURE.md
│   ├── PACK_DEVELOPMENT.md
│   ├── TESTING_GUIDE.md
│   └── JURISDICTION_GUIDE.md
└── scripts/
    ├── build.js
    ├── test-all.js
    └── deploy.js