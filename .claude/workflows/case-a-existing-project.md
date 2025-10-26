# Case A: 既存プロジェクト機能拡張ワークフロー

既存プロジェクトに新機能を追加する際のエージェント連携フロー。

## Phase 0: 要件ヒアリング（メインClaude Agent担当）

**重要**: ワークフローを実行する前に、あなた（メインClaude Agent）が以下をユーザーに質問してください。

### 要件ヒアリング項目

1. **追加したい機能は何ですか？**（具体的に）
2. **想定ユーザーは誰ですか？**（管理者/一般ユーザー/etc.）
3. **既存機能との関連は？**（独立/既存機能拡張）
4. **優先度は？**（高/中/低）
5. **期限はありますか？**

### 回答例
```
1. 機能: ユーザーロール管理機能（管理者がユーザーに役割を割り当てる）
2. 想定ユーザー: 管理者
3. 既存機能との関連: 既存ユーザー管理の拡張
4. 優先度: 高
5. 期限: 2週間後
```

---

## Phase 1: 要件定義・計画（Planning）

### 1.1 統合計画（Epic + タスク分解 + API契約）

**エージェント**: `planner`（旧 project-planner + sub-planner 統合）

```bash
Task:planner(prompt: "ユーザーロール管理機能を追加したい")
```

**出力**: `epic-user-role-management.md`
- Epic分解（3-5個のストーリー）
- 優先度設定・マイルストーン策定
- タスクごとのDoD
- API契約（FE/BE）
- 依存関係マップ

**依存関係**: なし

**stop条件**: タスク数 > 20件で警告（分割推奨）

---

## Phase 2: 実装（Implementation）

### 2.1 バックエンド実装

**エージェント**: `impl-dev-backend`
**依存**: `sub-planner`完了後

```bash
Task:impl-dev-backend(prompt: "Task 1: usersテーブルにroleカラム追加")
Task:impl-dev-backend(prompt: "Task 2: ユーザーロール取得API実装")
```

**編集スコープ**: `backend/**`のみ
**出力**: 
- `backend/app/api/users.py` - エンドポイント
- `backend/app/models.py` - モデル更新
- `backend/tests/unit/test_users.py` - ユニットテスト

**stop条件**: pytest失敗 > 0件で停止

### 2.2 フロントエンド実装

**エージェント**: `impl-dev-frontend`
**依存**: `impl-dev-backend`のAPI完成後

```bash
Task:impl-dev-frontend(prompt: "Task 3: ユーザーロール表示UI実装")
```

**編集スコープ**: `frontend/**`のみ
**出力**:
- `frontend/src/app/users/[id]/page.tsx` - ページ
- `frontend/src/lib/api/users.ts` - APIクライアント
- `frontend/src/components/RoleBadge.tsx` - コンポーネント

**stop条件**: ESLintエラー > 0件で停止

### 2.3 FE/BE統合チェック

**エージェント**: `code-reviewer`（integrator機能を統合）
**依存**: `impl-dev-frontend` + `impl-dev-backend`完了後

```bash
Task:code-reviewer(prompt: "ユーザーロールAPIの整合性チェック - FE/BE型定義同期確認")
```

**出力**: `integration-report.md`
- API契約一致確認
- 型定義同期（TypeScript ↔ Pydantic）
- 不整合修正提案

**stop条件**: Critical不整合 > 0件で停止

---

## Phase 3: テスト（Testing）

### 3.1 ユニットテスト

**エージェント**: `qa-unit`
**依存**: 実装完了後

```bash
# 並列実行
Task:qa-unit(prompt: "get_user_role関数のユニットテスト作成")
Task:qa-unit(prompt: "RoleBadgeコンポーネントのテスト作成")
```

**目標**: カバレッジ100%（ビジネスロジック）

**stop条件**: カバレッジ < 90%で警告

### 3.2 統合テスト

**エージェント**: `qa-integration`
**依存**: `qa-unit`完了後

```bash
Task:qa-integration(prompt: "ユーザーロールAPI統合テスト作成")
```

**テスト範囲**: FE → API → DB の一連のフロー

**stop条件**: 統合テスト失敗 > 0件で停止

### 3.3 E2Eテスト

**スラッシュコマンド**: `/e2e-full`
**依存**: `qa-integration`完了後

```bash
/e2e-full
```

**テスト範囲**: ブラウザ操作含む全体フロー

**stop条件**: E2E失敗 > 5件で停止

---

## Phase 4: 品質保証（Quality Assurance）

### 4.1 Lint/フォーマット

**エージェント**: `lint-fix`
**依存**: 全実装完了後

```bash
Task:lint-fix(prompt: "変更ファイルのLint修正とフォーマット")
```

**対象**: `git diff --name-only`の変更ファイルのみ

### 4.2 セキュリティスキャン

**エージェント**: `sec-scan`
**依存**: `lint-fix`完了後

```bash
Task:sec-scan(prompt: "新機能のセキュリティスキャン実行")
```

**stop条件**: Critical脆弱性 > 0件で停止

---

## Phase 5: ドキュメント更新（Documentation）

### 5.1 Serenaメモリ更新

```bash
mcp__serena__write_memory(
  memory_name: "project/session{番号}_user_role_feature.md",
  content: "# Session {番号} 完了報告..."
)
```

### 5.2 公式ドキュメント更新

**スラッシュコマンド**: `/docs-sync`

```bash
/docs-sync
```

**更新対象**:
- `docs/api/API.md`
- `docs/database/DATABASE.md`
- `next_session_prompt.md`

---

## Phase 6: リリース（Release）

### 6.1 Git Commit & PR作成

```bash
git checkout -b feat-user-role
git add .
git commit -m "feat: ユーザーロール管理機能追加

- バックエンドAPI実装
- フロントエンドUI実装
- ユニットテスト・統合テスト・E2Eテスト追加

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

mcp__github__create_pull_request(
  owner: "ShigaRyunosuke10",
  repo: "nissei",
  title: "feat: ユーザーロール管理機能追加",
  body: "## Summary\n- ユーザーロール管理機能追加\n\n## Test\n- [x] Unit Test (100%)\n- [x] Integration Test\n- [x] E2E Test",
  head: "feat-user-role",
  base: "main"
)
```

### 6.2 PR承認・マージ

```bash
# PRレビュー後
mcp__github__merge_pull_request(
  owner: "ShigaRyunosuke10",
  repo: "nissei",
  pullNumber: {PR番号},
  merge_method: "squash"
)
```

---

## エージェント依存関係マップ

```
planner（統合）
  ↓
  ├─ impl-dev-backend → qa-unit → qa-integration
  │                                    ↓
  └─ impl-dev-frontend → qa-unit ──────┤
                                       ↓
                                code-reviewer（FE/BE整合性）
                                       ↓
                                   /e2e-full
                                       ↓
                                   lint-fix
                                       ↓
                                   sec-scan
                                       ↓
                                   /docs-sync
                                       ↓
                                   Git Commit & PR
```

---

## 推定所要時間

- Phase 1: 30-60分
- Phase 2: 2-4時間
- Phase 3: 1-2時間
- Phase 4: 30分
- Phase 5: 30分
- Phase 6: 30分

**合計**: 5-8時間（中規模機能追加）

---

## ベストプラクティス

1. **計画フェーズを省略しない**: 手戻り防止のため必須
2. **依存関係を守る**: バックエンドAPI完成後にフロントエンド実装
3. **stop条件を尊重**: テスト失敗時は修正を優先
4. **並列実行可能な箇所**: ユニットテスト（FE/BE同時）
5. **ドキュメント同期を忘れない**: PRマージ前に必ず実行
