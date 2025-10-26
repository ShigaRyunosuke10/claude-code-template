# Claude Code Template Project

新規プロジェクト立ち上げ用テンプレート

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub](https://img.shields.io/badge/GitHub-ShigaRyunosuke10%2Fclaude--code--template-blue)](https://github.com/ShigaRyunosuke10/claude-code-template)

---

## 📦 概要

このテンプレートは、Claude Code（エージェントベース開発環境）を使った新規プロジェクト開発のスタートポイントです。

**含まれる設定**:
- ✅ **14体の汎用エージェント** - 計画、実装、テスト、品質保証、デプロイ、リリース
- ✅ **Phase Rollout System** - AI自律E2Eテストシステム（3段階デプロイ）
- ✅ **ワークフローテンプレート** - Case A（機能拡張）/ Case B（新規立ち上げ）/ Case C（デプロイ）
- ✅ **5つの横断的MCPサーバー** - GitHub, Serena, Playwright, Desktop Commander, Context7
- ✅ **Permissions & Hooks** - 安全な開発環境
- ✅ **AI開発ルール** - 命名規則、コミット規約、開発フロー

---

## 🚀 使い方

### Step 1: テンプレートをコピー

```bash
cp -r claude-code-template my-new-project
cd my-new-project
```

### Step 2: プレースホルダーを置換

[CLAUDE.md](./CLAUDE.md) を編集して、以下のプレースホルダーを実際の値に置換してください:

| プレースホルダー | 説明 | 例 |
|----------------|------|-----|
| `{{PROJECT_NAME}}` | プロジェクト名 | `my-awesome-app` |
| `{{GITHUB_OWNER}}` | GitHubオーナー名 | `YourUsername` |
| `{{REPO_NAME}}` | リポジトリ名 | `my-awesome-app` |
| `{{FRONTEND_PORT}}` | フロントエンドポート | `3000` |
| `{{BACKEND_PORT}}` | バックエンドポート | `8000` |

**置換例**:
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

### Step 3: プロジェクト固有の設定を追加（必要に応じて）

#### 3.1 MCPサーバー追加（オプション）

プロジェクト固有のMCPサーバー（例: Supabase, Firebase等）を [.mcp.json](./.mcp.json) に追加します。

```json
{
  "mcpServers": {
    "context7": { ... },
    "playwright": { ... },
    "github": { ... },
    "desktop-commander": { ... },
    "serena": { ... },
    // ↓ 新規追加
    "supabase": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--access-token",
        "${SUPABASE_ACCESS_TOKEN}",
        "--project-ref",
        "${SUPABASE_PROJECT_REF}"
      ]
    }
  }
}
```

#### 3.2 開発環境セクションを追加（オプション）

[CLAUDE.md](./CLAUDE.md) に以下のセクションを追加します（基本設定の後）:

```markdown
## 開発環境

### 必須ツール
- **Node.js**: v18.x以上
- **Python**: 3.13.x
- **Docker**: 20.x以上
- **PostgreSQL**: 14.x（Supabase）

### ローカル起動
\```bash
# バックエンド（Docker）
docker-compose up -d

# フロントエンド
cd frontend
npm install
npm run dev

# アクセス
# - フロントエンド: http://localhost:{{FRONTEND_PORT}}
# - バックエンド: http://localhost:{{BACKEND_PORT}}
# - API Docs: http://localhost:{{BACKEND_PORT}}/docs
\```

### テストユーザー
- Email: test@example.com
- Password: TestPassword123!
```

### Step 4: Git初期化

```bash
git init
git add .
git commit -m "chore: プロジェクト初期化

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 5: GitHubリポジトリ作成・プッシュ

```bash
# 1. GitHubで新規リポジトリ作成（Webから）

# 2. リモートリポジトリを追加
git remote add origin https://github.com/{{GITHUB_OWNER}}/{{REPO_NAME}}.git

# 3. メインブランチにリネーム
git branch -M main

# 4. プッシュ
git push -u origin main
```

---

## 🎯 開発開始

### Case A: 既存プロジェクトに機能を追加する場合

[.claude/workflows/case-a-existing-project.md](./.claude/workflows/case-a-existing-project.md) を参照

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

### Case B: ゼロから新規プロジェクトを立ち上げる場合

[.claude/workflows/case-b-new-project.md](./.claude/workflows/case-b-new-project.md) を参照

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

### Case C: デプロイを実行する場合

[.claude/workflows/case-c-deployment.md](./.claude/workflows/case-c-deployment.md) を参照

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

## 📂 ディレクトリ構造

```
claude-code-template/
├── .claude/
│   ├── agents/               # 14体のエージェント定義
│   │   ├── planner.md               # 統合: project-planner + sub-planner
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
│   ├── phases/               # Phase Rolloutシステム
│   │   ├── phase1-observer.json
│   │   ├── phase2-conservative.json
│   │   ├── phase3-full-autonomous.json
│   │   └── ROLLOUT_GUIDE.md
│   ├── scripts/              # ヘルパースクリプト
│   │   └── switch-phase.sh
│   ├── workflows/            # ワークフローテンプレート
│   │   ├── case-a-existing-project.md
│   │   ├── case-b-new-project.md
│   │   └── case-c-deployment.md
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
- [Case A ワークフロー](./.claude/workflows/case-a-existing-project.md)
- [Case B ワークフロー](./.claude/workflows/case-b-new-project.md)

---

## ⚠️ 注意事項

1. **プレースホルダー置換を忘れずに**: `CLAUDE.md` の `{{...}}` は必ず実際の値に置換してください
2. **MCPサーバー認証情報**: `.mcp.json` の環境変数（`${GITHUB_TOKEN}` 等）は、実行環境で設定してください
3. **Phase Rollout System**: E2Eテスト自律システムは、Phase 1（Observer Mode）から順に実行してください

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
