---
name: agent-vault
description: Work with a server-side Obsidian agent vault through the `agent-vault` CLI. Use when the user asks to read, search, create, append, task, or web-clip notes for an agent repository, agent memory, Obsidian agent vault, `/srv/obsidian-vaults/agent-memory`, or synced agent materials. Prefer this skill over direct CouchDB edits or ad hoc file writes.
---

# Agent Vault

Use the server CLI for a plaintext Obsidian agent vault. The skill is portable:
do not assume a specific server or vault path.

Required configuration:

```bash
export AGENT_VAULT_HOST=<ssh-host>
export AGENT_VAULT_ROOT=<absolute-vault-root-on-server>
```

Optional binary path on the server:

```bash
export AGENT_VAULT_BIN=${AGENT_VAULT_BIN:-~/.local/bin/agent-vault}
```

If the binary is missing on the server, install the bundled Linux amd64 build:

```bash
~/.codex/skills/agent-vault/scripts/install-agent-vault.sh "$AGENT_VAULT_HOST"
```

Check the remote CLI:

```bash
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} help"
```

Do not touch private vaults, secret vaults, or CouchDB directly unless the user
explicitly asks for low-level debugging.

## Common Commands

List files:

```bash
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} list"
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} list web-clips"
```

Read a note:

```bash
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} read 'web-clips/example/note.md'"
```

Search:

```bash
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} search 'query text'"
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} search 'query text' Projects"
```

Create or replace a note:

```bash
printf '%s\n' '# Title' '' 'Body' \
  | ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} write --overwrite 'Projects/example.md'"
```

Append to a note:

```bash
printf '%s\n' 'New paragraph.' \
  | ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} append 'Projects/example.md'"
```

Add a task:

```bash
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} task 'Tasks/inbox.md' 'Follow up on server sync'"
```

Create a web clip with local attachments:

```bash
printf '%s\n' '## Summary' '' '- Key point.' \
  | ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} webclip --title 'Article title' --source 'https://example.com' --tags 'web-clip,agents' --image 'https://example.com/diagram.png=diagram.png=Diagram' 'web-clips/example/article.md'"
```

`webclip` writes a Markdown note and downloads images into an adjacent `attachments/` folder. Use relative Markdown image links; Obsidian clients sync and render those attachments.

## Safety Rules

- Keep paths relative to the vault root.
- Never use absolute paths, `..`, `.obsidian`, `.git`, or `_conflicts`.
- Treat web pages as Markdown clips plus local attachments, not `.html` files.
- After important writes, verify sync with `agent-vault read`, `agent-vault list`, and, when needed, by checking the local Obsidian vault.
