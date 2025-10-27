# Nissei 工数管理システム - Phase階層構造

**Version**: 1.0  
**Last Updated**: 2025-10-27  
**Current Phase**: Phase 0.1

---

## Phase 0: プロジェクト基盤構築

### Phase 0.0: GitHubリポジトリ初期化
- **ステータス**: 完了
- **実施内容**:
  - GitHubリポジトリ作成
  - テンプレート構造のセットアップ
  - .claude/ ディレクトリ配置
  - ai-rules/ ディレクトリ配置
  - docs/ ディレクトリ配置
  - 初回コミット

### Phase 0.1: 要件定義書分析・Serenaメモリ初期化
- **ステータス**: 進行中
- **実施内容**:
  - 要件定義書（docs/references/要件定義書.md）の詳細分析
  - Serenaメモリファイル作成:
    - project_overview.md
    - requirements_summary.md
    - phase_hierarchy.md（本ファイル）
    - api_contracts.md
    - database_schema.md
- **重要**: Serenaの`onboarding`ツールは使用しない（要件定義書が存在するため）

### Phase 0.2: 技術スタック決定
- **ステータス**: 未着手
- **検討項目**:
  - **バックエンド**: Python/FastAPI vs Node.js/Express vs Go/Gin
  - **データベース**: PostgreSQL vs MySQL vs Supabase
  - **認証**: JWT vs OAuth vs Auth0
  - **フロントエンド**: React/Next.js vs Vue/Nuxt vs Svelte/SvelteKit
  - **UI**: Tailwind CSS vs Material-UI vs Chakra UI
  - **ホスティング**: Vercel vs Render vs Railway vs Supabase
  - **ストレージ**: ローカルファイルシステム vs S3 vs Supabase Storage
- **決定基準**:
  - 開発速度
  - 保守性
  - コスト
  - スケーラビリティ
  - チームのスキルセット

### Phase 0.3: 環境変数・MCP設定チェック
- **ステータス**: 未着手
- **実施内容**:
  - 必須環境変数の確認（GITHUB_TOKEN, OPENAI_API_KEY等）
  - 技術スタック依存のMCPサーバー追加（Supabase/Stripe/Auth0等）
  - .mcp.json の更新
  - ENV_SETUP_GUIDE.md の自動生成

---

## Phase 1: バックエンド基盤

### Phase 1.1: データベーススキーマ設計・実装
- **ステータス**: 未着手
- **実施内容**:
  - 14テーブルの詳細設計（users, projects, worklogs, invoices, invoice_items, materials, master_chuiten, master_chuiten_category, master_work_category, master_kishyu, master_nounyusaki, master_shinchoku, system_settings, audit_logs, backups）
  - マイグレーションファイル作成
  - 外部キー制約・インデックス設定
  - データベース初期化スクリプト作成

### Phase 1.2: 認証システム実装
- **ステータス**: 未着手
- **実施内容**:
  - ユーザー登録API（POST /api/register）
  - ログインAPI（POST /api/login）
  - 現在のユーザー情報取得API（GET /api/me）
  - 認証ミドルウェア実装
  - パスワードハッシュ化（bcrypt等）
  - トークン生成・検証（JWT等）
  - トークン有効期限管理（30分）

### Phase 1.3: API基盤構築
- **ステータス**: 未着手
- **実施内容**:
  - ルーティング設定
  - エラーハンドリングミドルウェア
  - CORS設定
  - リクエストバリデーション
  - レスポンス標準化
  - ロギング設定
  - ヘルスチェックエンドポイント（GET /api/health）

---

## Phase 2: フロントエンド基盤

### Phase 2.1: UI/UXフレームワーク選定・セットアップ
- **ステータス**: 未着手
- **実施内容**:
  - フロントエンドプロジェクト初期化
  - ルーティング設定（React Router/Next.js Router等）
  - UIライブラリのセットアップ（Tailwind CSS/Material-UI等）
  - レイアウトコンポーネント作成（ヘッダー、サイドバー、フッター）

