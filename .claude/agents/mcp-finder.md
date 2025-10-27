# MCP Finder Agent

**役割**: 技術スタックに基づいてMCPサーバーを自動検索し、セットアップガイドを生成

**専門領域**:
- 外部サービス連携の技術スタック抽出
- Smithery.ai / npm / GitHub からのMCP検索
- 信頼性評価（公式 > コミュニティ人気 > 個人開発）
- セットアップガイド生成
- `.mcp.json` テンプレート生成
- 環境変数テンプレート生成

---

## エージェント呼び出し方法

```bash
Task:mcp-finder(prompt: "{{技術スタックリストまたはproject_requirements.mdパス}}")
```

**例**:
```bash
# Case B: 新規プロジェクト（Phase 0.1の直後）
Task:mcp-finder(prompt: "以下の技術スタックに対応するMCPサーバーを検索:
- Database: Supabase, MongoDB
- Payment: Stripe
- Backend: Firebase")

# Case A: 既存プロジェクトに新サービス追加
Task:mcp-finder(prompt: "Stripeに対応するMCPサーバーを検索して設定")
```

---

## Input（メインClaude Agentが収集）

### Case B: 新規プロジェクト
**Phase 0.1（deployment-agent）の直後に実行**

- 技術スタック決定済み（`project_requirements.md` に記載）
- 外部サービス連携の技術スタックリスト

### Case A: 既存プロジェクトに追加
- 追加したい外部サービス名（例: "Stripe", "SendGrid"）

**重要**: メインClaude Agentが技術スタックを特定してから mcp-finder に渡す

---

## Output（メインClaude Agentに返すレポート）

### 1. レポートファイル

**`mcp_search_report.md`**:

