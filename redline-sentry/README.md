# redline-sentry

> Contract redlining for procurement — fast, opinionated, configurable.

## What it does

Drop a contract (NDA, MSA, DPA, SaaS agreement, SOW). Get back:
- Overall risk rating and recommendation
- Critical issues that must be fixed before signing
- Issues to negotiate with suggested redlines
- Missing clauses
- A negotiation cheat sheet (top 3 asks, what to concede, walk-away triggers)

Optionally produces a DOCX with tracked changes.

## How to customise it

Edit `config.yaml`. The defaults are sensible for typical B2B procurement under English law, but the real value comes from setting your own:
- Liability cap minimum (12 months? 24 months?)
- Payment terms (NET-30? NET-60?)
- Jurisdiction defaults
- Contract value threshold (when to relax)
- Contract-type-specific rules (NDA term, DPA strictness)

Every clause check is driven by this file. Don't touch SKILL.md unless you want to change the logic itself.

## What it is not

It is not legal advice. It is a structured first-pass review by an opinionated procurement reviewer. A qualified lawyer should approve anything you sign.

## Example

See `examples/sample-nda-review.md`.

## Files

```
redline-sentry/
├── SKILL.md                          # the skill itself
├── config.yaml                       # YOUR editable playbook
├── README.md                         # this file
├── templates/
│   ├── default-playbook.yaml         # read-only reference defaults
│   └── redline-output.docx           # base doc for DOCX output (TODO: ship)
└── examples/
    └── sample-nda-review.md          # worked example
```
