# 開発ワークフロー（動的計画ベース）

エージェント連携による効率的な開発フロー。**Phase 階層は planner が動的に生成**します。

## 基本原則

- **Phase は階層構造** - Phase 0 → Phase 0.1 → Phase 0.1.1
- **planner が動的に生成** - プロジェクトの状況に応じて柔軟に調整
- **Phase 開始時に見直し** - 実態と乖離していれば再計画

---

## Phase の階層構造

```
Phase 0: プロジェクト全体の大きなマイルストーン
  ├─ Phase 0.1: Phase 0 の中の作業単位
  │    ├─ Phase 0.1.1: Phase 0.1 の中の具体的なタスク
  │    └─ Phase 0.1.2: ...
  └─ Phase 0.2: ...
```

**例**:
```
Phase 0: プロジェクト基盤構築
  ├─ Phase 0.1: 技術スタック決定
  │    ├─ Phase 0.1.1: deployment-agent実行
  │    └─ Phase 0.1.2: 技術スタック確定
  ├─ Phase 0.2: 技術スタック検証
  │    └─ Phase 0.2.1: tech-stack-validator実行
  └─ Phase 0.3: MCP設定
       ├─ Phase 0.3.1: mcp-finder実行
       └─ Phase 0.3.2: MCP接続テスト

Phase 1: 認証システム実装
  ├─ Phase 1.1: 要件定義
  ├─ Phase 1.2: Backend API実装
  │    ├─ Phase 1.2.1: Supabase Auth統合
  │    └─ Phase 1.2.2: JWT検証ミドルウェア
  ├─ Phase 1.3: Frontend UI実装
  └─ Phase 1.4: テスト・リリース
```

---

## Phase の動的生成フロー

### 1. プロジェクト開始時

```bash
# ユーザー: 「Next.js + FastAPIで勤怠管理システムを作りたい」

# planner が Phase 階層を動的生成
Task:planner(prompt: "Next.js + FastAPIで勤怠管理システムを作りたい")
```

**planner の出力例**:
```markdown
# プロジェクト計画

## Phase 0: プロジェクト基盤構築（推定: 4-6時間）

### Phase 0.1: 技術スタック決定（推定: 1時間）
- Phase 0.1.1: deployment-agent実行（30分）
- Phase 0.1.2: 技術スタック確定（30分）

### Phase 0.2: 技術スタック検証（推定: 30分）
- Phase 0.2.1: tech-stack-validator実行（30分）

### Phase 0.3: MCP設定（推定: 1-2時間）
- Phase 0.3.1: mcp-finder実行（30分）
- Phase 0.3.2: MCP接続テスト（30分）

### Phase 0.4: プロジェクト初期化（推定: 2-3時間）
- Phase 0.4.1: Backend初期化（1時間）
- Phase 0.4.2: Frontend初期化（1時間）
- Phase 0.4.3: Docker Compose設定（1時間）

---

## Phase 1: 認証システム実装（推定: 6-8時間）

### Phase 1.1: 要件定義（推定: 1時間）

### Phase 1.2: Backend API実装（推定: 2時間）
- Phase 1.2.1: Supabase Auth統合（1時間）
- Phase 1.2.2: JWT検証ミドルウェア（1時間）

### Phase 1.3: Frontend UI実装（推定: 2時間）

### Phase 1.4: テスト・リリース（推定: 2-3時間）
```

---

### 2. Phase 開始時の見直し

**Phase 1 開始時**:
```bash
# 実態確認
Read: project_requirements.md
Read: .serena/memories/system/system_state.md
Read: docs/project/CURRENT_PHASE.md

# 現在の Phase 確認
# 計画: Phase 1.1 → Phase 1.2 → Phase 1.3 → Phase 1.4
# 実態: Backend の基盤は完成済み

# 再計画
Task:planner(prompt: "Phase 1 を見直したい。Backend基盤は完成済み。")
```

