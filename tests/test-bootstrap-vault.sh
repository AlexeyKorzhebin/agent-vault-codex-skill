#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

chmod +x "$repo/tests/fake-agent-vault.sh"

AGENT_VAULT_BIN="$repo/tests/fake-agent-vault.sh" \
AGENT_VAULT_ROOT="$tmp/vault" \
  "$repo/scripts/bootstrap-vault.sh"

test -f "$tmp/vault/00 Главная/Сегодня.md"
test -f "$tmp/vault/10 Входящие/Входящие.md"
test -f "$tmp/vault/system/Инструкции агенту/Правила хранилища.md"
test -f "$tmp/vault/system/Инструкции агенту/Использование skills Hermes.md"
test -f "$tmp/vault/system/Схемы/Источники истины.md"
grep -Fq 'path does not include 50 Архив' "$tmp/vault/00 Главная/Сегодня.md"

printf '\nПользовательская строка.\n' >>"$tmp/vault/10 Входящие/Входящие.md"

AGENT_VAULT_BIN="$repo/tests/fake-agent-vault.sh" \
AGENT_VAULT_ROOT="$tmp/vault" \
  "$repo/scripts/bootstrap-vault.sh"

grep -Fq 'Пользовательская строка.' "$tmp/vault/10 Входящие/Входящие.md"
printf 'bootstrap test: ok\n'
