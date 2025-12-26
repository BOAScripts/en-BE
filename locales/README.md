# Locale Definitions

This directory contains locale definition files used by the installer.
```
wget -o https://raw.githubusercontent.com/BOAScripts/en-BE/refs/heads/main/locales/en_BE.UTF-8
```

## en_BE.UTF-8

Belgian English locale with proper formatting for:
- Dates (dd/mm/yyyy)
- Times (24-hour format)
- Numbers (period as thousands separator)
- Currency (Euro with comma as decimal separator)

## File Format

Locale files follow the POSIX locale definition format. See the [GNU C Library documentation](https://www.gnu.org/software/libc/manual/html_node/Locale-Data.html) for details.

## Testing Locales

To test a locale definition before installation:

```bash
localedef -i locales/en_BE.UTF-8 -f UTF-8 test_locale
LC_ALL=test_locale date
```

## Adding New Locales

1. Create the locale file following POSIX standards
2. Test thoroughly on multiple distributions
3. Document the formatting conventions
4. Update the main script to support it

## Acknowledgments

- Original locale definition by **Yannick Vanhaeren** (2017) - [GitHub Gist](https://gist.github.com/yvh/630368018d7c683aca8da9e2baf7bfb9)
- Locale definition based on POSIX standards
- Inspired by the need for proper Belgian formatting
- Community contributions welcome
