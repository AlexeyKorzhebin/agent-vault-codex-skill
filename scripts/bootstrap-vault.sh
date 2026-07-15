#!/bin/sh
set -eu

: "${AGENT_VAULT_ROOT:?set AGENT_VAULT_ROOT to the absolute vault path}"

bin=${AGENT_VAULT_BIN:-agent-vault}
repo=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
templates=$repo/templates/vault

if [ ! -d "$templates" ]; then
  echo "template directory not found: $templates" >&2
  exit 1
fi

find "$templates" -type f -name '*.md' -print | LC_ALL=C sort |
while IFS= read -r source; do
  relative=${source#"$templates"/}
  if "$bin" --root "$AGENT_VAULT_ROOT" read "$relative" >/dev/null 2>&1; then
    printf 'skip existing: %s\n' "$relative"
    continue
  fi
  "$bin" --root "$AGENT_VAULT_ROOT" write "$relative" <"$source"
  printf 'created: %s\n' "$relative"
done
