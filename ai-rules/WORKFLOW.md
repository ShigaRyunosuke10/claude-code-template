# 開発ワークフロー（エージェントベース）

エージェント連携による効率的な開発フロー。既存プロジェクトへの機能追加（Case A）と新規プロジェクト立ち上げ（Case B）に対応。

## ワークフロー選択

### Case A: 既存プロジェクト機能拡張

**対象**: このプロジェクト（nissei）での新機能追加・バグ修正

**テンプレート**: [.claude/workflows/case-a-existing-project.md](../.claude/workflows/case-a-existing-project.md)

**6つのPhase**:
1. Planning（要件定義・計画）- project-planner → sub-planner
2. Implementation（実装）- impl-dev-backend → impl-dev-frontend → integrator
3. Testing（テスト）- qa-unit → qa-integration → E2E
4. Quality Assurance（品質保証）- lint-fix → sec-scan
5. Documentation（ドキュメント更新）- Serenaメモリ → 公式Docs
6. Release（リリース）- Git Commit & PR → マージ

**推定時間**: 5-8時間（中規模機能追加）

### Case B: 新規プロジェクト立ち上げ

**対象**: ゼロから新規プロジェクトを構築

**テンプレート**: [.claude/workflows/case-b-new-project.md](../.claude/workflows/case-b-new-project.md)

**6つのPhase**:
1. Architecture Design（アーキテクチャ設計）- project-planner
2. Project Initialization（プロジェクト初期化）- impl-dev-backend + impl-dev-frontend
3. Core Features（コア機能実装）- 認証システム + マスターデータ管理
4. Testing Infrastructure（テスト基盤構築）- qa-unit + qa-integration + E2E
5. Documentation（ドキュメント整備）- Serenaメモリ + 公式Docs + 開発ガイド
6. Deployment Infrastructure（デプロイ基盤構築）- Docker + CI/CD

**推定時間**: 42-84時間（1-2週間、中規模プロジェクト）

---

## 共通ワークフロー（Case A/B共通）

### セッション開始時（必須）

#### 0. 計画フェーズ（実装前・必須）

**目的**: 手戻り防止、見通しの良い開発

**手順**:
1. **Explore（探索）**: 関連ファイルを読む（Read）
2. **Analyze（分析）**: 影響範囲を分析
3. **Plan（計画）**: TodoWriteで詳細な実装計画を作成
   - 実装ステップをリスト化
   - 予想される変更ファイル列挙
   - テスト戦略策定
4. **Approve（承認）**: ユーザーに計画を提示して承認を得る

**計画例**:
```
TodoWrite:
1. backend/app/api/users.py のCRUD実装
2. backend/tests/test_users.py のテスト作成（TDD）
3. frontend/src/app/users/page.tsx のUI実装
4. E2Eテスト実行・確認
```

#### 1. 引き継ぎ情報確認

**優先順位**:
1. `next_session_prompt.md` があれば読む
2. なければSerenaメモリ確認

```bash
# Serenaメモリ確認
mcp__serena__activate_project(project: "nissei")
mcp__serena__read_memory(memory_file_name: "project/current_context.md")
```

#### 2. ブランチ作成

```bash
git checkout -b <type>-<機能名>
```

**Type**:
- `feat-`: 新機能
- `fix-`: バグ修正
- `refactor-`: リファクタリング
- `docs-`: ドキュメント

---

### エージェント活用パターン（Case A）

#### Phase 1: Planning（要件定義・計画）

**1.1 既存コード調査（Serena MCP）**

**目的**: 既存コードの構造を理解し、影響範囲を特定

```bash
# 1. 関連するシンボルを検索
mcp__serena__find_symbol(
  name_path: "User",
  relative_path: "backend/app",
  substring_matching: true,
  depth: 1  # クラス配下のメソッドも取得
)

# 2. パターン検索（例: 認証関連コード）
mcp__serena__search_for_pattern(
  substring_pattern: "role|permission",
  paths_include_glob: "**/*.py",
  restrict_search_to_code_files: true
)

# 3. 参照箇所の特定
mcp__serena__find_referencing_symbols(
  name_path: "User",
  relative_path: "backend/app/models/user.py"
)
```

**出力**: 既存のUser関連コード、認証ロジック、依存関係

**1.2 関連Issue確認（GitHub MCP）**

**目的**: 重複Issue・関連PRを確認

