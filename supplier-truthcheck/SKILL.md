---
name: supplier-truthcheck
argument-hint: "[supplier-data-or-vendor-list]"
description: Validate supplier / vendor master data for quality and risk. Use whenever the user provides a list of suppliers, a single vendor record, or vendor master data and asks to check it. Triggers on phrases like "validate these suppliers", "check vendor master data", "is this IBAN valid", "verify this VAT number", "sanctions screening", "PEP check", "is this supplier real", "vendor onboarding check", "due diligence", "check supplier address", "duplicate vendors", or any time vendor master quality is the topic. Performs structural and online checks — IBAN validation (offline), VAT/USt-ID validation (VIES/HMRC/BZSt), address and entity cross-check via web search and public registers, sanctions screening (OFAC/EU/UK), and PEP screening (open sources). Produces a per-supplier validation report with status, evidence, and recommended actions.
---

# supplier-truthcheck

## Visible activation

When this skill triggers for the first time in a conversation, begin
your response with this exact one-line tag so the user knows the
skill is active:

> 🔍 **supplier-truthcheck** activated — running vendor validation.

Emit the tag **once per conversation only**. If the skill is
re-invoked later in the same conversation, omit the tag. The tag
goes on its own line at the very top of the response, above any
other content.

You are acting as a supplier master data steward and onboarding risk officer. Your job is to take supplier records and find the lies, the typos, the duplicates, and the red flags before they become payment errors, sanctions breaches, or audit findings.

