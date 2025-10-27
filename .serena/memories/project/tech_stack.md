# Nissei 工数管理システム - 技術スタック

**Version**: 1.0
**Last Updated**: 2025-10-27
**Phase**: 0.2 - 技術スタック決定完了

---

## 技術スタック選定理由

Supabaseをデータベース・認証・ストレージのコアとして採用し、Webアプリケーションに最適化された統合ソリューションを構築します。

### Supabase採用の主な理由
- PostgreSQL 15ベースの高性能データベース
- 統合認証システム（Supabase Auth）でJWT自動管理
- ファイルストレージ機能（最大100MB対応）で資料管理機能を実現
- Row Level Security (RLS) による細かなアクセス制御
- リアルタイム機能（将来の拡張性）
- 自動バックアップとスナップショット
- 管理UIで開発・運用効率向上
- 無料枠が充実（500MB DB、1GB Storage、50,000 MAU）

---

## バックエンド

### フレームワーク: Python + FastAPI
- **バージョン**:
  - Python 3.11+
  - FastAPI 0.109+

- **選定理由**:
  - 型安全性（Pydantic）による堅牢な開発
  - 高速な非同期処理（ASGI）
  - 自動API ドキュメント生成（OpenAPI/Swagger）
  - Supabase Python クライアント（supabase-py）との公式連携
  - 学習コストが低く、保守性が高い

### データベース: Supabase (PostgreSQL 15)
- **接続**: Supabase Python SDK (`supabase-py`)

- **主要機能**:
  - **PostgreSQL 15**: リレーショナルデータベース（15テーブル構成）
  - **Row Level Security (RLS)**: テーブル単位で細かなアクセス制御
  - **自動インデックス**: パフォーマンス最適化
  - **トリガー/ストアドプロシージャ**: ビジネスロジックのDB層実装
  - **自動バックアップ**: PITR（Point-in-Time Recovery）対応

- **RLS設計方針**:
  ```sql
  -- users: 自分のレコードのみアクセス可
  CREATE POLICY "users_own_data" ON users
    FOR ALL USING (auth.uid() = id);

  -- projects: 管理者または担当者のみ編集可
  CREATE POLICY "projects_access" ON projects
    FOR ALL USING (
      auth.jwt() ->> 'is_admin' = 'true' OR
      assigned_user_id = auth.uid()
    );

  -- worklogs: 自分の工数のみ編集可
  CREATE POLICY "worklogs_own_data" ON worklogs
    FOR ALL USING (user_id = auth.uid());

  -- materials: 全員読み取り、管理者のみ書き込み
  CREATE POLICY "materials_read" ON materials
    FOR SELECT USING (true);
  CREATE POLICY "materials_write" ON materials
    FOR INSERT, UPDATE, DELETE USING (
      auth.jwt() ->> 'is_admin' = 'true'
    );
  ```

### 認証: Supabase Auth
- **認証方式**: JWT（JSON Web Token）
- **トークン有効期限**: 1時間（自動リフレッシュ機能あり）

- **機能**:
  - メールアドレス/パスワード認証
  - JWT自動発行・リフレッシュ
  - セッション管理（Cookie/LocalStorage対応）
  - パスワードリセット機能
  - メール確認機能（オプション）

- **認証フロー**:
  1. ユーザーがメール/パスワードでログイン
  2. Supabase Authがユーザー認証
  3. JWT（Access Token + Refresh Token）を発行
  4. クライアント側でトークン保存
  5. API呼び出し時に`Authorization: Bearer <token>`ヘッダー付与
  6. FastAPI側でトークン検証（Supabase JWT Secret使用）
  7. トークン期限切れ時は自動リフレッシュ

### ストレージ: Supabase Storage
- **用途**: 資料管理機能（materials テーブルと連携）
- **最大ファイルサイズ**: 100MB
- **対応ファイル形式**: PDF、Excel、Word、画像等

- **機能**:
  - 自動CDN配信（高速ダウンロード）
  - ファイル暗号化
  - アクセス制御（RLS連携）
  - サムネイル自動生成（画像の場合）
  - メタデータ管理（アップロード者、日時等）

- **バケット構成**:
  ```
  materials/
    ├── series/       # シリーズ共通資料
    ├── tonnage/      # トン数共通資料
    ├── model/        # 機種専用資料
    └── machine/      # 機番専用資料
  ```

### API設計
- **ベースURL**: `/api` または `/api/v1`
- **認証ヘッダー**: `Authorization: Bearer <token>`
- **レスポンス形式**: JSON