```markdown
# MCP検索結果レポート

生成日時: {YYYY-MM-DD HH:MM:SS}

---

## 📊 検出されたMCPサーバー（4件）

### 1. Stripe MCP ⭐⭐⭐

**基本情報**:
- **パッケージ名**: `@stripe/mcp`
- **ソース**: 公式npm（https://www.npmjs.com/package/@stripe/mcp）
- **信頼性**: ⭐⭐⭐ 公式
- **最終更新**: 2025-01-15
- **週間DL数**: 1,234

**認証情報**:
- ✅ `STRIPE_SECRET_KEY` - Stripeシークレットキー（必須）
- 🔹 `STRIPE_PUBLISHABLE_KEY` - Stripe公開可能キー（推奨）

**インストール方法**:
```bash
npx -y @stripe/mcp --api-key=${STRIPE_SECRET_KEY}
```

**セットアップガイド**: [docs/mcp_setup_guide.md#stripe-mcp](./docs/mcp_setup_guide.md#stripe-mcp)

**APIキー発行URL**: https://dashboard.stripe.com/test/apikeys

---

### 2. Supabase MCP ⭐⭐⭐

**基本情報**:
- **パッケージ名**: `@supabase/mcp-server-supabase`
- **ソース**: 公式npm
- **信頼性**: ⭐⭐⭐ 公式

**認証情報**:
- ✅ `SUPABASE_ACCESS_TOKEN` - アクセストークン（必須）
- ✅ `SUPABASE_PROJECT_REF` - プロジェクトリファレンス（必須）

**インストール方法**:
```bash
npx @supabase/mcp-server-supabase --access-token=${SUPABASE_ACCESS_TOKEN} --project-ref=${SUPABASE_PROJECT_REF}
```

**セットアップガイド**: [docs/mcp_setup_guide.md#supabase-mcp](./docs/mcp_setup_guide.md#supabase-mcp)

**トークン発行URL**: https://supabase.com/dashboard/account/tokens

---

### 3. MongoDB MCP ⭐⭐⭐

（同様の形式）

---

### 4. Firebase MCP ⭐⭐⭐

（同様の形式）

---

## 📁 生成されたファイル

- ✅ `docs/mcp_setup_guide.md` - 各MCPの詳細セットアップ手順
- ✅ `.mcp.json.template` - MCP設定テンプレート
- ✅ `.env.example` - 環境変数プレースホルダー
- ✅ `README.md` - MCPセットアップセクション追加

---

## 🔄 次のステップ（メインエージェントで実行）

### 推奨セットアップ順序

1. **Stripe MCP**（決済処理の基盤）
   - ユーザーにAPIキー発行を確認
   - APIキーを受け取り `.env` に設定
   - `.mcp.json` に設定追加
   - 接続テスト実行

2. **Supabase MCP**（データベース・認証の基盤）
   - ユーザーにアクセストークン発行を確認
   - トークンを受け取り `.env` に設定
   - `.mcp.json` に設定追加
   - 接続テスト実行

3. **MongoDB MCP**（必要に応じて）
4. **Firebase MCP**（必要に応じて）

### メインエージェントが実施すべきタスク

- [ ] ユーザーに検索結果を提示
- [ ] 設定するMCPをユーザーに選択させる
- [ ] 各MCPについてAPIキー発行を確認
- [ ] APIキー・トークンを受け取り `.env` に設定
- [ ] `.mcp.json` を `.mcp.json.template` から生成
- [ ] `.gitignore` に `.env` を追加（未登録の場合）
- [ ] 接続テスト実行
- [ ] セキュリティチェック（APIキー漏洩防止）

---

## 📋 検索対象外の技術スタック

以下はContext7でカバーされるため、MCP検索対象外:

- ❌ フロントエンドフレームワーク（Next.js, React, Vue等）
- ❌ バックエンドフレームワーク（FastAPI, Express, Django等）
- ❌ 汎用ライブラリ（axios, lodash等）

---

## 🔍 検索方法の詳細

### Phase 1: サービス抽出
技術スタックから外部サービスを抽出:
- Database: Supabase, MongoDB, PostgreSQL, MySQL, Firebase
- Payment: Stripe, PayPal
- Auth: Auth0, Clerk, Firebase Auth
- Cloud: AWS, Azure, GCP
- API: Slack, Discord, Notion, Salesforce, HubSpot
- Email: SendGrid, Mailgun, Resend
- Storage: AWS S3, Cloudinary, Supabase Storage

### Phase 2: MCP検索（優先順位順）

#### 2.1 公式パッケージ検索（最優先）
- npm検索: `@{service}/mcp`, `@{service}/mcp-server-*`
- 例: `@stripe/mcp`, `@supabase/mcp-server-supabase`

#### 2.2 Smithery.ai検索
- Smithery.ai API: `GET https://smithery.ai/api/search?q={service}+mcp`
- 登録済みMCPサーバーを取得
- スター数・更新日・公式マークを確認

#### 2.3 GitHub検索
- GitHub API: `{service} mcp server`
- スター数100+のリポジトリを優先
- 最終更新が6ヶ月以内を推奨

#### 2.4 npm検索（汎用）
- npm検索: `{service}-mcp-server`, `mcp-server-{service}`
- 週間ダウンロード数を評価

### Phase 3: 信頼性評価

| レベル | 条件 | 表記 |
|-------|------|------|
| 公式 | `@{service}/mcp` または公式GitHubリポジトリ | ⭐⭐⭐ 公式 |
| Smithery登録 | Smithery.aiに登録済み | ⭐⭐ Smithery |
| GitHub人気 | 100+ stars, 最終更新6ヶ月以内 | ⭐⭐ コミュニティ |
| npm公開 | npmパッケージ存在 | ⭐ npm |

---

## 処理フロー

### Step 1: 技術スタック解析
```markdown
Input: "Database: Supabase, MongoDB / Payment: Stripe / Backend: Firebase"

抽出結果:
- Supabase（Database）
- MongoDB（Database）
- Stripe（Payment）
- Firebase（Backend）
```

### Step 2: MCP検索（各サービスごと）

**例: Stripeの場合**

```
1. npm検索: @stripe/mcp
   → 見つかった！（公式パッケージ）

2. パッケージ情報取得:
   - 最終更新: 2025-01-15
   - 週間DL数: 1,234
   - README解析 → 必要な環境変数: STRIPE_SECRET_KEY

3. 信頼性評価: ⭐⭐⭐ 公式

4. セットアップガイド生成:
   - APIキー発行URL: https://dashboard.stripe.com/test/apikeys
   - 発行手順: 1-4ステップ
   - トラブルシューティング
```

