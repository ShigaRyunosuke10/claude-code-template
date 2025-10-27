# 環境変数・MCP設定ガイド（Phase 0.3）

**Version**: 1.0
**Last Updated**: 2025-10-27
**対象フェーズ**: Phase 0.3 - 環境変数・MCP設定チェック

---

## 概要

このドキュメントは、**Phase 0.3**で実行する環境変数・MCP設定のチェックリストです。Phase 0.2で決定した技術スタック（Supabaseベース）に基づいて、必要な環境変数とMCPサーバーを設定します。

---

## 環境変数チェックリスト

### Backend (.env) - 必須

| 環境変数名 | 説明 | 取得方法 | Phase 0.3での設定 |
|-----------|------|---------|------------------|
| `SUPABASE_URL` | SupabaseプロジェクトURL | Supabaseダッシュボード → Settings → API | **Phase 1で設定**（Supabaseプロジェクト作成後） |
| `SUPABASE_KEY` | Supabase Anon Key（公開可能） | Supabaseダッシュボード → Settings → API | **Phase 1で設定**（Supabaseプロジェクト作成後） |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Service Role Key（管理者権限） | Supabaseダッシュボード → Settings → API | **Phase 1で設定**（Supabaseプロジェクト作成後） |
| `JWT_SECRET` | Supabase JWT Secret | Supabaseダッシュボード → Settings → API → JWT Settings | **Phase 1で設定**（Supabaseプロジェクト作成後） |
| `ALLOWED_ORIGINS` | CORS許可オリジン | 手動設定（例: `https://your-frontend-domain.com`） | **Phase 1で設定**（フロントエンドURL決定後） |
| `ENV` | 環境（development/production） | 手動設定 | **Phase 0.3で設定可**（`development`） |
| `HOST` | サーバーホスト | 手動設定 | **Phase 0.3で設定可**（`0.0.0.0`） |
| `PORT` | サーバーポート | 手動設定 | **Phase 0.3で設定可**（`8000`） |

### Frontend (.env.local) - 必須

| 環境変数名 | 説明 | 取得方法 | Phase 0.3での設定 |
|-----------|------|---------|------------------|
| `NEXT_PUBLIC_SUPABASE_URL` | SupabaseプロジェクトURL | Supabaseダッシュボード → Settings → API | **Phase 1で設定**（Supabaseプロジェクト作成後） |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase Anon Key（公開可能） | Supabaseダッシュボード → Settings → API | **Phase 1で設定**（Supabaseプロジェクト作成後） |
| `NEXT_PUBLIC_API_BASE_URL` | バックエンドAPIベースURL | 手動設定（例: `https://your-backend-domain.com/api`） | **Phase 1で設定**（バックエンドURL決定後） |
| `NEXT_PUBLIC_ENV` | 環境（development/production） | 手動設定 | **Phase 0.3で設定可**（`development`） |

### MCP設定 (.env) - 必須

| 環境変数名 | 説明 | 取得方法 | Phase 0.3での設定 |
|-----------|------|---------|------------------|
| `GITHUB_TOKEN` | GitHub Personal Access Token | GitHub → Settings → Developer settings → Personal access tokens | **既に設定済み** |
| `OPENAI_API_KEY` | OpenAI API Key（Codex MCP用） | OpenAI → API Keys | **既に設定済み** |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Service Role Key（Supabase MCP用） | Supabaseダッシュボード → Settings → API | **Phase 1で設定**（Supabaseプロジェクト作成後） |

---

## Phase 0.3での実行内容

### 1. 環境変数ファイルのテンプレート作成

Phase 0.3では、**テンプレートファイルを作成**し、Phase 1でSupabaseプロジェクト作成後に実際の値を設定します。

#### Backend (.env.example)
```bash
# Supabase（Phase 1で設定）
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# JWT（Phase 1で設定）
JWT_SECRET=your-jwt-secret

# CORS（Phase 1で設定）
ALLOWED_ORIGINS=http://localhost:3000

# 環境
ENV=development

# サーバー設定
HOST=0.0.0.0
PORT=8000
```

#### Frontend (.env.local.example)
```bash
# Supabase（Phase 1で設定）
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# API（Phase 1で設定）
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api

# 環境
NEXT_PUBLIC_ENV=development
```

#### ルート (.env)
```bash
# GitHub（既に設定済み）
GITHUB_TOKEN=your-github-token

# OpenAI（既に設定済み）
OPENAI_API_KEY=your-openai-api-key

# Supabase（Phase 1で設定）
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 2. .gitignoreの確認

環境変数ファイルがGitに含まれないことを確認します。

```gitignore
# 環境変数
.env
.env.local
backend/.env
frontend/.env.local

