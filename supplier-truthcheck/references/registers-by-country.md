# Company Registers by Country

When verifying that a supplier is a real, active legal entity, query the relevant company register. Most EU registers are free for basic lookups; some charge for detailed records.

## United Kingdom

**Companies House** — `https://find-and-update.company-information.service.gov.uk/`

- Free for all basic lookups (name, number, address, directors, filing history)
- Search by company name or company number
- Verify: company status (active / dissolved / liquidation), registered office, directors, PSC (persons of significant control)
- API: `https://api.company-information.service.gov.uk/` (free, requires API key)

## Germany

**Handelsregister** — `https://www.handelsregister.de/`

- Free for basic lookups since 2022 (formerly chargeable)
- Search by company name or HRB/HRA number + Bundesland
- Verify: legal form (GmbH/AG/UG/etc.), registered office, Geschäftsführer (managing directors), Stammkapital
- For UG (haftungsbeschränkt) entities: extra caution — minimum capital can be as low as €1

## France

**Infogreffe** — `https://www.infogreffe.fr/`
**Pappers** — `https://www.pappers.fr/` (free, more user-friendly)

- Search by SIREN, SIRET, or name
- SIREN = 9-digit company identifier; SIRET = 14-digit establishment identifier (SIREN + 5)
- Verify: status, registered address, dirigeants

## Spain

**Registro Mercantil** — `https://www.registradores.org/`

- Some lookups are chargeable; basic existence/status often free
- Search by CIF (tax ID) or name

## Italy

**Registro Imprese** — `https://www.registroimprese.it/`

- Free basic lookups; detailed records chargeable
- Search by P.IVA (VAT) or name

## Netherlands

**KVK (Kamer van Koophandel)** — `https://www.kvk.nl/`

- Basic lookups free
- Search by KvK number or name
- Verify: status, address, directors

## Switzerland

**Zefix** — `https://www.zefix.ch/`

- Free, federal-level aggregator of all cantonal commercial registers
- Search by name, UID (Unternehmens-Identifikationsnummer), or canton

## Austria

**Firmenbuch** — `https://www.firmenbuchgrundbuch.at/`

- Limited free search; detailed lookups chargeable
- Search by FN (Firmenbuchnummer) or name

## Belgium

**Crossroads Bank for Enterprises** — `https://kbopub.economie.fgov.be/kbopub/zoeknummerform.html`

- Free basic lookups
- Search by enterprise number (BCE/KBO)

## Ireland

**CRO (Companies Registration Office)** — `https://www.cro.ie/`

- Basic lookups free
- Search by company number or name

## Poland

**KRS (Krajowy Rejestr Sądowy)** — `https://ekrs.ms.gov.pl/`

- Free
- Search by KRS number, REGON, NIP, or name

## EU master portal

**European e-Justice Portal — Business Registers Interconnection System (BRIS)** — `https://e-justice.europa.eu/content_business_registers_in_member_states-106-en.do`

Single search across all EU member state registers. Useful when you don't know which country a supplier is registered in but have a name.

## United States

The US has no federal company register. Each state runs its own Secretary of State business search:

- **Delaware** (where many companies incorporate): `https://icis.corp.delaware.gov/`
- **California**: `https://bizfileonline.sos.ca.gov/`
- **New York**: `https://apps.dos.ny.gov/publicInquiry/`
- etc.

For federal-level data: EIN is not publicly searchable in most cases. For public companies: SEC EDGAR at `https://www.sec.gov/edgar/`.

## Other notable

- **Canada**: Corporations Canada — `https://www.ic.gc.ca/app/scr/cc/CorporationsCanada/`
- **Australia**: ASIC — `https://connectonline.asic.gov.au/`
- **Singapore**: ACRA Bizfile — `https://www.bizfile.gov.sg/`
- **UAE**: each Emirate has its own register; for free zones, the relevant free zone authority

## Cross-reference pattern

For each supplier, the verification pattern is:
1. Identify likely country of registration (from address, VAT prefix, supplier-provided info)
2. Query the relevant register from this list
3. Match by VAT/company number (most reliable) or name (less reliable; fuzzy match)
4. Compare: status (active?), registered address (matches?), directors (any sanctions hits?)
5. Note any mismatches in the output

## What to flag

- **"Not found"** when the supplier claims to be a registered entity → flag, request the registration number
- **"Dissolved"** or **"In liquidation"** → block until clarified
- **Registered office at a known mail-drop / virtual office** → flag (note: not a fail; many legitimate businesses use these)
- **Multiple suppliers with the same registered office** → potential shell or duplicate
- **Director appears on sanctions or PEP lists** → escalate

The register check is most valuable as one signal in the broader screening. A clean register entry doesn't mean a clean supplier; a missing register entry doesn't always mean a fraudulent supplier (e.g. sole traders in some jurisdictions don't register).
