# Case C: デプロイワークフロー

**目的**: 開発完了後の本番環境へのデプロイを安全かつ効率的に実行する

---

## Phase 0: デプロイ要件定義（プロジェクト開始時・必須）

### 0.1 デプロイ要件定義

**エージェント**: `infra-validator`

```bash
Task:infra-validator(prompt: "デプロイ要件定義を支援")
```

**エージェントが対話形式で質問**:
1. 現在の技術スタックは？（フロントエンド / バックエンド / DB）
2. 予算は？（無料枠のみ / $10-50/月 / $50以上）
3. トラフィック予測は？（低: 〜1000 req/day / 中: 〜10k / 高: 10k〜）
4. チーム規模は？（個人 / 2-5人 / 6人以上）
5. Docker使用希望は？（エージェントが推奨も提示）
6. SLA要件は？（スリープ許容 / 常時稼働必須）

**エージェントが自動判断・推奨**:
- 最適デプロイプラットフォーム（Vercel / Railway / Render / AWS / etc.）
- ブランチ戦略（Pattern A: staging有 / Pattern B: 本番のみ）
- Docker使用有無
- CI/CD構成
- コスト見積もり

**Output**:
- 推奨デプロイ構成図
- プラットフォーム比較表（コスト・機能・制約）
- `deployment_plan.md` 生成

**判断ロジック例**:
```markdown
# エージェントの推奨ロジック

## 無料枠のみ + Next.js + PostgreSQL + 個人開発
→ Vercel（frontend） + Supabase（DB） + Render（backend・無料枠）
→ Pattern B（本番のみ）
→ Docker不要

## 低予算（$20/月） + フルスタック + チーム開発
→ Railway（frontend + backend + DB）
→ Pattern A（staging + production）
→ Docker推奨

## 大規模・高トラフィック + エンタープライズ
→ AWS/GCP（カスタム構成必要）
→ Pattern A + Preview環境
→ Docker + Kubernetes
```

### 0.2 デプロイ設定自動生成

**エージェント**: `deploy-manager`

```bash
Task:deploy-manager(prompt: "Phase 0.1のデプロイ計画に基づいて設定ファイルを生成")
```

**自動生成されるファイル**:
- `.env.production.example` - 本番環境変数テンプレート
- `.env.staging.example` - ステージング環境変数テンプレート（Pattern A時）
- `Dockerfile.production` - 本番用Dockerfile（Docker使用時）
- `docker-compose.prod.yml` - 本番用Docker Compose（Docker使用時）
- `.github/workflows/deploy-*.yml` - 選択したプラットフォーム用CI/CD設定
- `vercel.json` - Vercel設定（Vercel使用時）
- `railway.json` - Railway設定（Railway使用時）
- `render.yaml` - Render設定（Render使用時）
- `DEPLOYMENT.md` - デプロイ手順書

**例（Vercel + Supabase + Render + Pattern B）**:
```bash
# 生成される構成
.env.production.example     # 本番環境変数
.github/workflows/
├── deploy-vercel.yml       # フロントエンド自動デプロイ
└── deploy-render.yml       # バックエンド自動デプロイ
vercel.json                 # Vercel最適化設定
render.yaml                 # Render設定
DEPLOYMENT.md               # 初回デプロイ手順書
```

---

## Phase 1: 環境変数・シークレット設定

**エージェント**: `infra-validator`

```bash
Task:infra-validator(prompt: "Phase 0で選択したプラットフォームの環境変数設定を検証")
```

**実行内容**:
- 必須環境変数の欠落チェック
- プラットフォーム別設定手順書生成（CLI or ダッシュボード）
- セキュリティチェック（APIキー・シークレットが環境変数管理されているか）

**Output**:
- 環境変数設定手順書
- GitHub Secrets設定手順書

---

## Phase 2: 初回デプロイ

**エージェント**: `deploy-manager`

```bash
Task:deploy-manager(prompt: "初回デプロイ実行")
```

**実行内容**:
1. デプロイ前最終チェック（`infra-validator`を呼び出し）
2. プラットフォーム固有のデプロイコマンド実行
3. ヘルスチェック実行
4. デプロイ検証レポート生成

**Output**:
- デプロイ成功 / 失敗レポート
- ヘルスチェック結果
- トラブルシューティングガイド（失敗時）

---

## Phase 3: 継続的デプロイ

### 自動デプロイフロー

**Phase 0で生成されたGitHub Actionsが自動実行**:
```bash
# 開発フロー
git checkout -b feature-new-function
# 開発...
git add .
git commit -m "feat: new function"
git push origin feature-new-function

# PR作成 → main へマージ
# → GitHub Actions が自動デプロイ実行
# → ヘルスチェック自動実行
# → デプロイ成功通知（Slack/Discord等）
```

**ブランチ戦略はPhase 0で決定済み**:
- Pattern A（staging有）: develop → staging, main → production
- Pattern B（本番のみ）: main → production

---

## Phase 4: ロールバック・モニタリング

### 4.1 ロールバック

**エージェント**: `deploy-manager`

```bash
Task:deploy-manager(prompt: "前バージョンへロールバック")
```

**実行内容**:
- Git revert実行
- 自動デプロイトリガー
- ヘルスチェック
- ロールバック成功確認

### 4.2 デプロイ後ヘルスチェック

**エージェント**: `deploy-manager`

```bash
Task:deploy-manager(prompt: "デプロイ後ヘルスチェック実行")
```

**チェック項目**:
- ヘルスチェックエンドポイント（/health）
- 主要機能動作確認
- データベース接続確認
- 環境変数設定確認

---

## トラブルシューティング

### デプロイ失敗時

**エージェント**: `deploy-manager`

```bash
Task:deploy-manager(prompt: "デプロイエラー解析: {{ERROR_MESSAGE}}")
```

**エージェントが実行**:
1. プラットフォームログ解析
2. エラー原因特定
3. 修正提案
4. ローカル再現手順生成

---

## エージェント連携

### infra-validator（要件定義・検証）
- Phase 0: デプロイ要件定義・プラットフォーム推奨
- Phase 1: 環境変数検証・セキュリティチェック

### deploy-manager（実行・管理）
- Phase 0: 設定ファイル自動生成
- Phase 2: 初回デプロイ実行
- Phase 3: 継続的デプロイ管理
- Phase 4: ロールバック・ヘルスチェック・トラブルシューティング

---

## ベストプラクティス

### エージェント動的生成の利点
- ✅ テンプレートファイル不要（メンテナンス負荷ゼロ）
- ✅ あらゆるプラットフォームに対応可能
- ✅ 最新ベストプラクティスを自動適用
- ✅ プロジェクト固有要件に柔軟対応

### セキュリティ
- ✅ HTTPS必須
- ✅ APIキー・シークレットは環境変数で管理
- ✅ CORS設定を正しく構成
- ✅ レート制限実装

---

## 参考リンク

- **Vercel Docs**: https://vercel.com/docs
- **Railway Docs**: https://docs.railway.app
- **Render Docs**: https://render.com/docs
- **Supabase Docs**: https://supabase.com/docs
- **GitHub Actions**: https://docs.github.com/actions