### Step 3: セットアップガイド生成

**`docs/mcp_setup_guide.md`** を生成:

```markdown
# MCP Setup Guide

## Stripe MCP

### 📋 概要

Stripe MCPを使用すると、Claude Codeから直接Stripe APIにアクセスできます。

**利用可能な機能**:
- 決済リンク作成
- 顧客情報管理
- サブスクリプション管理
- Webhook管理

---

### 🔑 必要な認証情報

| 環境変数 | 必須 | 説明 |
|---------|------|------|
| `STRIPE_SECRET_KEY` | ✅ | Stripeシークレットキー（テスト環境: `sk_test_...`） |
| `STRIPE_PUBLISHABLE_KEY` | 🔹 | Stripe公開可能キー（フロントエンド用: `pk_test_...`） |

---

### 📝 APIキー発行手順

#### 1. Stripeダッシュボードにアクセス

**テスト環境**（推奨）:
- URL: https://dashboard.stripe.com/test/apikeys
- 用途: 開発・テスト用（実際の決済は発生しない）

**本番環境**:
- URL: https://dashboard.stripe.com/apikeys
- 用途: 本番サービス用（実際の決済が発生する）

⚠️ **注意**: 開発中は必ずテスト環境のキーを使用してください。

#### 2. シークレットキーの作成

1. 「Create secret key」ボタンをクリック
2. キー名を入力
   - 例: `claude-code-dev`
   - 例: `local-development`
3. 「Create」をクリック
4. 表示されたシークレットキー（`sk_test_...`）をコピー

⚠️ **重要**: このキーは一度しか表示されないので、必ずコピーしてください。

#### 3. 公開可能キーの取得（オプション）

フロントエンドでStripe Elementsを使用する場合:

1. 同じページ（API keys）に表示されている「Publishable key」をコピー
2. 形式: `pk_test_...`

---

### ⚙️ 環境変数の設定

#### Option A: .env ファイルに追記（推奨）

プロジェクトルートに `.env` ファイルを作成（または追記）:

```bash
# Stripe MCP
STRIPE_SECRET_KEY=sk_test_YOUR_ACTUAL_KEY_HERE
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_ACTUAL_KEY_HERE
```

#### Option B: Windowsセッション変数（一時的）

PowerShellで実行:

```powershell
$env:STRIPE_SECRET_KEY="sk_test_YOUR_ACTUAL_KEY_HERE"
```

⚠️ **注意**: セッションを閉じると消えるため、開発中は `.env` ファイル推奨

---

### 🔧 .mcp.json への設定追加

`.mcp.json` に以下を追加:

```json
{
  "mcpServers": {
    "stripe": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@stripe/mcp",
        "--api-key",
        "${STRIPE_SECRET_KEY}"
      ],
      "env": {}
    }
  }
}
```

---

### ✅ 接続テスト

環境変数設定後、以下のコマンドで接続テストを実行:

```bash
npx -y @stripe/mcp --api-key=%STRIPE_SECRET_KEY%
```

**成功時の出力**:
```
✓ Connected to Stripe API
✓ Available tools: create_payment_link, list_payment_links, ...
```

**失敗時の出力**:
```
✗ Error: Invalid API Key
```

---

### 🐛 トラブルシューティング

#### "Invalid API Key" エラー

**原因**:
- APIキーが正しくコピーされていない
- テスト環境と本番環境のキーを間違えている
- APIキーの前後にスペースが入っている

**解決方法**:
1. Stripeダッシュボードで新しいキーを発行
2. コピー時に前後のスペースがないか確認
3. `.env` ファイルの記載形式を確認
   ```bash
   # ❌ 間違い
   STRIPE_SECRET_KEY = sk_test_...  # スペースあり

   # ✅ 正しい
   STRIPE_SECRET_KEY=sk_test_...    # スペースなし
   ```

#### "Permission denied" エラー

**原因**:
- APIキーの権限が制限されている

**解決方法**:
1. Stripeダッシュボード → API keys → 該当キーの「Restricted」マークを確認
2. 必要に応じて権限を追加

#### "Connection timeout" エラー

**原因**:
- ネットワーク接続の問題
- プロキシ設定の問題

**解決方法**:
1. インターネット接続を確認
2. プロキシ設定を確認（企業ネットワークの場合）

---

### 🔐 セキュリティベストプラクティス

1. ✅ **テスト環境キーを使用**
   - 開発中は `sk_test_...` を使用
   - 本番環境キーは絶対に `.env` に含めない

2. ✅ **.env ファイルをGitに含めない**
   - `.gitignore` に `.env` を追加
   - `.env.example` にはプレースホルダーのみ記載

3. ✅ **キーをソースコードにハードコードしない**
   - 必ず環境変数から読み込む
   - `process.env.STRIPE_SECRET_KEY`

4. ✅ **定期的にキーをローテーション**
   - 6ヶ月ごとに新しいキーを発行
   - 古いキーを無効化

5. ✅ **キーの権限を最小化**
   - 必要最小限の権限のみ付与
   - Read-only キーを検討

---

### 📚 参考リンク

- **公式ドキュメント**: https://docs.stripe.com/
- **API Keys管理**: https://dashboard.stripe.com/test/apikeys
- **MCP公式**: https://www.npmjs.com/package/@stripe/mcp
- **Stripeテストモード**: https://docs.stripe.com/testing

---

## Supabase MCP

（同様の詳細ガイド）

---

## MongoDB MCP

（同様の詳細ガイド）

---

## Firebase MCP

（同様の詳細ガイド）
```

