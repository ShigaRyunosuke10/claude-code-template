# Claude Code Template Project

新規プロジェクト立ち上げ用テンプレート

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub](https://img.shields.io/badge/GitHub-ShigaRyunosuke10%2Fclaude--code--template-blue)](https://github.com/ShigaRyunosuke10/claude-code-template)

---

## 📦 概要

このテンプレートは、Claude Code（エージェントベース開発環境）を使った新規プロジェクト開発のスタートポイントです。

**含まれる設定**:
- ✅ **16体の汎用エージェント** - 計画、実装、テスト、品質保証、デプロイ、リリース
- ✅ **AI自律実行システム（Mode 1-3）** - AI自律E2Eテストシステム（段階的デプロイ）
- ✅ **動的ワークフローシステム** - plannerが状況に応じてPhase階層を生成
- ✅ **4つの横断的MCPサーバー** - GitHub, Serena, Playwright, Codex
- ✅ **Permissions & Hooks** - 安全な開発環境
- ✅ **AI開発ルール** - 命名規則、コミット規約、開発フロー

---

## 🚀 使い方

### Step 0: 環境変数設定

**必須設定（テンプレートのMCPサーバー用）**:

```bash
# 1. GitHub Personal Access Token（必須）
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# 2. OpenAI API Key（必須 - Codex AI相談機能用）
export OPENAI_API_KEY="sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# 確認
echo $GITHUB_TOKEN | head -c 10
echo $OPENAI_API_KEY | head -c 10
```

**取得方法**:

#### 1. GitHub Personal Access Token
1. [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
2. "Generate new token (classic)" をクリック
3. Scopes: `repo`, `workflow`, `admin:org`（プライベートリポジトリの場合は `repo` 全権限）
4. トークンをコピーして環境変数に設定

#### 2. OpenAI API Key
1. [OpenAI API Keys](https://platform.openai.com/api-keys) にアクセス
2. "Create new secret key" をクリック
3. APIキーをコピーして環境変数に設定
4. **用途**: エラーループ時のCodex AI自動相談
   - Critical/High問題: 初回発生時に自動相談
   - Medium問題: 3回失敗後に自動相談
   - 詳細: [ai-rules/CODEX_CONSULTATION.md](./ai-rules/CODEX_CONSULTATION.md)

**技術スタック依存の設定（Phase 0.2で自動チェック）**:

Phase 0.2 でテンプレートが技術スタックを決定後、`tech-stack-validator` が必要な環境変数を自動的にチェックします。
設定が不足している場合は、テンプレートが設定方法を案内します。

**自動生成される設定ガイド**:
- `ai-rules/ENV_SETUP_GUIDE.md` - 技術スタック別の環境変数設定手順が自動生成されます

**設定が必要になる可能性のある環境変数**:
- `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF` (Supabase使用時)
- `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY` (Stripe使用時)
- `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET` (Auth0使用時)
- その他（Vercel, AWS, GCP等、技術スタック次第）

詳細: [ai-rules/PHASE_START.md - Phase 0.2](./ai-rules/PHASE_START.md)、[ai-rules/ENV_SETUP_GUIDE.md](./ai-rules/ENV_SETUP_GUIDE.md)

---



### Step 1: テンプレートをコピー

```

### Step 2: プレースホルダーを置換（自動化）

**Phase 0.0 開始時に自動実行されます**。手動での置換は不要です。

Claude Code がPhase 0（プロジェクト基盤構築）の最初に以下を自動実行します：

1. **GitHubリポジトリ作成の確認**
   - リモートURLがなければリポジトリ作成を提案
   - **環境変数 `GITHUB_TOKEN` を使用してGitHub MCP経由で作成**
   - プロジェクト名、リポジトリ名、可視性をヒアリング

2. **CLAUDE.md プレースホルダー自動置換**
   - `{{PROJECT_NAME}}` → 実際のプロジェクト名
   - `{{GITHUB_OWNER}}` → GitHubオーナー名
   - `{{REPO_NAME}}` → リポジトリ名
   - `{{FRONTEND_PORT}}` → フロントエンドポート（デフォルト: 3000）
   - `{{BACKEND_PORT}}` → バックエンドポート（デフォルト: 8000）

3. **git init & commit & push**
   - 初回コミット作成
   - GitHubリポジトリにプッシュ

詳細: [ai-rules/PHASE_START.md - Step -1](./ai-rules/PHASE_START.md)

---

**手動で置換したい場合**:

```bash
# macOS/Linux
sed -i 's/{{PROJECT_NAME}}/my-awesome-app/g' CLAUDE.md
sed -i 's/{{GITHUB_OWNER}}/YourUsername/g' CLAUDE.md
sed -i 's/{{REPO_NAME}}/my-awesome-app/g' CLAUDE.md
sed -i 's/{{FRONTEND_PORT}}/3000/g' CLAUDE.md
sed -i 's/{{BACKEND_PORT}}/8000/g' CLAUDE.md

# Windows PowerShell
(Get-Content CLAUDE.md) -replace '{{PROJECT_NAME}}', 'my-awesome-app' | Set-Content CLAUDE.md
(Get-Content CLAUDE.md) -replace '{{GITHUB_OWNER}}', 'YourUsername' | Set-Content CLAUDE.md
(Get-Content CLAUDE.md) -replace '{{REPO_NAME}}', 'my-awesome-app' | Set-Content CLAUDE.md
(Get-Content CLAUDE.md) -replace '{{FRONTEND_PORT}}', '3000' | Set-Content CLAUDE.md
(Get-Content CLAUDE.md) -replace '{{BACKEND_PORT}}', '8000' | Set-Content CLAUDE.md
```

### Step 3: プロジェクト固有ディレクトリ作成

プロジェクト固有の機能・ルール・ワークフローを管理するためのディレクトリを作成します。

```bash
# プロジェクト固有ディレクトリ作成
mkdir -p .claude/project/{agents,workflows,commands,rules}
mkdir -p ai-rules-project

# .gitkeep 作成（空ディレクトリをGit管理）
touch .claude/project/agents/.gitkeep
touch .claude/project/workflows/.gitkeep
touch .claude/project/commands/.gitkeep
touch .claude/project/rules/.gitkeep
touch ai-rules-project/.gitkeep
```

**ディレクトリ構造**:
```
my-project/
├── .claude/
│   ├── agents/          # テンプレート（16体）- 変更禁止
│   ├── workflows/       # テンプレート（動的ワークフローガイド）- 変更禁止
│   ├── commands/        # テンプレート - 変更禁止
│   └── project/         # ★ プロジェクト固有
│       ├── agents/      # プロジェクト固有エージェント
│       ├── workflows/   # プロジェクト固有ワークフロー
│       ├── commands/    # プロジェクト固有コマンド
│       └── rules/       # プロジェクト固有ルール
│
├── ai-rules/            # テンプレート - 変更禁止
├── ai-rules-project/    # ★ プロジェクト固有ルール
│
└── docs/                # ★ プロジェクト資料
    ├── requirements/    # 要件定義書
    ├── specs/           # 技術仕様書
    ├── designs/         # 設計資料
    └── references/      # 参考資料
```

### Step 3.5: プロジェクト資料フォルダ（推奨）

ユーザー提供の資料（要件定義書、仕様書等）を格納するフォルダです。

```bash
# docs フォルダはテンプレートに含まれています
# 必要に応じて資料を配置してください
```

**使い方**:
- `docs/requirements/` - 要件定義書、ユーザーストーリー
- `docs/specs/` - API仕様、DB設計
- `docs/designs/` - アーキテクチャ図、UIモックアップ
- `docs/references/` - 競合分析、技術調査

詳細: 各フォルダ内の `README.md` を参照

### Step 4: Claude Code でプロジェクト開始（自動化）

**Phase 0（プロジェクト基盤構築）を開始してください**。

```
ユーザー「Next.js + FastAPIで勤怠管理システムを作りたい」
  ↓
Claude Code が Phase 0 を開始
  ↓
① GitHubリポジトリ作成の確認
  - プロジェクト名、リポジトリ名をヒアリング
  - 環境変数 GITHUB_TOKEN をチェック
  - GitHub MCP経由でリポジトリ作成 + git init, commit, push
  ↓
② CLAUDE.md プレースホルダー自動置換
  ↓
③ 技術スタック決定（deployment-agent）
④ 技術スタック検証（tech-stack-validator）
⑤ MCP設定（mcp-finder）
⑥ プロジェクト初期化
```

詳細: [ai-rules/PHASE_START.md - Step -1](./ai-rules/PHASE_START.md)

---

**手動で Git 初期化・GitHub リポジトリ作成したい場合**:

```bash
# 1. Git 初期化
git init
git add .
git commit -m "chore: プロジェクト初期化"

# 2. GitHubリポジトリ作成（GitHub CLI）
gh repo create my-awesome-app --private --source=. --description="プロジェクトの説明" --push

# または Web から作成
# 3. リモートリポジトリを追加
git remote add origin https://github.com/{{GITHUB_OWNER}}/{{REPO_NAME}}.git

# 4. メインブランチにリネーム
git branch -M main

# 5. プッシュ
git push -u origin main
```

---

## 🎯 開発開始

### 既存プロジェクトに機能を追加する場合

[ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md) を参照

```bash
# Claude Codeで以下のフローを実行
# Phase 0: 要件ヒアリング（メインClaude Agentが実行）

# Phase 1: Planning
Task:planner(prompt: "新機能の計画立案 + タスク詳細化")

# Phase 2: Implementation
Task:impl-dev-backend(prompt: "バックエンド実装")
Task:impl-dev-frontend(prompt: "フロントエンド実装")

# Phase 3: Testing
Task:qa-unit(prompt: "ユニットテスト作成")
Task:qa-integration(prompt: "統合テスト作成")

# Phase 4: Quality Assurance
/pre-commit-check  # lint-fix → sec-scan → code-reviewer (型定義整合性チェック含む)
/docs-sync
```

### ゼロから新規プロジェクトを立ち上げる場合

[ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md) を参照

```bash
# Claude Codeで以下のフローを実行
# Phase 0: 要件ヒアリング（メインClaude Agentが実行）

# Phase 1: アーキテクチャ設計
Task:planner(prompt: "プロジェクト構想・技術スタック選定 + タスク詳細化")

# Phase 2: プロジェクト初期化
Task:impl-dev-backend(prompt: "バックエンド初期セットアップ")
Task:impl-dev-frontend(prompt: "フロントエンド初期セットアップ")

# Phase 3: コア機能実装（認証システム優先）
Task:impl-dev-backend(prompt: "認証API実装")
Task:impl-dev-frontend(prompt: "認証UI実装")

# Phase 4: テスト基盤構築
Task:qa-unit(prompt: "ユニットテスト基盤セットアップ")
Task:qa-integration(prompt: "統合テスト基盤セットアップ")

# Phase 5: Quality Assurance
/pre-commit-check  # lint-fix → sec-scan → code-reviewer (型定義整合性チェック含む)

# Phase 6: ドキュメント整備
/docs-sync

# Phase 7: デプロイ基盤構築
Task:deployment-agent(prompt: "デプロイ構成推奨 + 設定ファイル生成 + 初回デプロイ")
```

### デプロイを実行する場合

[ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md) を参照

```bash
# Claude Codeで以下のフローを実行
# Phase 0: デプロイ要件定義（メインClaude Agentが実行）

# Phase 1: プラットフォーム推奨・設定ファイル生成
Task:deployment-agent(prompt: "以下の要件に基づいてデプロイ構成を推奨
- フロントエンド: Next.js
- バックエンド: FastAPI
- データベース: PostgreSQL (Supabase)
- チーム規模: 個人
- 予算: 無料枠のみ
")

# Phase 2: デプロイ前検証
Task:deployment-agent(prompt: "デプロイ前検証を実行")

# Phase 3: 初回デプロイ
Task:deployment-agent(prompt: "初回デプロイ実行")

# Phase 4: ヘルスチェック
Task:deployment-agent(prompt: "デプロイ後ヘルスチェック実行")

# Phase 5: CI/CD設定（継続的デプロイ）
# GitHub Actionsが自動実行（main ブランチへのpush時）

# トラブル時: ロールバック
Task:deployment-agent(prompt: "前バージョンへロールバック")
```

---

## 📝 プロジェクト固有設定の追加方法

テンプレートを使い始めた後、プロジェクト特有の機能・ルール・ワークフローを追加する方法。

詳細: [CLAUDE.md](./CLAUDE.md) の「プロジェクト固有設定」セクション

### 1. プロジェクト固有エージェントの追加

**使用例**: 決済処理専用エージェントを追加する場合

```bash
# ファイル作成
touch .claude/project/agents/payment-processor.md
```

**ファイル内容** (`.claude/project/agents/payment-processor.md`):
```markdown
# payment-processor

決済処理専用エージェント

## 責任
- Stripe API連携
- 決済ログ記録
- 決済エラーハンドリング

## 使用タイミング
- 決済機能の実装・変更時

## 呼び出し方法
\`\`\`bash
Task:payment-processor(prompt: "Stripe決済フローの実装")
\`\`\`
```

**CLAUDE.md更新**（「プロジェクト固有設定」セクション）:
```markdown
### プロジェクト固有エージェント

- **payment-processor** - 決済処理専用エージェント
  - 詳細: [.claude/project/agents/payment-processor.md](./.claude/project/agents/payment-processor.md)
  - 責任: Stripe API連携、決済ログ記録
```

### 2. プロジェクト固有ワークフローの追加

**使用例**: 決済フローを追加する場合

```bash
# ファイル作成
touch .claude/project/workflows/payment-flow.md
```

**CLAUDE.md更新**:
```markdown
### プロジェクト固有ワークフロー

- **決済フロー** - Stripe連携の標準ワークフロー
  - 詳細: [.claude/project/workflows/payment-flow.md](./.claude/project/workflows/payment-flow.md)
  - 使用タイミング: 決済機能の追加・変更時
```

### 3. 不要なテンプレート機能の明記

**CLAUDE.md更新**:
```markdown
### 不要なテンプレート機能（このプロジェクトでは使用しない）

- ❌ **deployment-agent** - デプロイは手動運用のため不使用
- ❌ **E2E自動修復システム** - E2Eテストは別ツール使用
```

**重要**:
- テンプレートファイル（`.claude/agents/`, `.claude/workflows/`, `ai-rules/`）は**絶対に削除・変更しない**
- 不要な機能はCLAUDE.mdに明記するだけ

### 4. プロジェクト固有の削除

プロジェクト固有機能が不要になった場合:

```bash
# ファイル削除
rm .claude/project/agents/payment-processor.md

# CLAUDE.md から該当箇所を削除

# Git commit
git commit -m "chore: payment-processor削除（決済機能廃止のため）"
```

---

## 📂 ディレクトリ構造

```
claude-code-template/
├── .claude/
│   ├── agents/               # 16体のエージェント定義
│   │   ├── planner.md               # 動的Phase階層生成
│   │   ├── mcp-finder.md            # MCP自動検索
│   │   ├── tech-stack-validator.md  # 技術スタック検証
│   │   ├── impl-dev-frontend.md
│   │   ├── impl-dev-backend.md
│   │   ├── qa-unit.md
│   │   ├── qa-integration.md
│   │   ├── playwright-test-planner.md
│   │   ├── playwright-test-generator.md
│   │   ├── playwright-test-healer.md
│   │   ├── lint-fix.md
│   │   ├── sec-scan.md
│   │   ├── code-reviewer.md         # 統合: integrator機能を含む
│   │   ├── doc-writer.md
│   │   ├── release-manager.md
│   │   └── deployment-agent.md      # 統合: deploy-manager + infra-validator
│   ├── commands/             # スラッシュコマンド
│   │   ├── docs-sync.md
│   │   ├── e2e-full.md
│   │   ├── pre-commit-check.md
│   │   └── release-check.md
│   ├── phases/               # AI自律実行システム（Mode 1-3）
│   │   ├── mode1-observer.json
│   │   ├── mode2-conservative.json
│   │   ├── mode3-full-autonomous.json
│   │   └── ROLLOUT_GUIDE.md
│   ├── scripts/              # ヘルパースクリプト
│   │   └── switch-mode.sh
│   ├── workflows/            # 動的ワークフローガイド
│   │   └── WORKFLOW.md
│   └── settings.json         # Permissions & Hooks
├── ai-rules/
│   ├── WORKFLOW.md           # 開発フロー詳細
│   ├── CONVENTIONS.md        # 命名規則・コミット規約
│   └── README.md             # クイックスタート
├── .mcp.json                 # MCP設定（汎用5サーバー）
├── CLAUDE.md                 # ルートファイル（テンプレート化）
└── README.md                 # このファイル
```

---

## 🔧 カスタマイズ

### エージェント追加

新しいエージェントを追加する場合は、[.claude/agents/](./.claude/agents/) にマークダウンファイルを作成し、[.claude/settings.json](./.claude/settings.json) の `agents` 配列に追加します。

### スラッシュコマンド追加

新しいスラッシュコマンドを追加する場合は、[.claude/commands/](./.claude/commands/) にマークダウンファイルを作成します。

---

## 📚 参考リンク

- [ワークフロー詳細](./ai-rules/WORKFLOW.md)
- [命名規則・コミット規約](./ai-rules/CONVENTIONS.md)
- [Phase Rollout Guide](./.claude/phases/ROLLOUT_GUIDE.md)
- [既存プロジェクトワークフロー](./.claude/workflows/WORKFLOW.md)
- [新規プロジェクトワークフロー](./.claude/workflows/WORKFLOW.md)

---

## ⚠️ 注意事項

1. **プレースホルダー置換を忘れずに**: `CLAUDE.md` の `{{...}}` は必ず実際の値に置換してください
2. **環境変数 GITHUB_TOKEN の設定**: Phase 0でのリポジトリ自動作成には環境変数の設定が必須です（Step 0参照）
3. **MCPサーバー認証情報**: `.mcp.json` の環境変数（`${GITHUB_TOKEN}` 等）は、実行環境で設定してください
4. **Phase Rollout System**: E2Eテスト自律システムは、Phase 1（Observer Mode）から順に実行してください

---

## 📄 ライセンス

MIT License

## 🙏 謝辞

このテンプレートは、実際のプロジェクト開発経験から抽出された汎用設定を含んでいます。

## 🔗 関連リンク

- [Claude Code 公式ドキュメント](https://docs.claude.com/en/docs/claude-code)
- [GitHub Copilot MCP](https://github.com/github/mcp)
- [Serena - AI Code Assistant](https://github.com/oraios/serena)
- [Playwright](https://playwright.dev/)
