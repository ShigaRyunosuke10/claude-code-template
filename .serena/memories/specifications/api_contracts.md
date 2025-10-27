# Nissei 工数管理システム - API契約仕様

**Version**: 1.0  
**Last Updated**: 2025-10-27  
**Base URL**: `/api` (未定、Phase 0.2で決定)

---

## 認証方式

- **方式**: トークンベース認証（JWT等、Phase 0.2で決定）
- **トークン有効期限**: 30分
- **ヘッダー**: `Authorization: Bearer <token>`

---

## 共通レスポンス形式

### 成功レスポンス
```json
{
  "status": "success",
  "data": { ... }
}
```

### エラーレスポンス
```json
{
  "status": "error",
  "message": "エラーメッセージ",
  "details": { ... } // オプション
}
```

---

## 1. 認証API

### 1.1 ユーザー登録
- **エンドポイント**: `POST /api/register`
- **認証**: 不要
- **リクエストボディ**:
```json
{
  "name": "山田太郎",
  "email": "yamada@example.com",
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!"
}
```
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "ユーザー登録が完了しました"
  }
}
```
- **エラーケース**:
  - 400: バリデーションエラー（パスワード強度不足、メール形式エラー等）
  - 409: メールアドレス重複

### 1.2 ログイン
- **エンドポイント**: `POST /api/login`
- **認証**: 不要
- **リクエストボディ**:
```json
{
  "email": "yamada@example.com",
  "password": "SecurePassword123!"
}
```
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid",
      "name": "山田太郎",
      "email": "yamada@example.com",
      "is_admin": false,
      "is_active": true
    }
  }
}
```
- **エラーケース**:
  - 401: 認証失敗（メールアドレスまたはパスワードが正しくありません）
  - 403: アカウント無効

### 1.3 現在のユーザー情報取得
- **エンドポイント**: `GET /api/me`
- **認証**: 必要
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "name": "山田太郎",
    "email": "yamada@example.com",
    "is_admin": false,
    "is_active": true
  }
}
```
- **エラーケース**:
  - 401: 認証エラー（トークン無効または期限切れ）

---

## 2. 案件管理API

### 2.1 案件一覧取得
- **エンドポイント**: `GET /api/projects`
- **認証**: 必要
- **クエリパラメータ**:
  - `page`: ページ番号（デフォルト: 1）
  - `per_page`: 1ページあたりの件数（デフォルト: 20、最大: 100）
  - `keyword`: 検索キーワード（管理番号・機番・機種を部分一致検索）
  - `assigned_user_id`: 担当者でフィルタ
  - `shinchoku_id`: 進捗でフィルタ
  - `overdue`: 期限切れのみ表示（true/false）
  - `sort_by`: ソートカラム（management_no/machine_no/kishyu/shinchoku/estimated_hours/actual_hours/deadline）
  - `sort_order`: ソート順（asc/desc）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "projects": [
      {
        "id": "uuid",
        "management_no": "E252019",
        "machine_no": "HMX7-CN2",
        "kishyu": "NEX140Ⅲ",
        "spec_code": "24AK",
        "full_model_name": "NEX140Ⅲ-24AK",
        "work_category": { "id": "uuid", "name": "盤配" },
        "assigned_user": { "id": "uuid", "name": "山田太郎" },
        "shinchoku": { "id": "uuid", "name": "進行中" },
        "estimated_hours": 50.0,
        "actual_hours": 45.5,
        "deadline": "2025-02-15",
        "remarks": "備考",
        "created_at": "2025-01-15T10:00:00Z",
        "updated_at": "2025-01-20T15:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_items": 123,
      "total_pages": 7
    }
  }
}
```

