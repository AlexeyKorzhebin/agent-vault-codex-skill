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

Then ask Codex to use `$agent-vault` for reading, searching, writing tasks, or
saving Markdown web clips with local attachments.

For web clips with image metadata, use the unambiguous
`URL|filename|label` form so signed and resized URLs keep their query
parameters intact. Image downloads are limited to public HTTP(S) destinations
and 10 MiB per image.

The bundled binary is built and tested on Linux amd64 from the
`ObsidianSyncRules/agent-vault-cli` source. Its SHA256 is published next to the
binary and is verified by the installer before deployment.