**planner の出力（再計画）**:
```markdown
## Phase 1: 認証システム実装（修正版）

### Phase 1.1: 要件定義（推定: 1時間）

### Phase 1.2: Supabase Auth統合（推定: 2時間）← 変更
- Phase 1.2.1: Backend統合（1時間）
- Phase 1.2.2: 接続テスト（1時間）

### Phase 1.3: Frontend UI実装（推定: 2時間）

### Phase 1.4: テスト・リリース（推定: 2-3時間）
```

---

## よくある Phase パターン（参考）

planner が参考にする「よくあるパターン」。固定ではなく、プロジェクトの状況に応じて調整します。

### パターン1: 新規プロジェクト立ち上げ

```
Phase 0: プロジェクト基盤構築
  ├─ Phase 0.1: 技術スタック決定
  ├─ Phase 0.2: 技術スタック検証
  ├─ Phase 0.3: MCP設定
  └─ Phase 0.4: プロジェクト初期化

Phase 1: 認証システム実装
  ├─ Phase 1.1: 要件定義
  ├─ Phase 1.2: Backend実装
  ├─ Phase 1.3: Frontend実装
  └─ Phase 1.4: テスト・リリース

Phase 2: コア機能実装
  └─ ...
```

### パターン2: 既存プロジェクト機能拡張

```
Phase 1: 機能A実装
  ├─ Phase 1.1: 要件定義
  ├─ Phase 1.2: Backend実装
  ├─ Phase 1.3: Frontend実装
  └─ Phase 1.4: テスト・リリース

Phase 2: 機能B実装
  └─ ...
```

### パターン3: リファクタリング

```
Phase 1: アーキテクチャ設計見直し
Phase 2: Backend リファクタリング
Phase 3: Frontend リファクタリング
Phase 4: テスト追加
```

---

## エージェント活用

Phase 内で使用するエージェントの詳細。

### 計画・要件定義

#### planner エージェント

**責任**: Phase/タスク分解、API契約定義、Phase階層の動的生成

**使用タイミング**:
- プロジェクト開始時
- Phase 開始時の見直し
- 新機能追加時

```bash
Task:planner(prompt: "ユーザーロール管理機能を追加したい")
```

**出力**:
- Phase 階層計画
- Epic分解（3-5個のストーリー）
- タスクごとのDoD
- API契約（FE/BE）
- 依存関係マップ

#### tech-stack-validator エージェント

**責任**: 技術スタック検証、最新情報確認

**使用タイミング**: Phase 0.2（技術スタック検証）

```bash
Task:tech-stack-validator(prompt: "Phase 0.1で決定した技術スタックを最新情報で検証")
```

#### mcp-finder エージェント

**責任**: MCP自動検索・提案

**使用タイミング**: Phase 0.3（MCP設定）

```bash
Task:mcp-finder(prompt: "技術スタックに対応するMCPサーバーを検索・提案")
```

---

### 実装

#### impl-dev-backend エージェント

**責任**: Backend実装

**編集スコープ**: `backend/**`のみ

**TDDサイクル（厳格版）**:
1. **RED（失敗するテストを書く）**
2. **GREEN（最小限の実装でパス）**
3. **REFACTOR（コード改善）**

```bash
Task:impl-dev-backend(prompt: "Phase 1.2.1: usersテーブルにroleカラム追加")
```

#### impl-dev-frontend エージェント

**責任**: Frontend実装

**編集スコープ**: `frontend/**`のみ

```bash
Task:impl-dev-frontend(prompt: "Phase 1.3.1: ユーザーロール表示UI実装")
```

#### code-reviewer エージェント

**責任**: FE/BE整合性チェック

```bash
Task:code-reviewer(prompt: "ユーザーロールAPIの整合性チェック")
```

**出力**: `integration-report.md`
- API契約一致確認
- 型定義同期（TypeScript ↔ Pydantic）
- 不整合修正提案

---

### テスト

#### qa-unit エージェント

**責任**: ユニットテスト作成

