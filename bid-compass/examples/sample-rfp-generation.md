# Example: RFP Generation (anonymised)

A walked-through example of what bid-compass produces in generate mode. Input: "I need to run an RFP for a customer support SaaS to replace our current ticketing system, budget around €100k/year, decision needed by end of Q2."

---

## Step 1 — Capture the demand

bid-compass asked the user a focused batch of questions:

> Before I draft the RFP, I need to clarify a few things:
> 1. What's the business problem? (e.g. "current tool can't handle voice channel", "agent productivity stuck at X", "no AI features"). The artefact (a ticketing tool) isn't the goal.
> 2. How many agent seats do you need licensed (peak and steady state)?
> 3. Geographies served — which countries' data goes through this?
> 4. Existing integrations that must continue working (CRM? Telephony? Knowledge base?)
> 5. Who will evaluate? You'll want CX leadership, IT/security, finance at minimum.
> 6. Is the incumbent invited to bid, or are you running a clean-sheet competitive?

User came back with answers. Quality gates checked:
- ✅ Demand defined: "Replace legacy ticketing with omnichannel platform supporting AI-assisted agent workflows; reduce average handle time by 20%"
- ✅ Budget: €80–120k/year all-in
- ✅ Evaluation criteria identified: functional fit, AI capability, integrations, commercial, security
- ✅ Scoring weights agreed (used `saas_software` template, adjusted: bumped Functional fit to 35%, AI capability split out at 10%, reduced Service & support to 5%)
- ✅ Mandatory separated: ISO 27001, GDPR DPA, EU data residency, 99.9% uptime SLA
- ✅ Stakeholders identified: CX Director (lead), IT Security (security), Finance (commercial), 2 senior agents (usability)
- ✅ Timeline realistic: 4 weeks Q&A + response, 2 weeks evaluation, 1 week shortlist, 1 week demos, decision in 8 weeks. Tight but workable for end-Q2.

## Step 2 — Scoring matrix

Approved by user:

| Criterion | Weight |
|---|---|
| Commercial | 25% |
| Functional fit | 35% |
| AI capability (split out) | 10% |
| Technical and security | 15% |
| Service and support | 5% |
| Risk and compliance | 10% |
| **Total** | **100%** |

Mandatory gates (yes/no, no scoring):
- ISO 27001 certified
- GDPR/UK GDPR compliant with executable DPA
- EU data residency available
- 99.9% uptime SLA with service credits
- Minimum €10M annual revenue (financial stability)
- Reference customer in our industry within last 24 months

## Step 3 — Outputs produced

1. **RFP document (DOCX)** — 18 pages, structured per config.yaml sections.
2. **Pricing template (XLSX)** — sheets for Year 1/2/3 costs, optional modules, implementation, training, support; TCO row.
3. **Scoring matrix (XLSX)** — pre-populated with criteria and weights, columns for each invited vendor, evidence cells, score cells, weighted total formula.

## Step 4 — Category-specific advice surfaced

Pulled from `references/category-advice.md`:

> **AI training on customer data**: Make this a yes/no question. Multiple SaaS vendors are now training models on customer data unless contractually prevented. If a vendor says "yes but anonymised", treat that as a "yes" until proven otherwise.
>
> **Per-agent pricing minimum commits**: Vendors will quote a "per-agent" price but require a 50-agent minimum. Force them to disclose minimum commit in the pricing template, not in the small print.
>
> **The demo effect**: Send all vendors the same 3 scripted scenarios to demo. One should be deliberately ugly (irate customer escalation across channels). The ones who skip your script and demo their "happy path" are telling you something.

## Step 5 — Next steps presented to user

1. Review the 3 generated files. Edit the RFP for anything tone-specific to your company.
2. Approve invited vendor list (suggest 5-7 to invite, expect 3-5 to respond properly).
3. Issue. Q&A window opens Day 1, closes Day 10. Responses due Day 21.
4. Come back to bid-compass in **evaluate mode** when you have the responses.