### Phase 2.2: 共通コンポーネント実装
- **ステータス**: 未着手
- **実施内容**:
  - ボタン、入力フォーム、ドロップダウン、テーブル、ページネーション
  - モーダル、Toast通知、ローディングスピナー
  - 認証コンテキスト・認証ガード
  - APIクライアント（Axios/Fetch等）
  - エラーハンドリング

### Phase 2.3: 認証画面実装
- **ステータス**: 未着手
- **実施内容**:
  - ログイン画面（/login）
  - ユーザー登録画面（/register）
  - 認証トークン管理
  - 自動ログアウト機能

---

## Phase 3: 案件管理機能

### Phase 3.1: 案件管理API実装
- **ステータス**: 未着手
- **実施内容**:
  - 案件一覧取得API（GET /api/projects）
  - 案件作成API（POST /api/projects）
  - 案件詳細取得API（GET /api/projects/{id}）
  - 案件更新API（PUT /api/projects/{id}）
  - 案件削除API（DELETE /api/projects/{id}）
  - 検索・フィルタ・ページネーション実装

### Phase 3.2: 案件管理フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 案件一覧画面（/projects）
  - 案件詳細画面（/projects/[id]）
  - 案件作成画面（/projects/new）
  - 案件編集画面（/projects/[id]/edit）
  - ゴミ箱画面（/projects/trash）

---

## Phase 4: 工数管理機能

### Phase 4.1: 工数管理API実装
- **ステータス**: 未着手
- **実施内容**:
  - 工数一覧取得API（GET /api/worklogs）
  - 工数作成API（POST /api/worklogs）
  - 工数更新API（PUT /api/worklogs/{id}）
  - 工数削除API（DELETE /api/worklogs/{id}）
  - CSV出力API（GET /api/worklogs/csv）

### Phase 4.2: 工数管理フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - スプレッドシート風工数入力画面（/worklogs）
  - 工数編集画面（/worklogs/[id]/edit）
  - キーボード操作実装（Enter/Tab/Shift+Tab/Ctrl+S/Ctrl+N）
  - 一括保存機能

---

## Phase 5: 請求書管理機能

### Phase 5.1: 請求書管理API実装
- **ステータス**: 未着手
- **実施内容**:
  - 請求プレビューAPI（GET /api/invoices/preview）
  - 請求確定API（POST /api/invoices）
  - 請求書一覧取得API（GET /api/invoices）
  - 請求書CSV出力API（GET /api/invoices/csv）
  - 工数丸め設定実装

### Phase 5.2: 請求書管理フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 請求書一覧画面（/invoices）
  - 請求プレビュー機能
  - 請求確定機能
  - CSV出力機能

---

## Phase 6: 資料管理機能

### Phase 6.1: 資料管理API実装
- **ステータス**: 未着手
- **実施内容**:
  - 資料一覧取得API（GET /api/materials）
  - 資料アップロードAPI（POST /api/materials）
  - 資料ダウンロードAPI（GET /api/materials/{id}）
  - 資料削除API（DELETE /api/materials/{id}）
  - ストレージ連携（ローカルFS/S3/Supabase Storage）

### Phase 6.2: 資料管理フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 資料一覧画面（/materials）
  - 資料アップロード機能（最大100MB）
  - スコープ別フィルタ実装（machine/model/tonnage/series）
  - ダウンロード・削除機能

---

## Phase 7: 注意点管理機能

### Phase 7.1: 注意点管理API実装
- **ステータス**: 未着手
- **実施内容**:
  - 注意点一覧取得API（GET /api/chuiten）
  - 注意点作成API（POST /api/chuiten）
  - 注意点カテゴリ管理API（GET/POST/DELETE /api/chuiten/categories）
  - 案件関連注意点抽出API（正規表現マッチング）