```bash
# 関連Issueを検索
mcp__github__search_issues(
  owner: "ShigaRyunosuke10",
  repo: "nissei",
  query: "ユーザーロール OR role management"
)

# 未解決Issueリスト
mcp__github__list_issues(
  owner: "ShigaRyunosuke10",
  repo: "nissei",
  state: "open"
)
```

**1.3 マクロ計画（Epic分解）**

```bash
Task:project-planner(prompt: "ユーザーロール管理機能を追加したい")
```

**出力**: `epic-user-role-management.md`
- Epic分解（3-5個のストーリー）
- 優先度設定
- マイルストーン策定

**1.4 ミクロ計画（タスク分解）**

```bash
Task:sub-planner(prompt: "epic-user-role-management.mdのタスク詳細化")
```

**出力**: `epic-user-role-management-tasks.md`
- タスクごとのDoD（Done定義）
- API契約（FE/BE）
- 依存関係マップ

**stop条件**: タスク数 > 20件で警告（分割推奨）

---

#### Phase 2: Implementation（実装）

**2.0 ライブラリドキュメント参照（Context7 MCP）**

**目的**: 使用ライブラリの最新ドキュメントを取得

```bash
# FastAPI の最新ドキュメント取得
mcp__context7__resolve-library-id(libraryName: "fastapi")
# 出力: '/tiangolo/fastapi'

mcp__context7__get-library-docs(
  context7CompatibleLibraryID: "/tiangolo/fastapi",
  topic: "dependency injection",
  tokens: 3000
)

# React/Next.js の最新ドキュメント取得
mcp__context7__resolve-library-id(libraryName: "next.js")
mcp__context7__get-library-docs(
  context7CompatibleLibraryID: "/vercel/next.js",
  topic: "server components",
  tokens: 3000
)
```

**使用タイミング**: 新しいライブラリ機能を使う時、APIの使い方が不明な時

**2.1 バックエンド実装**

```bash
Task:impl-dev-backend(prompt: "Task 1: usersテーブルにroleカラム追加")
Task:impl-dev-backend(prompt: "Task 2: ユーザーロール取得API実装")
```

**編集スコープ**: `backend/**`のみ

**Serena MCP でコード編集**:

```bash
# 1. 既存シンボルの置換
mcp__serena__replace_symbol_body(
  name_path: "User",
  relative_path: "backend/app/models/user.py",
  body: "class User(Base):\n    ..."  # 新しいコード
)

# 2. 新しいメソッド追加
mcp__serena__insert_after_symbol(
  name_path: "User/__init__",
  relative_path: "backend/app/models/user.py",
  body: "\n    def get_role(self):\n        return self.role\n"
)

# 3. import文追加
mcp__serena__insert_before_symbol(
  name_path: "User",
  relative_path: "backend/app/models/user.py",
  body: "from app.schemas.role import RoleEnum\n"
)
```

**TDDサイクル（厳格版）**:
1. **RED（失敗するテストを書く）**:
   ```python
   # backend/tests/test_users.py
   def test_get_user_role():
       response = client.get("/api/users/123/role")
       assert response.status_code == 200

   # 実行 - 期待通り失敗することを確認
   pytest tests/test_users.py::test_get_user_role -v
   # ❌ FAILED - OK（実装前なので当然）
   ```

2. **GREEN（最小限の実装でパス）**:
   ```python
   # backend/app/api/users.py
   @router.get("/users/{user_id}/role")
   def get_user_role(user_id: str):
       # 最小限の実装
       return {"user_id": user_id, "role": "admin"}

   # 再実行
   pytest tests/test_users.py::test_get_user_role -v
   # ✅ PASSED
   ```

3. **REFACTOR（コード改善）**:
   ```python
   # コードの重複削除、可読性向上
   # テストは常にパスし続けることを確認
   ```

**重要**: REDフェーズでテストが失敗することを必ず確認すること

**stop条件**: pytest失敗 > 0件で停止

**2.2 フロントエンド実装**

```bash
Task:impl-dev-frontend(prompt: "Task 3: ユーザーロール表示UI実装")
```

**編集スコープ**: `frontend/**`のみ

**UI開発ワークフロー（Visual Iteration）**:
1. デザインモック/スクリーンショット共有
2. 実装
3. Playwright MCPでスクリーンショット撮影
4. 比較・フィードバック
5. 繰り返し（差分がなくなるまで）

**stop条件**: ESLintエラー > 0件で停止

**2.3 FE/BE統合チェック**