**目標**: カバレッジ100%（ビジネスロジック）

```bash
Task:qa-unit(prompt: "get_user_role関数のユニットテスト作成")
```

**AAAパターン（Arrange-Act-Assert）**:
```python
def test_get_user_role_success():
    # Arrange（準備）
    user_id = "test-user-123"

    # Act（実行）
    result = get_user_role(user_id)

    # Assert（検証）
    assert result.role == "admin"
```

#### qa-integration エージェント

**責任**: 統合テスト作成

**テスト範囲**: FE → API → DB の一連のフロー

```bash
Task:qa-integration(prompt: "ユーザーロールAPI統合テスト作成")
```

#### E2Eテスト（Playwright）

**3ステップ**:

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

**E2Eテスト失敗時のフロー**:

| Error Type | 責任者 | 修正対象 | 試行制限 |
|-----------|--------|---------|---------|
| `test_code_bug` | Healer | `frontend/e2e/*.spec.ts` | 同一パターン3回 |
| `application_bug` | Claude Agent | `backend/**`, `frontend/src/**` | 同一パターン3回 |
| `infrastructure` | ユーザー | Docker, DB, Network | - |

**重要**: 同じエラーパターン（同じ `pattern_XXX`）が3回連続で解決しない場合のみ停止。

---

### 品質保証

#### lint-fix エージェント

**責任**: Lint/フォーマット（自動修正）

```bash
Task:lint-fix(prompt: "変更ファイルのLint修正とフォーマット")
```

**対象**: `git diff --name-only`の変更ファイルのみ

#### sec-scan エージェント

**責任**: セキュリティスキャン

```bash
Task:sec-scan(prompt: "新機能のセキュリティスキャン実行")
```

**Auto-Fix Strategy（優先度別）**:

| Priority | Max Retries | Consultation | Failure Behavior |
|----------|-------------|--------------|------------------|
| 🚨 Critical | 10 | ✅ 7回目に相談 | ❌ Block |
| ⚠️ High | 3 | ❌ なし | 📝 Technical Debt登録 |
| 💡 Medium | 1 | ❌ なし | ⚠️ Warning |
| 📝 Low | 0 | ❌ なし | ⚠️ Warning |

**コミット前必須チェック**:
```bash
/pre-commit-check
# lint-fix → sec-scan → code-reviewer を自動実行
```

---

### ドキュメント更新

#### Serenaメモリ更新（毎Phase完了後）

```bash
mcp__serena__write_memory(
  memory_name: "project/phase{番号}_{内容}.md",
  content: "Phase 完了報告..."
)
```

**変更内容に応じて更新**:
- `.serena/memories/specifications/api_specifications.md` - API変更時
- `.serena/memories/specifications/database_specifications.md` - DB変更時
- `.serena/memories/project/implementation_status.md` - 機能追加時
- `.serena/memories/project/current_context.md` - 常に更新

#### 公式ドキュメント更新（マイルストーン達成時）

**スラッシュコマンド**: `/docs-sync`

```bash
/docs-sync
```

**更新対象**:
- `docs/api/API.md` - Serenaメモリのサマリー
- `docs/database/DATABASE.md` - 同上
- `docs/project/CURRENT_PHASE.md` - Phase進捗記録
- `next_phase_prompt.md` - 次Phase推奨タスク

**方針**: Docsはメモリの要約。詳細はメモリに一元化。

---

### リリース

#### Git Commit & PR作成

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
  owner: "{{GITHUB_OWNER}}",
  repo: "{{REPO_NAME}}",
  title: "feat: ユーザーロール管理機能追加",
  body: "## Summary\n- ユーザーロール管理機能追加\n\n## Test\n- [x] Unit Test (100%)\n- [x] Integration Test\n- [x] E2E Test",
  head: "feat-user-role",
  base: "main"
)
```

**⚠️ 重要**: mainブランチへの直接pushは**絶対禁止**（ドキュメント更新含む）

---

## MCP活用

### Serena MCP（コードベース解析）

**使用タイミング**: 既存コード調査、Phase開始時の見直し

```bash
# シンボル検索
mcp__serena__find_symbol(name_path: "User", ...)

