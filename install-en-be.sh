#!/usr/bin/env bash
set -euo pipefail

readonly LOCALE_NAME="en_BE.UTF-8"
readonly LOCALE_SOURCE_NAME="en_BE"
readonly LOCALE_FILE="/usr/share/i18n/locales/${LOCALE_SOURCE_NAME}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOCAL_LOCALE_FILE="${SCRIPT_DIR}/locales/en_BE.UTF-8"
readonly BACKUP_DIR="${HOME}/.locale_backups"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S_%N)"

run_root() {
  if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

detect_distro_family() {
  local id="" id_like=""
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    id="${ID:-}"
    id_like="${ID_LIKE:-}"
  fi
  case " ${id} ${id_like} " in
    *" arch "*|*" cachyos "*|*" manjaro "*|*" endeavouros "*) echo arch ;;
    *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop "*) echo debian ;;
    *" rhel "*|*" fedora "*|*" centos "*|*" rocky "*|*" almalinux "*) echo rhel ;;
    *) echo unsupported ;;
  esac
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: required command not found: $1" >&2
    return 1
  }
}

locale_available() {
  locale -a 2>/dev/null | grep -Eiq '^en_BE[.]utf-?8$'
}

check_prerequisites() {
  local family="$1"
  require_command locale
  require_command localedef
  [[ $EUID -eq 0 ]] || require_command sudo
  [[ -r "$LOCAL_LOCALE_FILE" ]] || {
    echo "Error: locale source not found: $LOCAL_LOCALE_FILE" >&2
    return 1
  }
  if [[ ! -r /usr/share/i18n/locales/en_GB || ! -e /usr/share/i18n/charmaps/UTF-8.gz ]]; then
    echo "Error: glibc locale sources are missing." >&2
    if [[ "$family" == rhel ]]; then
      echo "Install them with: sudo dnf install glibc-locale-source" >&2
    else
      echo "Reinstall the glibc package and try again." >&2
    fi
    return 1
  fi
  if [[ "$family" == arch || "$family" == debian ]]; then
    require_command locale-gen
    [[ -f /etc/locale.gen ]] || {
      echo "Error: /etc/locale.gen is missing." >&2
      return 1
    }
  fi
}

ensure_backup_dir() {
  mkdir -p -m 0700 "$BACKUP_DIR"
}

