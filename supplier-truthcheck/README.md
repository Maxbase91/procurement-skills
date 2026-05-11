# supplier-truthcheck

> Vendor master data validation, sanctions and PEP screening, all from public sources.

## What it does

For each supplier, runs five layers of checks:

1. **Structural validation** (offline, instant): IBAN mod-97, VAT format, tax ID format, email/domain sanity
2. **Online VAT verification**: VIES (EU) / HMRC (UK) / BZSt strong-check (DE)
3. **Entity register lookup**: Companies House, Handelsregister, Pappers (FR), Zefix (CH), and other public registers
4. **Sanctions screening**: OFAC SDN, EU Consolidated, UK Sanctions, UN Consolidated
5. **PEP screening**: OpenSanctions for directors and beneficial owners

Plus duplicate detection within a batch (same IBAN, same VAT, same address with similar name).

## What's special about this

Everything uses **free, public data sources**. No subscription required. No commercial sanctions screening provider. If you need full Refinitiv/LexisNexis-grade screening, this is not it — but for first-pass vendor onboarding diligence, it's defensible and audit-worthy.

The most valuable feature is the integration: a single skill that runs the structural checks AND queries the right register AND screens sanctions AND screens PEPs AND finds duplicates — all in one pass, with one configurable rule file.

## How to customise

Edit `config.yaml`:
- Which checks to run (skip PEP if you don't need it)
- Sanctions match thresholds (Levenshtein distance, fuzzy matching, aliases)
- VAT validation strictness (require exact name match, partial OK, or fuzzy)
- Rate limits (for bulk validation; default respects VIES limits)
- Output format (per-supplier Markdown vs bulk XLSX)

## Limitations

- **Bulk validation is slow** — VIES rate-limits at ~30/min. 100 suppliers = ~4 minutes minimum.
- **Sanctions lists update frequently** — for repeated/automated use, snapshot the lists locally and refresh weekly. See `references/sanctions-implementation.md` for the pattern.
- **False positives on common names** — "John Smith" or "Anna Müller" will surface PEP matches that aren't your actual director. The skill flags but doesn't auto-clear; human review needed.
- **Not legal advice** — a sanctions hit triggers an action (don't onboard, escalate to compliance), not a legal opinion.

## Files

```
supplier-truthcheck/
├── SKILL.md
├── config.yaml                          # YOUR settings
├── README.md
├── references/
│   ├── iban-formats.md                  # full IBAN country table + checksum
│   ├── tax-id-formats.md                # VAT/tax ID formats by country
│   ├── sanctions-implementation.md      # how to query each list
│   └── registers-by-country.md          # company register URLs and methods
└── examples/
    └── sample-validation-report.md      # worked example
```
