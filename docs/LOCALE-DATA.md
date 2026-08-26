# Locale data decisions and sources

## Purpose

Belgium has glibc locales for French, Dutch, and German, but no locale for people who use English as their interface language while expecting Belgian regional formats. `en_BE` fills that gap. It combines English language data with Belgian currency, numbers, dates, paper size, measurement, addresses, and telephone conventions.

The project does not try to define a separate dialect of English. It provides an international language in a Belgian regional context and avoids choosing French, Dutch, or German conventions without a stated reason.

## Reuse policy

Choose locale data in this order:

1. Copy language-dependent data from `en_GB`. It is the closest glibc English locale and uses the same European context.
2. When `fr_BE`, `nl_BE`, and `de_BE` agree on a territorial convention, use that shared Belgian value. Copy from `i18n` instead when it expresses the same language-neutral value directly.
3. When the Belgian locales disagree, use the `en_GB` convention only when it is applicable to the field and the same choice already exists in at least one published Belgian locale.
4. Define fields locally when a category must combine English and Belgian data.
5. Depart from the published locales only when an authoritative source supports the correction. Record the source and the reason here.

This order makes each choice traceable. It also prevents the author's native language from silently deciding disputed regional formats.

## Current category decisions

| Category | Source | Reason |
|---|---|---|
| `LC_CTYPE` | `en_GB` | English character handling. |
| `LC_COLLATE` | `en_GB` | English collation. |
| `LC_MESSAGES` | `en_GB` | English responses and messages. |
| `LC_MONETARY` | Local | Euro, Belgian separators, and `€ 1.234,56` placement. |
| `LC_NUMERIC` | `fr_BE` | `fr_BE`, `nl_BE`, and `de_BE` resolve to comma decimals and period grouping. |
| `LC_TIME` | Local | English names, shared Belgian date and time structure, and `/` from both `en_GB` and `fr_BE`. |
| `LC_PAPER` | `i18n` | Language-neutral A4 dimensions, 210 by 297 mm. |
| `LC_TELEPHONE` | Local | Extends the shared Belgian values with the documented domestic format. |
| `LC_MEASUREMENT` | `i18n` | Language-neutral metric measurement. |
| `LC_NAME` | `en_GB` | English personal-name conventions. |
| `LC_ADDRESS` | Local | Belgian address metadata expressed in English. |

## Date and time conventions

`LC_TIME` needs local composition because day and month names are language data while date layout and week rules are regional data.

| Property | Source of convention |
|---|---|
| English day and month names | `en_GB` |
| Short date order, `dd/mm/yy` | `en_GB` and `fr_BE` |
| Slash date separator | `en_GB` and `fr_BE` |
| 24-hour time | All glibc Belgian locales and `en_GB` |
| Combined date and time layout | All glibc Belgian locales |
| Monday as first weekday | All glibc Belgian locales and `en_GB` |
| ISO week structure | All glibc Belgian locales and `en_GB` |

The short date is represented by `d_fmt="%d/%m/%y"`. A date such as 26 August 2026 is formatted as `26/08/26`. The combined formats follow the structure shared by `fr_BE`, `nl_BE`, and `de_BE`, with English names supplied locally.

## Monetary conventions

`LC_MONETARY` is a deliberate composition of Belgian territorial conventions and English presentation conventions:

| Property | Source of convention |
|---|---|
| Euro currency | Belgian territory |
| Decimal comma | All glibc Belgian locales |
| Period grouping | All glibc Belgian locales |
| Symbol before amount | `en_GB`, `nl_BE`, and `de_BE` |
| Space after symbol | `nl_BE` and `de_BE` |
| Leading negative sign | `en_GB` and `fr_BE` |
| Three-digit grouping | All Belgian locales |

This produces `€ 1.234,56` for a positive amount and `-€ 1.234,56` for a negative amount. Each disputed property follows `en_GB` where the same choice already exists in at least one published Belgian locale. No authoritative Belgian English monetary style guide has been identified, so this composition is a documented project choice rather than a claim about an official standard.

## Telephone conventions

glibc's `fr_BE` defines:

```text
tel_int_fmt="+%c %a %l"
int_prefix="32"
int_select="00"
```

`nl_BE` and `de_BE` copy the complete telephone category from `fr_BE`. Those three locales agree on the international template and prefixes, but none defines a domestic template. `en_BE` retains those shared values and adds `tel_dom_fmt="%A %l"`.

The fields describe these components:

- `%c`: country code, `32` for Belgium.
- `%a`: area code without the national prefix.
- `%A`: area code including the national prefix.
- `%l`: local subscriber number.
- `int_select`: prefix dialled from Belgium for an international call, `00`.
- `int_prefix`: Belgian country code, `32`.

Expected representations include:

```text
International: +32 2 123 45 67
Domestic:      02 123 45 67
```

The template is not limited to Brussels. `%A` represents the complete area code including its national `0` prefix, whether that code has two or three digits. Representative fixed-line area codes include:

| City | Language region | Domestic prefix | Example international prefix |
|---|---|---:|---:|
| Brussels | Bilingual region | `02` | `+32 2` |
| Antwerp | Dutch-speaking region | `03` | `+32 3` |
| Ghent | Dutch-speaking region | `09` | `+32 9` |
| Liège | French-speaking region | `04` | `+32 4` |
| Charleroi | French-speaking region | `071` | `+32 71` |

The ITU lists Belgium with country code `32`, international prefix `00`, and national prefix `0`:

https://www.itu.int/dms_pub/itu-t/opb/sp/T-SP-OB.827-2005-PDF-E.pdf

Belgium's federal portal publishes domestic numbers in the same spaced form in Dutch, French, and German, for example `02 501 81 11`:

- https://www.belgium.be/nl/contact
- https://www.belgium.be/fr/contact
- https://www.belgium.be/de/kontakt

The federal government also publishes paired domestic and international forms, such as `02 528 66 77` and `+32 2 511 51 51`:

https://handicap.belgium.be/fr/contact

The same federal source publishes city-specific examples including Antwerp `03`, Ghent `09`, Liège `04`, and Charleroi `071`:

https://handicap.belgium.be/fr/contact/centres-de-reconnaissance-du-handicap

Defining `tel_dom_fmt` locally is an intentional correctness improvement over the existing glibc Belgian locales. It does not create a language-specific convention. The template represents the national `0` prefix documented by the ITU and the spacing used across Dutch, French, and German Belgian government pages. A follow-up upstream change should add the same field to `fr_BE`, allowing `nl_BE` and `de_BE` to inherit it and restoring full Belgian parity.
