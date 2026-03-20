# claude-statusline-vt

Claude Code のステータスラインをリッチ表示するプラグインです。

```
⚡ BONUS TIME!! ⚡                        ← キャンペーン期間中のみ虹色で表示
🤖 Sonnet 4.6 │ 📊 15% │ ✏️ +12/-3 │ 🔀 main
5h ██░░░░░░ 18% Reset at 9pm(JST) │ 7d ██████░░ 60% Reset at 3.27 4pm(JST)
```
<img width="656" height="60" alt="image" src="https://github.com/user-attachments/assets/121bfbb8-2b6b-4538-abb1-8e488639750b" />


## 表示内容

- **Line 1**: モデル名 / コンテキスト使用率 / 編集行数 / Git ブランチ
- **Line 2**: 5時間・7日間レート制限（プログレスバー + 使用率 + リセット時刻）
- **BONUS TIME!!**: Anthropic のオフピーク2倍キャンペーン中の対象時間帯に虹色で表示（キャンペーン終了後は自動非表示）

### カラーコード

| 色 | 条件 |
|----|------|
| 緑 | 50% 未満 |
| 黄 | 50% 以上 80% 未満 |
| 赤 | 80% 以上 |

## インストール

### 1. マーケットプレイスを追加

```
/plugin marketplace add Tokine3/claude-statusline-vt
```

### 2. プラグインをインストール

```
/plugin install claude-statusline-vt@tokine3-plugins
```

### 3. プラグインをリロード

```
/reload-plugins
```

### 4. ステータスラインを設定

新しい会話を開始して、Claude に以下のように話しかけてください：

```
ステータスラインを設定して
```

Claude が自動的にセットアップスキルを実行し、`~/.claude/settings.json` を更新します。

## 動作要件

- macOS または Linux
- `jq` がインストール済みであること
- Claude Code v2.1.80 以降（`rate_limits` フィールド対応）

## ボーナスタイムの時間帯（JST）

Anthropic の2倍キャンペーン期間中、以下の時間帯にレート制限が2倍になります。

| 曜日 | 時間帯 |
|------|--------|
| 平日（月〜金） | AM 3:00 〜 PM 21:00 |
| 土・日 | 終日 |

キャンペーン終了日時（2026年3月29日 15:59 JST）を過ぎると自動的に非表示になります。

## v1.0.0 からのアップグレード

レイアウト変更・Haiku APIプローブ廃止など大きな変更があります。以下の手順でアップデートしてください。

1. プラグインを再インストール

```
/plugin install claude-statusline-vt@tokine3-plugins
```

2. セットアップスキルを再実行（`settings.json` のパスを更新するため）

```
ステータスラインを設定して
```

## ライセンス

MIT
