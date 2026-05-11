# LinkedIn launch post — three drafts

Three different angles. Each is procure-voice compliant (no "thrilled", no "leverage", no "best-in-class"), under 1,500 characters, ends with a clear CTA. Pick the one that fits your moment, or mix.

> **Before posting**: replace `[GITHUB_URL]` with your actual repo URL (e.g. `https://github.com/Maxbase91/procurement-skills`). Add screenshots if you have time — the worked-example markdown files render nicely as screenshots.

---

## Draft A — The direct contrast (recommended)

```
Two weeks ago, Anthropic announced 10 AI agent templates for financial
services. Pitchbooks, KYC screening, month-end close. Goldman, JPMorgan,
Citi, AIG on stage.

Finance got the headline. Procurement got nothing.

That's the larger spend category in most enterprises, with arguably more
day-to-day operational pain. So I built the procurement equivalent — not
as agents (those need orchestration, connectors, subagents), but as
Claude Skills: portable, transparent, configurable Markdown files anyone
can fork.

Five skills, open source, MIT licensed:

→ redline-sentry — contract redlining (NDAs, MSAs, DPAs, SaaS) with
  configurable risk playbook
→ spend-prism — spend analysis from Coupa/Ariba/SAP exports with your
  taxonomy
→ bid-compass — guided RFP generation and evaluation with mandatory
  quality gates
→ supplier-truthcheck — vendor master data validation: IBAN, VAT (VIES/
  HMRC/BZSt), company registers, sanctions (OFAC/EU/UK/UN), PEP
→ procure-voice — a tone overlay that strips consultant jargon from
  procurement writing

Every skill has a config.yaml. Fork the repo, edit your playbook, done.
No vendor lock-in, no subscription, no agent infrastructure.

If you have Claude.ai Pro/Team or Claude Code, you can install these
today.

[GITHUB_URL]

#procurement #ai #claude #sourcing
```

**Character count**: ~1,290 (well under LinkedIn's 3,000 limit; comfortable for the "see more" fold).

**Why this works**: opens with the contrast (the news everyone in your network saw), states the gap, then the solution. Specific, no hedging.

---

## Draft B — The practitioner angle

```
12 years in source-to-pay. SAP Ariba, S/4, Coupa, Concur, you name it.
The same painful tasks keep showing up:

→ Reading a 40-page MSA and figuring out where the real risk is
→ Cleaning a Coupa export to find the savings hiding in the tail
→ Writing an RFP that won't generate garbage responses
→ Validating a vendor master record before payment goes out

Anthropic shipped 10 finance agents this month. Useful, but they need
orchestration, connectors, subagent setup. Most procurement teams don't
have that infrastructure or runway.

So I built five Claude Skills instead — same idea (skills = instructions
+ domain knowledge), but portable, transparent, no plumbing required.

Open source, MIT licensed, configurable via YAML:

• redline-sentry  — contract redlining with your risk playbook
• spend-prism     — spend analysis from any ERP export
• bid-compass     — RFP generation + evaluation with quality gates
• supplier-truthcheck — IBAN + VAT + register + sanctions + PEP checks
• procure-voice   — strips consultant jargon from procurement writing

Each skill = ~5 minutes to install, 30 minutes to customise to your org.

[GITHUB_URL]

Feedback welcome. PRs especially — additional country support for
truthcheck and category templates for bid-compass are the obvious next
gaps.

#procurement #claude #ai #sourcetopay
```

**Character count**: ~1,420.

**Why this works**: opens with credibility (your 12 years), names the actual pains practitioners feel, positions the choice (agents vs skills) as a practical tradeoff. Reads like a senior practitioner talking to peers — which is exactly your audience.

---

## Draft C — The provocation

```
"AI for procurement" gets discussed like it's coming next year.

Two weeks ago, Anthropic shipped 10 agent templates for finance. Real
software, real customers, real workflows. Finance is two years ahead.

I got tired of waiting.

Five open-source Claude Skills for procurement, MIT licensed, live now:

redline-sentry — contract redlining
spend-prism — spend analysis (Coupa/Ariba/SAP)
bid-compass — guided RFP generation + evaluation
supplier-truthcheck — IBAN/VAT/register/sanctions/PEP screening
procure-voice — tone overlay that removes consultant clichés

Each is a Markdown file with a config.yaml you edit to match your org's
playbook. No connectors needed. No subagent orchestration. No vendor
deck.

If you have Claude.ai Pro/Team or Claude Code, install in five minutes.

[GITHUB_URL]

The procurement profession doesn't need to wait for vendors to package
AI for us. We can ship it ourselves.

#procurement #claude #ai
```

**Character count**: ~880.

**Why this works**: shortest, punchiest, most provocative ending. Best if you want maximum shares / comment threads. Riskier — the "I got tired of waiting" framing can read as either bold or self-important depending on your audience.

---

## Posting mechanics

**Best time**: Tuesday–Thursday, 8–10am London time. Procurement audience is most active mid-morning UK.

**Hashtags**: keep to 3–4. More than that screams "growth hack". The drafts above use #procurement #claude #ai #sourcetopay — pick 3.

**Image**: if you have 20 minutes, take a screenshot of one of the worked examples (e.g. `bid-compass/examples/sample-evaluation.md` rendered) and attach it. Posts with images get materially more reach.

**First comment (post-post)**: drop a comment with the GitHub URL as the first reply. LinkedIn down-ranks posts with external links in the main body, but is fine with them in comments.

**Tagging**: tag 2–3 people max who'd genuinely care. Don't blast. The procurement-AI Twitter/LinkedIn circle is small enough that anyone who'd care will find this organically if it's good.

**Response strategy**: prepare for two question types:
1. "Why skills, not agents?" — answer: portability, no setup, no lock-in, anyone can fork
2. "How does this differ from [Coupa AI / Zip / etc.]?" — answer: those are full platforms; this is open primitives you customise in 30 minutes, no subscription

---

## Optional: follow-up post (one week later)

If draft A or B lands well, a follow-up the week after with one specific example works:

> "A week ago I shared 5 open-source procurement skills for Claude.
> Here's what supplier-truthcheck actually does on a real (anonymised)
> vendor record..."
>
> [screenshot of sample-validation-report.md]
>
> Five free public data sources. Zero subscription cost. Sanctions hit
> detection that doesn't require Refinitiv. [GITHUB_URL]

Single-feature deep-dives consistently outperform launch announcements on LinkedIn. The launch post draws the audience; the follow-up converts them to clickers.