```bash
Task:integrator(prompt: "ユーザーロールAPIの整合性チェック")
```

**出力**: `integration-report.md`
- API契約一致確認
- 型定義同期
- 不整合修正提案

**stop条件**: Critical不整合 > 0件で停止

---

#### Phase 3: Testing（テスト）

**3.1 ユニットテスト**

```bash
# 並列実行
Task:qa-unit(prompt: "get_user_role関数のユニットテスト作成")
Task:qa-unit(prompt: "RoleBadgeコンポーネントのテスト作成")
```

**目標**: カバレッジ100%（ビジネスロジック）

**AAA（Arrange-Act-Assert）パターン**:
```python
def test_get_user_role_success():
    """正常系: ユーザーロール取得成功"""
    # Arrange（準備）
    user_id = "test-user-123"
    expected_role = "admin"
    mock_user = User(id=user_id, role=expected_role)

    # Act（実行）
    with patch('app.services.user_service.get_by_id', return_value=mock_user):
        result = get_user_role(user_id)

    # Assert（検証）
    assert result.role == expected_role
    assert result.user_id == user_id
```

**stop条件**: カバレッジ < 90%で警告

**3.2 統合テスト**

```bash
Task:qa-integration(prompt: "ユーザーロールAPI統合テスト作成")
```

**テスト範囲**: FE → API → DB の一連のフロー

**stop条件**: 統合テスト失敗 > 0件で停止

**3.3 E2Eテスト**

**⚠️ 重要**: `/e2e-full` は非推奨です。各エージェントを個別に実行してください。

**新機能のE2Eテスト作成（3ステップ）**:

```bash
# Step 1: テスト計画作成
Task:playwright-test-planner(prompt: "新機能のテスト計画作成")
# → 出力: frontend/specs/*.md

# Step 2: テストコード生成
Task:playwright-test-generator(prompt: "計画書からテストコード生成")
# → 出力: frontend/e2e/*.spec.ts

# Step 3: テスト実行・修復
Task:playwright-test-healer(prompt: "新規テストを実行・修復")
```

**既存テストの実行・修復のみ**:

```bash
# Phase 2/3検証、既存テスト修復
Task:playwright-test-healer(prompt: "既存テストを実行・修復")

# または直接実行
cd frontend
npm run test:e2e
```

**テスト対象**:
- フロントエンド（localhost:3000）
- バックエンド（localhost:8000）
- 正常系・異常系・エッジケース

**Playwright MCP で手動テスト・デバッグ**:

```bash
# 1. ページを開く
mcp__playwright__browser_navigate(url: "http://localhost:3000/login")

# 2. ページスナップショット取得（要素確認）
mcp__playwright__browser_snapshot()

# 3. フォーム入力
mcp__playwright__browser_fill_form(
  fields: [
    {name: "email", type: "textbox", ref: "...", value: "test@example.com"},
    {name: "password", type: "textbox", ref: "...", value: "TestPassword123!"}
  ]
)

# 4. ボタンクリック
mcp__playwright__browser_click(element: "ログインボタン", ref: "...")

# 5. ページ遷移待機
mcp__playwright__browser_wait_for(text: "ダッシュボード")

# 6. スクリーンショット保存
mcp__playwright__browser_take_screenshot(
  filename: "login_success.png",
  fullPage: true
)

# 7. コンソールエラー確認
mcp__playwright__browser_console_messages(onlyErrors: true)

# 8. ネットワークリクエスト確認
mcp__playwright__browser_network_requests()
```

**使用タイミング**:
- E2Eテスト失敗時のデバッグ
- UI実装時の動作確認
- スクリーンショット比較テスト

**Playwrightエージェント使用**:
- テスト作成: `frontend/.claude/agents/playwright-test-generator.md`
- テスト修正: `frontend/.claude/agents/playwright-test-healer.md`
- テスト計画: `frontend/.claude/agents/playwright-test-planner.md`

**stop条件**: E2E失敗 > 5件で停止

---

**3.4 E2Eテスト失敗時のフロー（重要）**

**原則: テスト失敗 = アプリケーションのバグ**

E2Eテストが失敗した場合、まずテストコードではなくアプリケーションコードを疑います。

**エラータイプ分類**:

