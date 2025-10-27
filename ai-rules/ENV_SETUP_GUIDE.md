# 環境変数・MCP設定ガイド

技術スタック確定後に必要な環境変数・MCP設定を一斉に設定するためのガイド。

**このファイルはテンプレートです。** プロジェクト開始時に `tech-stack-validator` エージェントが技術スタックに基づいて具体的な設定手順を自動生成します。

---

## 📋 設定タイミング

**Phase 0.2: 環境変数・MCP設定チェック**

- **実行タイミング**: 技術スタック決定後（Phase 0.1 → 0.2）
- **目的**: プロジェクトに必要な環境変数・MCP設定を漏れなく設定
- **自動化**: `tech-stack-validator` が技術スタックに基づいて設定ガイドを生成

---

## 🔑 設定項目一覧

### 必須設定（全プロジェクト共通）

#### 1. GITHUB_TOKEN
- **用途**: GitHubリポジトリ作成、PR/Issue管理
- **MCPサーバー**: `github`
- **設定方法**: [README.md「Step 0: 環境変数設定」](../README.md)参照
- **検証方法**:
  ```bash
  echo $GITHUB_TOKEN | head -c 10
  # 出力例: ghp_ABC123
  ```

---

## 🤖 tech-stack-validator の責任

**Phase 0.2 実行時**に以下を自動実行：

### 1. 技術スタック読み込み
```
mcp__serena__read_memory(memory_name: "system/tech_stack.md")
```

### 2. 必要な環境変数・MCP設定を特定
技術スタックから必要な設定を抽出：
- データベース（Supabase, PostgreSQL, MySQL等）
- 認証（Auth0, Firebase Auth, AWS Cognito等）
- 決済（Stripe, PayPal等）
- インフラ（Vercel, AWS, GCP等）
- AI/MCP（OpenAI, Anthropic, Context7等）

### 3. 最新情報を調査
各サービスの最新設定方法を調査：
- **WebSearch**: 公式ドキュメント、最新のセットアップ手順
- **Context7 MCP**: ライブラリ・SDKのドキュメント取得
- **例**: "Supabase MCP setup 2025", "Stripe environment variables Node.js"

### 4. 環境変数設定ガイドを生成
このファイルを上書きし、以下を含む具体的なガイドを作成：

```markdown
## 技術スタック別設定

### データベース: Supabase
**必要な環境変数**:
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`

**取得方法**:
1. [Supabase Dashboard](https://app.supabase.com/) にアクセス
2. Settings > API > Service Role Key をコピー
3. Settings > General > Reference ID をコピー

**環境変数設定**:
\```bash
# Windows PowerShell
$env:SUPABASE_ACCESS_TOKEN = "sbp_..."
$env:SUPABASE_PROJECT_REF = "your-project-ref"

# 永続化
[System.Environment]::SetEnvironmentVariable('SUPABASE_ACCESS_TOKEN', 'sbp_...', 'User')
[System.Environment]::SetEnvironmentVariable('SUPABASE_PROJECT_REF', 'your-project-ref', 'User')

# macOS/Linux
export SUPABASE_ACCESS_TOKEN="sbp_..."
export SUPABASE_PROJECT_REF="your-project-ref"

# 永続化（~/.bashrc または ~/.zshrc に追記）
echo 'export SUPABASE_ACCESS_TOKEN="sbp_..."' >> ~/.bashrc
echo 'export SUPABASE_PROJECT_REF="your-project-ref"' >> ~/.bashrc
\```

**検証**:
\```bash
echo $SUPABASE_ACCESS_TOKEN | head -c 10
echo $SUPABASE_PROJECT_REF
\```

### 認証: Auth0
（同様の形式で生成）

### 決済: Stripe
（同様の形式で生成）

...（技術スタック依存で動的生成）
```

### 5. ユーザーに設定を案内
未設定の環境変数があれば、生成したガイドを表示し設定を促す：

```markdown
⚠️ **以下の環境変数が未設定です**:

1. **SUPABASE_ACCESS_TOKEN** - Supabaseアクセストークン
2. **SUPABASE_PROJECT_REF** - SupabaseプロジェクトID

設定方法は上記「技術スタック別設定」セクションをご確認ください。

設定完了後、以下で検証してください：
\```bash
echo $SUPABASE_ACCESS_TOKEN | head -c 10
echo $SUPABASE_PROJECT_REF
\```
```

### 6. 設定完了を検証
すべての環境変数が設定されていることを確認：
```bash
# 各環境変数をチェック
echo $GITHUB_TOKEN | head -c 10
echo $SUPABASE_ACCESS_TOKEN | head -c 10
echo $SUPABASE_PROJECT_REF
# ...（技術スタック依存）
```

---

## 📝 フロー概要

```
Phase 0.1: 技術スタック決定
    ↓
Phase 0.2: 環境変数・MCP設定チェック（tech-stack-validator）
    ↓
tech-stack-validator が以下を実行:
    1. tech_stack.md 読み込み
    2. 必要な環境変数を特定
    3. 最新設定方法を調査（WebSearch/Context7）
    4. 本ファイルを具体的なガイドに上書き
    5. 未設定変数をユーザーに案内
    6. 設定完了を検証
    ↓
すべて設定完了 → Phase 0.3 へ
```

---

## 🎯 期待される成果物（Phase 0.2完了後）

このファイルが以下の構造に変わっていること：

- ✅ **必須設定（GITHUB_TOKEN）** - 常に含まれる
- ✅ **技術スタック別設定** - プロジェクト固有（Supabase, Stripe等）
- ✅ **取得方法** - 最新の公式ドキュメント参照
- ✅ **環境変数設定手順** - Windows/macOS/Linux対応
- ✅ **検証コマンド** - 設定確認方法

---

## 🔍 tech-stack-validator が参照すべきリソース

- **WebSearch**: 公式ドキュメント最新情報
  - 例: "Supabase environment variables setup 2025"
  - 例: "Stripe API keys configuration Node.js"
- **Context7 MCP**: ライブラリ・SDK公式ドキュメント
  - 例: `mcp__context7__search_context(query: "supabase-js setup")`
- **MCP Registry**: 利用可能なMCPサーバー一覧
  - [MCP Registry](https://github.com/modelcontextprotocol/registry)
