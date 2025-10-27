# Nissei 工数管理システム - データベーススキーマ

**Version**: 1.0  
**Last Updated**: 2025-10-27  
**DBMS**: 未定（Phase 0.2で決定、PostgreSQL/MySQL/Supabase等を検討）

---

## ER図概要

```
users (1) ---- (*) projects (担当者)
users (1) ---- (*) worklogs (作業者)
users (1) ---- (*) invoices (確定者)
users (1) ---- (*) materials (アップロード者)
users (1) ---- (*) audit_logs (操作者)
users (1) ---- (*) backups (作成者/復旧者)

projects (1) ---- (*) worklogs
projects (1) ---- (*) invoice_items

master_work_category (1) ---- (*) projects
master_kishyu (1) ---- (*) projects
master_shinchoku (1) ---- (*) projects

master_chuiten_category (1) ---- (*) master_chuiten

invoices (1) ---- (*) invoice_items
```

---

## テーブル一覧

| No | テーブル名 | 説明 | 行数見積もり |
|----|-----------|------|------------|
| 1 | users | ユーザー情報 | 〜100 |
| 2 | projects | 案件情報 | 〜10,000 |
| 3 | worklogs | 工数記録 | 〜100,000 |
| 4 | invoices | 請求書ヘッダー | 〜120（月次） |
| 5 | invoice_items | 請求書明細 | 〜10,000 |
| 6 | materials | 資料管理 | 〜1,000 |
| 7 | master_chuiten | 注意点マスタ | 〜500 |
| 8 | master_chuiten_category | 注意点カテゴリマスタ | 〜10 |
| 9 | master_work_category | 作業区分マスタ | 〜10 |
| 10 | master_kishyu | 機種マスタ | 〜50 |
| 11 | master_nounyusaki | 納入先マスタ | 〜50 |
| 12 | master_shinchoku | 進捗マスタ | 〜5 |
| 13 | system_settings | システム設定 | 〜10 |
| 14 | audit_logs | 監査ログ | 〜1,000,000 |
| 15 | backups | バックアップ管理 | 〜100 |

---

## 1. users（ユーザー情報）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| name | VARCHAR(100) | NOT NULL | - | ユーザー名 |
| email | VARCHAR(255) | NOT NULL | - | メールアドレス（ログインID） |
| password_hash | VARCHAR(255) | NOT NULL | - | パスワードハッシュ（bcrypt等） |
| is_admin | BOOLEAN | NOT NULL | false | 管理者フラグ |
| is_active | BOOLEAN | NOT NULL | true | アカウント有効フラグ |
| last_login | TIMESTAMP | NULL | - | 最終ログイン日時 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
UNIQUE INDEX idx_users_email (email)
INDEX idx_users_is_active (is_active)
INDEX idx_users_is_admin (is_admin)
```

### 備考

- **パスワードハッシュ**: bcrypt/argon2等の安全なハッシュアルゴリズムを使用
- **is_active**: falseの場合、ログイン不可
- **last_login**: ログイン成功時に更新

---

## 2. projects（案件情報）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| management_no | VARCHAR(50) | NOT NULL | - | 管理番号（例: E252019） |
| machine_no | VARCHAR(50) | NOT NULL | - | 機番（例: HMX7-CN2） |
| kishyu | VARCHAR(100) | NOT NULL | - | 機種（例: NEX140Ⅲ） |
| spec_code | VARCHAR(50) | NULL | - | 仕様コード（例: 24AK） |
| full_model_name | VARCHAR(200) | NOT NULL | - | フルモデル名（機種+仕様コード） |
| work_category_id | UUID | NOT NULL | - | 作業区分ID（FK: master_work_category.id） |
| assigned_user_id | UUID | NOT NULL | - | 担当者ID（FK: users.id） |
| shinchoku_id | UUID | NOT NULL | - | 進捗ID（FK: master_shinchoku.id） |
| estimated_hours | DECIMAL(10, 2) | NULL | - | 予定工数（時間） |
| actual_hours | DECIMAL(10, 2) | NOT NULL | 0.0 | 実績工数（時間、自動計算） |
| deadline | DATE | NULL | - | 作図期限 |
| remarks | TEXT | NULL | - | 備考 |
| deleted_at | TIMESTAMP | NULL | - | 削除日時（論理削除） |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
UNIQUE INDEX idx_projects_management_no (management_no) WHERE deleted_at IS NULL
INDEX idx_projects_machine_no (machine_no)
INDEX idx_projects_kishyu (kishyu)
INDEX idx_projects_assigned_user_id (assigned_user_id)
INDEX idx_projects_shinchoku_id (shinchoku_id)
INDEX idx_projects_deadline (deadline)
INDEX idx_projects_deleted_at (deleted_at)
```

