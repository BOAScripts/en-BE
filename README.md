# Locale English Belgium (en_BE)

# Installer for en_BE.UTF-8

```bash
git clone https://github.com/BOAScripts/en-BE.git
./en-BE/install-en-be.sh --examples
./en-BE/install-en-be.sh --install
./en-BE/install-en-be.sh --set-user-default
./en-BE/install-en-be.sh --set-default
./en-BE/install-en-be.sh --list-backups
./en-BE/install-en-be.sh --help
```

This project defines an English locale with Belgian regional formats. Its long-term goal is inclusion in glibc so Linux distributions can generate and offer `en_BE.UTF-8` as a normal locale, without requiring users to assemble equivalent `LC_*` overrides themselves.

The included Bash script installs and configures the locale locally on Arch-based, Debian-based, and RHEL-based systems while it is not yet available upstream.

## Features

- **Easy installation** of en_BE.UTF-8 locale
- **Automatic backups** before making system changes
- **Restore functionality** to revert changes if needed
- **Live examples** of date, time, and currency formatting

## Quick Start

```bash
# Clone the repository
git clone https://github.com/BOAScripts/en-BE.git
cd en-BE

# Make the script executable
chmod +x install-en-be.sh

# Run the installer
./install-en-be.sh
```

## Requirements

- An Arch-based, Debian-based, or RHEL-based Linux system
- `sudo` privileges
- RHEL: `glibc-locale-source`
- Optional: `python3` for enhanced formatting examples

## Usage

### Install Locale

Install the en_BE.UTF-8 locale without changing the system default:

```bash
./install-en-be.sh --install
```

Set it as the system default in a separate, backed-up operation:

```bash
./install-en-be.sh --set-default
```

Or configure it only for the current Bash or Zsh user:

```bash
./install-en-be.sh --set-user-default
```

The user action updates the login profile and backs up an existing profile first. It sets `LANG=en_BE.UTF-8` and unsets inherited `LC_*` overrides so Belgian formatting takes effect.

For a custom profile location, such as a Zsh environment file:

```bash
EN_BE_PROFILE="$ZDOTDIR/.zshenv" ./install-en-be.sh --set-user-default
```

### View Formatting Examples

See how dates, times, numbers, and currency are formatted:

```bash
./install-en-be.sh --examples
```

### Backup Current Configuration

Create a manual backup of your locale settings:

```bash
./install-en-be.sh --backup
```

### Restore from Backup

Restore a previous locale configuration:

```bash
./install-en-be.sh --restore
```

### List Available Backups

View all stored configuration backups:

```bash
./install-en-be.sh --list-backups
```

## Belgian Locale Format Examples

### Date & Time
- **Date format**: dd/mm/yy (e.g., 26/12/25)
- **Time format**: 24-hour clock (e.g., 18:00)
- **Full datetime**: 26/12/25 18:00:00

### Numbers & Currency
- **Decimal separator**: comma (,)
- **Thousands separator**: period (.)
- **Number example**: 1.234.567,89
- **Currency**: € 1.234,56

## What Gets Backed Up

The script automatically backs up:
- `/etc/locale.conf`
- `/etc/locale.gen`
- `/etc/default/locale`

Backups are stored in `~/.locale_backups/` with timestamps.

## How It Works

1. **Checks** if en_BE.UTF-8 is already installed
2. **Copies** the locale definition from the cloned repository
3. **Creates backup** of current configuration (automatic)
4. **Updates** `/etc/locale.gen` with the new locale
5. **Generates** the locale files
6. **Shows examples** of the new locale formatting

## Supported Distributions

Tested on:
- Debian 12+
- Arch Linux

The installer rejects other distribution families instead of guessing which configuration to change.

## Troubleshooting

### Locale not appearing after installation

```bash
# Verify locale was generated
locale -a | grep en_BE

# Regenerate locales
sudo locale-gen
```

### Permission denied errors

Ensure you have sudo privileges and the script is executable:

```bash
chmod +x install-en-be.sh
```

### Restore not working

List backups to verify they exist:

```bash
./install-en-be.sh --list-backups
```

For more issues, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## Project Structure
```
locale-installer/

├── install-en-be.sh       # Main installation script
├── locales/                # Locale definition files
│   └── en_BE.UTF-8         # Belgian English locale
├── docs/                   # Documentation
└── .github/                # GitHub configuration
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

### Adding New Locales

To add support for additional locales:

1. Add the locale file to `locales/`
2. Update the script configuration variables
3. Test on multiple distributions
4. Submit a pull request

## Safety Features

- **Automatic backups** before any system changes
- **Validated restore archives** limited to known locale files
- **Preserves existing LC_* settings** when changing `LANG`

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

- Locale definition based on POSIX standards
- [Credits](docs/CREDITS.md)
- [Locale data decisions and sources](docs/LOCALE-DATA.md)
- Community contributions welcome

## Support

- **Issues**: [GitHub Issues](https://github.com/BOAScripts/en-BE/issues)
- **Discussions**: [GitHub Discussions](https://github.com/BOAScripts/en-BE/discussions)
- **Documentation**: [docs/](docs/)

## Changelog

### v1.0.0 (2025-12-26)
- Initial release
- en_BE.UTF-8 locale support
- Backup/restore functionality
- Formatting examples
- Multiple operation modes
