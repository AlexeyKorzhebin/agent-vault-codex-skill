---
name: agent-vault
description: Use when the user asks to read, search, create, append, task, or web-clip notes in a server-side Obsidian agent vault, agent repository, agent memory, synced agent materials, or `/srv/obsidian-vaults/agent-memory`.
---

# Agent Vault

Use the server CLI for a plaintext Obsidian agent vault. Prefer it over direct
CouchDB edits or ad hoc file writes. Do not assume a specific server or vault
path.

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
  | ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-~/.local/bin/agent-vault} webclip --title 'Article title' --source 'https://example.com' --tags 'web-clip,agents' --image 'https://example.com/diagram.png?w=1200|diagram.png|Diagram' 'web-clips/example/article.md'"
```

Use `URL|filename|label` for every explicit image name or label. This keeps `=`
inside URL query parameters intact. Give each image a unique filename.

`webclip` writes a Markdown note and downloads images into an adjacent
`attachments/` folder. It accepts only public HTTP(S) image destinations,
revalidates redirects, limits each image to 10 MiB, and publishes the complete
clip only after all downloads succeed. Obsidian clients sync and render the
relative image links.

## Safety Rules

- Keep paths relative to the vault root.
- Never use absolute paths, `..`, `.obsidian`, `.git`, or `_conflicts`.
- Never route webclip downloads to loopback, private, or link-local addresses.
- Treat web pages as Markdown clips plus local attachments, not `.html` files.
- After important writes, verify sync with `agent-vault read`, `agent-vault list`, and, when needed, by checking the local Obsidian vault.
