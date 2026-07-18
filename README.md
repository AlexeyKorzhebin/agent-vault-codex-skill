# Agent Vault Codex Skill

Portable Codex skill for working with a server-side Obsidian agent vault through
the bundled `agent-vault` Linux amd64 CLI.

## Install

Clone this repository as a Codex skill:

```bash
git clone https://github.com/AlexeyKorzhebin/agent-vault-codex-skill ~/.codex/skills/agent-vault
```

Configure the target server and vault root:

```bash
export AGENT_VAULT_HOST=<ssh-host>
export AGENT_VAULT_ROOT=<absolute-vault-root-on-server>
```

Install the bundled binary on the server:

```bash
~/.codex/skills/agent-vault/scripts/install-agent-vault.sh "$AGENT_VAULT_HOST"
```

Then ask Codex to use `$agent-vault` for reading, searching, writing tasks,
attaching files, conditional updates/removals, or saving Markdown web clips with
local attachments.

For web clips with image metadata, use the unambiguous
`URL|filename|label` form so signed and resized URLs keep their query
parameters intact. Image downloads are limited to public HTTP(S) destinations
and 10 MiB per image.

The CLI also supports atomic raw web-clip bundles, 50 MiB adjacent attachments,
and SHA-256 compare-and-swap operations. These operations coordinate with the
LiveSync bridge through a vault-root advisory lock; direct unmanaged writes are
outside that guarantee.

The bundled binary is built and tested on Linux amd64 from the
`ObsidianSyncRules/agent-vault-cli` source. Its SHA256 is published next to the
binary and is verified by the installer before deployment.

## Hermes Agent

Клонировать репозиторий в независимый каталог, установить вложенный бинарный файл
и подключить skill к нужному профилю Hermes символической ссылкой:

```bash
git clone https://github.com/AlexeyKorzhebin/agent-vault-codex-skill \
  ~/.local/share/agent-vault-skill
~/.local/share/agent-vault-skill/scripts/install-agent-vault.sh --local
mkdir -p ~/.hermes/profiles/assistant/skills/productivity
ln -s ~/.local/share/agent-vault-skill \
  ~/.hermes/profiles/assistant/skills/productivity/agent-vault
```

Задать `AGENT_VAULT_ROOT` в окружении профиля `assistant`, запустить
`scripts/bootstrap-vault.sh`, начать новую сессию Hermes и проверить skill командой
`hermes -p assistant skills list`.
