# bid-compass

> Guided RFP generation and evaluation with mandatory quality gates.

## What it does

**Generate mode**: Walks you from a demand statement to a complete RFP package — RFP document, pricing template, scoring matrix. Quality gates prevent bad RFPs from going out (no budget, no weights, response window too short).

**Evaluate mode**: Takes vendor responses and your scoring matrix; checks mandatory gates first (no scoring of ineligible vendors), then produces evidence-based weighted scoring with a recommendation, risks, and a negotiation brief.

## What makes it different from "generate an RFP"

The whole point is **guidance**. The skill *will* push back if:
- You haven't defined the business problem (not the artefact)
- You skip scoring weights or have one criterion >50% without justification
- Mandatory requirements aren't separated from scored requirements
- Response window is too short
- Vendor responses are scored without checking gates first

You can override anything, but you'll be told and it'll be noted in the output.

## How to customise

Edit `config.yaml`:
- Quality gates (enable/disable, justification overrides)
- Scoring scale (1-5, 1-10, 0-100)
- Category scoring templates (SaaS, Professional Services, Hardware, Agency, Facilities)
- Timeline defaults
- RFP document section structure

Edit `references/category-advice.md` to add your own category tips.

## Files

```
bid-compass/
├── SKILL.md
├── config.yaml                              # YOUR settings
├── README.md
├── references/
│   └── category-advice.md                   # category-specific tips
├── templates/
│   ├── rfp-base.docx                        # base RFP document (TODO: ship)
│   ├── scoring-matrix.xlsx                  # scoring template (TODO: ship)
│   └── pricing-template.xlsx                # vendor pricing template (TODO: ship)
└── examples/
    ├── sample-rfp-generation.md             # worked example: generate mode
    └── sample-evaluation.md                 # worked example: evaluate mode
```
