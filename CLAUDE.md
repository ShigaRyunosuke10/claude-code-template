# Claude Code - {{PROJECT_NAME}}

エージェントベースの開発設定

---

## 基本設定

- **回答**: 日本語
- **リポジトリ**: {{GITHUB_OWNER}}/{{REPO_NAME}}
- **ポート**: フロントエンド {{FRONTEND_PORT}}、バックエンド {{BACKEND_PORT}}
- **タスク管理**: TodoWriteツールで進捗可視化（必須）

---

## プロジェクト資料フォルダ

ユーザー提供の資料（要件定義書、仕様書、設計資料等）を格納するフォルダです。

詳細: [ai-rules/DOCS_FOLDER_GUIDE.md](./ai-rules/DOCS_FOLDER_GUIDE.md)

```
docs/
├── requirements/          # 要件定義書
├── specs/                # 技術仕様書
├── designs/              # 設計資料
└── references/           # 参考資料
```

**要件変更時の注意**: 要件定義書を更新した場合、Phase開始時に自動検知されます。
詳細: [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md)

---

## Phase自律実行フロー

**基本原則**: ユーザーは見守るだけ。「計画 → 実装 → まとめ」を自動実行。

詳細: [ai-rules/PHASE_START.md](./ai-rules/PHASE_START.md)

### 計画フェーズ（自動実行）

**Phase 0（プロジェクト基盤構築）の場合**:
1. GitHubリポジトリ初期化チェック（自動・GitHub MCP使用）
2. next_phase_prompt.md 読み込み、タスク自動選択
3. 詳細計画作成、自動開始

**Phase 階層**: planner がプロジェクトの状況に応じて動的生成

### 実装フェーズ（自動実行）

エージェント自動呼び出し: `impl-dev-backend`, `impl-dev-frontend`, `qa-unit`, `qa-integration`, `code-reviewer`, `sec-scan`等

詳細: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)

### まとめフェーズ（自動実行）

達成内容サマリー、KPI記録、学んだこと整理、次回推奨タスク作成、Serenaメモリ更新、Git commit & PR作成

**完了音**: ピポパ♪（600Hz → 800Hz → 1000Hz）

---

## 要件変更フロー

開発途中に「新機能追加」「仕様変更」「設計見直し」等の発言があった場合、要件変更フローを開始。

詳細: [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md)

**簡易フロー**: 作業一時保存 → 要件ヒアリング → planner実行 → 作業再開

**不要なケース**: パラメータ変更、UI微調整、バグ修正、ドキュメント修正

---

## ユーザー介入が必要な場合

基本的にセッションは自律実行されますが、以下の場合のみユーザーに相談します：

1. **Critical問題が7回試行後も解決しない**
2. **同一バグが3回連続失敗**
3. **QUARANTINE（隔離）発生**

詳細: [ai-rules/PHASE_START.md#ユーザー介入が必要な場合](./ai-rules/PHASE_START.md)

---

## エージェント一覧（16体）

詳細: [.claude/agents/README.md](./.claude/agents/README.md)

### カテゴリ別概要

- **計画系**: planner, mcp-finder, tech-stack-validator
- **実装系**: impl-dev-frontend, impl-dev-backend
- **テスト系**: playwright-test-planner/generator/healer, qa-unit, qa-integration
- **品質保証系**: code-reviewer, lint-fix, sec-scan
- **インフラ系**: deployment-agent
- **リリース系**: release-manager, doc-writer

### プロジェクト固有コマンド

- **/docs-sync** - Serenaメモリ → 公式Docs同期
- **/pre-commit-check** - コミット前チェック（lint → sec-scan → code-reviewer）

---

## MCPサーバー

### テンプレート標準搭載

- **github** - PR/Issue管理（環境変数: `GITHUB_TOKEN`）
- **serena** - コードベース解析
- **playwright** - E2Eテスト
- **codex** - AI コーディングアシスタント（環境変数: `OPENAI_API_KEY`）
  - 詳細: [ai-rules/CODEX_CONSULTATION.md](./ai-rules/CODEX_CONSULTATION.md)

### 技術スタック依存（Phase 0.3で追加）

- **supabase** - Supabase DB操作（Supabase使用時）
- **stripe, auth0, vercel等** - プロジェクト次第で追加

**設定方法**:
- 必須環境変数: [README.md - Step 0](./README.md)
- 技術スタック依存: [ai-rules/ENV_SETUP_GUIDE.md](./ai-rules/ENV_SETUP_GUIDE.md)（Phase 0.3で自動生成）

---

## ★ プロジェクト固有設定

このプロジェクト特有の機能・ルール・ワークフローを管理します。

詳細: [ai-rules/PROJECT_CUSTOMIZATION.md](./ai-rules/PROJECT_CUSTOMIZATION.md)

### 参照の優先順位

1. **プロジェクト固有** → `.claude/project/`, `ai-rules-project/`
2. **テンプレート（共通）** → `.claude/`, `ai-rules/`

### 編集方針

- **複数ファイル持てる場合**: プロジェクト固有は `.claude/project/` または `ai-rules-project/` に配置
- **一つしか持てないファイル**: 直接編集OK（例: `.mcp.json`, `CLAUDE.md`）

---

## ドキュメント構造

### 開発プロセス

- [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md) - 開発フロー詳細
- [ai-rules/PHASE_START.md](./ai-rules/PHASE_START.md) - Phase実行フロー
- [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md) - 要件変更フロー
- [ai-rules/PHASE_COMPLETION.md](./ai-rules/PHASE_COMPLETION.md) - Phase完了手順
- [ai-rules/CONVENTIONS.md](./ai-rules/CONVENTIONS.md) - 命名規則・コミット規約

### エージェント・設定

- [.claude/agents/README.md](./.claude/agents/README.md) - エージェント一覧
- [.claude/settings.json](./.claude/settings.json) - Permissions & Hooks
- [.claude/phases/ROLLOUT_GUIDE.md](./.claude/phases/ROLLOUT_GUIDE.md) - AI自律システム段階導入

### プロジェクト固有

- [ai-rules/PROJECT_CUSTOMIZATION.md](./ai-rules/PROJECT_CUSTOMIZATION.md) - プロジェクト固有設定管理
- [.claude/project/](./.claude/project/) - プロジェクト固有エージェント・コマンド・ワークフロー
- [ai-rules-project/](./ai-rules-project/) - プロジェクト固有ルール

### AI向け技術詳細

- [.serena/memories/specifications/](./.serena/memories/specifications/) - API/DB/アーキテクチャ仕様
- [.serena/memories/project/](./.serena/memories/project/) - セッション記録

### 人間向けドキュメント

- [docs/api/API.md](./docs/api/API.md) - APIリファレンス
- [docs/database/DATABASE.md](./docs/database/DATABASE.md) - データベーススキーマ

---

## Permissions & Hooks

設定: [.claude/settings.json](./.claude/settings.json)

**禁止事項**: `rm -rf /*`, `git push --force main`, `.env*` ファイルへの書き込み

**Hooks**: mainブランチへの直接コミット防止、実装後のテスト推奨、E2Eテスト10件以上失敗で停止、Critical脆弱性検出で警告

---

## Technical Debt 管理

未解決の問題: [reports/technical-debt.md](./reports/technical-debt.md)

`/pre-commit-check`実行時に自動更新。

---

## テンプレート開発時の注意

**⚠️ 重要**: 必ず両リポジトリ（`claude-code-template/` + `claude-code-dev/`）にコミット&プッシュ

- mainブランチへの直接pushは禁止
- テンプレート開発時は両リポジトリへのコミットが必須
