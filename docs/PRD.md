# Product Requirements: procurement-skills

Status: reflects v0.3.0 (commit `f1f1cbb`) plus the security guardrails added afterwards. Items marked *Inferred* come from the README, SKILL.md files and git history rather than from a written spec.

## 1. Vision

An open-source (MIT) pack of Claude Agent Skills that makes Claude useful to procurement practitioners across the source-to-pay lifecycle. The pack is a set of Markdown instructions plus YAML configuration. There is no code service. Organisations customise it by editing `config.yaml`, never the skill logic (README, "Customising for your organisation").

Positioning (README): a procurement counterpart to Anthropic's finance agent templates, delivered as portable skills rather than orchestrated agents.

## 2. Target users and jobs-to-be-done

| User | Job | Skill |
|---|---|---|
| Procurement lead / contract manager | "Tell me what to push back on in this NDA/MSA/DPA before I sign" | redline-sentry |
| Spend / category analyst | "Turn this Coupa/Ariba/SAP export into a brief with anomalies and savings" | spend-prism |
| Strategic sourcing manager | "Draft an RFP that won't get garbage responses", "score these bids defensibly" | bid-compass |
| Vendor master / onboarding / compliance | "Is this supplier real, correctly set up, and not sanctioned?" | supplier-truthcheck |
| Anyone writing procurement content | "Make this sound like a human, not a consultancy deck" | procure-voice |

*Inferred:* primary audience is individual practitioners on Claude.ai Pro/Team/Enterprise, with a secondary developer audience using Claude Code.

## 3. Scope

### In (as implemented)
- Five skills, each a folder with `SKILL.md` (frontmatter `name`, `description`, `argument-hint`), `README.md`, and in four cases `config.yaml`.
- Worked examples under `<skill>/examples/`, plus synthetic sample inputs (NDA DOCX, Coupa XLSX, vendor record) to try three of the skills.
- Reference material under `<skill>/references/` and `<skill>/templates/`.
- `install.sh`: copy skills to `~/.claude/skills` (or `--target`), with `--force`, `--skip-existing`, interactive collision prompts, and `--package` to build Claude.ai upload zips into `dist/`.
- Visible one-line activation tag per skill (v0.2).
- Install guidance for Claude.ai, Claude Code and the API (`INSTALL.md`).

### Out (explicitly, README "What this is not" / "Roadmap")
- Legal advice; commercial-grade sanctions screening; replacing a P2P platform.
- Agents, orchestration, schedulers, connectors.
- Shipped DOCX/XLSX templates (listed as TODO).
- Shared `quality-gates.yaml`, offline sanctions snapshot scripts, `category-intel` and `supplier-qbr` skills.

## 4. Functional requirements

| ID | Requirement | Status |
|---|---|---|
| FR-1 | redline-sentry classifies contract type, runs a clause checklist against `config.yaml`, outputs a fixed Markdown structure (risk rating, issues, redlines, cheat sheet) | Implemented (instructions) |
| FR-2 | redline-sentry produces a DOCX tracked-changes redline on the user's own contract DOCX (or a new DOCX built with the docx skill), with the review on a cover page | Implemented (instructions); no template file |
| FR-3 | redline-sentry falls back to `templates/default-playbook.yaml` when config is missing | Implemented; the file equals the shipped `config.yaml` (checked by `validate.py`) |
| FR-4 | spend-prism detects source system from headers, cleans, categorises, detects anomalies, outputs a fixed brief; XLSX above 500 rows | Implemented (instructions) |
| FR-5 | spend-prism output follows the brief structure inline in SKILL.md | Implemented (instructions); no template file |
| FR-6 | bid-compass generate mode enforces quality gates, builds weighted scoring matrix (sum 100, no single weight >50% unless justified) | Implemented (instructions) |
| FR-7 | bid-compass evaluate mode checks mandatory gates before scoring, scores symmetrically with evidence | Implemented (instructions) |
| FR-8 | bid-compass builds the RFP DOCX, pricing XLSX and scoring-matrix XLSX from scratch with the docx/xlsx skills, using the layout in SKILL.md | Implemented (instructions); no template files |
| FR-9 | supplier-truthcheck shows an upfront data-flow notice, then runs 5 check layers (sanctions first with early stop on a HIT, structural, VAT online, register/address, PEP) plus batch duplicate detection | Implemented (instructions) |
| FR-10 | Sanctions hits are never softened | Implemented (instructions) |
| FR-11 | procure-voice rewrites to plain English; applied as overlay by the other skills | Implemented (instructions) |
| FR-12 | Skills treat input documents and fetched pages as untrusted data | Implemented (added post-v0.3.0) |
| FR-13 | `install.sh` installs, overwrites, skips, packages (tracked files only in a git checkout) | Implemented; covered by `scripts/test-install.sh` in CI |

## 5. Non-functional requirements

- **Portability:** plain Markdown/YAML, no runtime dependencies. `install.sh` needs bash and, for `--package`, `zip`.
- **Size:** keep each `SKILL.md` under 500 lines (README, Contributing). Current max is ~256.
- **Copyright:** skills quote at most 15 words from source documents.
- **Configurability:** org-specific values live in `config.yaml`, not in SKILL.md.
- **Honesty:** skills must say what could not be checked (supplier-truthcheck) and must not fabricate registry data.

## 6. Success metrics

*Open question:* none are defined in the repo. Candidates: GitHub stars/forks, issues/PRs from practitioners, number of community-contributed country registers or category templates.

## 7. Risks

| Risk | Mitigation today |
|---|---|
| Prompt injection via contracts, bids, spend exports or fetched web pages skews a review, score or sanctions result | "Untrusted input" section in four skills; human review still required |
| Users treat output as legal advice or authoritative sanctions screening | Disclaimers in README and redline-sentry output |
| Supplier data (names, VAT, directors) sent to third-party services and web search | supplier-truthcheck limits fields sent and shows an upfront notice of which fields go to which service; the user can opt out of individual checks |
| DOCX/XLSX output varies between runs (no base templates) | SKILL.md specifies sections and sheet layouts; CI fails on any SKILL.md reference to a file that does not exist |
| Skills drift between Claude.ai and Claude Code installs | Documented in INSTALL.md (no sync) |

## 8. Open questions


None open. Resolved in round 3: missing templates dropped, synthetic samples published under `examples/`, supplier-truthcheck data-flow notice and sanctions-first order, GitHub Releases built by `.github/workflows/release.yml`.