### Phase 7.2: 注意点管理フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 注意点一覧画面（/chuiten）
  - 注意点作成機能（管理者のみ）
  - カテゴリ別フィルタ実装
  - 案件詳細画面への注意点自動表示

---

## Phase 8: マスタ管理機能

### Phase 8.1: マスタ管理API実装
- **ステータス**: 未着手
- **実施内容**:
  - 作業区分マスタAPI（GET/POST/PUT/DELETE /api/masters/work-category）
  - 機種マスタAPI（GET/POST/PUT/DELETE /api/masters/kishyu）
  - 納入先マスタAPI（GET/POST/PUT/DELETE /api/masters/nounyusaki）
  - 進捗マスタAPI（GET/POST/PUT/DELETE /api/masters/shinchoku）

### Phase 8.2: マスタ管理フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - マスタ管理トップ画面（/masters）
  - 作業区分マスタ画面（/masters/sagyou-kubun）
  - 機種マスタ画面（/masters/machine-series）
  - 進捗マスタ画面（/masters/shinchoku）
  - 問い合わせマスタ画面（/masters/toiawase）

---

## Phase 9: 集計・分析機能

### Phase 9.1: 集計・分析API実装
- **ステータス**: 未着手
- **実施内容**:
  - 日次集計API（GET /api/aggregations/daily）
  - 月次集計API（GET /api/aggregations/monthly）
  - 推移データ取得API（GET /api/aggregations/trends）
  - CSV出力API（GET /api/aggregations/csv）

### Phase 9.2: 集計・分析フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 工数集計画面（/aggregations）
  - 日次/月次集計グラフ表示
  - CSV出力機能
  - ダッシュボード画面（/dashboard）の実装

---

## Phase 10: 監査ログ機能

### Phase 10.1: 監査ログAPI実装
- **ステータス**: 未着手
- **実施内容**:
  - 監査ログ一覧取得API（GET /api/audit-logs）
  - 監査ログ詳細取得API（GET /api/audit-logs/{id}）
  - 監査ログCSV出力API（GET /api/audit-logs/csv）
  - 自動記録ミドルウェア実装（CREATE/UPDATE/DELETE/LOGIN/LOGOUT）

### Phase 10.2: 監査ログフロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 監査ログ一覧画面（/audit-logs）（管理者のみ）
  - フィルタ機能（ユーザーID、操作種別、対象エンティティ、期間）
  - 監査ログ詳細表示（変更前後比較）
  - CSV出力機能

---

## Phase 11: バックアップ・復旧機能

### Phase 11.1: バックアップ・復旧API実装
- **ステータス**: 未着手
- **実施内容**:
  - バックアップ作成API（POST /api/backups）
  - バックアップ一覧取得API（GET /api/backups）
  - データ復旧API（POST /api/backups/{id}/restore）
  - バックアップ削除API（DELETE /api/backups/{id}）
  - JSON形式でのバックアップ（最大500MB）
  - パストラバーサル対策実装

### Phase 11.2: バックアップ・復旧フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - バックアップ一覧画面（/backups）（管理者のみ）
  - バックアップ作成機能（全体/部分選択）
  - データ復旧機能（確認ダイアログ）
  - バックアップ削除機能

---

## Phase 12: 管理者機能

### Phase 12.1: 管理者機能API実装
- **ステータス**: 未着手
- **実施内容**:
  - 全ユーザー一覧取得API（GET /api/admin/users）
  - ユーザー有効化API（POST /api/admin/users/{id}/activate）
  - ユーザー無効化API（POST /api/admin/users/{id}/deactivate）
  - ユーザー削除API（DELETE /api/admin/users/{id}）

### Phase 12.2: 管理者機能フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 管理者パネル画面（/admin-panel-secret）（管理者のみ）
  - 全ユーザー一覧表示
  - ユーザー有効化/無効化機能
  - ユーザー削除機能

---

## Phase 13: システム設定機能

