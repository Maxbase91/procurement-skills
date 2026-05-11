# Tax ID / VAT Format Reference

Structural format check before any online verification. For VAT numbers, the format check is the first gate; the online VIES/HMRC check is the second.

## EU VAT Numbers (per Directive 2006/112/EC)

| Country | Prefix | Length (after prefix) | Format |
|---|---|---|---|
| Austria | AT | 9 chars | U + 8 digits |
| Belgium | BE | 10 digits | First digit is 0 or 1 |
| Bulgaria | BG | 9 or 10 digits | – |
| Croatia | HR | 11 digits | – |
| Cyprus | CY | 9 chars | 8 digits + 1 letter |
| Czech Republic | CZ | 8, 9, or 10 digits | – |
| Denmark | DK | 8 digits | – |
| Estonia | EE | 9 digits | – |
| Finland | FI | 8 digits | – |
| France | FR | 11 chars | 2 alphanumeric + 9 digits |
| Germany | DE | 9 digits | – |
| Greece | EL | 9 digits | Note: EL not GR |
| Hungary | HU | 8 digits | – |
| Ireland | IE | 8 or 9 chars | Various: 7 digits + 1 letter, etc. |
| Italy | IT | 11 digits | – |
| Latvia | LV | 11 digits | – |
| Lithuania | LT | 9 or 12 digits | – |
| Luxembourg | LU | 8 digits | – |
| Malta | MT | 8 digits | – |
| Netherlands | NL | 12 chars | 9 digits + B + 2 digits |
| Poland | PL | 10 digits | – |
| Portugal | PT | 9 digits | – |
| Romania | RO | 2-10 digits | – |
| Slovakia | SK | 10 digits | – |
| Slovenia | SI | 8 digits | – |
| Spain | ES | 9 chars | Various incl. CIF: letter + 7 digits + char |
| Sweden | SE | 12 digits | Ends in 01 |

## Non-EU

| Country | Format |
|---|---|
| UK (GB) | GB + 9 digits OR GB + 12 digits OR GB + GD000 (gov) OR GB + HA000 (health) |
| Switzerland | CHE-XXX.XXX.XXX MWST (or TVA/IVA) — 9 digits with UID format |
| Norway | 9 digits + MVA |
| USA (EIN) | XX-XXXXXXX (9 digits) — but not publicly verifiable |
| Canada (BN) | 9 digits + RT0001 (or similar suffix) for GST/HST |

## German specifics (often confused)

Germany has TWO numbers for tax purposes — both may appear in supplier records:

- **USt-IdNr.** (Umsatzsteuer-Identifikationsnummer): the **VAT number** for intra-EU use. Format: `DE` + 9 digits. This is what gets checked in VIES.
- **Steuernummer**: domestic German tax number. Format varies by Bundesland (e.g. `12/345/67890`). NOT a VAT number. Cannot be validated via VIES.

If a German supplier provides only a Steuernummer, request the USt-IdNr. before paying any cross-border invoice.

## UK specifics

UK VAT is `GB` + 9 digits for most companies, `GB` + 12 digits for branches of foreign companies, with special codes for government departments (`GD`) and health authorities (`HA`). HMRC's validation endpoint accepts all formats.

## Format check pattern

```python
import re

VAT_PATTERNS = {
    "AT": r"^ATU\d{8}$",
    "BE": r"^BE[01]\d{9}$",
    "DE": r"^DE\d{9}$",
    "FR": r"^FR[A-Z0-9]{2}\d{9}$",
    "GB": r"^GB(\d{9}|\d{12}|GD\d{3}|HA\d{3})$",
    "IT": r"^IT\d{11}$",
    # ... see full table above
}

def validate_vat_format(vat: str) -> bool:
    vat = vat.replace(" ", "").upper()
    if len(vat) < 4:
        return False
    cc = vat[:2]
    if cc not in VAT_PATTERNS:
        return False
    return bool(re.match(VAT_PATTERNS[cc], vat))
```

A format check pass does NOT mean the VAT is valid or assigned to anyone — it means the structure is plausible. Always follow with VIES/HMRC verification for cross-border or significant supplier relationships.
