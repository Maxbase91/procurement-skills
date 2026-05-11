# IBAN Country Formats Reference

IBAN structure per ISO 13616. Validate offline by:
1. Check length matches country code
2. Strip spaces, uppercase all characters
3. Move first 4 characters to the end
4. Replace each letter with 2 digits (A=10, B=11, ..., Z=35)
5. Compute the resulting integer modulo 97. Must equal 1.

## Country code lengths

| Country | Code | Length | BBAN format |
|---|---|---|---|
| Andorra | AD | 24 | 4n,4n,12c |
| Austria | AT | 20 | 5n,11n |
| Azerbaijan | AZ | 28 | 4c,20n |
| Bahrain | BH | 22 | 4a,14c |
| Belgium | BE | 16 | 3n,7n,2n |
| Bosnia & Herzegovina | BA | 20 | 3n,3n,8n,2n |
| Brazil | BR | 29 | 8n,5n,10n,1a,1c |
| Bulgaria | BG | 22 | 4a,4n,2n,8c |
| Croatia | HR | 21 | 7n,10n |
| Cyprus | CY | 28 | 3n,5n,16c |
| Czech Republic | CZ | 24 | 4n,6n,10n |
| Denmark | DK | 18 | 4n,9n,1n |
| Estonia | EE | 20 | 2n,2n,11n,1n |
| Finland | FI | 18 | 6n,7n,1n |
| France | FR | 27 | 5n,5n,11c,2n |
| Germany | DE | 22 | 8n,10n |
| Gibraltar | GI | 23 | 4a,15c |
| Greece | GR | 27 | 3n,4n,16c |
| Hungary | HU | 28 | 3n,4n,1n,15n,1n |
| Iceland | IS | 26 | 4n,2n,6n,10n |
| Ireland | IE | 22 | 4c,6n,8n |
| Israel | IL | 23 | 3n,3n,13n |
| Italy | IT | 27 | 1a,5n,5n,12c |
| Latvia | LV | 21 | 4a,13c |
| Liechtenstein | LI | 21 | 5n,12c |
| Lithuania | LT | 20 | 5n,11n |
| Luxembourg | LU | 20 | 3n,13c |
| Malta | MT | 31 | 4a,5n,18c |
| Moldova | MD | 24 | 2c,18c |
| Monaco | MC | 27 | 5n,5n,11c,2n |
| Montenegro | ME | 22 | 3n,13n,2n |
| Netherlands | NL | 18 | 4a,10n |
| North Macedonia | MK | 19 | 3n,10c,2n |
| Norway | NO | 15 | 4n,6n,1n |
| Poland | PL | 28 | 8n,16n |
| Portugal | PT | 25 | 4n,4n,11n,2n |
| Romania | RO | 24 | 4a,16c |
| San Marino | SM | 27 | 1a,5n,5n,12c |
| Saudi Arabia | SA | 24 | 2n,18c |
| Serbia | RS | 22 | 3n,13n,2n |
| Slovakia | SK | 24 | 4n,6n,10n |
| Slovenia | SI | 19 | 5n,8n,2n |
| Spain | ES | 24 | 4n,4n,1n,1n,10n |
| Sweden | SE | 24 | 3n,16n,1n |
| Switzerland | CH | 21 | 5n,12c |
| Turkey | TR | 26 | 5n,1c,16c |
| United Kingdom | GB | 22 | 4a,6n,8n |

Legend: `n` = digit, `a` = uppercase letter, `c` = alphanumeric

## Mod-97 checksum (Python reference)

```python
def validate_iban(iban: str) -> bool:
    iban = iban.replace(" ", "").upper()
    # Move first 4 chars to end
    rearranged = iban[4:] + iban[:4]
    # Convert letters to numbers (A=10..Z=35)
    numeric = ""
    for ch in rearranged:
        if ch.isalpha():
            numeric += str(ord(ch) - ord("A") + 10)
        elif ch.isdigit():
            numeric += ch
        else:
            return False
    return int(numeric) % 97 == 1
```

## Common errors to recognise

- IBAN with internal spaces → strip before validating
- Lowercase IBAN → uppercase before validating
- Missing country code → invalid (don't try to guess)
- 1-character typos: passes length check but fails mod-97
- "I" mistyped as "1", "O" as "0": will fail mod-97
