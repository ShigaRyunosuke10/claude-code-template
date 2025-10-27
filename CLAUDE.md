# Claude Code - {{PROJECT_NAME}}

エージェントベースの開発設定

---

## 基本設定

- **回答**: 日本語
- **リポジトリ**: {{GITHUB_OWNER}}/{{REPO_NAME}}
- **ポート**: フロントエンド {{FRONTEND_PORT}}、バックエンド {{BACKEND_PORT}}
- **タスク管理**: TodoWriteツールで進捗可視化（必須）

---

## プロジェクト資料

ユーザー提供の資料（要件定義書、仕様書、設計資料等）を格納するフォルダ構成です。

### 📁 docs/ フォルダ構成

```
docs/
├── requirements/          # 要件定義書
│   ├── project-requirements.md
│   ├── user-stories.md
│   └── functional-requirements.xlsx
│
├── specs/                # 技術仕様書
│   ├── api-spec.yaml
│   ├── database-schema.sql
│   └── screen-wireframes.pdf
│
├── designs/              # 設計資料
│   ├── architecture-diagram.png
│   ├── ui-mockup.fig
│   └── sequence-diagram.mmd
│
└── references/           # 参考資料
    ├── competitor-analysis.md
    ├── market-research.pdf
    └── best-practices.md
```

### 使い方

1. **要件定義書を配置**
   - `docs/requirements/` に要件定義書を格納
   - AI が参照して実装計画を立てます

2. **仕様書を配置**
   - `docs/specs/` にAPI仕様、DB設計等を格納
   - AI が実装時に参照します

3. **設計資料を配置**
   - `docs/designs/` にアーキテクチャ図、UIモックアップ等を格納
   - AI が設計資料を参照して実装します

4. **参考資料を配置**
   - `docs/references/` に競合分析、技術調査等を格納
   - AI が技術選定時に参考にします

### 要件変更時の注意

要件定義書を更新した場合、Phase開始時に自動検知されます。
詳細: [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md)

---

## Phase自律実行フロー

**基本原則**: ユーザーは見守るだけ。「計画 → 実装 → まとめ」を自動実行。

詳細: [ai-rules/PHASE_START.md](./ai-rules/PHASE_START.md)

### ① 計画フェーズ（自動実行）

**Phase 0（プロジェクト基盤構築）の場合**:
1. **GitHubリポジトリ初期化チェック**（自動・GitHub MCP使用）← NEW
   - **環境変数 `GITHUB_TOKEN` をチェック**（必須）
   - 未設定の場合は設定手順を表示し、一時中断
   - リモートURLがなければリポジトリ作成を提案
   - プロジェクト名、リポジトリ名をヒアリング
   - **GitHub MCP (`mcp__github__create_repository`) でリポジトリ作成**
   - CLAUDE.md のプレースホルダー自動置換
   - git init, commit, push を自動実行
   - 詳細: [ai-rules/PHASE_START.md - Step -1](./ai-rules/PHASE_START.md)

**通常のPhaseの場合**:
1. **next_phase_prompt.md 読み込み** - 前回の推奨タスクを確認
2. **タスク自動選択** - 優先度: 高 → 中 → 低 の順で選択
3. **詳細計画作成** - TodoWriteで実装ステップをリスト化
4. **自動開始** - 承認不要、自動的に実装フェーズへ

### ② 実装フェーズ（自動実行）

**Phase 階層の動的生成**:
- planner がプロジェクトの状況に応じて Phase 階層を生成
- Phase 開始時に見直し、実態と乖離していれば再計画

詳細: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)

**エージェント自動呼び出し**:
- backend実装 → `impl-dev-backend`
- frontend実装 → `impl-dev-frontend`
- テスト → `qa-unit` / `qa-integration` / E2E
- 品質保証 → `code-reviewer` / `sec-scan`

**エラー時**: 自動修復を試みる（ループ対策あり）

### ③ まとめフェーズ（自動実行）

1. **達成内容サマリー作成**
2. **KPI記録**（Pass Rate、Test Debt Ratio等）
3. **学んだこと整理**
4. **次回推奨タスク作成**
5. **Serenaメモリ更新**
6. **Git commit & PR作成**

