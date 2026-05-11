# Sanctions Implementation — How to Query Each List

All sanctions data sources below are free and public. Use this reference when running sanctions screening as part of supplier-truthcheck.

## Why offline snapshots matter

For occasional one-off checks, querying the live sources via web_fetch is fine. For routine bulk checking (more than ~10 suppliers per session, or any automated/recurring use), snapshot the lists locally and run lookups against the snapshot. Reasons:
- Speed (no network round trip per supplier)
- Reliability (sources do have outages)
- Auditability (snapshot with timestamp = defensible "we checked on date X")

Refresh snapshots at least weekly. OFAC refreshes their list multiple times per week; EU and UK lists refresh on enforcement actions.

## OFAC SDN List (US Department of the Treasury)

**Source URL**: `https://www.treasury.gov/ofac/downloads/sdn.xml`

**Also useful**:
- Consolidated Sanctions List (broader than just SDN): `https://www.treasury.gov/ofac/downloads/consolidated/consolidated.xml`
- Specially Designated Nationals data dictionary: `https://www.treasury.gov/ofac/downloads/sdn_advanced_notes.pdf`

**Structure**: XML with entries containing primary name, akas (alternative names), addresses, dates of birth (for individuals), nationality, programs (e.g. UKRAINE-EO13662, IRAN), and identifying documents.

**Querying pattern**:
1. Download XML once per session/week.
2. Parse into a list of entries.
3. For each supplier, run name match against each entry's primary name + all aliases.
4. For matches above threshold, output the entry details (name matched, programs, address, type — individual or entity).

## EU Consolidated Financial Sanctions List

**Source URL**: `https://webgate.ec.europa.eu/fsd/fsf` (web portal); structured download requires registration but is free.

**Structure**: XML format. Each entry has subject type (P=person, E=entity), name, name aliases, birth details (for individuals), addresses, regulation references.

**Key field for matching**: `<nameAlias>` elements — there are usually multiple aliases per entry. All must be checked.

**Practical access**: The OpenSanctions project aggregates the EU list and provides a clean API (see PEP section below); using OpenSanctions for EU is often easier than the raw EC download.

## UK Sanctions List (HM Treasury / OFSI)

**Source URL**: `https://www.gov.uk/government/publications/the-uk-sanctions-list`

**Format**: ODS, CSV, and HTML. CSV is easiest for programmatic checks.

**Fields**: Name 6 (current name), Name Non-Latin Script, DOB, Nationality, Address, Regime, Listed On, Last Updated.

**UK-specific note**: Since 2021 the UK runs its own list separate from EU. Both must be checked if your suppliers operate in the UK or EU.

## UN Security Council Consolidated List

**Source URL**: `https://main.un.org/securitycouncil/en/content/un-sc-consolidated-list`

**Format**: XML. Smaller list (focused on terrorism, certain country regimes), but globally binding.

## Matching logic

For each supplier name, run a tiered match:

### Tier 1 — Exact match (case-insensitive, whitespace-normalised)
If any list entry primary name or alias matches the supplier name exactly, it's a HIT. Always escalate.

### Tier 2 — Fuzzy match
Use Levenshtein distance (or Damerau-Levenshtein for transpositions) with a threshold from config.yaml (default 3). Apply to:
- Supplier name vs each entry primary name
- Supplier name vs each entry alias

Below threshold = LIKELY HIT.

### Tier 3 — Phonetic match
For names that might be transliterated (Arabic, Cyrillic, Asian scripts), use Soundex or Double Metaphone. Useful for catching `Mohammed` vs `Muhammad`, `Putin` vs `Poutine`.

### Tier 4 — Address-only match
If a supplier address matches an address listed on a sanctions entry but the name doesn't match, flag it. This catches shell companies and aliases.

## False positive management

Common SDN names are short and ambiguous (e.g. "Ahmed", "Smith"). To reduce false positives:
- Require multiple signals to align (name + address, or name + nationality, or name + DOB for individuals)
- Use whole-name matching, not token matching ("Smith Ltd" should not match "John Smith" the individual)
- Cross-check by adding context (industry, country of registration)

But: when in doubt, escalate to human review. The cost of a false negative (paying a sanctioned entity) is far higher than the cost of a false positive (a 5-minute review).

## Reporting a confirmed hit

If a confirmed sanctions match is found:
- The supplier MUST NOT be onboarded.
- Any existing relationship must be reported to the relevant authority (UK: OFSI; EU: NCA; US: OFAC).
- Funds in transit may need to be frozen.

supplier-truthcheck does not provide legal advice on sanctions reporting obligations. It identifies matches and flags them. The user's compliance function must take the next step.

## Python pattern (illustrative)

```python
import xml.etree.ElementTree as ET
import requests
from rapidfuzz import fuzz

# Download and parse SDN
def load_ofac_sdn():
    r = requests.get("https://www.treasury.gov/ofac/downloads/sdn.xml")
    root = ET.fromstring(r.text)
    # Parse entries — structure documented in OFAC data dictionary
    return [...]

def screen(supplier_name: str, sdn_entries, threshold=80):
    hits = []
    for entry in sdn_entries:
        names_to_check = [entry["primary_name"]] + entry["aliases"]
        for candidate in names_to_check:
            score = fuzz.ratio(supplier_name.lower(), candidate.lower())
            if score >= threshold:
                hits.append({"entry": entry, "matched_name": candidate, "score": score})
    return hits
```

This is illustrative — the production pattern should also handle the EU, UK, and UN lists in the same way, then deduplicate hits across lists (a hit on multiple lists is more confidence, not double-counting).
