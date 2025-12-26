# Usage Guide

Comprehensive guide for using the locale installer script.

## Basic Installation

### Standard Installation

```bash
./install-en-be.sh
```

This will:
1. Check if the locale exists
2. Create a backup of current settings
3. Download and install en_BE.UTF-8
4. Show formatting examples
5. Prompt to set as system default

### Silent Installation

Set environment variable to skip prompts:

```bash
AUTO_CONFIRM=yes ./install-en-be.sh
```

## Advanced Usage

### Backup Management

#### Create Backup
```bash
./install-en-be.sh --backup
```

#### List Backups
```bash
./install-en-be.sh --list-backups
```

#### Restore Latest
```bash
./install-en-be.sh --restore
# Type: latest
```

#### Restore Specific Backup
```bash
./install-en-be.sh --restore
# Type: locale_backup_20250126_180000.tar.gz
```

### Viewing Examples Only

To see formatting without installation:

```bash
./install-en-be.sh --examples
```

## Setting Locale for Specific Users

### Per-User Configuration

Add to `~/.bashrc` or `~/.profile`:

```bash
export LANG=en_BE.UTF-8
export LC_ALL=en_BE.UTF-8
```

### Temporary Session

```bash
export LANG=en_BE.UTF-8
date  # Will use Belgian format
```

## Application-Specific Settings

### Python
```python
import locale
locale.setlocale(locale.LC_ALL, 'en_BE.UTF-8')
```

### Node.js
```javascript
const date = new Date().toLocaleDateString('en-BE');
```

### PHP
```php
setlocale(LC_ALL, 'en_BE.UTF-8');
```

## Verification

Check installed locales:
```bash
locale -a | grep en_BE
```

Check current settings:
```bash
locale
```

Test formatting:
```bash
LC_ALL=en_BE.UTF-8 date '+%x %X'
```
