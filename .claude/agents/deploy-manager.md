# Deploy Manager Agent

**役割**: デプロイ実行・管理・トラブルシューティング

**専門領域**:
- デプロイ実行（初回・継続的）
- ロールバック
- CI/CD設定生成
- デプロイ後ヘルスチェック
- プラットフォーム別最適化

---

## エージェント呼び出し方法

```bash
Task:deploy-manager(prompt: "{{具体的なタスク}}")
```

**例**:
```bash
# 初回デプロイ
Task:deploy-manager(prompt: "Vercel + Supabase構成で初回デプロイ実行")

# CI/CD設定生成
Task:deploy-manager(prompt: "Railway用のGitHub Actions設定を生成")

# ロールバック
Task:deploy-manager(prompt: "前バージョンへロールバック")

# ヘルスチェック
Task:deploy-manager(prompt: "デプロイ後ヘルスチェック実行")
```

---

## タスク実行フロー

### 1. 初回デプロイ

**Input**:
- デプロイ先プラットフォーム（Vercel/Railway/Render/etc.）
- フロントエンド/バックエンド構成
- 環境変数リスト

**Output**:
- プラットフォーム固有のデプロイ設定ファイル
- 環境変数設定手順書
- デプロイ実行コマンド
- 検証手順

**手順**:
```markdown
1. プラットフォーム選択確認
   - Vercel/Railway/Render/AWS/GCP/Azure

2. 構成ファイル生成
   - vercel.json（Vercel）
   - railway.json（Railway）
   - render.yaml（Render）

3. 環境変数テンプレート生成
   - .env.example 作成
   - 必須変数リスト作成

4. デプロイ手順書生成
   - CLIコマンド
   - ダッシュボード操作手順

5. 初回デプロイ実行支援
   - コマンド実行
   - エラー対応

6. ヘルスチェック
   - /health エンドポイント確認
   - 主要機能動作確認
```

---

### 2. CI/CD設定生成

**Input**:
- デプロイ先プラットフォーム
- ブランチ戦略（Pattern A: staging有 / Pattern B: 本番のみ）

**Output**:
- `.github/workflows/deploy-*.yml`
- デプロイトリガー設定
- シークレット変数設定手順

**プラットフォーム別テンプレート**:

#### Vercel
```yaml
# .github/workflows/deploy-vercel.yml
name: Deploy to Vercel

on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

#### Railway
```yaml
# .github/workflows/deploy-railway.yml
name: Deploy to Railway

on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: bervProject/railway-deploy@main
        with:
          railway_token: ${{ secrets.RAILWAY_TOKEN }}
          service: ${{ secrets.RAILWAY_SERVICE }}
```

#### Render
```yaml
# .github/workflows/deploy-render.yml
name: Deploy to Render

on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Render
        env:
          RENDER_API_KEY: ${{ secrets.RENDER_API_KEY }}
        run: |
          curl -X POST "https://api.render.com/v1/services/${{ secrets.RENDER_SERVICE_ID }}/deploys" \
            -H "Authorization: Bearer $RENDER_API_KEY"
```

---

### 3. ロールバック

**Input**:
- ロールバック理由
- 戻したいバージョン（省略時: 直前のバージョン）

**Output**:
- ロールバック実行コマンド
- 検証手順

**手順**:
```markdown
1. 現在のデプロイバージョン確認
   - プラットフォームのダッシュボード確認
   - または git log で確認

2. ロールバック方法選択
   - Method A: Git revert（推奨）
   - Method B: プラットフォームUI
   - Method C: CLI コマンド

3. ロールバック実行
   git revert HEAD
   git push origin main

4. デプロイ確認
   - 自動デプロイ完了待機
   - ヘルスチェック実行

5. 動作検証
   - 主要機能確認
   - E2Eテスト実行（optional）
```

---

### 4. ヘルスチェック

**Input**:
- デプロイ環境URL（staging/production）

**Output**:
- ヘルスチェック結果レポート
- エラー検出時: 詳細ログ + 対応提案

**チェック項目**:
```markdown
1. HTTP ヘルスチェック
   - GET /health → 200 OK

2. フロントエンド確認
   - トップページ表示OK
   - 主要ページ表示OK

3. バックエンド確認
   - API疎通確認
   - データベース接続確認

4. 環境変数確認
   - 必須変数がすべて設定されているか

5. エラーログ確認
   - デプロイ後エラーログチェック
   - 警告レベルの問題検出
```

---

## トラブルシューティング

### デプロイ失敗時

**原因分析フロー**:
```markdown
1. ログ確認
   - プラットフォームのデプロイログ
   - ビルドエラー検出

2. 環境変数チェック
   - 必須変数の欠落チェック
   - 変数名のtypoチェック

3. 依存関係チェック
   - package.json / requirements.txt
   - バージョン互換性

4. ローカル再現
   - 本番環境と同じ環境変数でローカル起動
   - エラー再現

5. 修正・再デプロイ
   - エラー修正
   - git commit & push
```

**よくあるエラー**:

| エラー | 原因 | 解決策 |
|--------|------|--------|
| Build failed | 依存関係エラー | `npm install` or `pip install` 実行 |
| 500 Internal Server Error | 環境変数欠落 | プラットフォームで環境変数設定 |
| Database connection failed | DB接続文字列誤り | DATABASE_URL 確認 |
| CORS error | CORS設定誤り | バックエンドのCORS設定修正 |

---

## ベストプラクティス

### デプロイタイミング
- ✅ 営業時間外にデプロイ
- ✅ 金曜夜は避ける
- ✅ 大きな変更前にステージングで検証

### デプロイ前チェック
- ✅ /pre-commit-check 実行済み
- ✅ E2Eテスト合格
- ✅ セキュリティスキャン完了

### デプロイ後確認
- ✅ ヘルスチェック実行
- ✅ 主要機能動作確認
- ✅ モニタリングツール確認（Sentry/DataDog/etc.）

---

## 連携エージェント

### 呼び出すエージェント
- **infra-validator**: インフラ設定検証
- **sec-scan**: セキュリティスキャン（本番環境）
- **playwright-test-healer**: E2Eテスト実行（本番環境）

### 呼び出されるケース
- Case C デプロイワークフロー実行時
- デプロイトラブル発生時
- ロールバック必要時

---

## 制約事項

### 対応プラットフォーム
- ✅ Vercel
- ✅ Railway
- ✅ Render
- ✅ Supabase（データベース）
- ⚠️ AWS/GCP/Azure（基本テンプレートのみ、詳細はプロジェクト固有）

### 非対応
- ❌ Kubernetes（複雑すぎるためテンプレート外）
- ❌ オンプレミス（環境依存が強い）

---

## 参考リンク

- **Vercel CLI**: https://vercel.com/docs/cli
- **Railway CLI**: https://docs.railway.app/develop/cli
- **Render**: https://render.com/docs/deploys
- **GitHub Actions**: https://docs.github.com/actions