### 外部キー

```sql
FOREIGN KEY (work_category_id) REFERENCES master_work_category(id)
FOREIGN KEY (assigned_user_id) REFERENCES users(id)
FOREIGN KEY (shinchoku_id) REFERENCES master_shinchoku(id)
```

### 備考

- **management_no**: ユニーク制約（deleted_atがNULLの場合のみ）
- **full_model_name**: 自動生成（kishyu + "-" + spec_code）
- **actual_hours**: worklogsテーブルから自動集計（トリガーまたはアプリケーション側で更新）
- **deleted_at**: 論理削除（NULLの場合は有効）

---

## 3. worklogs（工数記録）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| work_date | DATE | NOT NULL | - | 作業日 |
| project_id | UUID | NOT NULL | - | 案件ID（FK: projects.id） |
| user_id | UUID | NOT NULL | - | 作業者ID（FK: users.id） |
| hours | DECIMAL(10, 2) | NOT NULL | - | 作業時間（時間） |
| description | TEXT | NULL | - | 作業内容 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_worklogs_work_date (work_date)
INDEX idx_worklogs_project_id (project_id)
INDEX idx_worklogs_user_id (user_id)
INDEX idx_worklogs_project_date (project_id, work_date)
```

### 外部キー

```sql
FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
```

### 備考

- **hours**: 15分単位（0.25時間）以上
- **ON DELETE RESTRICT**: 案件・ユーザーに紐づく工数がある場合、削除不可

---

## 4. invoices（請求書ヘッダー）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| year | INTEGER | NOT NULL | - | 対象年（YYYY） |
| month | INTEGER | NOT NULL | - | 対象月（1〜12） |
| total_projects | INTEGER | NOT NULL | - | 合計案件数 |
| total_hours | DECIMAL(10, 2) | NOT NULL | - | 合計工数（時間） |
| status | VARCHAR(20) | NOT NULL | 'draft' | ステータス（draft/closed） |
| created_by | UUID | NOT NULL | - | 確定者ID（FK: users.id） |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 確定日時 |

### インデックス

```sql
PRIMARY KEY (id)
UNIQUE INDEX idx_invoices_year_month (year, month) WHERE status = 'closed'
INDEX idx_invoices_status (status)
INDEX idx_invoices_created_by (created_by)
```

### 外部キー

```sql
FOREIGN KEY (created_by) REFERENCES users(id)
```

### 備考

- **status**: 'draft'（下書き）、'closed'（確定済み）
- **ユニーク制約**: 同じ年月で確定済み請求書は1つのみ

---

## 5. invoice_items（請求書明細）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| invoice_id | UUID | NOT NULL | - | 請求書ID（FK: invoices.id） |
| project_id | UUID | NOT NULL | - | 案件ID（FK: projects.id） |
| management_no | VARCHAR(50) | NOT NULL | - | 管理番号 |
| machine_no | VARCHAR(50) | NOT NULL | - | 機番（委託業務内容） |
| hours | DECIMAL(10, 2) | NOT NULL | - | 実工数（時間、丸め適用後） |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_invoice_items_invoice_id (invoice_id)
INDEX idx_invoice_items_project_id (project_id)
```

### 外部キー

```sql
FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
FOREIGN KEY (project_id) REFERENCES projects(id)
```

### 備考

- **hours**: 丸め設定（system_settings.rounding）適用後の値
- **ON DELETE CASCADE**: 請求書削除時に明細も削除

