# Example: Mutual NDA Review (anonymised)

This is a worked example of what redline-sentry produces. The contract is a fictional mutual NDA between two SaaS companies considering a partnership.

---

# Contract Review: Mutual NDA — Acme Corp ↔ Globex Ltd

**Type:** Mutual NDA / Confidentiality Agreement
**Jurisdiction:** English law (acceptable)
**Overall risk rating:** 🟡 Medium
**Recommendation:** Sign with redlines

> _Not legal advice. A qualified lawyer should approve before signature._

## Executive Summary

- The NDA term is 7 years, more than double our 3-year playbook standard. Push back to 3 years, accept 5 years if pushed.
- Confidential information definition is acceptably scoped with standard carve-outs.
- A "residuals" clause allows the receiving party to use mental impressions of confidential info — this should be removed.
- No injunctive relief carve-out (the right to seek a court order without posting bond). Standard for NDAs, should be added.
- Otherwise a clean document. Two real issues, both negotiable in one round.

## Critical Issues (must fix)

None.

## Issues to Negotiate

**1. NDA Term — Clause 5.1**
Severity: ⚠️ Negotiate
The agreement runs for 7 years post-termination. Our playbook caps at 3 years.
- _Why it matters_: NDAs that run too long are unenforceable in practice and create indefinite review burden.
- _Suggested redline_: Replace "seven (7) years" with "three (3) years". Fallback: 5 years.

**2. Residual Knowledge — Clause 6.3**
Severity: ⚠️ Negotiate
A residuals clause permits use of information "retained in unaided memory."
- _Why it matters_: This is a common SaaS-vendor trick. It effectively allows the receiving party to use your confidential information as long as they don't write it down. It guts the NDA.
- _Suggested redline_: Delete clause 6.3 entirely. If counterparty insists, scope it tightly to non-confidential general industry knowledge only.

**3. No injunctive relief carve-out**
Severity: ❓ Missing
Standard NDA language permitting either party to seek injunctive relief without posting bond is absent.
- _Why it matters_: If the other party breaches, you want to be able to go to court fast.
- _Suggested redline_: Add a clause: "Either party may seek equitable relief, including injunction, without the requirement to post bond or prove actual damages, in addition to any other remedies available."

## Missing Clauses

- Injunctive relief carve-out (see above)
- No express provision for return / destruction of confidential info at end of term

## Acceptable Clauses

- Definition of Confidential Information — appropriately scoped
- Standard carve-outs (public domain, independently developed, lawfully received from third party)
- Mutual obligation
- English law and jurisdiction
- No assignment without consent

## Negotiation Cheat Sheet

**Top 3 asks** (in priority order):
1. Drop term from 7 → 3 years (must-have)
2. Delete the residuals clause (must-have)
3. Add injunctive relief language (should-have)

**What to concede**: If they push back on (1), accept 5 years. If they insist on residuals, scope it to "general industry knowledge gained from publicly available sources" — but if they refuse to scope it at all, that's a real problem.

**Walk-away triggers**:
- They refuse to remove or scope the residuals clause
- They insist on a unilateral NDA (you give, they don't)
- They demand a term over 5 years AND a residuals clause

---

This whole review took roughly two minutes of Claude time. A human reviewer can act on it in 5–10.