- **エンドポイント設計**:
  - 認証: `/api/auth/*`
  - 案件管理: `/api/projects/*`
  - 工数管理: `/api/worklogs/*`
  - 請求書管理: `/api/invoices/*`
  - 資料管理: `/api/materials/*`
  - 注意点管理: `/api/chuiten/*`
  - マスタ管理: `/api/masters/*`
  - 集計・分析: `/api/aggregations/*`
  - 監査ログ: `/api/audit-logs/*`
  - バックアップ: `/api/backups/*`
  - 管理者機能: `/api/admin/*`
  - システム設定: `/api/settings/*`

---

## フロントエンド

### フレームワーク: Next.js 14 (App Router)
- **バージョン**:
  - Next.js 14.0+
  - React 18.2+
  - TypeScript 5.3+

- **選定理由**:
  - App Router による最新のReact機能活用（Server Components、Streaming等）
  - SSR/SSG によるSEO最適化とパフォーマンス向上
  - ファイルベースルーティング（開発効率向上）
  - TypeScript完全対応（型安全性）
  - Supabase公式サポート（`@supabase/auth-helpers-nextjs`）
  - Vercelとの親和性（自動デプロイ、Edge Functions）

### UIライブラリ: Tailwind CSS + shadcn/ui
- **Tailwind CSS**:
  - ユーティリティファーストCSS
  - カスタマイズ性が高い
  - 高速開発が可能
  - バンドルサイズ最適化（未使用スタイル自動削除）

- **shadcn/ui**:
  - Radix UI ベースの高品質コンポーネント
  - アクセシビリティ対応（WAI-ARIA準拠）
  - カスタマイズ可能（ソースコードをプロジェクトにコピー）
  - ダークモード対応
  - フォーム、テーブル、ダイアログ等の主要コンポーネント完備

### 状態管理
- **Zustand**: グローバル状態管理
  - 用途: ユーザー情報、テーマ設定、グローバルモーダル等
  - 理由: シンプルなAPI、Redux不要、TypeScript完全対応

- **React Query (TanStack Query)**: サーバーステート管理
  - 用途: API通信、キャッシュ管理、楽観的更新
  - 理由: 自動キャッシュ、リトライ、バックグラウンド再検証、ページネーション対応

### Supabase連携
- **パッケージ**:
  - `@supabase/supabase-js`: Supabaseクライアント（ブラウザ/サーバー共通）
  - `@supabase/auth-helpers-nextjs`: Next.js専用認証ヘルパー
  - `@supabase/ssr`: Server Components対応

- **機能**:
  - クライアント側認証（自動トークン管理）
  - サーバーサイド認証（Middleware/API Routes）
  - リアルタイムサブスクリプション（将来の拡張性）
  - ファイルアップロード/ダウンロード

### フォルダ構成（Next.js App Router）
```
frontend/
├── app/                    # App Router（ルーティング）
│   ├── (auth)/            # 認証関連ページ
│   │   ├── login/         # ログインページ
│   │   └── register/      # 登録ページ
│   ├── (dashboard)/       # ダッシュボードレイアウト
│   │   ├── projects/      # 案件管理
│   │   ├── worklogs/      # 工数管理
│   │   ├── invoices/      # 請求書管理
│   │   ├── materials/     # 資料管理
│   │   └── settings/      # 設定
│   ├── api/               # API Routes（Next.js側）
│   ├── layout.tsx         # ルートレイアウト
│   └── page.tsx           # トップページ
├── components/            # UIコンポーネント
│   ├── ui/                # shadcn/ui コンポーネント
│   ├── forms/             # フォーム関連
│   ├── tables/            # テーブル関連
│   └── layouts/           # レイアウト関連
├── lib/                   # ユーティリティ
│   ├── supabase/          # Supabase クライアント
│   ├── utils/             # 汎用関数
│   └── validations/       # バリデーション
├── hooks/                 # カスタムHooks
├── stores/                # Zustand ストア
├── types/                 # TypeScript型定義
└── public/                # 静的ファイル
```

---

## ホスティング・デプロイ

### フロントエンド: Vercel
- **選定理由**:
  - Next.js最適化（開発元が同じ）
  - 自動デプロイ（Git連携）
  - Edge Functions（地理的に最適なリージョンで実行）
  - プレビューデプロイ（PR毎に自動生成）
  - 環境変数管理
  - カスタムドメイン対応

- **料金プラン**:
  - Hobby（無料）: 個人開発、趣味プロジェクト
  - Pro（$20/月）: 商用利用、チーム開発

### バックエンド: Railway または Render
- **選定理由**:
  - FastAPI対応（Python実行環境）
  - 自動デプロイ（Git連携）
  - 環境変数管理
  - ログ監視
  - スケーラビリティ