---

## 6. materials（資料管理）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| title | VARCHAR(200) | NOT NULL | - | 資料名 |
| scope | VARCHAR(20) | NOT NULL | - | 共有範囲（machine/model/tonnage/series） |
| series | VARCHAR(50) | NOT NULL | - | 対象シリーズ（NEX/NX/SX等） |
| tonnage | INTEGER | NULL | - | 対象トン数（140/200等、tonnage/model/machineの場合必須） |
| kishyu | VARCHAR(100) | NULL | - | 対象機種（NEX140Ⅲ等、model/machineの場合必須） |
| machine_no | VARCHAR(50) | NULL | - | 対象機番（HMX7-CN2等、machineの場合必須） |
| file_name | VARCHAR(255) | NOT NULL | - | 元ファイル名 |
| file_path | VARCHAR(500) | NOT NULL | - | ストレージ上のファイルパス |
| file_size | BIGINT | NOT NULL | - | ファイルサイズ（バイト） |
| uploaded_by | UUID | NOT NULL | - | アップロード者ID（FK: users.id） |
| uploaded_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | アップロード日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_materials_scope (scope)
INDEX idx_materials_series (series)
INDEX idx_materials_tonnage (tonnage)
INDEX idx_materials_kishyu (kishyu)
INDEX idx_materials_machine_no (machine_no)
INDEX idx_materials_uploaded_by (uploaded_by)
```

### 外部キー

```sql
FOREIGN KEY (uploaded_by) REFERENCES users(id)
```

### 備考

- **scope**: 'series'（シリーズ共通）、'tonnage'（トン数共通）、'model'（機種専用）、'machine'（機番専用）
- **file_path**: ストレージ（ローカルFS/S3/Supabase Storage）上のパス
- **file_size**: 最大100MB

---

## 7. master_chuiten（注意点マスタ）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| sequence_no | INTEGER | NOT NULL | - | 連番（ユニーク） |
| category_id | UUID | NOT NULL | - | カテゴリID（FK: master_chuiten_category.id） |
| target_series | VARCHAR(50) | NOT NULL | - | 対象シリーズ（NEX/NX/SX等） |
| target_model_pattern | VARCHAR(200) | NULL | - | 対象機種パターン（正規表現、例: NEX140.*） |
| content | TEXT | NOT NULL | - | 注意点内容 |
| created_by | VARCHAR(100) | NOT NULL | - | 作成者名 |
| remarks | TEXT | NULL | - | 備考 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |

### インデックス

```sql
PRIMARY KEY (id)
UNIQUE INDEX idx_master_chuiten_sequence_no (sequence_no)
INDEX idx_master_chuiten_category_id (category_id)
INDEX idx_master_chuiten_target_series (target_series)
```

### 外部キー

```sql
FOREIGN KEY (category_id) REFERENCES master_chuiten_category(id) ON DELETE RESTRICT
```

### 備考

- **target_model_pattern**: 正規表現パターン（例: NEX140.*）
- **ON DELETE RESTRICT**: カテゴリに紐づく注意点がある場合、カテゴリ削除不可

---

## 8. master_chuiten_category（注意点カテゴリマスタ）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| name | VARCHAR(100) | NOT NULL | - | カテゴリ名（使い方/組付/注意点等） |
| display_order | INTEGER | NOT NULL | 9999 | 表示順序 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_master_chuiten_category_display_order (display_order)
```

---

## 9. master_work_category（作業区分マスタ）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| name | VARCHAR(100) | NOT NULL | - | 区分名（盤配/線加工等） |
| display_order | INTEGER | NOT NULL | 9999 | 表示順序 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_master_work_category_display_order (display_order)
```

---

## 10. master_kishyu（機種マスタ）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| name | VARCHAR(100) | NOT NULL | - | 機種名（NEX140Ⅲ等） |
| series | VARCHAR(50) | NOT NULL | - | シリーズ（NEX/NX/SX等） |
| tonnage | INTEGER | NOT NULL | - | トン数（140/200等） |
| display_order | INTEGER | NOT NULL | 9999 | 表示順序 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_master_kishyu_series (series)
INDEX idx_master_kishyu_tonnage (tonnage)
INDEX idx_master_kishyu_display_order (display_order)
```

