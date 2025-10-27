# エージェント一覧

このフォルダには16体の汎用エージェントが定義されています。

---

## 📊 カテゴリ別エージェント一覧

### 計画系（1体）

#### **planner** - プロジェクト計画・Phase管理
- 役割: Phase開始時の計画作成、タスク分解、エージェント呼び出し
- 呼び出し: 自動（Phase開始時）
- 詳細: [planner.md](./planner.md)

---

### 実装系（2体）

#### **impl-dev-backend** - バックエンド実装
- 役割: バックエンドコード実装、API開発、データベース操作
- 呼び出し: `Task:impl-dev-backend(prompt: "...")`
- 詳細: [impl-dev-backend.md](./impl-dev-backend.md)

#### **impl-dev-frontend** - フロントエンド実装
- 役割: フロントエンドコード実装、UI開発、状態管理
- 呼び出し: `Task:impl-dev-frontend(prompt: "...")`
- 詳細: [impl-dev-frontend.md](./impl-dev-frontend.md)

---

### テスト系（5体）

#### **playwright-test-planner** - E2Eテスト計画
- 役割: E2Eテストケース計画、テストシナリオ作成
- 呼び出し: `Task:playwright-test-planner(prompt: "...")`
- 詳細: [playwright-test-planner.md](./playwright-test-planner.md)

#### **playwright-test-generator** - E2Eテスト生成
- 役割: Playwrightテストコード生成
- 呼び出し: `Task:playwright-test-generator(prompt: "...")`
- 詳細: [playwright-test-generator.md](./playwright-test-generator.md)

#### **playwright-test-healer** - E2Eテスト自動修復
- 役割: 失敗したE2Eテストの自動修復（SMOKE/HEALING/QUARANTINE）
- 呼び出し: `Task:playwright-test-healer(prompt: "...")`
- 詳細: [playwright-test-healer.md](./playwright-test-healer.md)

#### **qa-unit** - ユニットテスト
- 役割: ユニットテスト実行、カバレッジ確認
- 呼び出し: `Task:qa-unit(prompt: "...")`
- 詳細: [qa-unit.md](./qa-unit.md)

#### **qa-integration** - 統合テスト
- 役割: 統合テスト実行、API統合確認
- 呼び出し: `Task:qa-integration(prompt: "...")`
- 詳細: [qa-integration.md](./qa-integration.md)

---

### 品質保証系（3体）

#### **code-reviewer** - コードレビュー
- 役割: コードレビュー、バグ検出、改善提案
- 呼び出し: `Task:code-reviewer(prompt: "...")`
- 詳細: [code-reviewer.md](./code-reviewer.md)

#### **lint-fix** - リント修正
- 役割: リント・フォーマットエラー自動修正
- 呼び出し: `Task:lint-fix(prompt: "...")`
- 詳細: [lint-fix.md](./lint-fix.md)

#### **sec-scan** - セキュリティスキャン
- 役割: セキュリティ脆弱性スキャン、依存関係チェック
- 呼び出し: `Task:sec-scan(prompt: "...")`
- 詳細: [sec-scan.md](./sec-scan.md)

---

### インフラ系（3体）

#### **deployment-agent** - デプロイ・技術スタック決定
- 役割: 技術スタック決定、インフラ構成、デプロイ設定
- 呼び出し: `Task:deployment-agent(prompt: "...")`
- 詳細: [deployment-agent.md](./deployment-agent.md)

#### **tech-stack-validator** - 技術スタック検証
- 役割: 技術スタック最新状況確認、ベストプラクティス適用、環境変数設定ガイド生成
- 呼び出し: `Task:tech-stack-validator(prompt: "...")`
- 詳細: [tech-stack-validator.md](./tech-stack-validator.md)

#### **mcp-finder** - MCP検索・設定
- 役割: 技術スタックに最適なMCPサーバー検索・設定
- 呼び出し: `Task:mcp-finder(prompt: "...")`
- 詳細: [mcp-finder.md](./mcp-finder.md)

---

### リリース系（2体）

#### **release-manager** - リリース管理
- 役割: リリースノート作成、バージョン管理、リリース判定
- 呼び出し: `Task:release-manager(prompt: "...")`
- 詳細: [release-manager.md](./release-manager.md)

#### **doc-writer** - ドキュメント作成
- 役割: README.md、API仕様書、開発ドキュメント作成
- 呼び出し: `Task:doc-writer(prompt: "...")`
- 詳細: [doc-writer.md](./doc-writer.md)

---

## 🤖 Codex AI相談機能

以下のエージェントは、エラーループ時に自動的にCodex AIに相談します：

- **impl-dev-backend** - 同一バグパターン3回失敗時
- **impl-dev-frontend** - 同一バグパターン3回失敗時
- **playwright-test-healer** - HEALING仮説処方失敗時
- **code-reviewer** - Critical問題検出時
- **qa-unit** - 同一テストケース3回失敗時
- **qa-integration** - 同一統合テストケース3回失敗時

詳細: [ai-rules/CODEX_CONSULTATION.md](../../ai-rules/CODEX_CONSULTATION.md)

---

## 📚 関連ドキュメント

- [ai-rules/WORKFLOW.md](../../ai-rules/WORKFLOW.md) - 開発フロー全体
- [ai-rules/PHASE_START.md](../../ai-rules/PHASE_START.md) - Phase開始手順
- [CLAUDE.md](../../CLAUDE.md) - プロジェクト設定