### 2.2 案件作成
- **エンドポイント**: `POST /api/projects`
- **認証**: 必要
- **リクエストボディ**:
```json
{
  "management_no": "E252019",
  "machine_no": "HMX7-CN2",
  "kishyu": "NEX140Ⅲ",
  "spec_code": "24AK",
  "work_category_id": "uuid",
  "assigned_user_id": "uuid",
  "shinchoku_id": "uuid",
  "estimated_hours": 50.0,
  "deadline": "2025-02-15",
  "remarks": "備考"
}
```
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "management_no": "E252019",
    "full_model_name": "NEX140Ⅲ-24AK",
    ...
  }
}
```
- **エラーケース**:
  - 400: バリデーションエラー
  - 409: 管理番号重複

### 2.3 案件詳細取得
- **エンドポイント**: `GET /api/projects/{id}`
- **認証**: 必要
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "management_no": "E252019",
    "machine_no": "HMX7-CN2",
    "kishyu": "NEX140Ⅲ",
    "spec_code": "24AK",
    "full_model_name": "NEX140Ⅲ-24AK",
    "work_category": { "id": "uuid", "name": "盤配" },
    "assigned_user": { "id": "uuid", "name": "山田太郎" },
    "shinchoku": { "id": "uuid", "name": "進行中" },
    "estimated_hours": 50.0,
    "actual_hours": 45.5,
    "deadline": "2025-02-15",
    "remarks": "備考",
    "created_at": "2025-01-15T10:00:00Z",
    "updated_at": "2025-01-20T15:30:00Z",
    "worklog_summary": {
      "total_hours": 45.5,
      "progress_rate": 91.0,
      "recent_7days": [
        { "date": "2025-01-20", "hours": 8.0 },
        { "date": "2025-01-19", "hours": 7.5 }
      ]
    },
    "related_worklogs": [
      {
        "id": "uuid",
        "work_date": "2025-01-20",
        "user": { "id": "uuid", "name": "山田太郎" },
        "hours": 8.0,
        "description": "配線図作成"
      }
    ],
    "related_materials": [
      {
        "id": "uuid",
        "title": "NEX140Ⅲ設計資料",
        "scope": "model",
        "file_name": "nex140iii_design.pdf"
      }
    ],
    "related_chuiten": [
      {
        "id": "uuid",
        "category": "注意点",
        "content": "配線時は必ず電源を切ること"
      }
    ]
  }
}
```
- **エラーケース**:
  - 404: 案件が見つからない

### 2.4 案件更新
- **エンドポイント**: `PUT /api/projects/{id}`
- **認証**: 必要
- **リクエストボディ**: 案件作成と同じ（全フィールドまたは一部フィールド）
- **レスポンス**: 更新後の案件データ
- **エラーケース**:
  - 400: バリデーションエラー
  - 404: 案件が見つからない
  - 409: 管理番号重複

### 2.5 案件削除（論理削除）
- **エンドポイント**: `DELETE /api/projects/{id}`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "案件を削除しました"
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ削除可能）
  - 404: 案件が見つからない

---

## 3. 工数管理API

