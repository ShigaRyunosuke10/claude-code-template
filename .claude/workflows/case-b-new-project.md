# Case B: 新規プロジェクト立ち上げワークフロー

ゼロから新規プロジェクトを立ち上げる際のエージェント連携フロー。

## Phase 1: アーキテクチャ設計（Architecture Design）

### 1.1 プロジェクト構想

**エージェント**: `project-planner`

```bash
Task:project-planner(prompt: "Next.js + FastAPI + Supabaseで勤怠管理システムを構築したい")
```

**出力**: `project-overview.md`
- システム概要
- 技術スタック
- フェーズ分割（Phase 1-6等）
- マイルストーン

### 1.2 システムアーキテクチャ設計

**エージェント**: `project-planner`

```bash
Task:project-planner(prompt: "システムアーキテクチャ設計書を作成")
```

**出力**: `system_architecture.md`
- フロントエンド構成
- バックエンド構成
- データベース構成
- デプロイ構成

---

## Phase 2: プロジェクト初期化（Project Initialization）

### 2.1 バックエンド初期化

**エージェント**: `impl-dev-backend`

```bash
Task:impl-dev-backend(prompt: "FastAPIプロジェクト初期セットアップ
- Docker Compose設定
- FastAPI基本構成
- Supabase接続
- 認証システム基盤")
```

**作成ファイル**:
- `backend/Dockerfile`
- `backend/docker-compose.yml`
- `backend/app/main.py`
- `backend/app/core/config.py`
- `backend/app/core/security.py`

### 2.2 フロントエンド初期化

**エージェント**: `impl-dev-frontend`

```bash
Task:impl-dev-frontend(prompt: "Next.js 14プロジェクト初期セットアップ
- App Router構成
- Tailwind CSS設定
- 認証フロー基盤
- APIクライアント設定")
```

**作成ファイル**:
- `frontend/package.json`
- `frontend/tailwind.config.ts`
- `frontend/src/app/layout.tsx`
- `frontend/src/lib/api/client.ts`

### 2.3 CI/CD初期設定

```bash
# GitHub Actions設定
.github/workflows/ci.yml
.github/workflows/cd.yml
```

---

## Phase 3: コア機能実装（Core Features）

### 3.1 認証システム

**Phase 3.1.1: バックエンド認証API**

```bash
Task:impl-dev-backend(prompt: "認証API実装
- POST /api/auth/register
- POST /api/auth/login
- GET /api/auth/me")
```

**Phase 3.1.2: フロントエンド認証UI**

```bash
Task:impl-dev-frontend(prompt: "認証UI実装
- /login ページ
- /register ページ
- AuthGuard実装")
```

**Phase 3.1.3: 統合チェック**

```bash
Task:integrator(prompt: "認証システムの整合性チェック")
```

### 3.2 マスターデータ管理

**Phase 3.2.1: データベース設計**

```bash
Task:impl-dev-backend(prompt: "マスターテーブル設計・マイグレーション作成")
```

**Phase 3.2.2: CRUD API実装**

```bash
# 並列実行可能
Task:impl-dev-backend(prompt: "ユーザー管理API実装")
Task:impl-dev-backend(prompt: "プロジェクト管理API実装")
```

**Phase 3.2.3: UI実装**

```bash
# 並列実行可能
Task:impl-dev-frontend(prompt: "ユーザー一覧・詳細UI実装")
Task:impl-dev-frontend(prompt: "プロジェクト一覧・詳細UI実装")
```

---

## Phase 4: テスト基盤構築（Testing Infrastructure）

### 4.1 ユニットテスト基盤

**エージェント**: `qa-unit`

```bash
# バックエンド
Task:qa-unit(prompt: "pytest環境セットアップ
- conftest.py作成
- MockSupabaseClient実装
- フィクスチャ定義")

# フロントエンド（必要な場合）
Task:qa-unit(prompt: "Jest環境セットアップ
- jest.config.js作成
- テストユーティリティ実装")
```

### 4.2 統合テスト基盤

**エージェント**: `qa-integration`

```bash
Task:qa-integration(prompt: "統合テスト環境セットアップ
- TestClient設定
- DB初期化ヘルパー
- トランザクションロールバック")
```

### 4.3 E2Eテスト基盤

```bash
# Playwrightセットアップ
cd frontend
npx playwright install

# E2Eテストヘルパー作成
Task:playwright-test-planner(prompt: "E2Eテスト基盤構築
- authヘルパー
- waitヘルパー
- storageState設定")
```

---

## Phase 5: ドキュメント整備（Documentation）

### 5.1 AI向けメモリ作成

