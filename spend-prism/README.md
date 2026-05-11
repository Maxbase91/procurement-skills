# spend-prism

> Spend analysis that finds the savings hiding in your ERP exports.

## What it does

Point it at a Coupa / Ariba / SAP / Oracle / Concur export (or any spend CSV/XLSX). Get back:
- Top suppliers, categories, concentration
- Anomalies (price variance, duplicate invoices, maverick spend, spikes)
- Tail spend with consolidation opportunities
- Ranked savings opportunities with estimated value
- Data quality issues called out, not hidden

## How to customise

Edit `config.yaml`:
- **Taxonomy mode**: user-defined (your categories), UNSPSC, eClass, or AI-inferred
- **Currency**: reporting currency
- **Anomaly thresholds**: how sensitive should the flags be?
- **Tail spend definition**: bottom-N% or amount-threshold
- **Preferred suppliers**: enables maverick spend detection

The user can also pass a taxonomy in the prompt for a one-off run.

## Supported source systems

Auto-detected: **Coupa**, **SAP Ariba**, **SAP S/4 / ECC**, **Oracle Procurement**, **Concur (T&E)**, generic CSV/XLSX. Telltale columns in each are documented in SKILL.md.

## What it is not

It is not a replacement for your spend cube or a real BI tool. It is a fast, opinionated first-pass that surfaces the action items.

## Files

```
spend-prism/
├── SKILL.md
├── config.yaml                         # YOUR settings
├── README.md
├── templates/
│   ├── default-taxonomy.yaml           # reference L1/L2 starter
│   └── spend-brief-template.md         # output structure (TODO: ship)
└── examples/
    └── sample-spend-analysis.md        # worked example
```