---

## 11. master_nounyusaki（納入先マスタ）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| name | VARCHAR(200) | NOT NULL | - | 納入先名 |
| display_order | INTEGER | NOT NULL | 9999 | 表示順序 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_master_nounyusaki_display_order (display_order)
```

---

## 12. master_shinchoku（進捗マスタ）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| name | VARCHAR(100) | NOT NULL | - | 進捗名（未着手/進行中/完了） |
| display_order | INTEGER | NOT NULL | 9999 | 表示順序 |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_master_shinchoku_display_order (display_order)
```

---

## 13. system_settings（システム設定）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| key | VARCHAR(100) | NOT NULL | - | 設定キー（rounding_method/rounding_unit等） |
| value | TEXT | NOT NULL | - | 設定値（JSON形式も可） |
| description | TEXT | NULL | - | 設定説明 |
| updated_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 更新日時 |

### インデックス

```sql
PRIMARY KEY (id)
UNIQUE INDEX idx_system_settings_key (key)
```

### 備考

- **rounding_method**: 'up'（切り上げ）、'down'（切り捨て）、'round'（四捨五入）
- **rounding_unit**: '1.0'（1時間）、'0.5'（30分）、'0.25'（15分）

---

## 14. audit_logs（監査ログ）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| timestamp | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 操作日時（UTC） |
| user_id | UUID | NULL | - | 操作者ID（FK: users.id、ログアウト後はNULL可） |
| action | VARCHAR(50) | NOT NULL | - | 操作種別（CREATE/UPDATE/DELETE/LOGIN/LOGOUT） |
| entity_type | VARCHAR(100) | NULL | - | 対象エンティティ（projects/worklogs/invoices等） |
| entity_id | UUID | NULL | - | 対象レコードID |
| old_value | JSONB | NULL | - | 変更前の値（JSON形式、UPDATE操作時のみ） |
| new_value | JSONB | NULL | - | 変更後の値（JSON形式、CREATE/UPDATE操作時のみ） |
| ip_address | VARCHAR(45) | NULL | - | クライアントIPアドレス（IPv4/IPv6） |
| user_agent | TEXT | NULL | - | ユーザーエージェント（ブラウザ情報） |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_audit_logs_timestamp (timestamp)
INDEX idx_audit_logs_user_id (user_id)
INDEX idx_audit_logs_action (action)
INDEX idx_audit_logs_entity_type (entity_type)
INDEX idx_audit_logs_entity_id (entity_id)
```

### 外部キー

```sql
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
```

### 備考

- **timestamp**: UTC形式で記録
- **old_value/new_value**: JSONB形式（PostgreSQLの場合）またはJSON/TEXT形式
- **ON DELETE SET NULL**: ユーザー削除時にuser_idをNULLに設定

---

## 15. backups（バックアップ管理）

### カラム定義

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | auto | 主キー |
| name | VARCHAR(200) | NOT NULL | - | バックアップ名 |
| description | TEXT | NULL | - | 説明 |
| backup_type | VARCHAR(20) | NOT NULL | - | バックアップ種別（full/partial） |
| tables | JSONB | NOT NULL | - | 対象テーブル一覧（JSON配列） |
| file_path | VARCHAR(500) | NOT NULL | - | バックアップファイルパス |
| file_size | BIGINT | NOT NULL | - | ファイルサイズ（バイト） |
| status | VARCHAR(20) | NOT NULL | 'in_progress' | ステータス（in_progress/completed/failed） |
| created_by | UUID | NOT NULL | - | 作成者ID（FK: users.id） |
| created_at | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | 作成日時 |
| restored_at | TIMESTAMP | NULL | - | 復旧日時 |
| restored_by | UUID | NULL | - | 復旧者ID（FK: users.id） |

### インデックス

```sql
PRIMARY KEY (id)
INDEX idx_backups_status (status)
INDEX idx_backups_created_by (created_by)
INDEX idx_backups_created_at (created_at)
```

### 外部キー

```sql
FOREIGN KEY (created_by) REFERENCES users(id)
FOREIGN KEY (restored_by) REFERENCES users(id)
```

### 備考

- **backup_type**: 'full'（全体バックアップ）、'partial'（部分バックアップ）
- **tables**: JSON配列（例: ["users", "projects", "worklogs"]）
- **file_path**: backend/backups/ディレクトリ内のファイルパス
- **status**: 'in_progress'（実行中）、'completed'（完了）、'failed'（失敗）

---

## トリガー/ストアドプロシージャ候補

### 1. projects.actual_hours の自動更新

**トリガー**: worklogsテーブルのINSERT/UPDATE/DELETEで`projects.actual_hours`を自動更新

```sql
-- PostgreSQLの例
CREATE OR REPLACE FUNCTION update_project_actual_hours()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE projects
  SET actual_hours = (
    SELECT COALESCE(SUM(hours), 0)
    FROM worklogs
    WHERE project_id = NEW.project_id OR project_id = OLD.project_id
  ),
  updated_at = CURRENT_TIMESTAMP
  WHERE id = NEW.project_id OR id = OLD.project_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_project_actual_hours
