# Example: RFP Evaluation (anonymised)

Walked-through example, evaluate mode. Same RFP as the generation example. Five vendors responded.

---

## Step 1 — Inputs verified

- Original scoring matrix: confirmed loaded
- Vendor responses: 5 (Acme, Globex, Initech, Hooli, Soylent)
- Evaluators: CX Director, IT Security lead, Finance Business Partner
- Mandatory gates: not yet checked; run as part of this exercise

## Step 2 — Mandatory gate check (run FIRST)

| Vendor | ISO 27001 | GDPR DPA | EU data residency | 99.9% SLA | Revenue >€10M | Industry reference | Status |
|---|---|---|---|---|---|---|---|
| Acme | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Proceed |
| Globex | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ (consumer retail only) | ❌ DISQUALIFIED |
| Initech | ✅ | ✅ | ❌ (US/Singapore only) | ✅ | ✅ | ✅ | ❌ DISQUALIFIED |
| Hooli | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Proceed |
| Soylent | ❌ (SOC 2 only) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ DISQUALIFIED |

**2 of 5 proceed to scoring.** This is normal. The point of gates is to filter early.

User confirmed: proceed with Acme and Hooli.

## Step 3 — Scoring

Detailed scoring matrix produced as XLSX. Excerpts:

**Commercial (25%)**

| | Acme | Hooli |
|---|---|---|
| Year 1 all-in | €98k | €112k |
| Year 3 TCO | €324k | €358k |
| Price increase cap | 4% annual | "CPI + 2%" |
| Payment terms | NET-30 | NET-15 (push back) |
| Exit costs | €0 (data export included) | €15k data export fee |
| **Score** | **4** | **3** |
| **Justification** | Cleaner pricing, no exit penalty, better terms | Higher TCO, exit fee is a red flag |

**Functional fit (35%)**

Detailed breakdown across 12 must-haves and 8 nice-to-haves. Acme: 4. Hooli: 4. (Tied on functionality.)

**AI capability (10%)**

Acme: 3 (LLM-assisted reply suggestions, sentiment analysis; AI training on customer data is opt-in but defaults on). Hooli: 4 (more mature AI feature set, dedicated AI ops team, training opt-out by default).

**Technical and security (15%)**

Acme: 4. Hooli: 4. Both strong; differences in detail.

**Service and support (5%)**

Acme: 4. Hooli: 3.

**Risk and compliance (10%)**

Acme: 3 (newer to EU, smaller team). Hooli: 4 (longer track record).

## Step 4 — Weighted scores

| Vendor | Commercial (25%) | Func fit (35%) | AI (10%) | Tech/sec (15%) | Service (5%) | Risk (10%) | **Total** |
|---|---|---|---|---|---|---|---|
| Acme | 4 × 0.25 = 1.00 | 4 × 0.35 = 1.40 | 3 × 0.10 = 0.30 | 4 × 0.15 = 0.60 | 4 × 0.05 = 0.20 | 3 × 0.10 = 0.30 | **3.80** |
| Hooli | 3 × 0.25 = 0.75 | 4 × 0.35 = 1.40 | 4 × 0.10 = 0.40 | 4 × 0.15 = 0.60 | 3 × 0.05 = 0.15 | 4 × 0.10 = 0.40 | **3.70** |

## Step 5 — Recommendation

```markdown
# RFP Evaluation: Customer Support SaaS

**Vendors evaluated:** 5 (3 disqualified at gates)
**Recommendation:** Acme — proceed to BAFO + reference checks
**Confidence:** Medium

## Ranking

| Rank | Vendor | Weighted Score | Top Strength | Top Risk |
| ---- | ------ | -------------- | ------------ | -------- |
| 1 | Acme | 3.80 | Cleanest commercial terms, no exit fee | Smaller EU team, less mature AI |
| 2 | Hooli | 3.70 | More mature AI capability, better risk profile | Higher TCO, NET-15 terms, exit fee |

## Key Differentiators

The two vendors are functionally equivalent. Acme wins on commercial (€34k lower 3-year TCO, no exit fee, capped price increase). Hooli wins on AI capability and risk. The gap is small — 0.10 in 3.80 — and could flip on negotiation.

## Risks & Mitigations

- **Acme smaller EU presence**: ask for named EU customer references; verify EU support hours.
- **Hooli exit fee**: this is non-negotiable in their model. Major red flag for long-term flexibility. Use as commercial lever.
- **AI training defaults**: Acme defaults to ON, Hooli to OFF. Get Acme to contractually commit to OFF before signing.

## Suggested Next Steps

1. Reference calls with 3 Acme EU customers (industry preferred)
2. BAFO request to both, focused on: Acme — extend commercial advantage by getting price increase cap to 3% and confirming AI-off default; Hooli — drop exit fee and improve payment terms.
3. Demo with the scripted "ugly path" scenario (irate customer multi-channel).
4. Final decision with stakeholder vote after step 3.

## Audit Trail

Full scoring matrix: `/mnt/user-data/outputs/rfp-eval-cs-saas.xlsx`
All scoring rationales documented per criterion per vendor with quoted evidence from responses.
```

## Step 6 — Negotiation brief (on request)

User asked: "what should I push on with Acme now?"

```markdown
# Negotiation brief: Acme

## Where Acme is strong (less leverage)
- Functional fit and integrations
- They know they're competitive on commercial

## Where Acme is weaker vs Hooli (use this)
- AI maturity — push for: faster roadmap commitment OR AI feature credits
- EU presence — push for: dedicated EU CSM, SLA-backed EU support hours
- Risk profile — they need this win to consolidate EU, so they'll move on terms

## Specific asks (ranked)
1. **Must have**: Price increase cap reduced from 4% → 3% over 3 years
2. **Must have**: AI training on customer data contractually OFF by default
3. **Strong push**: 10% discount in year 1 for early signature (by Q2 end)
4. **Should ask**: Named EU CSM in the contract
5. **Worth trying**: Termination for convenience after year 1 with 60 days notice

## What you can give back
- 3-year commitment instead of annual (gives them ARR certainty)
- Reference customer / case study rights (if pilot succeeds)
- Faster procurement / signature in exchange for the price ask

## Walk-away
If they refuse on both #1 and #2: Hooli becomes the recommendation.
```
