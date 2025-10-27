# MCP設定ガイド

このドキュメントでは、テンプレートで使用する各MCPサーバーの詳細な設定手順を説明します。

---

## 目次

1. [GitHub MCP](#1-github-mcp-必須)
2. [Codex MCP](#2-codex-mcp-必須)
3. [Supabase MCP](#3-supabase-mcp-技術スタック依存)
4. [Serena MCP](#4-serena-mcp-必須自動設定)
5. [Playwright MCP](#5-playwright-mcp-技術スタック依存)

---

## 1. GitHub MCP（必須）

### 概要
- **URL**: `https://api.githubcopilot.com/mcp`
- **認証方式**: OAuth（GitHub Copilot統合）
- **用途**: リポジトリ操作、Issue/PR管理

### 設定手順

#### Step 1: GitHub Copilot サブスクリプション確認
GitHub MCPはGitHub Copilotのライセンスが必要です。
- https://github.com/settings/copilot にアクセス
- サブスクリプションが有効か確認

#### Step 2: .mcp.json設定
テンプレートには既に設定済み：
```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp"
  }
}
```

#### Step 3: Claude Code再起動
MCPサーバーが自動的にOAuth認証を実行します。

#### Step 4: 接続確認
```bash
gh repo view --json name,owner,description
```

**成功時の出力例**:
```json
{
  "name": "my-project",
  "owner": { "login": "username" },
  "description": "Project description"
}
```

### トラブルシューティング

**❌ エラー: "Unauthorized"**
- **原因**: GitHub Copilotライセンスが無効
- **解決**: GitHub Copilot サブスクリプションを有効化

**❌ エラー: "gh: command not found"**
- **原因**: GitHub CLI未インストール
- **解決**: https://cli.github.com/ からインストール

---

## 2. Codex MCP（必須）

### 概要
- **コマンド**: `codex mcp-server`
- **認証方式**: CLI事前ログイン（`~/.codex/auth.json`）
- **用途**: ライブラリドキュメント取得、API仕様確認

### ⚠️ 重要: 事前準備が必須

Codex MCPは**Phase 0開始前**に以下の準備が必要です：

1. **Codex CLI インストール**
2. **OpenAI APIキー取得**
3. **Codex CLI ログイン実行**

### 設定手順

#### Step 0: 事前準備（Phase 0開始前）

##### 0-1. Codex CLI インストール
```bash
# macOS/Linux
curl -fsSL https://cli.openai.com/install.sh | sh

# Windows
winget install OpenAI.Codex
```

##### 0-2. OpenAI APIキー取得
1. https://platform.openai.com/api-keys にアクセス
2. "Create new secret key" をクリック
3. 名前: 例 "Codex MCP"
4. 権限: `codex:read`（読み取り専用で十分）
5. キーをコピー（再表示不可）

##### 0-3. Codex CLI ログイン
```bash
codex login --api-key "sk-proj-xxxxxxxxxxxxx"
```

**成功時の出力**:
```
Welcome to Codex CLI!
Authentication saved to ~/.codex/auth.json
```

#### Step 1: .mcp.json設定
テンプレートには既に設定済み：
```json
{
  "codex": {
    "type": "stdio",
    "command": "codex",
    "args": ["mcp-server"],
    "env": {}
  }
}
```

**重要**: `env: {}` は空で正しいです。認証情報は `~/.codex/auth.json` から読み込まれます。

#### Step 2: Claude Code再起動
MCPサーバーが自動的に起動します。

#### Step 3: 接続確認（Phase 0.4で実行）
```bash
# Codex MCPツールが利用可能か確認
mcp__codex__search_docs(query: "React useEffect", library: "react")
```

**成功時**: React useEffectのドキュメントが返される

### トラブルシューティング

**❌ エラー: "codex: command not found"**
- **原因**: Codex CLI未インストール
- **解決**: Step 0-1を実行

**❌ エラー: "Authentication required"**
- **原因**: `codex login` 未実行
- **解決**: Step 0-3を実行

**❌ エラー: "Invalid API key"**
- **原因**: APIキーが無効 or 権限不足
- **解決**: OpenAI Dashboardで新しいキーを生成

### バージョン互換性

**Codex CLI v0.36.0以降の変更**:
- 以前: `OPENAI_API_KEY` 環境変数を読み込み
- 現在: `codex login` で `~/.codex/auth.json` に保存
- **移行**: 古い方式を使用中の場合、`codex login` を実行

---

## 3. Supabase MCP（技術スタック依存）

### 概要
- **URL**: `https://mcp.supabase.com/mcp`
- **認証方式**: OAuth（ブラウザベース）
- **用途**: データベース操作、認証管理、ストレージ操作

### 前提条件
- Supabaseプロジェクトが作成済み
- プロジェクトのデータベースが初期化済み

### 設定手順

#### Step 1: Supabaseプロジェクト作成（手動）
1. https://supabase.com/dashboard にアクセス
2. "New project" をクリック
3. プロジェクト名、データベースパスワード、リージョンを設定
4. プロジェクト作成完了まで待機（2-3分）

#### Step 2: .mcp.json設定
テンプレートには既に設定済み：
```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp"
  }
}
```

#### Step 3: Claude Code再起動
MCPサーバーが自動的にOAuth認証を開始します。

#### Step 4: ブラウザでログイン（自動起動）
1. ブラウザでSupabaseログイン画面が開く
2. Supabaseアカウントでログイン
3. **重要**: 正しい組織（Organization）を選択
4. "Authorize"をクリックしてアクセス許可

#### Step 5: 接続確認（Phase 0.4で実行）
```bash
# Supabase MCPツールが利用可能か確認
mcp__supabase__execute_sql(
  query: "SELECT version();",
  project_ref: "your-project-ref"
)
```

**成功時**: PostgreSQLバージョン情報が返される

### オプション設定

#### プロジェクト限定（推奨）
特定のプロジェクトにのみアクセスを許可：
```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp?project_ref=abcdefghijklmnop"
  }
}
```

#### 読み取り専用モード（推奨）
データベースへの書き込みを禁止：
```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp?read_only=true"
  }
}
```

#### 両方の組み合わせ
```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp?project_ref=xxx&read_only=true"
  }
}
```

### トラブルシューティング

**❌ エラー: "No projects found"**
- **原因**: 選択した組織にプロジェクトが存在しない
- **解決**: ブラウザで正しい組織を選択してログインし直す

**❌ エラー: "Project not found"**
- **原因**: `project_ref` が誤っている
- **解決**: Supabase Dashboard → Project Settings → General → Reference ID を確認

**❌ エラー: "Connection timeout"**
- **原因**: プロジェクトが一時停止中
- **解決**: Supabase Dashboardでプロジェクトを再開

### CI環境用設定（上級者向け）

CI環境ではブラウザベースOAuthが使えないため、Personal Access Tokenを使用します。

#### Step 1: Personal Access Token生成
1. https://supabase.com/dashboard/account/tokens にアクセス
2. "Generate new token" をクリック
3. 名前: 例 "CI MCP Token"
4. スコープ: 必要な権限を選択
5. トークンをコピー（再表示不可）

#### Step 2: .mcp.json設定（CI用）
```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp?project_ref=${SUPABASE_PROJECT_REF}",
    "headers": {
      "Authorization": "Bearer ${SUPABASE_ACCESS_TOKEN}"
    }
  }
}
```

#### Step 3: 環境変数設定
```bash
# .env
SUPABASE_ACCESS_TOKEN=sbp_xxxxxxxxxxxxx
SUPABASE_PROJECT_REF=abcdefghijklmnop
```

---

## 4. Serena MCP（必須・自動設定）

### 概要
- **リポジトリ**: `git+https://github.com/oraios/serena`
- **認証方式**: なし（ローカル実行）
- **用途**: プロジェクトメモリ管理、コンテキスト保存

### 設定手順

#### Step 1: .mcp.json設定
テンプレートには既に設定済み：
```json
{
  "serena": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "git+https://github.com/oraios/serena"],
    "env": {}
  }
}
```

#### Step 2: 自動セットアップ
Serena MCPは**Phase 0.1で自動的に初期化**されます：
- `.serena/` ディレクトリ自動作成
- 初期メモリファイル生成
- プロジェクトメタデータ保存

#### Step 3: 接続確認（自動実行）
```bash
mcp__serena__list_memories()
```

**成功時**: メモリファイル一覧が返される

### トラブルシューティング

**❌ エラー: "Failed to clone repository"**
- **原因**: Git未インストール or ネットワーク問題
- **解決**: Gitをインストール、またはネットワーク接続確認

**❌ エラー: ".serena/ directory not found"**
- **原因**: Phase 0.1が未実行
- **解決**: Phase 0.1を実行してSerenaメモリを初期化

---

## 5. Playwright MCP（技術スタック依存）

### 概要
- **パッケージ**: `@playwright/mcp@latest`
- **認証方式**: なし（ローカル実行）
- **用途**: ブラウザ自動化、E2Eテスト、スクリーンショット取得

### 前提条件
- Node.js 18以上がインストール済み

### 設定手順

#### Step 1: .mcp.json設定
テンプレートには既に設定済み：
```json
{
  "playwright": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@playwright/mcp@latest"],
    "env": {}
  }
}
```

#### Step 2: Claude Code再起動
MCPサーバーが自動的に起動し、Playwrightブラウザをダウンロードします。

**初回起動時**:
```
Installing Playwright browsers...
✓ chromium downloaded
✓ firefox downloaded
✓ webkit downloaded
```

#### Step 3: 接続確認（Phase 0.4で実行）
```bash
# Playwright MCPツールが利用可能か確認
mcp__playwright__navigate(url: "https://example.com")
```

**成功時**: ブラウザが起動し、指定URLにアクセス

### トラブルシューティング

**❌ エラー: "Browser binary not found"**
- **原因**: Playwrightブラウザ未インストール
- **解決**:
```bash
npx playwright install
```

**❌ エラー: "Timeout waiting for browser"**
- **原因**: システムリソース不足 or ファイアウォール
- **解決**:
  - メモリ使用状況確認
  - ファイアウォールでNode.jsを許可

**❌ エラー: "EACCES: permission denied"**
- **原因**: ブラウザバイナリの実行権限なし
- **解決**:
```bash
# macOS/Linux
chmod +x ~/.cache/ms-playwright/*/chrome-linux/chrome

# Windows: 管理者権限でClaude Codeを起動
```

---

## Phase 0.4でのMCP接続確認チェックリスト

Phase 0.4では以下の順序でMCP接続を確認します：

### ✅ 1. GitHub MCP
```bash
gh repo view --json name
```

### ✅ 2. Codex MCP
```bash
mcp__codex__search_docs(query: "test", library: "react")
```

### ✅ 3. Supabase MCP（技術スタック依存）
```bash
mcp__supabase__execute_sql(query: "SELECT 1;")
```

### ✅ 4. Serena MCP
```bash
mcp__serena__list_memories()
```

### ✅ 5. Playwright MCP（技術スタック依存）
```bash
mcp__playwright__navigate(url: "https://example.com")
```

**全て成功 → Phase 0.4 完了 → Phase 0 完了**

---

## 参考リンク

- [GitHub MCP公式ドキュメント](https://github.com/features/copilot)
- [Codex CLI公式サイト](https://cli.openai.com/)
- [Supabase MCP公式ドキュメント](https://supabase.com/docs/guides/getting-started/mcp)
- [Serena MCPリポジトリ](https://github.com/oraios/serena)
- [Playwright MCP公式ドキュメント](https://playwright.dev/docs/mcp)