### 3.1 工数一覧取得
- **エンドポイント**: `GET /api/worklogs`
- **認証**: 必要
- **クエリパラメータ**:
  - `page`: ページ番号
  - `per_page`: 1ページあたりの件数
  - `start_date`: 開始日（YYYY-MM-DD）
  - `end_date`: 終了日（YYYY-MM-DD）
  - `project_id`: 案件でフィルタ
  - `user_id`: 担当者でフィルタ
  - `sort_by`: ソートカラム（work_date/hours）
  - `sort_order`: ソート順（asc/desc、デフォルト: desc）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "worklogs": [
      {
        "id": "uuid",
        "work_date": "2025-01-20",
        "project": {
          "id": "uuid",
          "management_no": "E252019",
          "full_model_name": "NEX140Ⅲ-24AK"
        },
        "user": { "id": "uuid", "name": "山田太郎" },
        "hours": 8.0,
        "description": "配線図作成",
        "created_at": "2025-01-20T17:00:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

### 3.2 工数作成
- **エンドポイント**: `POST /api/worklogs`
- **認証**: 必要
- **リクエストボディ**:
```json
{
  "work_date": "2025-01-20",
  "project_id": "uuid",
  "hours": 8.0,
  "description": "配線図作成"
}
```
- **レスポンス**: 作成された工数データ
- **エラーケース**:
  - 400: バリデーションエラー（作業時間1分未満等）

### 3.3 工数更新
- **エンドポイント**: `PUT /api/worklogs/{id}`
- **認証**: 必要
- **リクエストボディ**: 工数作成と同じ
- **レスポンス**: 更新後の工数データ
- **エラーケース**:
  - 400: バリデーションエラー
  - 404: 工数が見つからない

### 3.4 工数削除
- **エンドポイント**: `DELETE /api/worklogs/{id}`
- **認証**: 必要
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "工数を削除しました"
  }
}
```
- **エラーケース**:
  - 404: 工数が見つからない

### 3.5 工数CSV出力
- **エンドポイント**: `GET /api/worklogs/csv`
- **認証**: 必要
- **クエリパラメータ**: 工数一覧取得と同じフィルタ
- **レスポンス**: CSVファイル（BOM付きUTF-8、カンマ区切り）
- **ヘッダー**: 作業日, 管理番号, 機種, 担当者, 作業時間, 作業内容

---

## 4. 請求書管理API

### 4.1 請求プレビュー
- **エンドポイント**: `GET /api/invoices/preview`
- **認証**: 必要（管理者のみ）
- **クエリパラメータ**:
  - `year`: 年（YYYY）
  - `month`: 月（1〜12）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "year": 2025,
    "month": 1,
    "total_projects": 15,
    "total_hours": 320.5,
    "items": [
      {
        "project_id": "uuid",
        "management_no": "E252019",
        "machine_no": "HMX7-CN2",
        "hours": 45.5
      }
    ]
  }
}
```

### 4.2 請求確定
- **エンドポイント**: `POST /api/invoices`
- **認証**: 必要（管理者のみ）
- **リクエストボディ**:
```json
{
  "year": 2025,
  "month": 1
}
```
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "id": "uuid",
    "year": 2025,
    "month": 1,
    "total_projects": 15,
    "total_hours": 320.5,
    "status": "closed",
    "created_by": { "id": "uuid", "name": "管理者" },
    "created_at": "2025-02-01T10:00:00Z"
  }
}
```
- **エラーケース**:
  - 409: 同じ年月の請求書が既に確定済み

### 4.3 請求書一覧取得
- **エンドポイント**: `GET /api/invoices`
- **認証**: 必要（管理者のみ）
- **クエリパラメータ**:
  - `page`: ページ番号
  - `per_page`: 1ページあたりの件数
  - `sort_order`: ソート順（デフォルト: desc）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "invoices": [
      {
        "id": "uuid",
        "year": 2025,
        "month": 1,
        "total_projects": 15,
        "total_hours": 320.5,
        "status": "closed",
        "created_by": { "id": "uuid", "name": "管理者" },
        "created_at": "2025-02-01T10:00:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

### 4.4 請求書CSV出力
- **エンドポイント**: `GET /api/invoices/csv`
- **認証**: 必要（管理者のみ）
- **クエリパラメータ**:
  - `year`: 年（YYYY）
  - `month`: 月（1〜12）
- **レスポンス**: CSVファイル（BOM付きUTF-8、カンマ区切り、CSVインジェクション対策済み）
- **ヘッダー**: 管理番号, 委託業務内容, 実工数
- **エラーケース**:
  - 404: 該当月の請求書が見つからない

---

## 5. 資料管理API

### 5.1 資料一覧取得
- **エンドポイント**: `GET /api/materials`
- **認証**: 必要
- **クエリパラメータ**:
  - `scope`: スコープでフィルタ（machine/model/tonnage/series）
  - `series`: シリーズでフィルタ（NEX/NX/SX等）
  - `tonnage`: トン数でフィルタ
  - `machine_no`: 機番でフィルタ
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "materials": [
      {
        "id": "uuid",
        "title": "NEX140Ⅲ設計資料",
        "scope": "model",
        "series": "NEX",
        "tonnage": 140,
        "kishyu": "NEX140Ⅲ",
        "machine_no": null,
        "file_name": "nex140iii_design.pdf",
        "uploaded_by": { "id": "uuid", "name": "山田太郎" },
        "uploaded_at": "2025-01-15T10:00:00Z"
      }
    ]
  }
}
```