backup_config() {
  ensure_backup_dir
  local backup_file="${BACKUP_DIR}/locale_backup_${TIMESTAMP}.tar.gz"
  local files=() path
  for path in etc/locale.conf etc/locale.gen etc/default/locale usr/share/i18n/locales/en_BE; do
    [[ -e "/$path" ]] && files+=("$path")
  done
  echo "==> Creating backup: $backup_file"
  if ((${#files[@]})); then
    run_root tar -C / -czf - -- "${files[@]}" >"$backup_file"
  else
    tar -czf "$backup_file" --files-from /dev/null
  fi
  {
    printf 'locale_source_present=%s\n' "$([[ -e "$LOCALE_FILE" ]] && echo yes || echo no)"
    printf 'locale_available=%s\n' "$(locale_available && echo yes || echo no)"
  } >"${backup_file}.meta"
  chmod 0600 "$backup_file" "${backup_file}.meta"
  printf '%s\n' "$backup_file" >"${BACKUP_DIR}/latest_backup.txt"
}

list_backups() {
  ensure_backup_dir
  local backups=("${BACKUP_DIR}"/locale_backup_*.tar.gz)
  if [[ ! -e "${backups[0]}" ]]; then echo "No backups found"; else printf '%s\n' "${backups[@]}"; fi
}

validate_backup_archive() {
  local backup_file="$1" entry
  while IFS= read -r entry; do
    case "$entry" in
      etc/locale.conf|etc/locale.gen|etc/default/locale|usr/share/i18n/locales/en_BE) ;;
      *) echo "Error: unexpected path in backup: $entry" >&2; return 1 ;;
    esac
  done < <(tar -tzf "$backup_file")
}

restore_config() {
  ensure_backup_dir
  list_backups
  local choice backup_file source_was_present="yes" locale_was_available="yes"
  read -r -p "Enter backup filename, or 'latest': " choice
  if [[ "$choice" == latest ]]; then
    [[ -r "${BACKUP_DIR}/latest_backup.txt" ]] || { echo "Error: no latest backup" >&2; return 1; }
    backup_file="$(<"${BACKUP_DIR}/latest_backup.txt")"
  else
    backup_file="${BACKUP_DIR}/${choice}"
  fi
  case "$backup_file" in
    "${BACKUP_DIR}"/locale_backup_*.tar.gz) ;;
    *) echo "Error: backup must be inside $BACKUP_DIR" >&2; return 1 ;;
  esac
  [[ -f "$backup_file" ]] || { echo "Error: backup not found: $backup_file" >&2; return 1; }
  validate_backup_archive "$backup_file"
  if [[ -r "${backup_file}.meta" ]]; then
    source_was_present="$(awk -F= '$1 == "locale_source_present" { print $2 }' "${backup_file}.meta")"
    locale_was_available="$(awk -F= '$1 == "locale_available" { print $2 }' "${backup_file}.meta")"
  fi
  echo "==> Restoring: $backup_file"
  run_root tar -C / -xzf "$backup_file" --no-same-owner --no-same-permissions
  [[ "$source_was_present" != no ]] || run_root rm -f -- "$LOCALE_FILE"
  case "$(detect_distro_family)" in
    arch|debian)
      run_root locale-gen
      ;;
    rhel)
      if [[ "$locale_was_available" == yes && -r "$LOCALE_FILE" ]]; then
        run_root localedef -i "$LOCALE_SOURCE_NAME" -f UTF-8 "$LOCALE_NAME"
      elif [[ "$locale_was_available" == no ]] && locale_available; then
        run_root localedef --delete-from-archive en_BE.utf8
      fi
      ;;
  esac
  echo "==> Restore complete. Log out and back in before testing defaults."
}

show_locale_examples() {
  locale_available || { echo "Error: $LOCALE_NAME is not installed" >&2; return 1; }
  echo "==> $LOCALE_NAME examples"
  LC_ALL="$LOCALE_NAME" date '+  Date:     %x'
  LC_ALL="$LOCALE_NAME" date '+  Time:     %X'
  LC_ALL="$LOCALE_NAME" date '+  DateTime: %c'
  LC_ALL="$LOCALE_NAME" locale -k decimal_point thousands_sep currency_symbol \
    mon_decimal_point mon_thousands_sep
}

enable_locale_gen_entry() {
  if grep -Eq '^[[:space:]]*#?[[:space:]]*en_BE[.]UTF-8[[:space:]]+UTF-8[[:space:]]*$' /etc/locale.gen; then
    run_root sed -Ei \
      's|^[[:space:]]*#?[[:space:]]*en_BE[.]UTF-8[[:space:]]+UTF-8[[:space:]]*$|en_BE.UTF-8 UTF-8|' \
      /etc/locale.gen
  else
    printf '%s\n' 'en_BE.UTF-8 UTF-8' | run_root tee -a /etc/locale.gen >/dev/null
  fi
  run_root locale-gen
}

install_locale() {
  local family="$1"
  echo "==> Installing locale source: $LOCALE_FILE"
  run_root install -o root -g root -m 0644 "$LOCAL_LOCALE_FILE" "$LOCALE_FILE"
  if [[ "$family" == arch || "$family" == debian ]]; then
    enable_locale_gen_entry
  else
    run_root localedef -i "$LOCALE_SOURCE_NAME" -f UTF-8 "$LOCALE_NAME"
  fi
  locale_available || { echo "Error: $LOCALE_NAME was not generated" >&2; return 1; }
  echo "==> $LOCALE_NAME installed"
}

set_system_locale() {
  local family
  family="$(detect_distro_family)"
  if [[ "$family" == debian ]]; then
    require_command update-locale
    run_root update-locale "LANG=$LOCALE_NAME"
  else
    require_command localectl
    run_root localectl set-locale "LANG=$LOCALE_NAME"
  fi
  echo "==> System LANG set to $LOCALE_NAME. Existing LC_* settings were preserved."
  echo "==> Log out and back in for the change to reach your session."
}

