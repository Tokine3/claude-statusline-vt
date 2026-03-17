# claude-statusline-vt

Claude Code のステータスラインをリッチ表示するプラグインです。

```
⚡ BONUS TIME!! ⚡          ← ボーナスタイム中のみ虹色で表示
🤖 claude-sonnet-4-6 │ 📊 15% │ ✏️ +12/-3 │ 🔀 main
⏱ 5h  ▰▰▱▱▱▱▱▱▱▱  18%   Resets 9pm (Asia/Tokyo)
📅 7d  ▰▰▰▰▰▰▱▱▱▱  60%   Resets Mar 20 at 4am (Asia/Tokyo)
```
例）
<img width="579" height="134" alt="image" src="https://github.com/user-attachments/assets/b597c4a0-64d9-4e80-8137-00f8cd479917" />


## 表示内容

- **Line 1**: モデル名 / コンテキスト使用率 / 編集行数 / Gitブランチ
- **Line 2**: 5時間レート制限（プログレスバー + リセット時刻）
- **Line 3**: 7日間レート制限（プログレスバー + リセット時刻）
- **BONUS TIME!!**: Anthropicのオフピーク促進時間帯（JST）に虹色で表示

## インストール

### 1. マーケットプレイスを追加

```
/plugin marketplace add Tokine3/claude-statusline-vt
```

### 2. プラグインをインストール

```
/plugin install claude-statusline-vt@tokine3-plugins
```

### 3. ステータスラインを設定

```
/setup-statusline
```

## 動作要件

- macOS（Keychain経由でトークン取得）または Linux
- `jq`, `curl` がインストール済みであること
- Claude Code の OAuth ログイン済みであること

## ボーナスタイムの時間帯（JST）

Anthropic の2倍キャンペーン期間中、以下の時間帯にレート制限が2倍になります。

| 曜日 | 時間帯 |
|------|--------|
| 平日（月〜金） | AM 3:00 〜 PM 21:00 |
| 土・日 | 終日 |

## ライセンス

MIT