**完了音**: ピポパ♪（600Hz → 800Hz → 1000Hz）

---

## 要件変更フロー

開発途中に「新機能追加」「仕様変更」「設計見直し」等の発言があった場合、要件変更フローを開始。

詳細: [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md)

**簡易フロー**:
1. 作業一時保存 (`git commit -m "wip: ..."`)
2. 要件ヒアリング
3. planner実行（要件検証 → 計画生成）
4. 作業再開

**要件変更フロー不要なケース**: パラメータ変更、UI微調整、バグ修正、ドキュメント修正

---

## ユーザー介入が必要な場合

基本的にセッションは自律実行されますが、以下の場合のみユーザーに相談します：

1. **Critical問題が7回試行後も解決しない**
   - 選択肢: 続行（最大10回）/ Technical Debt登録 / 停止

2. **同一バグが3回連続失敗**
   - 選択肢: 続行（最大6回）/ 手動修正 / Technical Debt登録

3. **QUARANTINE（隔離）発生**
   - E2Eテストを一時的に隔離（推奨: 3日）

詳細: [ai-rules/PHASE_START.md](./ai-rules/PHASE_START.md#ユーザー介入が必要な場合)

---

## テンプレート開発時の注意

**⚠️ 重要**: 必ず両リポジトリ（`claude-code-template/` + `claude-code-dev/`）にコミット&プッシュ

- mainブランチへの直接pushは禁止
- テンプレート開発時は両リポジトリへのコミットが必須

---

## エージェント一覧（16体）

詳細: [.claude/agents/](./.claude/agents/)

### 計画・要件定義
- **planner** - Epic+タスク+API契約生成
- **mcp-finder** - 技術スタックに対応するMCP自動検索・セットアップガイド生成
- **tech-stack-validator** - 技術スタック検証・最新情報確認（Context7連携、ユーザー意図尊重）

### 実装
- **impl-dev-frontend** / **impl-dev-backend** - 実装

### 品質保証
- **code-reviewer** - レビュー+FE/BE整合性チェック
- **qa-unit** / **qa-integration** - テスト作成
- **playwright-test-planner** / **playwright-test-generator** / **playwright-test-healer** - E2E
- **lint-fix** / **sec-scan** - 品質保証

### ドキュメント・デプロイ
- **doc-writer** / **release-manager** - ドキュメント・リリース
- **deployment-agent** - デプロイ全般

### プロジェクト固有コマンド

- **/docs-sync** - Serenaメモリ → 公式Docs同期
- **/pre-commit-check** - コミット前チェック（lint → sec-scan → code-reviewer）

---

## MCPサーバー

- **github** - PR/Issue管理
- **serena** - コードベース解析
- **playwright** - E2Eテスト
- **desktop-commander** - ファイルシステム操作
- **context7** - ライブラリドキュメント取得
- **codex** - AI コーディングアシスタント（エラーループ時の自動相談）

**設定方法**: [ai-rules/ENV_SETUP_GUIDE.md](./ai-rules/ENV_SETUP_GUIDE.md)（技術スタック依存の環境変数設定ガイド）
詳細: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)

---

## ★ プロジェクト固有設定

このプロジェクト特有の機能・ルール・ワークフローを管理します。

詳細: [ai-rules/PROJECT_CUSTOMIZATION.md](./ai-rules/PROJECT_CUSTOMIZATION.md)

### 参照の優先順位

1. **プロジェクト固有** → `.claude/project/`, `ai-rules-project/`
2. **テンプレート（共通）** → `.claude/`, `ai-rules/`

### 編集方針

**複数ファイル持てる場合**（エージェント、ワークフロー、ルール等）:
- テンプレートは変更禁止
- プロジェクト固有は `.claude/project/` または `ai-rules-project/` に配置

**一つしか持てないファイル**（設定ファイル等）:
- 直接編集OK
- 例: `.mcp.json`, `CLAUDE.md`, `.claude/settings.json`, `.gitignore`

### プロジェクト固有エージェント

現在登録なし。プロジェクト固有のエージェントが必要な場合は `.claude/project/agents/` に追加してください。

