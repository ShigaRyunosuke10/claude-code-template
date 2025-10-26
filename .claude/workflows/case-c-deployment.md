# Case C: デプロイワークフロー

**目的**: 開発完了後の本番環境へのデプロイを安全かつ効率的に実行する

---

## Phase 1: デプロイ先決定（プロジェクト開始時・必須）

### Step 1: 要件に基づくプラットフォーム選択

**質問リスト**:
1. フロントエンド・バックエンド構成は？
2. データベースは必要か？
3. 予算は？（無料枠 / 有料）
4. スケール予定は？
5. チーム開発 or 個人開発？

### Step 2: プラットフォーム別推奨

#### Option A: Vercel + Supabase（推奨・個人/小規模チーム）
**適用例**:
- Next.js + FastAPI/Express
- PostgreSQL必要
- 無料枠で開始したい

**メリット**:
- ✅ 無料枠が充実
- ✅ 自動デプロイ（GitHubプッシュで即反映）
- ✅ セットアップ簡単

**デメリット**:
- ⚠️ バックエンドは別途デプロイ必要（Railway/Renderなど）

**構成**:
```
Frontend: Vercel
Backend: Railway or Render
Database: Supabase（PostgreSQL）
```

---

#### Option B: Railway（推奨・フルスタック）
**適用例**:
- フロントエンド + バックエンド + DB 一括管理
- Docker対応
- シンプルな構成

**メリット**:
- ✅ フルスタック対応（1プラットフォームで完結）
- ✅ Docker対応
- ✅ 自動デプロイ

**デメリット**:
- ⚠️ 無料枠が少ない（$5/月〜）

**構成**:
```
Frontend + Backend + Database: すべてRailway
```

---

#### Option C: Render（推奨・バランス型）
**適用例**:
- Railway同様のフルスタック
- 無料枠重視

**メリット**:
- ✅ 無料枠あり
- ✅ フルスタック対応
- ✅ 自動デプロイ

**デメリット**:
- ⚠️ 無料枠はスリープあり（アクセスがないと停止）

**構成**:
```
Frontend + Backend + Database: すべてRender
```

---

#### Option D: AWS/GCP/Azure（大規模/エンタープライズ）
**適用例**:
- 大規模サービス
- 高度なインフラ要件
- 予算が潤沢

**メリット**:
- ✅ スケーラビリティ無限
- ✅ あらゆる要件に対応

**デメリット**:
- ⚠️ セットアップ複雑
- ⚠️ コスト高い
- ⚠️ インフラ知識必須

**構成**:
```
テンプレートでは対象外（プロジェクト固有設定が必要）
```

---

## Phase 2: デプロイ環境構成

### Pattern A: ステージング + 本番（チーム開発推奨）

**ブランチ戦略**:
```
main ブランチ        → 本番環境（example.com）
develop ブランチ     → ステージング環境（staging.example.com）
feature/* ブランチ   → ローカル開発のみ
```

**フロー**:
```
1. feature/* で開発
2. develop へPR → マージ → ステージング自動デプロイ
3. ステージングで検証
4. main へPR → マージ → 本番自動デプロイ
```

**コスト**:
- インフラ費用: 2倍（staging + production）
- メリット: 本番でのバグリスク最小

---

### Pattern B: 本番のみ（個人開発推奨）

**ブランチ戦略**:
```
main ブランチ        → 本番環境（example.com）
feature/* ブランチ   → ローカル開発のみ
```

**フロー**:
```
1. feature/* で開発
2. main へPR → マージ → 本番自動デプロイ
```

**コスト**:
- インフラ費用: 最小
- メリット: シンプル・高速デプロイ

---

## Phase 3: デプロイ実装

### Step 1: インフラ設定

**エージェント使用**:
```bash
Task:infra-validator(prompt: "{{PLATFORM}}のインフラ設定を検証")
```

**実行内容**:
- プラットフォーム固有の設定ファイル作成
- 環境変数テンプレート作成
- デプロイスクリプト検証

---

### Step 2: CI/CD設定

**GitHub Actions テンプレート選択**:

