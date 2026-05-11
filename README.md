# Procurement Skills for Claude

> An open-source pack of [Claude Agent Skills](https://docs.claude.com) for procurement professionals. Anthropic shipped agents for finance. This is skills for procurement.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What's in the pack

Five skills, each focused on one part of the source-to-pay lifecycle. Drop the folder into Claude's skill directory and Claude becomes a procurement specialist with your house playbook, your taxonomy, your scoring weights, and your tone.

| Skill | What it does | When it fires |
|---|---|---|
| **redline-sentry** | Contract redlining (NDAs, MSAs, DPAs, SaaS) with risk rating, suggested redlines, negotiation cheat sheet | "review this contract", "is this NDA risky", "redline this MSA" |
| **spend-prism** | Spend analysis from Coupa/Ariba/SAP/Oracle/Concur exports — categories, anomalies, tail spend, savings opportunities | "analyse this spend", "find anomalies", "categorise these suppliers" |
| **bid-compass** | Guided RFP generation and evaluation with configurable scoring and mandatory quality gates | "draft an RFP", "evaluate these bids", "scoring matrix" |
| **supplier-truthcheck** | Vendor master data validation — IBAN mod-97, VAT (VIES/HMRC/BZSt), company registers, sanctions (OFAC/EU/UK/UN), PEP | "validate these suppliers", "check this IBAN", "sanctions screening" |
| **procure-voice** | Tone overlay — honest, plain-English procurement writing that strips jargon and leads with the point | applied automatically by the other skills; or "make this less corporate" |

Every skill is configurable via its own `config.yaml`. You edit your playbook, your weights, your taxonomy — never the skill logic.

## Why this exists

On 5 May 2026, Anthropic [announced 10 agent templates for financial services](https://www.anthropic.com/news/finance-agents) — pitchbooks, KYC, month-end close, the works. Finance got the headline.

Procurement is the next-largest spend category in most enterprises and arguably has more day-to-day operational pain than finance. There's no equivalent pack for procurement. So here's one — not as agents (those need orchestration, connectors, subagents), but as **skills**: portable, transparent, configurable Markdown files that any Claude user can fork and adapt.

If you have Claude.ai Pro/Team or Claude Code, you can install these in 5 minutes and use them today.

## Quick install

These skills work in three places. Pick the one you use most — full
details in [INSTALL.md](INSTALL.md).

### Most users: Claude.ai web / Claude Desktop / mobile / Cowork

```
git clone https://github.com/YOUR_USERNAME/procurement-skills.git
cd procurement-skills
./install.sh --package
```

This produces 5 upload-ready zips in `dist/`. Then in Claude.ai:
**Settings → Capabilities → Skills → Upload skill**. Upload each zip.
Once uploaded, the skills appear in the slash menu (`/redline-sentry`,
`/spend-prism`, etc.) across Claude.ai web, Desktop, mobile, and
Cowork — anywhere your Anthropic account logs in.

Requires Claude.ai Pro/Max/Team/Enterprise with code execution enabled.

### Developers: Claude Code

```
git clone https://github.com/YOUR_USERNAME/procurement-skills.git
cd procurement-skills
./install.sh
```

Copies all 5 skills to `~/.claude/skills/`. They're available in your
next Claude Code session as slash commands and auto-trigger from
natural language.

### API workspaces

See [INSTALL.md](INSTALL.md) for API upload. Note that skills uploaded
to the API are not visible in Claude.ai web or Claude Code — each
surface has its own skill store.

**Important**: skills do not sync between surfaces. If you use Claude.ai
AND Claude Code, install in both. The skills themselves are identical;
the storage is what differs.

## Customising for your organisation

Every skill has a `config.yaml` you can edit:

- **redline-sentry**: liability cap thresholds, jurisdiction, contract-type playbooks
- **spend-prism**: your category taxonomy (UNSPSC, eClass, or custom), currency, anomaly thresholds
- **bid-compass**: scoring weights per category, quality gates, RFP structure
- **supplier-truthcheck**: which checks to run, fuzzy match thresholds, rate limits
- **procure-voice**: tone enforcement (rules don't need configuring; they're the skill)

The skills are designed so that anyone — you, your team, a client — can fork the repo, edit only the `config.yaml` files, and have a customised procurement assistant without touching skill logic.

## Worked examples

Each skill folder has an `examples/` directory with realistic worked outputs:

- [redline-sentry/examples/sample-nda-review.md](redline-sentry/examples/sample-nda-review.md)
- [spend-prism/examples/sample-spend-analysis.md](spend-prism/examples/sample-spend-analysis.md)
- [bid-compass/examples/sample-rfp-generation.md](bid-compass/examples/sample-rfp-generation.md)
- [bid-compass/examples/sample-evaluation.md](bid-compass/examples/sample-evaluation.md)
- [supplier-truthcheck/examples/sample-validation-report.md](supplier-truthcheck/examples/sample-validation-report.md)
- [procure-voice/examples/before-after-pairs.md](procure-voice/examples/before-after-pairs.md)

These show what to expect when each skill fires. They're also the easiest way to evaluate whether a skill fits your workflow before you customise it.

## What this is not

- **Not legal advice.** redline-sentry flags risk; it doesn't replace a lawyer.
- **Not commercial sanctions screening.** supplier-truthcheck uses free public data sources (OFAC SDN, EU Consolidated, UK Sanctions, UN Consolidated). For full Refinitiv/LexisNexis-grade screening, use a commercial provider.
- **Not a replacement for a P2P platform.** spend-prism reads exports from Coupa/Ariba/SAP; it doesn't replace them.
- **Not agents.** No orchestration, no scheduled runs, no connectors. Skills are invoked by you, in the moment, and complete in a single conversation.

## How to verify a skill triggered

Skills run silently by default in Claude.ai. To make activation
visible, each of these skills emits a one-line tag on first
invocation in a conversation:

| Skill | Tag |
|---|---|
| redline-sentry | 🛡️ **redline-sentry** activated — running contract review. |
| spend-prism | 📊 **spend-prism** activated — running spend analysis. |
| bid-compass | 🧭 **bid-compass** activated — guiding RFP workflow. |
| supplier-truthcheck | 🔍 **supplier-truthcheck** activated — running vendor validation. |
| procure-voice | ✍️ **procure-voice** activated — rewriting in plain English. |

If you see the tag, the skill fired. The tag appears once per
conversation per skill — re-invoking the same skill later in the
same chat won't repeat it.

You can also invoke any skill explicitly via slash command in Claude
Code: `/redline-sentry`, `/spend-prism`, `/bid-compass`,
`/supplier-truthcheck`, `/procure-voice`. In Claude.ai
(Pro/Team/Enterprise) skills auto-trigger from natural language
matching the description.

**Other ways to confirm a skill is active**: in Claude Code or
Cowork, expand the tool-call block above the response — you'll see
Claude reading `SKILL.md` from the relevant skill folder. Or just
ask Claude: "which skill did you use?"

## Roadmap (community input welcome)

Things explicitly **not** in v1, considered for future:

- DOCX templates shipping with the skills (currently text-based output; templates are TODO)
- A `quality-gates.yaml` shared resource so redline-sentry and bid-compass can reference common organisational standards from one place
- Local snapshot scripts for sanctions lists (for offline bulk screening)
- A `category-intel` skill for weekly market briefs (deferred — needs a scheduler, not just a skill)
- A `supplier-qbr` skill (deferred — needs structured supplier performance data inputs)

Open an issue or pull request if you want one of these or have other ideas.

## Contributing

Pull requests welcome, especially:

- Additional country support in supplier-truthcheck (more company registers, more tax ID formats)
- Additional scoring templates in bid-compass for niche categories
- Translations of procure-voice for non-English procurement teams
- Worked examples in your industry vertical

The skills follow [Anthropic's skill-creator conventions](https://docs.claude.com): YAML frontmatter with `name` and `description`, body in Markdown, references and templates in subfolders. Keep SKILL.md under 500 lines; push detail to references.

## License

MIT. Use it, fork it, sell services around it, embed it in your own tools. No attribution required, but appreciated.

## Acknowledgements

Inspired by Anthropic's [Agents for Financial Services](https://www.anthropic.com/news/finance-agents) (May 2026) — they showed the pattern works for finance. This is the same idea, applied to the category they didn't cover.