| Error Type | 責任者 | 修正対象 | 試行制限 |
|-----------|--------|---------|---------|
| `test_code_bug` | Healer | `frontend/e2e/*.spec.ts` | 同一パターン3回 |
| `application_bug` | Claude Agent (impl-dev-backend/frontend) | `backend/**`, `frontend/src/**` | **同一パターン3回** |
| `infrastructure` | ユーザー | Docker, DB, Network | - |
| `potential_application_bug` | Healer → Claude | 追加調査後に分類 | - |

**重要**: 同じエラーパターン（同じ `pattern_XXX`）が3回連続で解決しない場合のみ停止します。
- ✅ **正常動作**: バグA → バグB → バグC（異なるバグを順次修正）→ 続行
- ❌ **ループ**: バグA → バグA → バグA（同じバグで3回失敗）→ 停止・報告

---

**application_bug 修正フロー（ループ検出システム）**:

```bash
# Step 1: エラー分類（Healerが実施）
Learning Memory に記録:
{
  "id": "pattern_XXX",
  "errorType": "application_bug",
  "rootCause": "...",
  "resolved": false,
  "fixAttempts": []
}

# Step 2: Claude Agent による修正（同一パターン3回まで）
# 1回目の試行
Task:impl-dev-backend(prompt: "pattern_XXX のバグ修正")
# または
Task:impl-dev-frontend(prompt: "pattern_XXX のバグ修正")

# 修正内容:
# 1. Backend logs 確認
# 2. 根本原因分析（APIエラー？DBエラー？認証エラー？）
# 3. アプリケーションコード修正
# 4. E2Eテスト再実行
# 5. Learning Memory 更新（fixAttempts に記録）

# 2回目・3回目の試行（1回目で失敗した場合）
# 別アプローチで修正
# fixAttempts 配列に追加記録

# Step 3: ループ検出時の対応
# 同じ pattern_XXX が3回連続で解決しない場合:
# 1. 続行する（さらに3回試行、最大6回まで）
# 2. 手動で修正する
# 3. Technical Debt登録（reports/technical-debt.md）
```

**maxAttemptsReached 判定**:
- 同じ `pattern_XXX` が3回連続で解決しない → `maxAttemptsReached: true` → ユーザーに相談
- 相談後「続行」選択 → さらに3回試行可能（合計6回まで）
- 相談後「Technical Debt登録」選択 → Issue作成、後日対応

**重要**: Healerは `frontend/e2e/*.spec.ts` のみ修正可能。`application_bug` は**必ず Claude Agent が修正**します。

---

#### Phase 4: Quality Assurance（品質保証 - Auto-Fix付き）

**コミット前必須チェック**:

```bash
/pre-commit-check
# lint-fix → sec-scan → code-reviewer を自動実行
```

**自動実行（Hook）**: `git commit`時に自動ブロック → `/pre-commit-check`実行を促す

---

**4.1 Auto-Fix Strategy（優先度別）**

| Priority | Max Retries | Consultation | Failure Behavior |
|----------|-------------|--------------|------------------|
| 🚨 Critical | 10 | ✅ 7回目に相談 | ❌ Block (相談後選択) |
| ⚠️ High | 3 | ❌ なし | 📝 Technical Debt登録 |
| 💡 Medium | 1 | ❌ なし | ⚠️ Warning |
| 📝 Low | 0 | ❌ なし | ⚠️ Warning |

**Loop Detection**: 同じ問題3回連続 or Issue数増加 → 7回目で相談

---

**4.2 Critical問題の相談プロンプト（7回目）**

```
❓ Critical問題を7回試行しましたが解決できません。

【問題詳細】
File: backend/app/api/projects.py:45
Issue: トランザクション未使用

【試行内容】
- 1-3回目: async with db.begin() 追加 → 構文エラー
- 4-6回目: import文修正 → まだエラー
- 7回目: 別アプローチ → 解決できず

【現在のTechnical Debt】
- High: 2件（N+1クエリ、型安全性）
- 詳細: reports/technical-debt.md

【選択肢】
1. 続行する（さらに3回試行、最大10回まで）
2. 手動で修正する（コミットブロック）
3. Technical Debt登録（コミット許可、Issue作成）

どうしますか？
```

---

**4.3 Technical Debt Management**

**File**: [reports/technical-debt.md](../reports/technical-debt.md)

**自動更新タイミング**:
- `/pre-commit-check`実行時
- 解決済み問題は自動削除
- 未解決のHigh問題を追加

**Desktop Commander MCP でLint/Format実行（内部動作）**:

```bash
# 1. 変更ファイル一覧取得
mcp__desktop-commander__execute_shell_command(
  command: "git diff --name-only",
  cwd: "c:\\Users\\shiga\\Desktop\\Dev\\nissei"
)

# 2. バックエンドLint実行
mcp__desktop-commander__execute_shell_command(
  command: "cd backend && ruff check . && black --check .",
  cwd: "c:\\Users\\shiga\\Desktop\\Dev\\nissei"
)

# 3. フロントエンドLint実行
mcp__desktop-commander__execute_shell_command(
  command: "cd frontend && npm run lint",
  cwd: "c:\\Users\\shiga\\Desktop\\Dev\\nissei"
)

# 4. セキュリティスキャン
mcp__desktop-commander__execute_shell_command(
  command: "cd backend && pip-audit",
  cwd: "c:\\Users\\shiga\\Desktop\\Dev\\nissei"
)

mcp__desktop-commander__execute_shell_command(
  command: "cd frontend && npm audit",
  cwd: "c:\\Users\\shiga\\Desktop\\Dev\\nissei"
)
```

---

**4.4 Skip Option（ドキュメントのみの変更）**

```bash
git commit --no-verify -m "docs: update README"
```

**注意**: 実装コード変更時は必ず `/pre-commit-check` 実行してください。

---

#### Phase 5: Documentation（ドキュメント更新）

**使い分け**:
- **Serenaメモリ**: AI用の詳細仕様（技術的詳細・WHY/HOW）
- **公式Docs**: 人間用の概要（使い方・設計思想・WHAT/HOW TO USE）

**5.1 毎PR後に更新（Serenaメモリのみ）**

```bash
mcp__serena__write_memory(
  memory_name: "project/session{番号}_user_role_feature.md",
  content: "# Session {番号} 完了報告..."
)
```

**変更内容に応じて更新**:
- `.serena/memories/specifications/api_specifications.md` - API変更時
- `.serena/memories/specifications/database_specifications.md` - DB変更時
- `.serena/memories/project/implementation_status.md` - 機能追加時
- `.serena/memories/project/current_context.md` - 常に更新（セッション引き継ぎ用）

**5.2 マイルストーン達成時に更新（公式Docs）**

**スラッシュコマンド**: `/docs-sync`

```bash
/docs-sync
```

**更新対象**（フェーズ完了時や大きな機能追加時のみ）:
- `docs/api/API.md` - Serenaメモリのサマリーとして
- `docs/database/DATABASE.md` - 同上
- `docs/project/CURRENT_PHASE.md` - フェーズ進捗記録
- `next_session_prompt.md` - 次セッション推奨タスク

**方針**: Docsはメモリの要約。詳細はメモリに一元化

---

#### Phase 6: Release（リリース）

**6.1 Git Commit & PR作成**

```bash
git checkout -b feat-user-role
git add .
git commit -m "feat: ユーザーロール管理機能追加

- バックエンドAPI実装
- フロントエンドUI実装
- ユニットテスト・統合テスト・E2Eテスト追加

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin feat-user-role

mcp__github__create_pull_request(
  owner: "ShigaRyunosuke10",
  repo: "nissei",
  title: "feat: ユーザーロール管理機能追加",
  body: "## Summary\n- ユーザーロール管理機能追加\n\n## Test\n- [x] Unit Test (100%)\n- [x] Integration Test\n- [x] E2E Test",
  head: "feat-user-role",
  base: "main"
)
```

**⚠️ 重要**: mainブランチへの直接pushは**絶対禁止**（ドキュメント更新含む）

**6.2 PR承認・マージ**

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
project-planner（マクロ計画）
  ↓
sub-planner（ミクロ計画）
  ↓
  ├─ impl-dev-backend（バックエンド） → qa-unit（ユニット） → qa-integration（統合）
  │                                                                     ↓
  └─ impl-dev-frontend（フロントエンド） → qa-unit（ユニット） ──────┤
                                                                        ↓
                                                                   integrator（整合性）
                                                                        ↓
                                                              playwright-test-healer
                                                                        ↓
                                                                    lint-fix
                                                                        ↓
                                                                    sec-scan
                                                                        ↓
                                                                   /docs-sync
                                                                        ↓
                                                                Git Commit & PR
