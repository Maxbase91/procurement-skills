# Example: Supplier Validation Report (anonymised)

Single-supplier validation. Input: a vendor master record for "Beispiel GmbH" with the following data:

```
Name: Beispiel GmbH
Address: Musterstraße 42, 10115 Berlin, Germany
VAT: DE123456789
IBAN: DE89 3704 0044 0532 0130 00
Tax ID (Steuernummer): 30/123/45678
Contact email: invoicing@beispiel-gmbh.de
Director: Anna Müller
```

---

# Supplier Validation: Beispiel GmbH

**Overall status:** 🟡 REVIEW
**Recommended action:** Onboard with one clarification (VAT name match)

## Structural Checks

- **IBAN**: ✅ Valid
  - Country code: DE (Germany)
  - Length: 22 chars (correct for DE format)
  - Mod-97 checksum: passed (computed = 1)
  - BIC alignment: not provided to check
- **VAT format**: ✅ Valid (DE + 9 digits)
- **Tax ID (Steuernummer)**: ✅ Plausible Berlin format (3-digit Finanzamt code + 11 digits structured)
  - Note: Steuernummer is the domestic German tax number, not the VAT ID. Both are valid to hold.
- **Email**: ✅ Valid business domain (matches company name; not free/disposable)

## Identity Verification

- **VAT registered (VIES)**: ✅ VALID
  - Registered name in VIES: "Beispiel Deutschland GmbH"
  - Registered address: "Musterstraße 42, 10115 Berlin, DE"
- **Name match with supplier record**: ⚠️ PARTIAL
  - Supplier: "Beispiel GmbH"
  - Registry: "Beispiel Deutschland GmbH"
  - This is a common variant — but worth a one-question clarification with the supplier: "Are you Beispiel GmbH or Beispiel Deutschland GmbH? Please confirm the legal entity for contracting."
- **Handelsregister (German company register)**: ✅ Active
  - Entry: HRB 123456 B (Amtsgericht Berlin Charlottenburg)
  - Status: Active
  - Geschäftsführer: Anna Müller (matches supplier record)
  - Registered Stammkapital: €25,000 (suggests GmbH, not UG — financially substantive)
- **Address verified**: ✅ Matches register and VIES

## Sanctions Screening

- **OFAC SDN**: ✅ CLEAR (no name, alias, or address match)
- **EU Consolidated**: ✅ CLEAR
- **UK Sanctions**: ✅ CLEAR
- **UN Consolidated**: ✅ CLEAR
- Director "Anna Müller" also screened individually: ✅ CLEAR

## PEP Screening

- **Directors checked**: Anna Müller
- **Source**: OpenSanctions
- **Status**: ✅ No PEP match found
- **Note**: "Anna Müller" is a common name; verification was scoped to German PEPs and EU-level only. If enhanced DD is required (e.g. for high-risk category), expand to global politically exposed persons screening.

## Findings & Recommendations

1. **VAT registered name mismatch** — REVIEW
   - The VIES record shows "Beispiel Deutschland GmbH" but the supplier record shows "Beispiel GmbH". This is typically a parent vs subsidiary issue, or a legal-name-vs-trading-name issue.
   - **Action**: Confirm with the supplier which legal entity will be contracted and invoicing. If "Beispiel Deutschland GmbH", update the master record. If "Beispiel GmbH", ask whether they have a separate VAT registration (and if so, request it).

2. **No BIC provided**
   - Not a fail, but request BIC for the IBAN to enable a cross-check against country code consistency.

3. **No insurance / bank details verification**
   - Beyond this skill's scope. For a high-value relationship, request bank reference letter or use a payment verification service to confirm the IBAN is associated with the named beneficiary.

## Summary

The supplier appears to be a real, active German GmbH with a clean sanctions and PEP profile. The only loose thread is the VAT name mismatch, which requires one clarifying question before final onboarding. Recommend proceeding with that one check.
