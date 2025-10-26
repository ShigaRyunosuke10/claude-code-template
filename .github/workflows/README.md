# GitHub Actions Deployment Templates

このディレクトリには、各種プラットフォームへのデプロイ用GitHub Actionsテンプレートが含まれています。

## 使い方

### 1. テンプレートを選択

プロジェクトで使用するデプロイ先に応じて、適切なテンプレートを選択してください：

- `deploy-vercel.yml.template` - Vercel（フロントエンド）
- `deploy-railway.yml.template` - Railway（フルスタック）
- `deploy-render.yml.template` - Render（フルスタック）

### 2. ファイル名変更

選択したテンプレートの `.template` 拡張子を削除します：

```bash
# 例: Vercelを使う場合
mv deploy-vercel.yml.template deploy-vercel.yml
```

### 3. GitHub Secretsを設定

各テンプレートのコメントに記載されている必要なシークレットをGitHubリポジトリに追加します。

**GitHub Secretsの追加方法**:
1. GitHubリポジトリページを開く
2. Settings → Secrets and variables → Actions
3. "New repository secret" をクリック
4. 必要なシークレットを追加

### 4. プレースホルダーを置換

テンプレート内の `{{YOUR_DOMAIN}}` を実際のドメインに置き換えます。

### 5. ブランチ戦略に合わせて調整

**Pattern A（ステージング + 本番）の場合**:
```yaml
on:
  push:
    branches:
      - main      # Production
      - develop   # Staging
```

**Pattern B（本番のみ）の場合**:
```yaml
on:
  push:
    branches:
      - main      # Production only
```

## プラットフォーム別詳細

### Vercel

**必要なSecrets**:
- `VERCEL_TOKEN` - [Vercel Dashboard](https://vercel.com/account/tokens) で生成
- `VERCEL_ORG_ID` - プロジェクト設定から取得
- `VERCEL_PROJECT_ID` - プロジェクト設定から取得

**取得方法**:
```bash
# Vercel CLIをインストール
npm i -g vercel

# ログイン
vercel login

# プロジェクトにリンク
vercel link

# org_id と project_id を確認
cat .vercel/project.json
```

### Railway

**必要なSecrets**:
- `RAILWAY_TOKEN` - [Railway Dashboard](https://railway.app/account/tokens) で生成
- `RAILWAY_SERVICE` - サービスID（Dashboard のURLから取得）

**取得方法**:
```bash
# Railway CLIをインストール
npm i -g @railway/cli

# ログイン
railway login

# サービスIDを確認
railway status
```

### Render

**必要なSecrets**:
- `RENDER_API_KEY` - [Render Dashboard](https://dashboard.render.com/account/api-keys) で生成
- `RENDER_SERVICE_ID` - サービス設定のURLから取得

**取得方法**:
1. Render Dashboardでサービスを開く
2. URLから Service ID を確認: `https://dashboard.render.com/web/srv-XXXXX`
3. `srv-XXXXX` が Service ID

## 不要なテンプレートの削除

使用しないテンプレートファイルは削除してOKです：

```bash
# 例: Railwayのみ使う場合
rm deploy-vercel.yml.template
rm deploy-render.yml.template
```

## トラブルシューティング

### デプロイが失敗する

1. GitHub Secretsが正しく設定されているか確認
2. プラットフォームのAPIトークンが有効か確認
3. Actionsタブでエラーログを確認

### Health Checkが失敗する

1. デプロイが完了するまでの待機時間を調整（`sleep`の秒数を増やす）
2. ヘルスチェックエンドポイント（`/health`）が実装されているか確認
3. ドメインが正しいか確認

## 参考リンク

- [GitHub Actions ドキュメント](https://docs.github.com/actions)
- [Vercel デプロイ](https://vercel.com/docs/deployments/overview)
- [Railway デプロイ](https://docs.railway.app/deploy/deployments)
- [Render デプロイ](https://render.com/docs/deploys)
