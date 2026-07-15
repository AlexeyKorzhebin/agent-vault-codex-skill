#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  install-agent-vault.sh --local [install-dir]
  install-agent-vault.sh <ssh-host> [install-dir]

Устанавливает вложенный Linux amd64 бинарный файл agent-vault локально или через SSH.
Каталог установки по умолчанию: ~/.local/bin.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

mode="${1:-}"
destination="${2:-~/.local/bin}"
if [[ -z "$mode" ]]; then
  usage >&2
  exit 2
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd -- "$script_dir/.." && pwd)"
bin_dir="$skill_dir/assets/bin"
src="$bin_dir/agent-vault-linux-amd64"
sha_file="$bin_dir/agent-vault-linux-amd64.sha256"

[[ -f "$src" ]] || { echo "missing bundled binary: $src" >&2; exit 1; }

if [[ -f "$sha_file" ]]; then
  if command -v shasum >/dev/null 2>&1; then
    (cd "$bin_dir" && shasum -a 256 -c "$(basename "$sha_file")" >/dev/null)
  elif command -v sha256sum >/dev/null 2>&1; then
    (cd "$bin_dir" && sha256sum -c "$(basename "$sha_file")" >/dev/null)
  else
    echo "checksum tool not found" >&2
    exit 1
  fi
fi

expand_install_dir() {
  local value=$1
  if [[ "$value" == "~" ]]; then
    printf '%s\n' "$HOME"
  elif [[ "$value" == "~/"* ]]; then
    printf '%s/%s\n' "$HOME" "${value#\~/}"
  elif [[ "$value" == /* ]]; then
    printf '%s\n' "$value"
  else
    printf '%s/%s\n' "$HOME" "$value"
  fi
}

if [[ "$mode" == "--local" ]]; then
  install_dir=$(expand_install_dir "$destination")
  install -d "$install_dir"
  install -m 0755 "$src" "$install_dir/agent-vault"
  "$install_dir/agent-vault" help >/dev/null
  printf 'installed: %s\n' "$install_dir/agent-vault"
  exit 0
fi

host=$mode
remote_tmp="/tmp/agent-vault-linux-amd64-$(date +%s)-$$"
scp -q "$src" "$host:$remote_tmp"
ssh "$host" "sh -s -- '$destination' '$remote_tmp'" <<'REMOTE_INSTALL'
set -eu
install_dir=$1
remote_tmp=$2
if [ "$install_dir" = "~" ]; then
  install_dir=$HOME
elif [ "${install_dir#\~/}" != "$install_dir" ]; then
  install_dir="$HOME/${install_dir#\~/}"
elif [ "${install_dir#/}" = "$install_dir" ]; then
  install_dir="$HOME/$install_dir"
fi
mkdir -p "$install_dir"
install -m 0755 "$remote_tmp" "$install_dir/agent-vault"
rm -f "$remote_tmp"
"$install_dir/agent-vault" help >/dev/null
printf 'installed: %s\n' "$install_dir/agent-vault"
REMOTE_INSTALL
