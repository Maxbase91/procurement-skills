# Example: Spend Analysis (anonymised)

Realistic example showing what spend-prism produces. Input was a Coupa export with 2,847 transactions across FY2025.

---

# Spend Analysis: FY2025 · Coupa

**Total spend:** €18.4M
**Suppliers:** 412 · **Transactions:** 2,847
**Period:** 1 Jan 2025 – 31 Dec 2025
**Source system:** Coupa (identified from columns: Supplier, Commodity, Department, PO Number)
**Taxonomy:** User-defined (from config.yaml)

## Executive Summary

- IT and Professional Services account for 64% of total spend. The remaining 36% is spread across 387 suppliers — a textbook long tail.
- Two suppliers (AWS, Microsoft) are 28% of total spend. Concentration risk, but not unusual for the size.
- Tail spend (bottom 20% = 327 suppliers) is €1.1M. Strong consolidation case, particularly in office supplies (47 suppliers) and SaaS (61 suppliers).
- Three anomalies worth a call this week: a €240k spike in marketing agency Q3, three probable-duplicate invoices from a single supplier (€38k), and a sole-source IT consultancy at 73% of "IT Professional Services" category.
- Data quality is decent. 8% of transactions had missing Commodity in Coupa — auto-categorised with high confidence using supplier + description.

## Top 10 Suppliers by Spend

| Rank | Supplier | Spend | % of total | Category |
|---|---|---|---|---|
| 1 | Amazon Web Services | €2,840,000 | 15.4% | IT / SaaS / Cloud |
| 2 | Microsoft | €2,310,000 | 12.6% | IT / SaaS / Cloud |
| 3 | Deloitte | €1,180,000 | 6.4% | Professional Services / Consulting |
| 4 | Salesforce | €890,000 | 4.8% | IT / SaaS / Cloud |
| 5 | WeWork | €720,000 | 3.9% | Facilities / Rent & Leases |
| 6 | KPMG | €640,000 | 3.5% | Professional Services / Audit |
| 7 | LinkedIn | €520,000 | 2.8% | Marketing / Marketing Technology |
| 8 | Adobe | €480,000 | 2.6% | IT / SaaS / Cloud |
| 9 | DHL | €390,000 | 2.1% | Logistics / Freight |
| 10 | Allianz | €360,000 | 2.0% | Financial Services / Insurance |

Top 10 = 56.1% of spend. Standard pareto shape.

## Spend by Category (L1)

- IT: €8.9M (48.4%)
- Professional Services: €2.9M (15.8%)
- Marketing: €1.8M (9.8%)
- Facilities: €1.4M (7.6%)
- Travel: €1.1M (6.0%)
- Logistics: €0.9M (4.9%)
- HR: €0.7M (3.8%)
- Financial Services: €0.5M (2.7%)
- Other: €0.2M (1.1%)

## Anomalies & Risks

**1. Marketing agency Q3 spike** — 🟡 Medium
"BrightFlame Creative" spend jumped from monthly avg €18k to €240k in September. Likely a campaign push, but worth confirming there's a PO covering it and not a series of split invoices.

**2. Probable duplicate invoices — Acme IT Services** — 🚨 High
Three invoices of €12,667 each, dated 14 Mar, 17 Mar, 21 Mar, same description "March consulting hours." Could be three legitimate weekly invoices, but the symmetry is suspicious. Worth a 5-minute check.

**3. Category concentration: IT Professional Services** — ⚠️ Medium
"Strataform Consulting" is 73% of IT Professional Services (€840k). If they exit, you have a problem. Recommend developing a second source by FY26 mid-year.

**4. Maverick spend: SaaS** — ⚠️ Medium
€340k of SaaS spend bypasses Microsoft EA (your preferred supplier per config). Top offenders: Notion (€48k), Miro (€36k), Linear (€22k). Worth a consolidation review — Microsoft 365 has overlapping tools.

## Tail Spend

- **327 tail suppliers**, €1.1M total spend (6.0% of total)
- Average tail supplier spend: €3,400/year
- Top consolidation opportunities:
  1. **Office supplies** — 47 suppliers, €280k. Most likely consolidates to 2-3 (Viking, Staples, local).
  2. **SaaS micro-tools** — 61 suppliers, €390k. Consolidate to 5-8 strategic + Microsoft 365 overlap audit.
  3. **Catering** — 28 suppliers, €120k. Likely consolidates to 1 preferred + 1 backup per office.

## Savings Opportunities (Ranked)

| # | Opportunity | Est. savings | Effort | Next step |
|---|---|---|---|---|
| 1 | Renegotiate AWS commit (consumption up 40% YoY) | €280–420k | Medium | Schedule TAM call this week |
| 2 | SaaS consolidation (61 → 8 tools) | €120–180k | High | Build SaaS inventory in Q1 |
| 3 | Office supplies consolidation | €40–60k | Low | Run mini-tender, target Viking |
| 4 | Second-source Strataform | Risk reduction | Medium | Add to category strategy |
| 5 | Maverick SaaS lockdown | €40–80k | Medium | Update SaaS approval workflow |

## Data Quality Issues

- 8% of transactions had blank Commodity field in Coupa source. Auto-categorised; spot-check 20 random rows recommended.
- 12 currency conversions applied (USD → EUR at €1 = $1.08). Material exposure.
- 3 transactions with negative amounts confirmed as credit notes (€-18k total).
- 4 supplier names normalised: "MSFT Ireland Ops" → "Microsoft"; "AMZN UK" → "Amazon"; etc.
- 1 intercompany transaction filtered out (€85k to internal subsidiary).
