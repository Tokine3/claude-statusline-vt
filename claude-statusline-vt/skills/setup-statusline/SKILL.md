---
name: setup-statusline
description: Configure Claude Code to use the claude-statusline-vt script. Run this after installing the plugin.
---

以下の手順でステータスラインを設定します。

1. まず、このスキルの `Base directory` から実際のインストールパスを特定します：
   - Base directory の例: `~/.claude/plugins/cache/tokine3-plugins/claude-statusline-vt/1.0.0/skills/setup-statusline`
   - `statusline.sh` のパスは Base directory から `skills/setup-statusline` を除いたディレクトリ直下です
   - 例: `~/.claude/plugins/cache/tokine3-plugins/claude-statusline-vt/1.0.0/statusline.sh`

2. `~/.claude/settings.json` を開き、`statusLine` の設定を追加または更新します（パスは上で特定した実際のパスを使用）：

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/plugins/cache/tokine3-plugins/claude-statusline-vt/1.0.0/statusline.sh"
  }
}
```

ユーザーの `~/.claude/settings.json` を読み込み、`statusLine` フィールドが存在しない場合は追加、すでに存在する場合は上記の値に更新してください。
設定後、「ステータスラインを設定しました。Claude Code を再起動すると反映されます。」と伝えてください。
