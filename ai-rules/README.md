# AI Rules - nissei プロジェクト

プラグインベースの開発ガイドライン

## 📁 ファイル構成

```
ai-rules/
├── README.md        # 本ファイル
├── WORKFLOW.md      # 開発フロー
└── CONVENTIONS.md   # 命名規則・コミット規約
```

## 🚀 クイックスタート

### 1. セッション開始
- `next_session_prompt.md` があれば読む
- なければSerenaメモリ確認

### 2. ブランチ作成
```bash
git checkout -b feat-<機能名>
```

### 3. 実装
[CONVENTIONS.md](./CONVENTIONS.md) に従って命名

### 4. テスト
```
/nissei:e2e-full
```

### 5. リリース前チェック
```
/nissei:release-check
```
- ユニットテスト自動生成
- AI自動レビュー
- セキュリティスキャン
- 依存関係監査
- パフォーマンス分析
- E2Eテスト

### 6. PR作成・マージ
[WORKFLOW.md](./WORKFLOW.md) の「PR作成」を参照

### 7. マージ後
```
/nissei:docs-sync
```

## ⚠️ 重要

- mainブランチへの直接作業禁止
- コミット前にE2Eテスト必須
- PR作成後にcode-reviewer実行必須
- マージ後にdocs-updater実行必須
