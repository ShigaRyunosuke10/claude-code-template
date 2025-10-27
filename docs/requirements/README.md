# Requirements / 要件定義書

ユーザー提供の要件定義書を格納するフォルダです。

## 格納するファイル

- **要件定義書** - プロジェクトの要件をまとめたドキュメント
- **ユースケース** - 機能の利用シナリオ
- **ユーザーストーリー** - ユーザー視点の機能要求
- **機能要求一覧** - 実装すべき機能のリスト

## ファイル形式

- Markdown (`.md`)
- PDF (`.pdf`)
- Word (`.docx`)
- Excel (`.xlsx`)
- テキスト (`.txt`)

## 使用例

```
docs/requirements/
├── project-requirements.md      # メインの要件定義書
├── user-stories.md              # ユーザーストーリー
├── functional-requirements.xlsx # 機能要求一覧
└── initial-proposal.pdf         # 初期提案書
```

## 注意事項

- このフォルダは**ユーザー提供の資料**専用です
- AI が参照して実装計画を立てます
- 要件変更時はファイルを更新し、REQUIREMENTS_CHANGE.md のフローに従ってください

## 関連ドキュメント

- [ai-rules/REQUIREMENTS_CHANGE.md](../ai-rules/REQUIREMENTS_CHANGE.md) - 要件変更フロー
- [ai-rules/WORKFLOW.md](../ai-rules/WORKFLOW.md) - 開発ワークフロー