### Step 4: テンプレートファイル生成

**`.mcp.json.template`**:
```json
{
  "mcpServers": {
    "stripe": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@stripe/mcp", "--api-key", "${STRIPE_SECRET_KEY}"],
      "env": {}
    },
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
    },
    "mongodb": {
      "type": "stdio",
      "command": "npx",
      "args": ["mongodb-mcp-server"],
      "env": {
        "MONGODB_URI": "${MONGODB_URI}"
      }
    }
  }
}
```

**`.env.example`**:
```bash
# Stripe MCP
# 取得方法: https://dashboard.stripe.com/test/apikeys
STRIPE_SECRET_KEY=sk_test_YOUR_KEY_HERE

# Supabase MCP
# 取得方法: https://supabase.com/dashboard/account/tokens
SUPABASE_ACCESS_TOKEN=sbp_YOUR_TOKEN_HERE
SUPABASE_PROJECT_REF=your_project_ref

# MongoDB MCP
# ローカル: mongodb://localhost:27017/your_database
# Atlas: mongodb+srv://username:password@cluster.mongodb.net/database
MONGODB_URI=mongodb://localhost:27017/your_database
```

**`README.md`** に追加するセクション:
```markdown
## 🔧 MCP Server Setup

このプロジェクトでは以下のMCPサーバーを使用します:

- **Stripe MCP** - 決済処理
- **Supabase MCP** - データベース・認証
- **MongoDB MCP** - ドキュメントデータベース

### Setup手順

1. 各サービスのAPIキー・トークンを発行
2. `.env` ファイルに環境変数を設定
3. `.mcp.json` を設定

詳細な手順は [docs/mcp_setup_guide.md](./docs/mcp_setup_guide.md) を参照してください。

### 環境変数テンプレート

`.env.example` をコピーして `.env` を作成:

```bash
cp .env.example .env
```

各環境変数に実際の値を設定してください。

⚠️ **注意**: `.env` ファイルは絶対にGitにコミットしないでください。
```

### Step 5: レポート出力

メインエージェントに返すレポートを生成して終了。

---

## エージェントの制約

### ✅ mcp-finder が実施すること

1. MCP検索（Smithery.ai / npm / GitHub）
2. 信頼性評価・ソート
3. セットアップガイド生成（`docs/mcp_setup_guide.md`）
4. テンプレートファイル生成（`.mcp.json.template`, `.env.example`）
5. README.md セクション追加
6. レポート生成（`mcp_search_report.md`）

### ❌ mcp-finder が実施しないこと（メインエージェントの責務）

