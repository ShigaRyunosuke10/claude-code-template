# Specs / 仕様書

技術仕様書を格納するフォルダです。

## 格納するファイル

- **API仕様書** - RESTful API / GraphQL のエンドポイント定義
- **データベース設計書** - テーブル定義、ER図
- **画面仕様書** - UIコンポーネント、画面遷移図
- **外部連携仕様書** - 外部サービス・API連携の仕様

## ファイル形式

- OpenAPI / Swagger (`.yaml`, `.json`)
- Markdown (`.md`)
- SQL (`.sql`)
- PDF (`.pdf`)
- Draw.io / Mermaid (`.drawio`, `.mmd`)

## 使用例

```
docs/specs/
├── api-spec.yaml                # OpenAPI 3.0 仕様書
├── database-schema.sql          # DB スキーマ定義
├── database-erd.png             # ER図
├── screen-wireframes.pdf        # 画面ワイヤーフレーム
└── external-apis.md             # 外部API連携仕様
```

## 注意事項

- このフォルダは**技術仕様**専用です
- 要件定義書は `docs/requirements/` に格納してください
- AI が実装時に参照します

## 関連ドキュメント

- [ai-rules/CONVENTIONS.md](../ai-rules/CONVENTIONS.md) - 命名規則・コーディング規約
- [ai-rules/WORKFLOW.md](../ai-rules/WORKFLOW.md) - 開発ワークフロー