### 5.2 資料アップロード
- **エンドポイント**: `POST /api/materials`
- **認証**: 必要
- **リクエスト**: Multipart form-data
  - `title`: タイトル（必須）
  - `scope`: スコープ（必須、machine/model/tonnage/series）
  - `series`: シリーズ（必須）
  - `tonnage`: トン数（条件付き必須）
  - `kishyu`: 機種（条件付き必須）
  - `machine_no`: 機番（条件付き必須）
  - `file`: ファイル（必須、最大100MB）
- **レスポンス**: 作成された資料データ
- **エラーケース**:
  - 400: バリデーションエラー（ファイルサイズ超過等）

### 5.3 資料ダウンロード
- **エンドポイント**: `GET /api/materials/{id}`
- **認証**: 必要
- **レスポンス**: ファイルストリーム
- **エラーケース**:
  - 404: 資料が見つからない

### 5.4 資料削除
- **エンドポイント**: `DELETE /api/materials/{id}`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "資料を削除しました"
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ削除可能）
  - 404: 資料が見つからない

---

## 6. 注意点管理API

### 6.1 注意点一覧取得
- **エンドポイント**: `GET /api/chuiten`
- **認証**: 必要
- **クエリパラメータ**:
  - `category_id`: カテゴリでフィルタ
  - `series`: シリーズでフィルタ
  - `keyword`: 注意点内容を部分一致検索
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "chuiten": [
      {
        "id": "uuid",
        "sequence_no": 1,
        "category": { "id": "uuid", "name": "注意点" },
        "target_series": "NEX",
        "target_model_pattern": "NEX140.*",
        "content": "配線時は必ず電源を切ること",
        "created_by": "山田太郎",
        "remarks": "備考"
      }
    ]
  }
}
```

### 6.2 注意点作成
- **エンドポイント**: `POST /api/chuiten`
- **認証**: 必要（管理者のみ）
- **リクエストボディ**:
```json
{
  "sequence_no": 1,
  "category_id": "uuid",
  "target_series": "NEX",
  "target_model_pattern": "NEX140.*",
  "content": "配線時は必ず電源を切ること",
  "created_by": "山田太郎",
  "remarks": "備考"
}
```
- **レスポンス**: 作成された注意点データ
- **エラーケース**:
  - 400: バリデーションエラー
  - 403: 権限エラー（管理者のみ作成可能）
  - 409: 連番重複

---

## 7. マスタ管理API

### 7.1 マスタ一覧取得（汎用）
- **エンドポイント**: `GET /api/masters/{type}`
- **認証**: 必要
- **パスパラメータ**: `type` - work-category/kishyu/nounyusaki/shinchoku
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "masters": [
      {
        "id": "uuid",
        "name": "盤配",
        "display_order": 1,
        "created_at": "2025-01-15T10:00:00Z",
        "updated_at": "2025-01-15T10:00:00Z"
      }
    ]
  }
}
```

### 7.2 マスタ作成
- **エンドポイント**: `POST /api/masters/{type}`
- **認証**: 必要（管理者のみ）
- **リクエストボディ**:
```json
{
  "name": "盤配",
  "display_order": 1,
  "series": "NEX",      // 機種マスタの場合のみ
  "tonnage": 140        // 機種マスタの場合のみ
}
```
- **レスポンス**: 作成されたマスタデータ
- **エラーケース**:
  - 400: バリデーションエラー
  - 403: 権限エラー（管理者のみ作成可能）

### 7.3 マスタ更新
- **エンドポイント**: `PUT /api/masters/{type}/{id}`
- **認証**: 必要（管理者のみ）
- **リクエストボディ**: マスタ作成と同じ
- **レスポンス**: 更新後のマスタデータ
- **エラーケース**:
  - 400: バリデーションエラー
  - 403: 権限エラー（管理者のみ更新可能）
  - 404: マスタが見つからない

