---
description: コミット前の包括的なチェックリスト実行
allowed-tools: SlashCommand(/unit-testing:*), SlashCommand(/performance-testing-review:*), SlashCommand(/security-scanning:*), Bash(npm run test:e2e:*)
---

# リリース前チェックリスト

このコマンドは、コミット前に実行する包括的なチェックリストです。

## 実行内容

### 1. ユニットテスト自動生成
外部プラグイン（グローバルインストール済み）を使用してユニットテストを自動生成します。

```
/unit-testing:test-generate backend/ frontend/
```

### 2. AI自動レビュー
コードの品質、セキュリティ、保守性を自動レビューします。

```
/performance-testing-review:ai-review
```

### 3. セキュリティスキャン
セキュリティ脆弱性をスキャンします（SAST）。

```
/security-scanning:security-sast
```

### 4. E2Eテスト実行
Playwrightを使用してE2Eテストを実行します。

**前提**: フロントエンド・バックエンドが起動していること

```bash
cd frontend
npm run test:e2e
```

## 注意事項

- このコマンドは複数のプラグイン（グローバルインストール済み）を使用します
- 各チェックでエラーが見つかった場合は、修正してから次に進んでください
- すべてのチェックをパスしてからコミットしてください

## 使用タイミング

- コミット前（必須）
- PR作成前
- リリース前