#### Vercel の場合
```bash
# .github/workflows/deploy-vercel.yml を使用
# 自動生成: Task:deploy-manager(prompt: "Vercel用CI/CD設定")
```

#### Railway の場合
```bash
# .github/workflows/deploy-railway.yml を使用
# 自動生成: Task:deploy-manager(prompt: "Railway用CI/CD設定")
```

#### Render の場合
```bash
# .github/workflows/deploy-render.yml を使用
# 自動生成: Task:deploy-manager(prompt: "Render用CI/CD設定")
```

---

### Step 3: 初回デプロイ

**手順**:
```bash
1. インフラ設定完了確認
   Task:infra-validator(prompt: "デプロイ前最終チェック")

2. 環境変数設定
   - プラットフォームのダッシュボードで設定
   - .env.example をガイドとして使用

3. 初回デプロイ実行
   Task:deploy-manager(prompt: "初回デプロイ実行")

4. デプロイ検証
   - ヘルスチェックURL確認
   - E2Eテスト実行（本番環境）
```

---

## Phase 4: 継続的デプロイ

### 通常デプロイフロー

**Pattern A（ステージング有）**:
```bash
# Step 1: feature → develop
git checkout -b feature-new-function
# 開発...
git add .
git commit -m "feat: new function"
git push origin feature-new-function

# PR作成 → develop へマージ
# → ステージング環境に自動デプロイ

# Step 2: ステージング検証
# E2Eテスト実行、動作確認

# Step 3: develop → main
# PR作成 → main へマージ
# → 本番環境に自動デプロイ
```

**Pattern B（本番のみ）**:
```bash
# Step 1: feature → main
git checkout -b feature-new-function
# 開発...
git add .
git commit -m "feat: new function"
git push origin feature-new-function

# PR作成 → main へマージ
# → 本番環境に自動デプロイ
```

---

### ロールバック手順

**緊急時のロールバック**:
```bash
# Method 1: Git revert（推奨）
git revert HEAD
git push origin main
# → 前のバージョンに自動デプロイ

# Method 2: プラットフォームUI
# Vercel/Railway/Render のダッシュボードから
# 前のデプロイバージョンを選択してロールバック

# Method 3: エージェント使用
Task:deploy-manager(prompt: "前バージョンへロールバック")
```

---

## Phase 5: モニタリング

### デプロイ後チェックリスト

**必須確認項目**:
- [ ] ヘルスチェックURL（`/health`）が200を返す
- [ ] フロントエンドが正常表示
- [ ] 主要APIエンドポイントが動作
- [ ] データベース接続OK
- [ ] 環境変数が正しく設定されている

**エージェント使用**:
```bash
Task:deploy-manager(prompt: "デプロイ後ヘルスチェック実行")
```

---

## エージェント一覧

### deploy-manager
- デプロイ実行
- ロールバック
- ヘルスチェック
- CI/CD設定生成

### infra-validator
- インフラ設定検証
- 環境変数チェック
- セキュリティスキャン（本番環境用）

---

## トラブルシューティング

### デプロイ失敗時

**Step 1: ログ確認**
```bash
# プラットフォームのログを確認
# Vercel: Vercel Dashboard → Deployments → Logs
# Railway: Railway Dashboard → Deployments → Logs
# Render: Render Dashboard → Logs
```

**Step 2: ローカルで再現**
```bash
# 本番環境と同じ環境変数でローカル起動
# エラーを再現して修正
```

**Step 3: エージェント支援**
```bash
Task:deploy-manager(prompt: "デプロイエラー解析: {{ERROR_MESSAGE}}")
```

---

## ベストプラクティス

### 環境変数管理
- ✅ `.env.example` をリポジトリにコミット
- ✅ 実際の `.env` は `.gitignore` で除外
- ✅ 本番環境の環境変数はプラットフォームのダッシュボードで管理
- ❌ 環境変数をコードにハードコードしない

### デプロイタイミング
- ✅ 営業時間外にデプロイ（トラブル対応可能な時間帯）
- ✅ 金曜夜は避ける（週末にトラブル対応したくない）
- ✅ 大きな変更前にバックアップ

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