### 7.4 マスタ削除
- **エンドポイント**: `DELETE /api/masters/{type}/{id}`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "マスタを削除しました"
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ削除可能）
  - 404: マスタが見つからない
  - 409: 他のテーブルから参照されている（外部キー制約）

---

## 8. 集計・分析API

### 8.1 日次集計
- **エンドポイント**: `GET /api/aggregations/daily`
- **認証**: 必要
- **クエリパラメータ**:
  - `start_date`: 開始日（YYYY-MM-DD）
  - `end_date`: 終了日（YYYY-MM-DD）
  - `user_id`: 特定ユーザーのみ集計（任意）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "daily_aggregations": [
      {
        "date": "2025-01-15",
        "total_hours": 45.5,
        "project_count": 10
      }
    ]
  }
}
```

### 8.2 月次集計
- **エンドポイント**: `GET /api/aggregations/monthly`
- **認証**: 必要
- **クエリパラメータ**:
  - `year_month`: 年月（YYYY-MM）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "year_month": "2025-01",
    "project_aggregations": [
      {
        "project_id": "uuid",
        "management_no": "E252019",
        "full_model_name": "NEX140Ⅲ-24AK",
        "total_hours": 45.5,
        "worklog_count": 12
      }
    ],
    "total_hours": 320.5
  }
}
```

---

## 9. 監査ログAPI

### 9.1 監査ログ一覧取得
- **エンドポイント**: `GET /api/audit-logs`
- **認証**: 必要（管理者のみ）
- **クエリパラメータ**:
  - `page`: ページ番号
  - `per_page`: 1ページあたりの件数（デフォルト: 50、最大: 100）
  - `user_id`: ユーザーでフィルタ
  - `action`: 操作種別でフィルタ（CREATE/UPDATE/DELETE/LOGIN/LOGOUT）
  - `entity_type`: 対象エンティティでフィルタ（projects/worklogs/invoices等）
  - `start_date`: 開始日
  - `end_date`: 終了日
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "audit_logs": [
      {
        "id": "uuid",
        "timestamp": "2025-01-20T15:30:00Z",
        "user": { "id": "uuid", "name": "山田太郎", "email": "yamada@example.com" },
        "action": "UPDATE",
        "entity_type": "projects",
        "entity_id": "uuid",
        "ip_address": "192.168.1.1",
        "user_agent": "Mozilla/5.0 ..."
      }
    ],
    "pagination": { ... }
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみアクセス可能）

### 9.2 監査ログCSV出力
- **エンドポイント**: `GET /api/audit-logs/csv`
- **認証**: 必要（管理者のみ）
- **クエリパラメータ**: 監査ログ一覧取得と同じフィルタ
- **レスポンス**: CSVファイル（BOM付きUTF-8、カンマ区切り）
- **ヘッダー**: 日時, ユーザー名, メールアドレス, 操作, 対象, エンティティID, IPアドレス, ユーザーエージェント

---

## 10. バックアップ・復旧API

### 10.1 バックアップ作成
- **エンドポイント**: `POST /api/backups`
- **認証**: 必要（管理者のみ）
- **リクエストボディ**:
```json
{
  "name": "2025年1月末バックアップ",
  "description": "月次バックアップ",
  "backup_type": "full",
  "tables": [] // partial の場合はテーブル一覧を指定
}
```
- **レスポンス**: 作成されたバックアップデータ
- **エラーケース**:
  - 400: バリデーションエラー
  - 403: 権限エラー（管理者のみ作成可能）