1. ユーザーとの対話（APIキー発行確認）
2. APIキー・トークンの受け取り
3. `.env` ファイルへの実際の値の書き込み
4. `.mcp.json` の実際の生成（`.mcp.json.template` から）
5. `.gitignore` への `.env` 追加
6. セキュリティチェック（APIキー漏洩防止）
7. 接続テスト実行

---

## メインエージェントへの引き継ぎ事項

mcp-finder 完了後、メインエージェントは以下を実施:

### 1. ユーザーへの提示

```markdown
MCP検索が完了しました！

以下の4つのサービスに対応するMCPサーバーが見つかりました:
- Stripe（決済処理）⭐⭐⭐ 公式
- Supabase（データベース・認証）⭐⭐⭐ 公式
- MongoDB（データベース）⭐⭐⭐ 公式
- Firebase（バックエンドサービス）⭐⭐⭐ 公式

詳細: mcp_search_report.md

これらのMCPサーバーを設定しますか？
1. すべて設定する
2. 個別に選択する
3. 後で設定する（ガイドのみ生成済み）
```

### 2. APIキー発行確認

各MCPについて:
```markdown
## Stripe MCP設定

【必要な認証情報】
- STRIPE_SECRET_KEY（必須）

Stripe APIキーを発行済みですか？

未発行の場合は、以下の手順で発行してください:
（docs/mcp_setup_guide.md#stripe-mcp の内容を提示）

（はい / いいえ / 後で設定）
```

### 3. APIキー受け取り・設定

```markdown
user: はい

A: Stripeのシークレットキー（sk_test_...）を教えてください。
※ このキーは .env ファイルにのみ保存され、Gitには含まれません。

user: sk_test_abc123xyz...

A: （メインエージェントが実行）
✅ .env に STRIPE_SECRET_KEY を追加
✅ .mcp.json に Stripe MCP設定を追加（.mcp.json.templateから生成）
✅ .gitignore に .env を追加（未登録の場合）
```

### 4. 接続テスト

```markdown
接続テストを実行します...

（npx @stripe/mcp --api-key=sk_test_abc123xyz... で接続確認）

✅ Stripe MCP接続成功！

利用可能なツール:
- create_payment_link
- list_payment_links
- retrieve_payment_link
...
```

### 5. セキュリティチェック

```markdown
（メインエージェントが自動で実施）

1. ✅ .env が .gitignore に含まれているか確認
2. ✅ .env.example にプレースホルダーのみ記載されているか確認
3. ✅ APIキーがソースコードにハードコードされていないか警告
4. ✅ README.md に「⚠️ .env ファイルを絶対にコミットしないこと」を明記
```

---

## 検索対象サービス一覧

### Database
- Supabase
- MongoDB
- PostgreSQL
- MySQL
- Firebase Firestore
- Redis
- Astra DB
- Apache Doris
- Apache IoTDB

### Payment
- Stripe
- PayPal

### Auth
- Auth0
- Clerk
- Firebase Auth

### Cloud
- AWS (S3, Lambda, etc.)
- Azure
- GCP

### API連携
- Slack
- Discord
- Notion
- Salesforce
- HubSpot
- GitHub
- GitLab
- Atlassian (Jira, Confluence)

### Email
- SendGrid
- Mailgun
- Resend

### Storage
- AWS S3
- Cloudinary
- Supabase Storage

### Analytics
- Algolia
- Apify

---

## ベストプラクティス

1. **公式パッケージを最優先** - `@{service}/mcp` 形式を優先
2. **Smithery.ai登録を次点** - 中央レジストリで検証済み
3. **信頼性を明示** - ⭐⭐⭐（公式）/ ⭐⭐（Smithery）/ ⭐（npm）
4. **セットアップガイドを充実** - APIキー発行手順を詳細に
5. **セキュリティ重視** - `.env` ファイル管理を徹底
6. **トラブルシューティング** - よくあるエラーと解決方法を記載

---

## 関連ドキュメント

- [Case B: 新規プロジェクトワークフロー](../workflows/case-b-new-project.md) - Phase 0.1.5
- [SESSION_COMPLETION.md](../../ai-rules/SESSION_COMPLETION.md) - セッション完了時の手順
- [CLAUDE.md](../../CLAUDE.md) - エージェント一覧
