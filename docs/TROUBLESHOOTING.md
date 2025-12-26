# Troubleshooting Guide

Common issues and solutions.

## Installation Issues

### Locale Not Found After Installation

**Symptoms**: `locale -a` doesn't show en_BE

**Solution**:
```bash
sudo locale-gen
sudo update-locale
```

### Permission Denied

**Symptoms**: Cannot write to system directories

**Solution**: Ensure you have sudo privileges
```bash
sudo -v  # Test sudo access
```

## Runtime Issues

### Changes Not Applied After Login

**Solution**: Fully restart your session
```bash
# Complete logout/login or:
sudo systemctl restart display-manager
```

### Mixed Locale Settings

**Symptoms**: Some applications use wrong format

**Solution**: Set all LC_* variables
```bash
export LC_ALL=en_BE.UTF-8
```

## Backup/Restore Issues

### Backup File Corrupted

**Solution**: Create fresh backup
```bash
./install-en-be.sh --backup
```

### Cannot Find Backups

**Check**: Backup directory exists
```bash
ls -la ~/.locale_backups/
```

## Distribution-Specific

### Arch Linux
```bash
sudo pacman -S glibc
sudo locale-gen
```

### Debian/Ubuntu
```bash
sudo apt install locales
sudo dpkg-reconfigure locales
```

### Fedora/RHEL
```bash
sudo dnf install glibc-langpack-en
```

## Getting Help

If issues persist:
1. Check system logs: `journalctl -xe`
2. Verify locale files: `ls -la /usr/share/i18n/locales/`
3. Open an issue with full error output
