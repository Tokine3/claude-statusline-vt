---
name: setup-statusline
description: Configure Claude Code to use the claude-statusline-vt script. Run this after installing the plugin.
---

以下の手順でステータスラインを設定します。

1. まず、このプラグインのインストールパスを確認します：
   - プラグインは通常 `~/.claude/plugins/claude-statusline-vt/` にインストールされます

2. `~/.claude/settings.json` を開き、`statusLine` の設定を追加または更新します：

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/plugins/claude-statusline-vt/statusline.sh"
  }
}
```

ユーザーの `~/.claude/settings.json` を読み込み、`statusLine` フィールドが存在しない場合は追加、すでに存在する場合は上記の値に更新してください。
設定後、「ステータスラインを設定しました。Claude Code を再起動すると反映されます。」と伝えてください。
