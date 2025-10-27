# Designs / 設計資料

設計資料を格納するフォルダです。

## 格納するファイル

- **アーキテクチャ図** - システム構成図、インフラ構成図
- **UI/UXデザイン** - モックアップ、デザインカンプ
- **クラス図** - オブジェクト指向設計
- **シーケンス図** - 処理フロー、API呼び出し順序
- **状態遷移図** - 画面遷移、ステータス管理

## ファイル形式

- 画像 (`.png`, `.jpg`, `.svg`)
- Figma / Sketch (`.fig`, `.sketch`)
- PDF (`.pdf`)
- Draw.io / Mermaid (`.drawio`, `.mmd`)
- PlantUML (`.puml`)

## 使用例

```
docs/designs/
├── architecture-diagram.png     # システム構成図
├── ui-mockup.fig                # Figma デザインファイル
├── class-diagram.puml           # クラス図 (PlantUML)
├── sequence-diagram.mmd         # シーケンス図 (Mermaid)
└── state-machine.drawio         # 状態遷移図 (Draw.io)
```

## 注意事項

- このフォルダは**設計資料**専用です
- UI/UXデザインは実装前にレビューしてください
- AI が設計資料を参照して実装します

## 関連ドキュメント

- [ai-rules/WORKFLOW.md](../ai-rules/WORKFLOW.md) - 開発ワークフロー
- [.claude/agents/](../.claude/agents/) - 実装エージェント