# パターン検索
mcp__serena__search_for_pattern(substring_pattern: "role|permission", ...)

# コード編集
mcp__serena__replace_symbol_body(...)
mcp__serena__insert_after_symbol(...)
```

### Context7 MCP（ライブラリドキュメント取得）

**使用タイミング**: 新しいライブラリ機能を使う時

```bash
# FastAPI の最新ドキュメント取得
mcp__context7__resolve-library-id(libraryName: "fastapi")
mcp__context7__get-library-docs(
  context7CompatibleLibraryID: "/tiangolo/fastapi",
  topic: "dependency injection",
  tokens: 3000
)
```

### Playwright MCP（E2Eテスト・デバッグ）

**使用タイミング**: E2Eテスト失敗時のデバッグ、UI実装時の動作確認

```bash
# ページを開く
mcp__playwright__browser_navigate(url: "http://localhost:3000/login")

# フォーム入力
mcp__playwright__browser_fill_form(fields: [...])

# スクリーンショット保存
mcp__playwright__browser_take_screenshot(
  filename: "login_success.png",
  fullPage: true
)
```

### GitHub MCP（PR/Issue管理）

```bash
# Issue検索
mcp__github__search_issues(
  owner: "{{GITHUB_OWNER}}",
  repo: "{{REPO_NAME}}",
  query: "ユーザーロール OR role management"
)

# PR作成
mcp__github__create_pull_request(...)
```

---

## Permissions & Hooks設定

詳細: [.claude/settings.json](../.claude/settings.json)

### Permissions（権限管理）

**denyScopes**（禁止操作）:
- `Bash:rm -rf /*` - 全削除禁止
- `Bash:git push --force main` - mainブランチへのforce push禁止
- `Write:.env*` - 環境変数ファイル書き込み禁止

### Hooks（自動トリガー）

- `prevent-main-branch-direct-commit`: mainブランチへの直接コミット防止（block）
- `planning-enforcer`: 実装前に計画完了確認（confirm）
- `auto-test-after-impl`: 実装後の自動テスト提案（suggest）
- `critical-test-failure`: E2Eテスト10件以上失敗で停止（halt）
- `security-vulnerability-detected`: Critical脆弱性検出で警告（warn）

---

## 絶対禁止事項

- **mainブランチへの直接commit & push**（実装コード・ドキュメント含め**一切禁止**）
- Critical問題があるPRのマージ

## 必須事項

- Phase開始時: **Phase見直し完了**してから実装開始
- コミット前: **E2E + pytest は必ずパス**（ドキュメント更新のみの場合は不要）
- PR作成後: 実装コード変更の場合は必ず手動レビュー
- Phase完了後: 必ず**Serenaメモリ更新**

---

## 関連ドキュメント

### 開発プロセス
- [CONVENTIONS.md](./CONVENTIONS.md) - 命名規則・コミット規約
- [PHASE_START.md](./PHASE_START.md) - Phase開始手順
- [PHASE_COMPLETION.md](./PHASE_COMPLETION.md) - Phase完了手順
- [REQUIREMENTS_CHANGE.md](./REQUIREMENTS_CHANGE.md) - 要件変更フロー
- [README.md](./README.md) - ai-rules概要

### エージェント定義
- [../.claude/agents/](../.claude/agents/) - 汎用エージェント（16体）

### 設定ファイル
- [../.claude/settings.json](../.claude/settings.json) - Permissions & Hooks設定
- [../.claude/commands/](../.claude/commands/) - プロジェクト固有スラッシュコマンド

### ドキュメント
- [../docs/](../docs/) - 公式ドキュメント（人間向け）
- [../.serena/memories/](../.serena/memories/) - Serenaメモリ（AI向け）