- **Railway**:
  - 無料枠: $5/月クレジット
  - 料金: 使った分だけ課金
  - 推奨: 小規模プロジェクト

- **Render**:
  - 無料枠: Web Service（1インスタンス、自動スリープあり）
  - 料金: $7/月〜
  - 推奨: 中規模以上のプロジェクト

### データベース・認証・ストレージ: Supabase (クラウド)
- **プラン**:
  - Free（無料）:
    - 500MB データベース
    - 1GB ストレージ
    - 50,000 MAU（月間アクティブユーザー）
    - 50,000 リクエスト/月
  - Pro（$25/月）:
    - 8GB データベース
    - 100GB ストレージ
    - 100,000 MAU
    - 5,000,000 リクエスト/月
    - 自動バックアップ（7日間保持）
    - メールサポート

---

## 開発ツール

### バージョン管理
- **Git + GitHub**
  - リポジトリ: `shiga-org/nissei-worklog`
  - ブランチ戦略: GitHub Flow（main + feature branches）
  - PR運用: レビュー必須、CI/CD連携

### パッケージマネージャ
- **Backend**: Poetry (Python)
  - 依存関係管理
  - 仮想環境自動構築
  - `pyproject.toml`で設定管理

- **Frontend**: pnpm (Node.js)
  - 高速インストール
  - ディスクスペース節約
  - モノレポ対応

### コード品質
- **Backend**:
  - **Black**: コードフォーマッター（PEP8準拠）
  - **Ruff**: 超高速リンター（Flake8/Pylintの代替）
  - **mypy**: 型チェック

- **Frontend**:
  - **ESLint**: JavaScriptリンター（Next.js公式設定）
  - **Prettier**: コードフォーマッター
  - **TypeScript**: 型チェック（厳格モード）

### テスト
- **Backend**:
  - **pytest**: ユニットテスト・統合テスト
  - **pytest-cov**: カバレッジ測定
  - **httpx**: 非同期HTTPクライアント（テスト用）

- **Frontend**:
  - **Vitest**: ユニットテスト（Vite ベース、高速）
  - **React Testing Library**: コンポーネントテスト
  - **Playwright**: E2Eテスト（ブラウザ自動化）

### CI/CD
- **GitHub Actions**
  - Backend:
    - リンター実行（Black、Ruff、mypy）
    - テスト実行（pytest）
    - カバレッジレポート
  - Frontend:
    - リンター実行（ESLint、Prettier）
    - テスト実行（Vitest、Playwright）
    - ビルドチェック
  - デプロイ:
    - Vercel自動デプロイ（main ブランチ）
    - Railway/Render自動デプロイ（main ブランチ）

---

## 環境変数（Phase 0.3で設定）

### Backend (.env)
```bash
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# JWT
JWT_SECRET=your-jwt-secret

# CORS
ALLOWED_ORIGINS=https://your-frontend-domain.com

# 環境
ENV=development  # development / production

# サーバー設定
HOST=0.0.0.0
PORT=8000
```

### Frontend (.env.local)
```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# API
NEXT_PUBLIC_API_BASE_URL=https://your-backend-domain.com/api

# 環境
NEXT_PUBLIC_ENV=development  # development / production
```

---

## アーキテクチャ概要

```
[ユーザー（ブラウザ）]
  ↓
[Next.js Frontend (Vercel)]
  ↓ (Supabase Client SDK)
[Supabase]
  ├── Auth（認証・JWT発行）
  ├── PostgreSQL（データベース）
  └── Storage（ファイル保存）
  ↓
[FastAPI Backend (Railway/Render)]
  ↓ (Supabase Python SDK)
[Supabase PostgreSQL]
```

### データフロー
1. **認証フロー**:
   - ユーザーがNext.jsのログインフォームに入力
   - Supabase Authで認証（JWT発行）
   - JWT をクライアント側で保存（Cookie/LocalStorage）
   - 以降のAPI呼び出しで`Authorization: Bearer <token>`ヘッダー付与

2. **データ取得フロー**:
   - Next.jsからFastAPI バックエンドにAPIリクエスト（JWT付き）
   - FastAPI がJWT検証（Supabase JWT Secret使用）
   - Supabase PostgreSQL からデータ取得（RLS適用）
   - JSON形式でレスポンス
   - Next.jsでUI表示

3. **ファイルアップロードフロー**:
   - Next.jsからFastAPI バックエンドにファイルアップロード
   - FastAPI がSupabase Storage にファイル保存
   - ファイルメタデータ（パス、サイズ等）をPostgreSQLの`materials`テーブルに保存
   - ファイルURLを返却