# テンプレートは含める（!で除外を解除）
!.env.example
!.env.local.example
```

### 3. MCPサーバーの確認

`.mcp.json`に以下のMCPサーバーが設定されていることを確認します。

#### 既存MCP
- `github`: GitHub操作（PR/Issue管理）
- `serena`: コードベース解析
- `playwright`: E2Eテスト
- `codex`: AIコーディングアシスタント

#### 新規追加（Phase 0.2で追加済み）
- `supabase`: Supabase操作（プロジェクト作成、スキーマ管理、クエリ実行等）

---

## Supabase MCPサーバーについて

### 概要
Supabase MCPサーバーは、AIツール（Claude、Cursor等）からSupabaseを直接操作できるMCPサーバーです。

### 機能
- Supabaseプロジェクトの作成・管理
- テーブル設計・マイグレーション生成
- SQLクエリ実行・レポート作成
- ブランチ・設定管理
- TypeScript型定義生成
- ログ取得・デバッグ

### セキュリティ注意事項
- **開発・テスト専用**（本番環境では使用しない）
- **Service Role Key必須**（管理者権限APIキー、絶対に公開しない）
- **読み取り専用モード推奨**（`read_only`パラメータ設定）

### 設定（.mcp.json）
```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp",
    "headers": {
      "Authorization": "Bearer ${SUPABASE_SERVICE_ROLE_KEY}"
    }
  }
}
```

---

## Phase 0.3の完了条件

以下が完了したら、Phase 0.3を完了とします：

- [x] `.env.example`ファイル作成（Backend）
- [x] `.env.local.example`ファイル作成（Frontend）
- [x] `.gitignore`に環境変数ファイルが含まれていることを確認
- [x] `.mcp.json`にSupabase MCPサーバーが設定されていることを確認
- [x] README.mdに環境変数設定手順を追加（Step 0）

**注意**: 実際の環境変数値（`SUPABASE_URL`、`SUPABASE_KEY`等）は**Phase 1でSupabaseプロジェクト作成後**に設定します。Phase 0.3ではテンプレートファイルの作成のみを行います。

---

## Phase 1での作業

Phase 1では、以下の手順でSupabaseプロジェクトを作成し、環境変数を設定します：

### 1. Supabaseプロジェクト作成
1. [Supabase Dashboard](https://supabase.com/dashboard)にアクセス
2. 「New Project」をクリック
3. プロジェクト名: `nissei-worklog`
4. Database Password: 安全なパスワードを設定
5. Region: 日本に最も近いリージョン（例: `ap-northeast-1`）
6. Pricing Plan: Free（開発段階）
7. 「Create new project」をクリック

### 2. 環境変数取得
1. Supabaseダッシュボード → Settings → API
2. 以下をコピー：
   - Project URL（`SUPABASE_URL`）
   - anon public key（`SUPABASE_KEY`、`NEXT_PUBLIC_SUPABASE_ANON_KEY`）
   - service_role key（`SUPABASE_SERVICE_ROLE_KEY`、**絶対に公開しない**）
3. Settings → API → JWT Settings
   - JWT Secret（`JWT_SECRET`）をコピー

### 3. 環境変数設定

#### Windows PowerShell
```powershell
# Backend
cd backend
Copy-Item .env.example .env
# .envファイルを編集してSupabaseの値を設定

# Frontend
cd ../frontend
Copy-Item .env.local.example .env.local
# .env.localファイルを編集してSupabaseの値を設定

# ルート（Supabase MCP用）
cd ..
# .envファイルにSUPABASE_SERVICE_ROLE_KEYを追加
```

#### macOS/Linux
```bash
# Backend
cd backend
cp .env.example .env
# .envファイルを編集してSupabaseの値を設定

# Frontend
cd ../frontend
cp .env.local.example .env.local
# .env.localファイルを編集してSupabaseの値を設定

# ルート（Supabase MCP用）
cd ..
# .envファイルにSUPABASE_SERVICE_ROLE_KEYを追加
```

### 4. 動作確認
```bash
# Backend起動
cd backend
poetry run uvicorn main:app --reload

# Frontend起動（別ターミナル）
cd frontend
pnpm dev

# ブラウザでアクセス
# http://localhost:3000
```

---

## トラブルシューティング

### Supabase接続エラー
- **原因**: `SUPABASE_URL`または`SUPABASE_KEY`が間違っている
- **対処**: Supabaseダッシュボードで再度確認

### JWT検証エラー
- **原因**: `JWT_SECRET`が間違っている
- **対処**: Supabaseダッシュボード → Settings → API → JWT Settings で確認

### CORS エラー
- **原因**: `ALLOWED_ORIGINS`にフロントエンドURLが含まれていない
- **対処**: `ALLOWED_ORIGINS=http://localhost:3000`を追加

### Supabase MCP接続エラー
- **原因**: `SUPABASE_SERVICE_ROLE_KEY`が設定されていない
- **対処**: ルートの`.env`に`SUPABASE_SERVICE_ROLE_KEY`を追加

---

## 参考リンク

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase MCP Server Guide](https://supabase.com/docs/guides/getting-started/mcp)
- [FastAPI Environment Variables](https://fastapi.tiangolo.com/advanced/settings/)
- [Next.js Environment Variables](https://nextjs.org/docs/app/building-your-application/configuring/environment-variables)