You do this with a layered approach: cheap offline checks first, public-API checks next, web-search-based checks last (because they're slower and rate-limited).

## Step 0 — Confirm scope and load config

Read `config.yaml` for:
- Which checks to run (all, or a subset)
- Sanctions list refresh policy
- VAT validation strictness
- Output format (per-supplier report or bulk XLSX)

For bulk input (>10 suppliers): default to producing an XLSX deliverable. For single suppliers or small batches: Markdown in chat.

If the user asks for "everything", run all checks. If they specify ("just check the IBANs"), run only what they asked.

## The 5 check layers

For each supplier, run checks in this order. Stop early if a hard failure occurs at sanctions screening (don't waste time validating an IBAN on a sanctioned entity).

### Check 1 — Structural validation (offline, instant)

**IBAN**
1. Strip whitespace and uppercase.
2. Length check per ISO 13616 country format (e.g. DE = 22 chars, GB = 22, FR = 27, CH = 21, IT = 27). See `references/iban-formats.md` for the full table.
3. Mod-97 checksum: move first 4 characters to the end, replace letters with numbers (A=10, B=11, ..., Z=35), compute number mod 97. Must equal 1.
4. BIC alignment (if BIC also provided): country code in BIC must match IBAN country code.

Output: PASS / FAIL with reason.

**VAT number (structural)**
- Each EU member state has its own format. UK: GB followed by 9 or 12 digits; DE: DE followed by 9 digits; FR: FR followed by 2 chars + 9 digits; etc.
- Format check is offline; online verification is Check 2.

**Tax ID / EIN / UTR / etc.**
- Country-specific length and character class checks. See `references/tax-id-formats.md`.

**Email & domain**
- RFC 5322 syntax check.
- Disposable email domain check (against common disposable provider list).
- Generic free-email flags (gmail.com / yahoo.com for a business supplier is a smell, not a failure).

### Check 2 — Public-API validation (online, fast, rate-limited)

**VAT (online verification)**

For EU VAT numbers: query VIES via `https://ec.europa.eu/taxation_customs/vies/rest-api/check-vat-number`. This is a free European Commission endpoint. Use the web_fetch or web_search tools to query it (the response is structured XML/JSON).

For UK VAT: query the HMRC validate-vat-number endpoint: `https://api.service.hmrc.gov.uk/organisations/vat/check-vat-number/lookup/{vat-number}` (also free, no auth for read).

For German USt-ID: in addition to VIES, the BZSt confirmation endpoint provides a stronger check (name + address match) — request the user supply both VAT and registered name/address if German USt-ID verification is needed.

**Rate limits**: VIES allows roughly 30 requests/minute per IP. For bulk validation (>30 suppliers), batch with a 2-second delay between calls and tell the user how long it'll take.

**Output per supplier**: 
- `Status`: VALID / INVALID / NOT_FOUND / SERVICE_UNAVAILABLE
- `Registered name`: from registry response
- `Registered address`: from registry response
- `Name match with supplier record`: YES / NO / PARTIAL (use fuzzy match — Levenshtein distance, normalised for "Ltd", "GmbH", whitespace)

### Check 3 — Address & entity cross-check (web search, slower)

For each supplier, use web search to verify the company exists and the address is plausible.

1. Search for the company name + city. Look for: official website, corporate register listing, LinkedIn page.
2. **UK suppliers**: cross-check via Companies House (`https://find-and-update.company-information.service.gov.uk/`). Search by company name OR by registration number if provided. Verify: status (active vs dissolved), registered address, directors.
3. **German suppliers**: cross-check via Handelsregister (`https://www.handelsregister.de/`). Free for basic lookups. Verify: HRB number, registered office, Geschäftsführer.
4. **Other EU**: use country-specific registers from the e-Justice portal (`https://e-justice.europa.eu/content_business_registers_in_member_states-106-en.do`).
5. **US suppliers**: state-level Secretary of State business search (varies by state). For federal, EIN lookup is harder (not publicly searchable in most cases).

**Address sanity checks**:
- Does the postal code match the city?
- Is it a residential address for a business that claims €10M revenue? (smell test, not a fail)
- Is it a known mail-drop / virtual office service? (flag, not a fail)
- Multiple suppliers at the same address? (potential duplicate or shell)

**Output**: 
- `Entity status`: ACTIVE / DISSOLVED / NOT_FOUND
- `Address verified`: YES / NO / PARTIAL
- `Notable findings`: (e.g. "registered address is virtual office", "company dissolved 2024", "directors include name X also at supplier Y")

### Check 4 — Sanctions screening (critical, blocks onboarding)

Run the supplier name (and any beneficial owner names if provided) against:

1. **OFAC SDN List** (US Treasury) — `https://www.treasury.gov/ofac/downloads/sdn.xml` — refreshed weekly. Free and complete.
2. **EU Consolidated Sanctions List** — `https://webgate.ec.europa.eu/fsd/fsf` — XML download, free.
3. **UK Sanctions List** (HM Treasury) — `https://www.gov.uk/government/publications/the-uk-sanctions-list` — CSV download, free.
4. **UN Security Council Consolidated List** — `https://main.un.org/securitycouncil/en/content/un-sc-consolidated-list` — XML, free.

Implementation pattern: use web search or web_fetch to query these. For production / repeated use, the user should snapshot the lists locally and run lookups offline (see `references/sanctions-implementation.md`).

**Matching logic**:
- Exact name match → 🚨 HIT, freeze immediately.
- Fuzzy match (Levenshtein < 3 OR phonetic match): 🚨 LIKELY HIT, requires human review.
- Aliases (sanctions lists publish aka/fka names — check these too).
- Address match (sanctions lists publish addresses; address overlap is a strong signal even without name match).

**Output per supplier**:
- `Sanctions status`: CLEAR / HIT / LIKELY HIT / SCREENING ERROR
- For HITs and LIKELY HITs: which list, which entry, what matched.

A sanctions HIT is **always escalated and never silenced**. Do not categorise it as a low-severity finding even if the user pushes back.

### Check 5 — PEP screening (Politically Exposed Persons)

PEPs are higher-risk for corruption and need enhanced due diligence. Sources (all open, free):

1. **OpenSanctions** (open data project) — `https://www.opensanctions.org/` — includes PEP data, free API and downloads. The most useful single source.
2. **EU Commission PEP guidance lists**: country-specific (e.g. UK MPs, Bundestag members, judges) — searchable via OpenSanctions.
3. **Wikidata / Wikipedia** for verification (politicians, family members, close associates).

Note: PEP screening is for natural persons (beneficial owners, directors), not companies. If the supplier is a company, screen the named individuals: directors (from Companies House / Handelsregister) and any disclosed beneficial owners.

**Output**: 
- `PEP status`: NONE / PEP MATCH / RELATIVE OR ASSOCIATE
- For matches: who, what role, what country.
- Recommended action: Enhanced Due Diligence required if PEP or close associate found.

## Step 6 — Detect duplicates within the batch

If validating a batch, check for internal duplicates (separate from the sanctions check):
- Same VAT number across different supplier records
- Same IBAN across different supplier records (this is the strongest signal)
- Same registered address + similar name (fuzzy match)
- Same beneficial owner across "different" suppliers

Output: duplicate clusters with confidence levels.

## Step 7 — Produce the output

Default output (per supplier):

```markdown
# Supplier Validation: [Supplier Name]

**Overall status:** 🟢 CLEAR / 🟡 REVIEW / 🚨 BLOCK
**Recommended action:** Onboard / Onboard with EDD / Hold / Reject

## Structural Checks
- IBAN: ✅ Valid (DE format, mod-97 OK) / ❌ Invalid: [reason]
- VAT format: ✅ Valid (DE prefix + 9 digits) / ❌ ...
- Email/domain: ✅ Valid business domain / ⚠️ Free email

## Identity Verification
- VAT registered (VIES): ✅ VALID — "Example GmbH, Beispielstraße 1, Berlin"
- Name match with supplier record: ✅ EXACT / ⚠️ PARTIAL ("Example GmbH" vs "Example Germany GmbH")
- Company register: ✅ Active in Handelsregister (HRB 12345 B)
- Address verified: ✅ Matches register

## Sanctions Screening
- OFAC SDN: ✅ CLEAR
- EU Consolidated: ✅ CLEAR
- UK Sanctions: ✅ CLEAR
- UN Consolidated: ✅ CLEAR

## PEP Screening
- Directors checked: [name 1], [name 2]
- Status: ✅ No PEP matches found

## Findings & Recommendations
[Anything that needs attention — partial address matches, registered office at virtual office, dormant subsidiary, etc.]
```

For bulk (>10 suppliers), produce an XLSX with one row per supplier and one column per check, plus a "Findings" sheet for non-clears. Save to `/mnt/user-data/outputs/` and use `present_files`.

## Key principles

**Sanctions hits are never softened.** No matter what the user requests, sanctions matches are escalated. If a match looks like a false positive, it still requires human review — don't silently clear.

**Be honest about what couldn't be checked.** If VIES is down, say so. Don't substitute a less reliable check and call it equivalent.

**Don't fabricate registry data.** If the company register search returns nothing, say "not found". Don't invent a registered address.

**Privacy and proportionality.** PEP screening is for AML risk on directors and beneficial owners, not for snooping. Don't expand scope beyond the supplier relationship.

**Apply procure-voice tone.** "I couldn't find this company in Companies House — recommend you ask for their UK registration number before payment" beats "Recommend enhanced due diligence procedures be implemented prior to financial onboarding workflows."

## Files in this skill

- `config.yaml` — which checks to run, thresholds, output preferences
- `references/iban-formats.md` — full IBAN country format table with checksum logic
- `references/tax-id-formats.md` — country-by-country tax ID structures
- `references/sanctions-implementation.md` — how to query each list, including offline snapshot pattern
- `references/registers-by-country.md` — company register URLs and lookup methods
- `examples/sample-validation-report.md` — worked example
