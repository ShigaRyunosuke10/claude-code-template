# 命名規則・コミット規約

## 命名規則

### ファイル・ディレクトリ

**フロントエンド（Next.js）**:
- ページコンポーネント: `kebab-case` (例: `user-profile.tsx`)
- 再利用コンポーネント: `PascalCase` (例: `UserCard.tsx`)
- ユーティリティ: `camelCase` (例: `formatDate.ts`)

**バックエンド（FastAPI）**:
- すべて `snake_case` (例: `user_router.py`, `user_model.py`)

### 変数・関数

**TypeScript/JavaScript**:
- 変数: `camelCase` (例: `userName`, `totalCount`)
- 定数: `UPPER_SNAKE_CASE` (例: `API_BASE_URL`)
- 関数: `camelCase` (例: `getUserData`)
- クラス: `PascalCase` (例: `UserService`)

**Python**:
- 変数: `snake_case` (例: `user_name`, `total_count`)
- 定数: `UPPER_SNAKE_CASE` (例: `API_BASE_URL`)
- 関数: `snake_case` (例: `get_user_data`)
- クラス: `PascalCase` (例: `UserService`)

### APIエンドポイント

- リソース名: 複数形の名詞
- パス: `kebab-case`（小文字）
- 動詞は使わない（HTTPメソッドで表現）

**例**:
```
GET    /api/users              # ユーザー一覧
GET    /api/users/{id}         # 特定ユーザー
POST   /api/users              # ユーザー作成
PUT    /api/users/{id}         # ユーザー更新
DELETE /api/users/{id}         # ユーザー削除

GET    /api/projects/{id}/work-logs        # ネストされたリソース
POST   /api/auth/login                     # アクション
```

### データベース

**テーブル名**: 複数形 + `snake_case`
- 例: `users`, `projects`, `work_logs`

**カラム名**: `snake_case`
- 例: `user_id`, `created_at`, `is_active`
- 主キー: `id` (UUID推奨)
- 外部キー: `<テーブル名単数形>_id` (例: `user_id`)
- タイムスタンプ: `created_at`, `updated_at`

### 環境変数

- **形式**: `UPPER_SNAKE_CASE`
- **値にクォートは付けない**

**例**:
```env
DATABASE_URL=postgresql://localhost:5432/mydb
API_BASE_URL=http://localhost:8000
JWT_SECRET_KEY=your-secret-key
```

### ブランチ名

```
feat-<機能名>        # 新機能
fix-<修正内容>       # バグ修正
refactor-<対象>      # リファクタリング
docs-<内容>          # ドキュメント
```

## コミットメッセージ規約

### 基本フォーマット

```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Type（必須）

- `feat`: 新機能追加
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `refactor`: バグ修正や機能追加を含まないコードの変更
- `test`: テストの追加・修正
- `chore`: ビルドプロセスやツールの変更

### Subject（必須）

- 50文字以内
- 日本語で簡潔に記述
- 命令形（「〜を追加」「〜を修正」）
- 末尾にピリオドを付けない

### Body（任意）

- 詳細な変更内容
- 変更理由
- 影響範囲

---

## ドキュメント管理規約

### CLAUDE.md の記載ルール

**CLAUDE.mdは最低限のルールと参照先のみ記載する**

#### ✅ 記載すべき内容
- **基本設定**: プロジェクト名、リポジトリ、ポート、回答言語
- **最低限のルール**: タスク管理（TodoWrite必須）、要件変更フロー、ユーザー介入条件
- **参照先リンク**: 詳細はai-rules/、.claude/配下のファイルへのリンク
- **MCPサーバー一覧**: テンプレート標準搭載、技術スタック依存（詳細は別ファイル）
- **エージェント一覧**: カテゴリ別概要（詳細は.claude/agents/README.md）

#### ❌ 記載すべきでない内容
- **詳細な手順**: Phase実行フロー詳細、エージェント実装詳細等
- **フォルダ構成の詳細**: docs/の使い方、ディレクトリツリー等
- **プロジェクト固有設定の例**: 具体例は別ファイルに切り出す
- **長いコードブロック**: 10行以上のコードブロックは別ファイル

#### 目安
- **全体**: 150行以内（現状346行 → 150行に削減）
- **1セクション**: 10-20行程度
- **参照リンク**: 詳細は必ず別ファイルへのリンクを記載

#### 切り出し先ファイル
- **プロジェクト資料フォルダ**: [DOCS_FOLDER_GUIDE.md](./DOCS_FOLDER_GUIDE.md)
- **Phase実行フロー**: [PHASE_START.md](./PHASE_START.md)、[WORKFLOW.md](./WORKFLOW.md)
- **エージェント一覧**: [.claude/agents/README.md](../.claude/agents/README.md)
- **プロジェクト固有設定**: [PROJECT_CUSTOMIZATION.md](./PROJECT_CUSTOMIZATION.md)
- **環境変数設定**: [ENV_SETUP_GUIDE.md](./ENV_SETUP_GUIDE.md)
- **Codex相談**: [CODEX_CONSULTATION.md](./CODEX_CONSULTATION.md)

#### 理由
- **可読性向上**: 短く簡潔なCLAUDE.mdはプロジェクト全体を素早く把握できる
- **保守性向上**: 詳細は専門ファイルに集約、修正が容易
- **重複排除**: 同じ内容を複数ファイルに記載しない