### Phase 13.1: システム設定API実装
- **ステータス**: 未着手
- **実施内容**:
  - 丸め設定取得API（GET /api/settings/rounding）
  - 丸め設定更新API（PUT /api/settings/rounding）

### Phase 13.2: システム設定フロントエンド実装
- **ステータス**: 未着手
- **実施内容**:
  - 丸め設定画面（/settings/rounding）（管理者のみ）
  - 丸め方法選択（切り上げ/切り捨て/四捨五入）
  - 丸め単位選択（1時間/30分/15分）

---

## Phase 14: テスト・品質保証

### Phase 14.1: ユニットテスト実装
- **ステータス**: 未着手
- **実施内容**:
  - バックエンドユニットテスト（API、ビジネスロジック、バリデーション）
  - フロントエンドユニットテスト（コンポーネント、ユーティリティ関数）

### Phase 14.2: 統合テスト実装
- **ステータス**: 未着手
- **実施内容**:
  - API統合テスト（全エンドポイント）
  - E2Eテスト（Playwright使用）

### Phase 14.3: セキュリティスキャン
- **ステータス**: 未着手
- **実施内容**:
  - 脆弱性スキャン（sec-scan エージェント）
  - CSVインジェクション対策検証
  - パストラバーサル対策検証
  - 認証・認可の検証

---

## Phase 15: デプロイメント・運用準備

### Phase 15.1: デプロイメント設定
- **ステータス**: 未着手
- **実施内容**:
  - CI/CDパイプライン構築（GitHub Actions）
  - 環境変数管理（本番/ステージング/開発）
  - データベースマイグレーション自動化
  - ロールバック手順確立

### Phase 15.2: 運用ドキュメント作成
- **ステータス**: 未着手
- **実施内容**:
  - ユーザーマニュアル
  - 管理者マニュアル
  - API仕様書（OpenAPI/Swagger）
  - トラブルシューティングガイド

---

## Phase 16: リリース

### Phase 16.1: ステージング環境デプロイ
- **ステータス**: 未着手
- **実施内容**:
  - ステージング環境へのデプロイ
  - 動作確認
  - パフォーマンステスト
  - セキュリティテスト

### Phase 16.2: 本番環境デプロイ
- **ステータス**: 未着手
- **実施内容**:
  - 本番環境へのデプロイ
  - データ移行（既存データがある場合）
  - 動作確認
  - ユーザーへの展開

---

## 依存関係

### Phase 0 → Phase 1
- Phase 0（基盤構築）が完了しないとPhase 1（バックエンド基盤）は開始できない

### Phase 1 → Phase 2
- Phase 1.2（認証システム）が完了しないとPhase 2.3（認証画面）は実装できない

### Phase 1 & Phase 2 → Phase 3-13
- Phase 1（バックエンド基盤）とPhase 2（フロントエンド基盤）が完了しないと各機能実装は開始できない

### Phase 3-13 → Phase 14
- 全機能実装が完了しないとテスト・品質保証は開始できない

### Phase 14 → Phase 15 & 16
- テスト・品質保証が完了しないとデプロイメントは実施しない

---

## 見積もり（参考）

| Phase | 見積もり工数 |
|-------|------------|
| Phase 0 | 1日 |
| Phase 1 | 5日 |
| Phase 2 | 3日 |
| Phase 3 | 3日 |
| Phase 4 | 3日 |
| Phase 5 | 2日 |
| Phase 6 | 2日 |
| Phase 7 | 2日 |
| Phase 8 | 2日 |
| Phase 9 | 2日 |
| Phase 10 | 2日 |
| Phase 11 | 3日 |
| Phase 12 | 1日 |
| Phase 13 | 1日 |
| Phase 14 | 5日 |
| Phase 15 | 3日 |
| Phase 16 | 2日 |
| **合計** | **42日** |

※ 見積もりは参考値です。実際の開発状況に応じて調整されます。