AFTER INSERT OR UPDATE OR DELETE ON worklogs
FOR EACH ROW
EXECUTE FUNCTION update_project_actual_hours();
```

### 2. audit_logs の自動記録

**トリガー**: projects/worklogs/invoices等のCRUD操作で自動的にaudit_logsに記録

（実装はミドルウェアまたはトリガーで対応）

---

## 初期データ

### master_shinchoku（進捗マスタ）

```sql
INSERT INTO master_shinchoku (id, name, display_order) VALUES
('uuid-1', '未着手', 1),
('uuid-2', '進行中', 2),
('uuid-3', '完了', 3);
```

### master_chuiten_category（注意点カテゴリマスタ）

```sql
INSERT INTO master_chuiten_category (id, name, display_order) VALUES
('uuid-1', '使い方', 1),
('uuid-2', '組付', 2),
('uuid-3', '注意点', 3),
('uuid-4', 'チェック項目', 4),
('uuid-5', 'トラブルシューティング', 5);
```

### system_settings（システム設定）

```sql
INSERT INTO system_settings (id, key, value, description) VALUES
('uuid-1', 'rounding_method', 'up', '工数丸め方法（up/down/round）'),
('uuid-2', 'rounding_unit', '1.0', '工数丸め単位（1.0/0.5/0.25）');
```

---

## バックアップ・復旧

- **バックアップ形式**: JSON形式でテーブルデータをエクスポート
- **バックアップ対象**: 全14テーブル（または指定テーブル）
- **復旧処理**: トランザクション処理で全テーブルをリストア
- **最大ファイルサイズ**: 500MB

---

## パフォーマンス最適化

### ページネーション

- `LIMIT`と`OFFSET`を使用（または`CURSOR`ベースページネーション）
- デフォルト20件/ページ、最大100件/ページ

### インデックス戦略

- 頻繁に検索されるカラムにインデックスを作成
- 複合インデックス（例: `project_id, work_date`）で検索性能向上
- 論理削除フィールド（`deleted_at`）にインデックス

### クエリ最適化

- N+1問題を避けるため、JOIN/サブクエリを適切に使用
- 集計クエリは必要に応じてマテリアライズドビュー検討

---

## セキュリティ対策

- **パスワードハッシュ**: bcrypt/argon2等の安全なアルゴリズム
- **SQLインジェクション対策**: プリペアドステートメント使用
- **パストラバーサル対策**: ファイルパスを検証
- **CSVインジェクション対策**: CSV出力時に特殊文字をエスケープ

---

## マイグレーション戦略

- **ツール**: 未定（Phase 0.2で決定、Alembic/Prisma Migrate/Flyway等を検討）
- **バージョン管理**: マイグレーションファイルをGitで管理
- **ロールバック**: 各マイグレーションにロールバックスクリプトを用意