**例**:
```markdown
- **payment-processor** - 決済処理専用エージェント
  - 詳細: [.claude/project/agents/payment-processor.md](./.claude/project/agents/payment-processor.md)
  - 責任: Stripe API連携、決済ログ記録
```

### プロジェクト固有ワークフロー

現在登録なし。プロジェクト固有のワークフローが必要な場合は `.claude/project/workflows/` に追加してください。

**例**:
```markdown
- **決済フロー** - Stripe連携の標準ワークフロー
  - 詳細: [.claude/project/workflows/payment-flow.md](./.claude/project/workflows/payment-flow.md)
  - 使用タイミング: 決済機能の追加・変更時
```

### プロジェクト固有コマンド

現在登録なし。プロジェクト固有のコマンドが必要な場合は `.claude/project/commands/` に追加してください。

**例**:
```markdown
- **/payment-check** - 決済データ整合性チェック
  - 詳細: [.claude/project/commands/payment-check.md](./.claude/project/commands/payment-check.md)
```

### プロジェクト固有ルール

現在登録なし。プロジェクト固有のルールが必要な場合は `.claude/project/rules/` または `ai-rules-project/` に追加してください。

**例**:
```markdown
- **決済セキュリティルール** - PCI DSS準拠
  - 詳細: [.claude/project/rules/PAYMENT_RULES.md](./.claude/project/rules/PAYMENT_RULES.md)
- **カスタム開発規約**
  - 詳細: [ai-rules-project/CUSTOM_CONVENTIONS.md](./ai-rules-project/CUSTOM_CONVENTIONS.md)
```

### 不要なテンプレート機能（このプロジェクトでは使用しない）

現在登録なし。使用しないテンプレート機能があれば明記してください（ファイルは削除せず無視）。

**例**:
```markdown
- ❌ **deployment-agent** - デプロイは手動運用のため不使用
- ❌ **Case C ワークフロー** - デプロイワークフロー不使用
- ❌ **playwright-test-*** - E2Eテストは別ツール使用
```

**重要**: テンプレートファイル（`.claude/agents/`, `.claude/workflows/`, `ai-rules/`）は**絶対に削除・変更しない**でください。

---

## ドキュメント構造

### 開発プロセス
- [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md) - 開発フロー詳細
- [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md) - 要件変更フロー
- [ai-rules/PHASE_COMPLETION.md](./ai-rules/PHASE_COMPLETION.md) - Phase完了手順
- [ai-rules/CONVENTIONS.md](./ai-rules/CONVENTIONS.md) - 命名規則・コミット規約

### ツール設定
- [.claude/settings.json](./.claude/settings.json) - Permissions & Hooks
- [.claude/agents/](./.claude/agents/) - エージェント定義（16体）
- [.claude/phases/ROLLOUT_GUIDE.md](./.claude/phases/ROLLOUT_GUIDE.md) - AI自律システム段階導入（Mode 1-3）

### AI向け技術詳細
- [.serena/memories/specifications/](./.serena/memories/specifications/) - API/DB/アーキテクチャ仕様
- [.serena/memories/project/](./.serena/memories/project/) - セッション記録

### 人間向けドキュメント
- [docs/api/API.md](./docs/api/API.md) - APIリファレンス
- [docs/database/DATABASE.md](./docs/database/DATABASE.md) - データベーススキーマ

---

## Permissions & Hooks

設定: [.claude/settings.json](./.claude/settings.json)

**禁止事項**:
- `rm -rf /*` - 全削除禁止
- `git push --force main` - mainへのforce push禁止
- `.env*` ファイルへの書き込み禁止

**Hooks**:
- mainブランチへの直接コミット防止
- 実装後のテスト推奨
- E2Eテスト10件以上失敗で停止
- Critical脆弱性検出で警告

---

## Technical Debt 管理

未解決の問題: [reports/technical-debt.md](./reports/technical-debt.md)

`/pre-commit-check`実行時に自動更新。

---

## 参考リンク

- **ワークフロー詳細**: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)
- **要件変更**: [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md)
- **Phase完了**: [ai-rules/PHASE_COMPLETION.md](./ai-rules/PHASE_COMPLETION.md)
- **AI自律システム導入**: [.claude/phases/ROLLOUT_GUIDE.md](./.claude/phases/ROLLOUT_GUIDE.md)
