# Sample vendor onboarding record (synthetic)

A demo input for supplier-truthcheck. Every identifier below is fictional:
the company, the directors, the VAT number, the tax number, the address, the
bank details, the email domain (`.example` is reserved for documentation) and
the phone number. Do not use them for anything except testing the skill.

Copy the block below into Claude and ask:
"Run supplier-truthcheck on this vendor record"

---

```
Vendor Onboarding Request

Legal name:        Beispiel Logistik GmbH
Trading name:      Beispiel Logistics
Registration:      Germany, GmbH
Tax ID (USt-IdNr): DE999888777
Steuernummer:      99/999/99999
Registered address: Musterstraße 99
                    10115 Berlin
                    Germany
Director:          Anna Beispiel
Director:          Klaus Muster
Bank details:
  Beneficiary:    Beispiel Logistik GmbH
  IBAN:           DE37 9999 9999 0123 4567 89
  BIC:            EXMPDEFFXXX
  Bank:           Beispielbank AG
Contact:           accounts@beispiel-logistik.example
Phone:             +49 30 0000000

Intended use:      Freight forwarding services across DACH region
Annual spend:      EUR 180,000 estimated
Payment terms:     NET-30
```

---

## What the skill should find

1. **Data-flow notice** at the start: which fields go to which external
   service (see "Before any online check" in SKILL.md).
2. **Sanctions screening** (OFAC, EU, UK, UN) runs first among the online
   checks: expected CLEAR, so the remaining checks continue.
3. **IBAN structural check**: PASS (valid DE length, mod-97 checksum OK,
   BIC country matches). The bank code is fictional; the structural check
   does not look it up.
4. **VAT format**: PASS (DE + 9 digits).
5. **VIES lookup**: DE999888777 is not a registered VAT number, so expect
   INVALID / NOT FOUND and the advice to ask the supplier for clarification
   before onboarding.
6. **Company register / address**: no register entry for the company;
   the address cannot be verified. Expect "not found", not an invented
   registry record.
7. **PEP screening on the directors**: expected no match.
8. **Email**: `.example` is a reserved documentation domain; expect a flag.

Expected overall result: 🟡 REVIEW or 🚨 BLOCK with "Hold" (identity not
confirmed), never 🟢 CLEAR.
