# 環境変数・MCP設定ガイド

技術スタック確定後に必要な環境変数・MCP設定を一斉に設定するためのガイド。

---

## 📋 設定タイミング

**Phase 0.2: 環境変数・MCP設定チェック**

- **実行タイミング**: 技術スタック決定後（Phase 0.1 → 0.2）
- **目的**: プロジェクトに必要な環境変数・MCP設定を漏れなく設定
- **自動化**: 技術スタックに基づいて必要な設定を自動検知

---

## 🔑 設定項目一覧

### 必須設定（全プロジェクト共通）

#### 1. GITHUB_TOKEN
- **用途**: GitHubリポジトリ作成、PR/Issue管理
- **MCPサーバー**: `github`
- **設定方法**: README.md「Step 0: 環境変数設定」参照
- **検証方法**:
  ```bash
  echo $GITHUB_TOKEN | head -c 10
  # 出力例: ghp_ABC123
  ```

---

### 技術スタック別設定

#### データベース: Supabase

**必要な設定**:
1. **SUPABASE_ACCESS_TOKEN**
   - Supabaseアクセストークン
   - 取得方法: [Supabase Dashboard](https://app.supabase.com/) > Settings > API > Service Role Key

2. **SUPABASE_PROJECT_REF**
   - プロジェクトID
   - 取得方法: Supabase Dashboard > Settings > General > Reference ID

**`.mcp.json` 設定**:
```json
{
  "mcpServers": {
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

**環境変数設定**:
```bash
# Windows PowerShell
$env:SUPABASE_ACCESS_TOKEN = "sbp_..."
$env:SUPABASE_PROJECT_REF = "your-project-ref"

# 永続化
[System.Environment]::SetEnvironmentVariable('SUPABASE_ACCESS_TOKEN', 'sbp_...', 'User')
[System.Environment]::SetEnvironmentVariable('SUPABASE_PROJECT_REF', 'your-project-ref', 'User')

# macOS/Linux
export SUPABASE_ACCESS_TOKEN="sbp_..."
export SUPABASE_PROJECT_REF="your-project-ref"

# 永続化
echo 'export SUPABASE_ACCESS_TOKEN="sbp_..."' >> ~/.bashrc
echo 'export SUPABASE_PROJECT_REF="your-project-ref"' >> ~/.bashrc
```

---

#### データベース: PostgreSQL (非Supabase)

**必要な設定**:
- DATABASE_URL
- PostgreSQL接続情報（ホスト、ポート、ユーザー、パスワード）

**MCPサーバー**: 不要（直接接続）

---

#### データベース: MongoDB

**必要な設定**:
- MONGODB_URI

**MCPサーバー**: 必要に応じて追加

---

#### AI機能: OpenAI (Codex)

**必要な設定**:
1. **OPENAI_API_KEY**
   - OpenAI APIキー
   - 取得方法: [OpenAI Platform](https://platform.openai.com/api-keys)

**MCPサーバー**: `codex` (既に`.mcp.json`に設定済み)

**Codex CLI設定**:
```bash
# Codex CLIインストール
npm install -g @openai/codex-cli

# 認証
codex auth login
# または
export OPENAI_API_KEY="sk-..."
```

---

#### ドキュメント: Context7

**必要な設定**:
1. **CONTEXT7_API_KEY**
   - Context7 APIキー
   - 取得方法: [Context7 Dashboard](https://context7.upstash.com/)

**MCPサーバー**: `context7` (既に`.mcp.json`に設定済み)

**環境変数設定**:
```bash
# Windows PowerShell
$env:CONTEXT7_API_KEY = "your-api-key"
[System.Environment]::SetEnvironmentVariable('CONTEXT7_API_KEY', 'your-api-key', 'User')

# macOS/Linux
export CONTEXT7_API_KEY="your-api-key"
echo 'export CONTEXT7_API_KEY="your-api-key"' >> ~/.bashrc
```

---

#### 認証: Auth0

**必要な設定**:
- AUTH0_DOMAIN
- AUTH0_CLIENT_ID
- AUTH0_CLIENT_SECRET

**MCPサーバー**: 不要（SDKで直接連携）

---

#### 決済: Stripe

**必要な設定**:
- STRIPE_SECRET_KEY
- STRIPE_PUBLISHABLE_KEY

**MCPサーバー**: 不要（SDKで直接連携）

---

#### デプロイ: Vercel

**必要な設定**:
- VERCEL_TOKEN

**取得方法**: [Vercel Dashboard](https://vercel.com/account/tokens)

---

#### デプロイ: AWS

**必要な設定**:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

---

## 🔄 Phase 0.2: 環境変数・MCP設定チェックフロー

### Step 1: 技術スタック読み込み

```bash
# Serenaメモリから技術スタックを読み込み
mcp__serena__read_memory(memory_name: "system/tech_stack.md")
```

**取得情報**:
- データベース種類（Supabase / PostgreSQL / MongoDB）
- 認証方式（Auth0 / Supabase Auth / JWT）
- 決済サービス（Stripe / PayPal）
- デプロイ先（Vercel / AWS / Netlify）
- AI機能有無（OpenAI / Anthropic）

---

### Step 2: 必要な環境変数を特定

**技術スタック別マッピング**:

| 技術スタック | 必要な環境変数 | MCPサーバー |
|-------------|--------------|-----------|
| Supabase | `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF` | `supabase` |
| Auth0 | `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET` | - |
| Stripe | `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY` | - |
| OpenAI (Codex) | `OPENAI_API_KEY` | `codex` |
| Context7 | `CONTEXT7_API_KEY` | `context7` |
| Vercel | `VERCEL_TOKEN` | - |

---

### Step 3: 環境変数チェック

```bash
# 必須: GITHUB_TOKEN
echo $GITHUB_TOKEN | head -c 10

# 技術スタック依存
echo $SUPABASE_ACCESS_TOKEN | head -c 10
echo $CONTEXT7_API_KEY | head -c 10
echo $OPENAI_API_KEY | head -c 10
```

---

### Step 4: 未設定の環境変数を一括案内

**メインClaude Agentが表示**:

```markdown
## 🔧 環境変数・MCP設定が必要です

技術スタック確定に基づき、以下の設定が必要です。

### 必須設定

#### ✅ GITHUB_TOKEN
- 状態: 設定済み

### 技術スタック別設定

#### ❌ SUPABASE_ACCESS_TOKEN（未設定）
- 用途: Supabase データベース操作
- 取得方法: https://app.supabase.com/ > Settings > API > Service Role Key
- 設定コマンド:
  ```powershell
  $env:SUPABASE_ACCESS_TOKEN = "sbp_..."
  [System.Environment]::SetEnvironmentVariable('SUPABASE_ACCESS_TOKEN', 'sbp_...', 'User')
  ```

#### ❌ SUPABASE_PROJECT_REF（未設定）
- 用途: Supabaseプロジェクト識別
- 取得方法: https://app.supabase.com/ > Settings > General > Reference ID
- 設定コマンド:
  ```powershell
  $env:SUPABASE_PROJECT_REF = "your-project-ref"
  [System.Environment]::SetEnvironmentVariable('SUPABASE_PROJECT_REF', 'your-project-ref', 'User')
  ```

#### ⚠️ OPENAI_API_KEY（任意・推奨）
- 用途: エラーループ時のAI自動相談（Codex）
- 取得方法: https://platform.openai.com/api-keys
- 設定コマンド: README.md「Step 0.5」参照

#### ⚠️ CONTEXT7_API_KEY（任意・推奨）
- 用途: ライブラリドキュメント自動取得
- 取得方法: https://context7.upstash.com/
- 設定コマンド:
  ```powershell
  $env:CONTEXT7_API_KEY = "your-api-key"
  [System.Environment]::SetEnvironmentVariable('CONTEXT7_API_KEY', 'your-api-key', 'User')
  ```

### 次のステップ

1. 上記の環境変数を設定してください
2. Claude Code を再起動してください
3. Phase 0.2 を再実行します

**選択肢**:
A. 今すぐ設定する（推奨） → 設定後に Phase 0.2 再実行
B. 後で設定する → Phase 0 を一時中断
C. スキップ（任意設定のみ） → Phase 0.3 へ進む（機能制限あり）
```

---

### Step 5: .mcp.json プレースホルダー置換

**設定完了後、自動実行**:

```bash
# Supabase設定をプレースホルダーから環境変数参照に変更
sed -i 's/"--access-token", "sbp_.*"/"--access-token", "${SUPABASE_ACCESS_TOKEN}"/' .mcp.json
sed -i 's/"--project-ref", ".*"/"--project-ref", "${SUPABASE_PROJECT_REF}"/' .mcp.json

# Windows PowerShell版
(Get-Content .mcp.json) -replace '"--access-token", "sbp_.*"', '"--access-token", "${SUPABASE_ACCESS_TOKEN}"' | Set-Content .mcp.json
(Get-Content .mcp.json) -replace '"--project-ref", ".*"', '"--project-ref", "${SUPABASE_PROJECT_REF}"' | Set-Content .mcp.json
```

---

### Step 6: 設定検証

```bash
# 環境変数確認
echo "GITHUB_TOKEN: $(echo $GITHUB_TOKEN | head -c 10)"
echo "SUPABASE_ACCESS_TOKEN: $(echo $SUPABASE_ACCESS_TOKEN | head -c 10)"
echo "SUPABASE_PROJECT_REF: $SUPABASE_PROJECT_REF"
echo "OPENAI_API_KEY: $(echo $OPENAI_API_KEY | head -c 10)"
echo "CONTEXT7_API_KEY: $(echo $CONTEXT7_API_KEY | head -c 10)"

# .mcp.json検証
cat .mcp.json | grep -E "SUPABASE|OPENAI|CONTEXT7|GITHUB"
```

---

## ✅ 成功基準

- [ ] 技術スタックに基づいて必要な環境変数が特定された
- [ ] 未設定の環境変数がユーザーに一括案内された
- [ ] 環境変数設定後、`.mcp.json` のプレースホルダーが置換された
- [ ] 全ての必須環境変数が設定済み
- [ ] Claude Code 再起動後、MCPサーバーが正常に動作

---

## 📚 参考リンク

- [Supabase API Keys](https://app.supabase.com/)
- [OpenAI API Keys](https://platform.openai.com/api-keys)
- [Context7 Dashboard](https://context7.upstash.com/)
- [GitHub Personal Access Tokens](https://github.com/settings/tokens?type=beta)
- [Vercel Tokens](https://vercel.com/account/tokens)
