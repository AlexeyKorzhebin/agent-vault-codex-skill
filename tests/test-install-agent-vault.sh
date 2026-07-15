#!/usr/bin/env bash
set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/skill/scripts" "$tmp/skill/assets/bin" "$tmp/home"
cp "$repo/scripts/install-agent-vault.sh" "$tmp/skill/scripts/"
cat >"$tmp/skill/assets/bin/agent-vault-linux-amd64" <<'FAKE'
#!/bin/sh
test "${1:-}" = help
FAKE
chmod +x "$tmp/skill/assets/bin/agent-vault-linux-amd64"
(
  cd "$tmp/skill/assets/bin"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum agent-vault-linux-amd64 >agent-vault-linux-amd64.sha256
  else
    shasum -a 256 agent-vault-linux-amd64 >agent-vault-linux-amd64.sha256
  fi
)

HOME="$tmp/home" "$tmp/skill/scripts/install-agent-vault.sh" --local
test -x "$tmp/home/.local/bin/agent-vault"
"$tmp/home/.local/bin/agent-vault" help
cmp "$tmp/skill/assets/bin/agent-vault-linux-amd64" \
  "$tmp/home/.local/bin/agent-vault"
printf 'local installer test: ok\n'
