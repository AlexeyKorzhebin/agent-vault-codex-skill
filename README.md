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