### 10.2 バックアップ一覧取得
- **エンドポイント**: `GET /api/backups`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "backups": [
      {
        "id": "uuid",
        "name": "2025年1月末バックアップ",
        "description": "月次バックアップ",
        "backup_type": "full",
        "tables": ["users", "projects", "worklogs", ...],
        "file_size": 1024000,
        "status": "completed",
        "created_by": { "id": "uuid", "name": "管理者" },
        "created_at": "2025-02-01T10:00:00Z",
        "restored_at": null,
        "restored_by": null
      }
    ]
  }
}
```

### 10.3 データ復旧
- **エンドポイント**: `POST /api/backups/{id}/restore`
- **認証**: 必要（管理者のみ）
- **リクエストボディ**:
```json
{
  "tables": [] // 未指定で全テーブル復旧、指定時は部分復旧
}
```
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "データを復旧しました",
    "restored_tables": ["users", "projects", ...]
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ復旧可能）
  - 404: バックアップが見つからない

### 10.4 バックアップ削除
- **エンドポイント**: `DELETE /api/backups/{id}`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "バックアップを削除しました"
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ削除可能）
  - 404: バックアップが見つからない

---

## 11. 管理者機能API

### 11.1 全ユーザー一覧取得
- **エンドポイント**: `GET /api/admin/users`
- **認証**: 必要（管理者のみ）
- **クエリパラメータ**:
  - `is_active`: アカウント状態でフィルタ（true/false）
  - `is_admin`: 管理者権限でフィルタ（true/false）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "users": [
      {
        "id": "uuid",
        "name": "山田太郎",
        "email": "yamada@example.com",
        "is_admin": false,
        "is_active": true,
        "created_at": "2025-01-15T10:00:00Z",
        "last_login": "2025-01-20T09:00:00Z"
      }
    ]
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみアクセス可能）

### 11.2 ユーザー有効化
- **エンドポイント**: `POST /api/admin/users/{id}/activate`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "ユーザーを有効化しました"
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ実行可能）
  - 404: ユーザーが見つからない

### 11.3 ユーザー無効化
- **エンドポイント**: `POST /api/admin/users/{id}/deactivate`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "ユーザーを無効化しました"
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ実行可能）
  - 404: ユーザーが見つからない

### 11.4 ユーザー削除
- **エンドポイント**: `DELETE /api/admin/users/{id}`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "message": "ユーザーを削除しました"
  }
}
```
- **エラーケース**:
  - 403: 権限エラー（管理者のみ削除可能）
  - 404: ユーザーが見つからない
  - 409: 工数データ等が紐づいている（外部キー制約）

---

## 12. システム設定API

### 12.1 丸め設定取得
- **エンドポイント**: `GET /api/settings/rounding`
- **認証**: 必要（管理者のみ）
- **レスポンス**:
```json
{
  "status": "success",
  "data": {
    "rounding_method": "up",
    "rounding_unit": 1.0
  }
}
```

### 12.2 丸め設定更新
- **エンドポイント**: `PUT /api/settings/rounding`
- **認証**: 必要（管理者のみ）
- **リクエストボディ**:
```json
{
  "rounding_method": "up",
  "rounding_unit": 1.0
}
```
- **レスポンス**: 更新後の設定データ
- **エラーケース**:
  - 400: バリデーションエラー
  - 403: 権限エラー（管理者のみ更新可能）

---

## HTTPステータスコード一覧

| コード | 説明 | 使用例 |
|--------|------|--------|
| 200 | OK | 正常レスポンス（GET/PUT） |
| 201 | Created | リソース作成成功（POST） |
| 204 | No Content | 削除成功（DELETE） |
| 400 | Bad Request | バリデーションエラー |
| 401 | Unauthorized | 認証エラー（トークン無効/期限切れ） |
| 403 | Forbidden | 権限エラー（管理者のみアクセス可能な操作） |
| 404 | Not Found | リソースが見つからない |
| 409 | Conflict | 重複エラー（管理番号重複、請求書重複等） |
| 500 | Internal Server Error | サーバーエラー |

---

## セキュリティ対策

- **CSRFトークン**: POST/PUT/DELETEリクエストにはCSRFトークンを含める（実装方法はPhase 0.2で決定）
- **CORS**: 許可されたオリジンのみアクセス可能
- **レート制限**: 1分間に60リクエストまで（実装方法はPhase 0.2で決定）
- **CSVインジェクション対策**: CSV出力時に`=`, `+`, `-`, `@`で始まる値を自動エスケープ
- **パストラバーサル対策**: ファイルパスを検証、許可されたディレクトリ外へのアクセスを拒否