---

## データベーススキーマ管理

### マイグレーションツール: Supabase Migrations (SQL)
- **管理方法**: SQLファイルベース
- **ディレクトリ構成**:
  ```
  supabase/
  ├── migrations/                # マイグレーションファイル
  │   ├── 20250101000000_initial_schema.sql
  │   ├── 20250102000000_add_rls_policies.sql
  │   └── 20250103000000_add_triggers.sql
  ├── seed.sql                   # 初期データ
  └── config.toml                # Supabase設定
  ```

- **マイグレーション実行**:
  ```bash
  # ローカルでマイグレーション適用
  supabase db push

  # 本番環境にマイグレーション適用
  supabase db push --linked

  # マイグレーション履歴確認
  supabase migration list
  ```

### 初期データ (seed.sql)
```sql
-- 進捗マスタ
INSERT INTO master_shinchoku (id, name, display_order) VALUES
  (gen_random_uuid(), '未着手', 1),
  (gen_random_uuid(), '進行中', 2),
  (gen_random_uuid(), '完了', 3);

-- 注意点カテゴリマスタ
INSERT INTO master_chuiten_category (id, name, display_order) VALUES
  (gen_random_uuid(), '使い方', 1),
  (gen_random_uuid(), '組付', 2),
  (gen_random_uuid(), '注意点', 3),
  (gen_random_uuid(), 'チェック項目', 4),
  (gen_random_uuid(), 'トラブルシューティング', 5);

-- システム設定
INSERT INTO system_settings (id, key, value, description) VALUES
  (gen_random_uuid(), 'rounding_method', 'up', '工数丸め方法（up/down/round）'),
  (gen_random_uuid(), 'rounding_unit', '1.0', '工数丸め単位（1.0/0.5/0.25）');
```

---

## セキュリティ対策

### 1. Row Level Security (RLS)
- **有効化**: 全テーブルでRLS有効化
- **ポリシー設計**:
  - **users**: 自分のレコードのみアクセス可
  - **projects**: 管理者または担当者のみ編集可
  - **worklogs**: 自分の工数のみ編集可
  - **materials**: 全員読み取り、管理者のみ書き込み
  - **invoices**: 管理者のみアクセス可
  - **audit_logs**: 管理者のみ読み取り可

### 2. 認証トークン (JWT)
- **発行元**: Supabase Auth
- **有効期限**: 1時間（Access Token）
- **リフレッシュトークン**: 30日間有効（自動更新）
- **署名アルゴリズム**: HS256（HMAC SHA-256）
- **検証**: FastAPI側でSupabase JWT Secretを使用

### 3. APIセキュリティ
- **CORS設定**: 許可されたオリジンのみアクセス可（`ALLOWED_ORIGINS`環境変数）
- **レート制限**: 1分間に60リクエストまで（FastAPI Middleware）
- **CSRFトークン**: POST/PUT/DELETEリクエストにCSRFトークン付与（Next.js側）
- **入力検証**: Pydantic（FastAPI）、Zod（Next.js）で厳格な型チェック

### 4. ファイルセキュリティ
- **ファイルサイズ制限**: 最大100MB
- **ファイル形式検証**: MIMEタイプチェック
- **パストラバーサル対策**: ファイルパスを検証、許可されたディレクトリ外へのアクセスを拒否
- **ウイルススキャン**: 将来的にClamAV等の導入検討

### 5. CSV出力セキュリティ
- **CSVインジェクション対策**: `=`, `+`, `-`, `@`で始まる値を自動エスケープ
- **文字エンコーディング**: BOM付きUTF-8（Excelで正常に開ける）
- **改行・カンマのエスケープ**: ダブルクォート処理

### 6. 監査ログ
- **記録内容**: 全CRUD操作、ログイン/ログアウト、IP アドレス、ユーザーエージェント
- **保存先**: `audit_logs`テーブル（PostgreSQL）
- **保持期間**: 1年間（古いログは自動アーカイブ）

---

## コスト見積もり（月額）

| サービス | プラン | 料金 | 備考 |
|---------|--------|------|------|
| Supabase | Free / Pro | $0 / $25 | 無料枠で十分、Pro推奨（本番環境） |
| Vercel | Hobby / Pro | $0 / $20 | Hobby可、Pro推奨（商用利用） |
| Railway | 従量課金 | $0〜 $7 | 無料枠あり、使った分だけ課金 |
| Render | Free / Starter | $0 / $7 | Free可（自動スリープあり） |
| **合計** | - | **$0〜 $52** | 無料枠活用で$0〜、本番環境で$25〜52 |