get_user_profile() {
  local shell_name
  if [[ -n "${EN_BE_PROFILE:-}" ]]; then
    case "$EN_BE_PROFILE" in
      /*) printf '%s\n' "$EN_BE_PROFILE" ;;
      *) printf '%s/%s\n' "$HOME" "$EN_BE_PROFILE" ;;
    esac
    return 0
  fi
  shell_name="$(basename "${SHELL:-}")"
  case "$shell_name" in
    zsh)
      local zdotdir
      if [[ -n "${ZDOTDIR:-}" ]]; then
        zdotdir="$ZDOTDIR"
      else
        zdotdir="$(zsh -fc 'printf %s "${ZDOTDIR:-$HOME}"')"
      fi
      printf '%s/.zprofile\n' "$zdotdir"
      ;;
    bash)
      if [[ -e "$HOME/.bash_profile" ]]; then
        printf '%s/.bash_profile\n' "$HOME"
      elif [[ -e "$HOME/.bash_login" ]]; then
        printf '%s/.bash_login\n' "$HOME"
      else
        printf '%s/.profile\n' "$HOME"
      fi
      ;;
    *)
      echo "Error: per-user configuration supports Bash and Zsh; detected ${shell_name:-unknown}" >&2
      return 1
      ;;
  esac
}

set_user_locale() {
  local profile profile_dir temp_file backup_file
  profile="$(get_user_profile)"
  profile_dir="$(dirname "$profile")"
  mkdir -p "$profile_dir"
  temp_file="$(mktemp "${profile_dir}/.en-be-profile.XXXXXX")"

  if [[ -e "$profile" ]]; then
    backup_file="${profile}.en-be-backup-${TIMESTAMP}"
    cp -p -- "$profile" "$backup_file"
    awk '
      $0 == "# >>> en-BE locale >>>" { managed = 1; next }
      $0 == "# <<< en-BE locale <<<" { managed = 0; next }
      !managed { print }
    ' "$profile" >"$temp_file"
    chmod --reference="$profile" "$temp_file"
    echo "==> Profile backup: $backup_file"
  else
    chmod 0644 "$temp_file"
  fi

  cat >>"$temp_file" <<EOF

# >>> en-BE locale >>>
export LANG=$LOCALE_NAME
unset LC_ALL LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
unset LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION
# <<< en-BE locale <<<
EOF
  mv -- "$temp_file" "$profile"
  echo "==> User locale configured in: $profile"
  echo "==> Start a new login session to apply it."
}

show_usage() {
  cat <<EOF
Usage: $0 [OPTION]

Install and configure $LOCALE_NAME on Arch-based, Debian-based, and RHEL-based systems.

Options:
  --install       Install the locale without changing system LANG
  --set-user-default
                  Set the locale for the current Bash or Zsh user
  --set-default   Set system LANG after the locale is installed
  --examples      Show formatting examples
  --backup        Back up locale configuration and the custom source
  --restore       Restore a backup
  --list-backups  List available backups
  --help          Display this help

Set EN_BE_PROFILE to override the profile selected by --set-user-default.
EOF
}

main() {
  local action="${1:---install}" family
  case "$action" in
    --install)
      family="$(detect_distro_family)"
      [[ "$family" != unsupported ]] || { echo "Error: supported families are Arch, Debian, and RHEL" >&2; exit 1; }
      check_prerequisites "$family"
      if locale_available; then echo "==> $LOCALE_NAME is already installed"; else backup_config; install_locale "$family"; fi
      show_locale_examples
      ;;
    --set-default)
      locale_available || { echo "Error: install $LOCALE_NAME first" >&2; exit 1; }
      backup_config
      set_system_locale
      ;;
    --set-user-default)
      locale_available || { echo "Error: install $LOCALE_NAME first" >&2; exit 1; }
      set_user_locale
      ;;
    --examples) show_locale_examples ;;
    --backup) backup_config ;;
    --restore) restore_config ;;
    --list-backups) list_backups ;;
    --help|-h) show_usage ;;
    *) echo "Error: unknown option: $action" >&2; show_usage >&2; exit 1 ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
