#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install-agent-vault.sh <ssh-host> [install-dir]

Copies the bundled Linux amd64 agent-vault binary to a remote server.

Arguments:
  ssh-host     SSH host alias or user@host.
  install-dir Remote install directory. Defaults to ~/.local/bin.

Examples:
  install-agent-vault.sh hermes
  install-agent-vault.sh openclaw /usr/local/bin
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

host="${1:-}"
install_dir="${2:-~/.local/bin}"

if [[ -z "$host" ]]; then
  usage >&2
  exit 2
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd -- "$script_dir/.." && pwd)"
bin_dir="$skill_dir/assets/bin"
src="$bin_dir/agent-vault-linux-amd64"
sha_file="$bin_dir/agent-vault-linux-amd64.sha256"

if [[ ! -f "$src" ]]; then
  echo "missing bundled binary: $src" >&2
  exit 1
fi

if [[ -f "$sha_file" ]]; then
  if command -v shasum >/dev/null 2>&1; then
    (cd "$bin_dir" && shasum -a 256 -c "$(basename "$sha_file")" >/dev/null)
  elif command -v sha256sum >/dev/null 2>&1; then
    (cd "$bin_dir" && sha256sum -c "$(basename "$sha_file")" >/dev/null)
  else
    echo "warning: neither shasum nor sha256sum is available; skipping checksum verification" >&2
  fi
fi

remote_tmp="/tmp/agent-vault-linux-amd64-$(date +%s)-$$"
scp -q "$src" "$host:$remote_tmp"

ssh "$host" "sh -s -- '$install_dir' '$remote_tmp'" <<'REMOTE_INSTALL'
set -eu
install_dir="$1"
remote_tmp="$2"

if [ "$install_dir" = "~" ]; then
  install_dir="$HOME"
else
  without_tilde="${install_dir#\~/}"
  if [ "$without_tilde" != "$install_dir" ]; then
    install_dir="$HOME/$without_tilde"
  else
    case "$install_dir" in
      /*) ;;
      *) install_dir="$HOME/$install_dir" ;;
    esac
  fi
fi

mkdir -p "$install_dir"
install -m 0755 "$remote_tmp" "$install_dir/agent-vault"
rm -f "$remote_tmp"
"$install_dir/agent-vault" help >/dev/null
printf 'installed: %s\n' "$install_dir/agent-vault"
REMOTE_INSTALL