### コスト最適化ポイント
- **Supabase**: Free枠（500MB DB、1GB Storage）で十分な場合は$0
- **Vercel**: Hobby枠で個人開発可能（商用利用はPro推奨）
- **Railway/Render**: Railway無料枠またはRender Free（自動スリープ許容）

---

## Phase 1での実装優先順位

### 優先度1（必須）
1. **Supabaseプロジェクト作成**
   - Supabaseダッシュボードでプロジェクト作成
   - データベースURL、API Key取得

2. **データベーススキーマ構築**
   - 15テーブルのマイグレーション作成
   - 初期データ投入（seed.sql）

3. **Row Level Security設定**
   - 全テーブルでRLS有効化
   - ポリシー設定（users、projects、worklogs、materials等）

4. **Supabase Auth設定**
   - メール/パスワード認証有効化
   - JWT設定（有効期限、署名アルゴリズム）

5. **FastAPIバックエンド基盤**
   - プロジェクト構造作成
   - Supabase Python SDK連携
   - 認証ミドルウェア実装
   - 基本的なCRUD APIエンドポイント（projects、worklogs）

6. **Next.jsフロントエンド基盤**
   - プロジェクト構造作成
   - Supabase クライアント設定
   - 認証フロー実装（ログイン/ログアウト）
   - 基本的なUI（ダッシュボード、案件一覧、工数一覧）

### 優先度2（重要）
7. **Supabase Storage設定**
   - バケット作成（materials）
   - RLS設定（アクセス制御）

8. **資料管理機能**
   - ファイルアップロード機能
   - ファイルダウンロード機能
   - メタデータ管理（materialsテーブル）

9. **請求書機能**
   - 請求プレビュー
   - 請求確定
   - CSV出力

10. **監査ログ機能**
    - 全CRUD操作の自動記録
    - ログ閲覧UI（管理者のみ）

### 優先度3（後回し可）
11. **バックアップ・復旧機能**
12. **注意点管理機能**
13. **集計・分析機能**
14. **管理者機能（ユーザー管理）**

---

## 技術スタック選定理由まとめ

| 要素 | 選定技術 | 理由 |
|-----|---------|-----|
| **DB** | Supabase (PostgreSQL 15) | 認証・ストレージ統合、RLS、自動バックアップ、管理UI |
| **Backend** | FastAPI (Python 3.11+) | 高速、型安全、自動ドキュメント、Supabase SDK対応 |
| **Frontend** | Next.js 14 (App Router) | SSR、Supabase公式サポート、開発速度、型安全 |
| **UI** | Tailwind CSS + shadcn/ui | モダン、高速開発、カスタマイズ性、アクセシビリティ |
| **認証** | Supabase Auth | JWT自動発行、セッション管理、パスワードリセット |
| **ストレージ** | Supabase Storage | 100MBファイル対応、CDN、暗号化 |
| **状態管理** | Zustand + React Query | シンプルAPI、サーバーステート管理、キャッシュ |
| **デプロイ** | Vercel + Railway/Render | 自動デプロイ、スケーラビリティ、環境変数管理 |

---

## 次のステップ（Phase 0.3）

Phase 0.3では、以下の環境変数・MCP設定を行います：

### 必須環境変数
- `SUPABASE_URL`: Supabaseプロジェクト作成後に取得
- `SUPABASE_KEY`: SupabaseダッシュボードのSettings → API
- `SUPABASE_SERVICE_ROLE_KEY`: 管理者権限APIキー（注意: 公開厳禁）
- `JWT_SECRET`: Supabaseの JWT Secret（Settings → API → JWT Settings）
- `GITHUB_TOKEN`: GitHub Personal Access Token（既存）
- `OPENAI_API_KEY`: OpenAI API Key（Codex MCP用、既存）

### MCP設定
- `supabase` MCPサーバーの追加（Phase 0.3で検討）
- 必要に応じて`stripe`、`auth0`等の追加（将来の拡張性）

---

## 参考リンク

- **Supabase**: https://supabase.com/
- **FastAPI**: https://fastapi.tiangolo.com/
- **Next.js**: https://nextjs.org/
- **shadcn/ui**: https://ui.shadcn.com/
- **Tailwind CSS**: https://tailwindcss.com/
- **Zustand**: https://github.com/pmndrs/zustand
- **React Query**: https://tanstack.com/query/latest
- **Vercel**: https://vercel.com/
- **Railway**: https://railway.app/
- **Render**: https://render.com/