```bash
mcp__serena__write_memory(
  memory_name: "project/project_overview.md",
  content: "プロジェクト概要..."
)

mcp__serena__write_memory(
  memory_name: "specifications/api_specifications.md",
  content: "API仕様..."
)

mcp__serena__write_memory(
  memory_name: "specifications/database_specifications.md",
  content: "データベース仕様..."
)

mcp__serena__write_memory(
  memory_name: "specifications/system_architecture.md",
  content: "システムアーキテクチャ..."
)
```

### 5.2 人間向けドキュメント作成

```bash
# ドキュメントディレクトリ構造作成
mkdir -p docs/api docs/database docs/project

# ドキュメント作成
docs/api/API.md
docs/database/DATABASE.md
docs/project/PHASES.md
docs/project/CURRENT_PHASE.md
```

### 5.3 開発ガイド作成

```bash
# プロジェクトルート
CLAUDE.md - Claude Code基本設定
README.md - プロジェクト概要・セットアップ

# ai-rules/
ai-rules/WORKFLOW.md - 開発フロー
ai-rules/CONVENTIONS.md - 命名規則・コミット規約
ai-rules/README.md - クイックスタート
```

---

## Phase 6: デプロイ基盤構築（Deployment Infrastructure）

### 6.1 Docker本番ビルド

```bash
# Dockerfile.prod作成
backend/Dockerfile.prod
frontend/Dockerfile.prod
docker-compose.prod.yml
```

### 6.2 CI/CD完全設定

```bash
# GitHub Actions完全設定
.github/workflows/ci.yml - Lint/Test/Build/Security
.github/workflows/cd.yml - Docker Build & Deploy
```

### 6.3 デプロイ手順書

```bash
DEPLOYMENT.md - 本番環境デプロイ手順書
```

---

## エージェント依存関係マップ

```
【Phase 1: 設計】
project-planner (アーキテクチャ設計)
  ↓
【Phase 2: 初期化】
impl-dev-backend (バックエンド初期化)
  ∥ (並列実行可能)
impl-dev-frontend (フロントエンド初期化)
  ↓
【Phase 3: コア機能】
impl-dev-backend (認証API) → impl-dev-frontend (認証UI) → integrator
  ↓
impl-dev-backend (CRUD API) → impl-dev-frontend (UI) → integrator
  ↓
【Phase 4: テスト基盤】
qa-unit (ユニットテスト基盤)
  ∥ (並列実行可能)
qa-integration (統合テスト基盤)
  ∥ (並列実行可能)
playwright-test-planner (E2Eテスト基盤)
  ↓
【Phase 5: ドキュメント】
mcp__serena__write_memory (AIメモリ作成)
  +
人間向けドキュメント作成
  ↓
【Phase 6: デプロイ】
Docker本番ビルド + CI/CD設定
```

---

## 推定所要時間

- Phase 1: 2-4時間（設計）
- Phase 2: 4-8時間（初期化）
- Phase 3: 20-40時間（コア機能）
- Phase 4: 8-16時間（テスト基盤）
- Phase 5: 4-8時間（ドキュメント）
- Phase 6: 4-8時間（デプロイ）

**合計**: 42-84時間（1-2週間、中規模プロジェクト）

---

## ベストプラクティス

1. **Phase 1を丁寧に**: アーキテクチャ設計が後の効率を決定
2. **認証システムを最優先**: すべての機能の基盤
3. **テスト基盤を早期構築**: 後から追加するのは困難
4. **ドキュメントを初期から整備**: AIメモリと人間向けドキュメントを分離
5. **CI/CDを早期導入**: 品質保証の自動化

---

## 初回セッションの推奨フロー

### Session 1: プロジェクト構想・設計（4-6時間）

```bash
# 1. プロジェクト構想
Task:project-planner(prompt: "プロジェクト概要・技術スタック・フェーズ分割")

# 2. システムアーキテクチャ設計
Task:project-planner(prompt: "システムアーキテクチャ設計書作成")

# 3. AIメモリ初期化
mcp__serena__write_memory(memory_name: "project/project_overview.md", ...)
mcp__serena__write_memory(memory_name: "specifications/system_architecture.md", ...)

# 4. ドキュメント作成
CLAUDE.md, README.md, ai-rules/WORKFLOW.md等

# 5. Git初期化・初回コミット
git init
git add .
git commit -m "chore: プロジェクト初期化"
```

### Session 2以降: Phase 2-6を順次実装

各セッション終了時:
- Serenaメモリ更新（session記録）
- next_session_prompt.md更新
- Git Commit & PR
