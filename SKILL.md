---
name: agent-vault
description: Чтение, поиск и сохранение долговечных материалов и задач в серверном агентском Obsidian vault.
metadata:
  version: 1.1.0
  hermes:
    tags: [obsidian, productivity, memory]
    category: productivity
---

# Агентский vault

Используйте `agent-vault` вместо прямого изменения CouchDB или файлов vault.

Обязательное окружение:

```bash
export AGENT_VAULT_ROOT=/absolute/path/to/the/vault
```

Локальный запуск, когда агент работает на сервере с vault:

```bash
${AGENT_VAULT_BIN:-agent-vault} --root "$AGENT_VAULT_ROOT" list
```

Удалённый запуск используется только при явно заданном `AGENT_VAULT_HOST`:

```bash
ssh "$AGENT_VAULT_HOST" "AGENT_VAULT_ROOT='$AGENT_VAULT_ROOT' ${AGENT_VAULT_BIN:-agent-vault} list"
```

Никогда не предполагайте имя сервера или корень vault. Перед созданием проектов,
областей, контактов, встреч, идей и источников прочитайте
`references/vault-conventions.md`.

## Основные команды

```bash
${AGENT_VAULT_BIN:-agent-vault} --root "$AGENT_VAULT_ROOT" list
${AGENT_VAULT_BIN:-agent-vault} --root "$AGENT_VAULT_ROOT" read "relative/path.md"
${AGENT_VAULT_BIN:-agent-vault} --root "$AGENT_VAULT_ROOT" search "query"
printf '%s\n' '# Title' '' 'Body' | ${AGENT_VAULT_BIN:-agent-vault} --root "$AGENT_VAULT_ROOT" write "relative/path.md"
${AGENT_VAULT_BIN:-agent-vault} --root "$AGENT_VAULT_ROOT" task "relative/path.md" "Task text"
```

После каждой записи прочитайте тот же путь. Используйте `write --overwrite` только
после подтверждения пользователем замены существующей заметки.

## Веб-клипы

Сохраняйте веб-страницы как Markdown с адресом источника во frontmatter и
локальными изображениями:

```bash
printf '%s\n' '## Summary' '' '- Key point.' | \
  ${AGENT_VAULT_BIN:-agent-vault} --root "$AGENT_VAULT_ROOT" webclip \
    --title "Article title" \
    --source "https://example.com/article" \
    --tags "web-clip,agents" \
    --image "https://example.com/diagram.png?w=1200|diagram.png|Diagram" \
    "40 Ресурсы/Источники/Статьи/example/article.md"
```

Используйте формат `URL|filename|label`; имена файлов должны быть уникальными. Не
сохраняйте HTML как основной материал.

## Безопасность

- Все пути должны быть относительными к `AGENT_VAULT_ROOT`.
- Не используйте абсолютные пути заметок, `..`, `.obsidian`, `.git` и `_conflicts`.
- Не обращайтесь к личным или секретным vault.
- Не сохраняйте пароли, API-ключи, токены, приватные ключи и содержимое `.env`.
- Не загружайте изображения веб-клипов с loopback, частных или link-local адресов.
- Запрашивайте подтверждение перед удалением, массовым перемещением, внешней
  отправкой, финансовыми операциями и изменениями инфраструктуры вне утверждённого плана.
