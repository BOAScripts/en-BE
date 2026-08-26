# Credits

## Original locale definition

This project started from the `en_BE.UTF-8` locale definition published by:

**Yannick Vanhaeren**

- GitHub: [@yvh](https://github.com/yvh)
- Original work: [English locale for Belgium gist](https://gist.github.com/yvh/630368018d7c683aca8da9e2baf7bfb9), published in 2017

The gist provided the idea and starting locale definition for this repository.

## Work in this repository

The locale has since been reviewed and revised against glibc's `en_GB`, `fr_BE`, `nl_BE`, and `de_BE` locales. The repository now includes:

- documented rules for combining English language data with Belgian regional conventions.
- revised monetary, numeric, date, time, paper, measurement, address, and telephone data.
- source references and a rationale for locally defined values.
- installation, update, user configuration, backup, and restore support for Arch, Debian, and RHEL-based distributions.
- usage, validation, and troubleshooting documentation.

See [Locale data decisions and sources](LOCALE-DATA.md) for the current field-level rationale.

## Licence status

The original gist does not state a licence. Permission to use, modify, redistribute, and submit its material to glibc under the GNU LGPL version 2.1 or later has been requested from Yannick Vanhaeren. This section will be updated when a response is received.

The repository's own work remains covered by its [MIT licence](../LICENSE), subject to the unresolved status of material derived from the original gist.