```

**並列実行可能**:
- impl-dev-backend と impl-dev-frontend（API契約が確定している場合）
- qa-unit（バックエンド）と qa-unit（フロントエンド）

---

## Permissions & Hooks設定

詳細: [.claude/settings.json](../.claude/settings.json)

### Permissions（権限管理）

**defaultMode**: `allow`（基本的に許可）

**denyScopes**（禁止操作）:
- `Bash:rm -rf /*` - 全削除禁止
- `Bash:git push --force main` - mainブランチへのforce push禁止
- `Bash:git reset --hard HEAD~*` - Hard reset禁止
- `Write:.env*` - 環境変数ファイル書き込み禁止

### Hooks（自動トリガー）

**PreToolUse（実行前）**:
- `prevent-main-branch-direct-commit`: mainブランチへの直接コミット防止（block）
- `planning-phase-enforcer`: 実装前に計画フェーズ完了確認（confirm）

**PostToolUse（実行後）**:
- `auto-format-after-edit`: 編集後の自動フォーマット提案（suggest）
- `auto-test-after-impl`: 実装後の自動テスト提案（suggest）

### Stop条件（自動停止）

- `critical-test-failure`: E2Eテスト10件以上失敗で停止（halt）
- `security-vulnerability-detected`: Critical脆弱性検出で警告（warn）

---

## コンテキスト管理

### /clearコマンド使用タイミング

**目的**: 長いセッションで集中力維持、コンテキスト肥大化防止

**使用すべき時**:
- 大きなタスク完了後
- コンテキストが肥大化した時（10回以上のやり取り）
- 異なるタスクに切り替える前
- エラーで混乱した時

**使用後の手順**:
```bash
1. next_session_prompt.md を再読み込み
2. 現在のタスクを確認
3. 必要なら関連ファイルを再度Read
```

---

## コンテキスト共有方法

**効果的な情報提供**:
- **画像**: UI/UXの説明、エラースクリーンショット、デザインモック
- **URL**: 参考実装、公式ドキュメント、Issue・PR
- **ファイルパス**: 該当箇所の明示（行番号つき推奨）

**例**:
```
「backend/app/api/auth.py:45 で認証エラーが発生します。
スクリーンショット: [添付]
参考: https://fastapi.tiangolo.com/tutorial/security/」
```

---

## 命名規則・コミット規約

詳細: [CONVENTIONS.md](./CONVENTIONS.md)

**命名規則**:
- TypeScript/JavaScript: camelCase
- Python: snake_case
- API: kebab-case（複数形の名詞）
- Database: snake_case
- 環境変数: UPPER_SNAKE_CASE

**コミットメッセージ形式**:
```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Type**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `refactor`: リファクタリング
- `test`: テスト
- `chore`: ビルド・ツール変更

---

## ⚠️ 注意事項

### 絶対禁止事項
- **mainブランチへの直接commit & push**（実装コード・ドキュメント含め**一切禁止**）
- Critical問題があるPRのマージ

### 必須事項
- セッション開始時: **計画フェーズ完了**してから実装開始
- コミット前: **E2E + pytest は必ずパス**（ドキュメント更新のみの場合は不要）
- PR作成後: 実装コード変更の場合は必ず手動レビュー
- マージ後: 必ず**Serenaメモリ更新**（公式Docsはマイルストーン時）

### 例外なしルール
**全ての変更は必ずPRを通す**（ドキュメント更新、typo修正、コメント追加も含む）

---

## 🔗 関連ドキュメント

### 開発プロセス
- [CONVENTIONS.md](./CONVENTIONS.md) - 命名規則・コミット規約
- [README.md](./README.md) - ai-rules概要
- [../CLAUDE.md](../CLAUDE.md) - プロジェクト設定

### ワークフローテンプレート
- [../.claude/workflows/case-a-existing-project.md](../.claude/workflows/case-a-existing-project.md) - 既存プロジェクト拡張
- [../.claude/workflows/case-b-new-project.md](../.claude/workflows/case-b-new-project.md) - 新規プロジェクト立ち上げ

### エージェント定義
- [../.claude/agents/](../.claude/agents/) - 汎用エージェント（9体）
- [../frontend/.claude/agents/](../frontend/.claude/agents/) - Playwrightエージェント（3体）

### 設定ファイル
- [../.claude/settings.json](../.claude/settings.json) - Permissions & Hooks設定
- [../.claude/commands/](../.claude/commands/) - プロジェクト固有スラッシュコマンド

### ドキュメント
- [../docs/](../docs/) - 公式ドキュメント（人間向け）
- [../.serena/memories/](../.serena/memories/) - Serenaメモリ（AI向け）
