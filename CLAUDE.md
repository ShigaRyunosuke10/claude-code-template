# Claude Code - {{PROJECT_NAME}}

エージェントベースの開発設定

## 基本設定

- **回答**: 日本語
- **リポジトリ**: {{GITHUB_OWNER}}/{{REPO_NAME}}
- **ポート**: フロントエンド {{FRONTEND_PORT}}、バックエンド {{BACKEND_PORT}}
- **タスク管理**: TodoWriteツールを使用して作業の進捗を可視化（必須）

## セッション開始フロー（必須）

### 0. ワークフロー選択と要件定義

#### Case A: 既存プロジェクト機能拡張
- テンプレート: [.claude/workflows/case-a-existing-project.md](./.claude/workflows/case-a-existing-project.md)
- 詳細: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)

**Case B: 新規プロジェクト立ち上げ**
- テンプレート: [.claude/workflows/case-b-new-project.md](./.claude/workflows/case-b-new-project.md)

**Case C: デプロイ**
- テンプレート: [.claude/workflows/case-c-deployment.md](./.claude/workflows/case-c-deployment.md)
- 詳細: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)

**重要**: 各Caseで、ワークフローファイルを読む前に、あなた（メインClaude Agent）が要件ヒアリングを実施してください。

---

#### Case A: 要件ヒアリング手順

ユーザーに以下を質問してください:
1. 追加したい機能は何ですか？（具体的に）
2. 想定ユーザーは誰ですか？（管理者/一般ユーザー/etc.）
3. 既存機能との関連は？（独立/既存機能拡張）
4. 優先度は？（高/中/低）
5. 期限はありますか？

回答を `planner` エージェントに渡して計画立案を依頼します。

---

#### Case B: 要件ヒアリング手順

**Phase 0: 技術スタック・インフラ要件定義**

ユーザーに以下を順番に質問してください:
1. プロジェクトの目的・概要は？
2. フロントエンドフレームワーク希望は？（Next.js / React / Vue / etc.）
3. バックエンドフレームワーク希望は？（FastAPI / Express / Django / etc.）
4. データベース種類は？（PostgreSQL / MySQL / MongoDB / etc.）
5. 認証システムは？（Supabase Auth / NextAuth / Auth0 / カスタム）
6. ストレージ必要？（Supabase Storage / S3 / Cloudinary / 不要）
7. チーム規模は？（個人 / 2-5人 / 6人以上）
8. 予算は？（無料枠のみ / $10-50/月 / $50以上）

回答を `deployment-agent` に渡して推奨構成を取得:
```bash
Task:deployment-agent(prompt: "以下の要件に基づいてデプロイ構成を推奨してください
- フロントエンド: {回答2}
- バックエンド: {回答3}
- データベース: {回答4}
- 認証: {回答5}
- ストレージ: {回答6}
- チーム規模: {回答7}
- 予算: {回答8}
")
```

---

#### Case C: 要件ヒアリング手順

**Phase 0: デプロイ要件定義**

ユーザーに以下を順番に質問してください:
1. 現在の技術スタックは？（フロントエンド / バックエンド / DB）
2. 予算は？（無料枠のみ / $10-50/月 / $50以上）
3. トラフィック予測は？（低: 〜1000 req/day / 中: 〜10k / 高: 10k〜）
4. チーム規模は？（個人 / 2-5人 / 6人以上）
5. Docker使用希望は？（Yes / No / おまかせ）
6. SLA要件は？（スリープ許容 / 常時稼働必須）

回答を `deployment-agent` に渡して推奨構成を取得:
```bash
Task:deployment-agent(prompt: "以下の要件に基づいてデプロイ構成を推奨してください
- 技術スタック: {回答1}
- 予算: {回答2}
- トラフィック: {回答3}
- チーム規模: {回答4}
- Docker: {回答5}
- SLA: {回答6}
")
```

---

### 1. 計画フェーズ（実装前・必須）

**目的**: 手戻り防止、見通しの良い開発

**手順**:
1. **Explore**: 関連ファイルを読む（Read）
2. **Analyze**: 影響範囲を分析
3. **Plan**: TodoWriteで詳細な実装計画を作成
4. **Approve**: ユーザーに計画を提示して承認を得る

### 2. 引き継ぎ情報確認

**優先順位**:
1. `next_session_prompt.md` があれば読む
2. なければSerenaメモリ確認

```bash
mcp__serena__activate_project(project: "{{PROJECT_NAME}}")
mcp__serena__read_memory(memory_file_name: "project/current_context.md")
```

### 3. ブランチ作成

```bash
git checkout -b <type>-<機能名>
```

**Type**: `feat-`, `fix-`, `refactor-`, `docs-`

---

## 要件変更フロー（開発途中の機能変更・追加）

### トリガー
ユーザーが開発途中に自然言語で以下のような発言をした場合、メインClaude Agentが要件変更と判断してフローを開始します。

**要件変更フローが必要なケース**:
- 「新機能を追加したい」
- 「機能の仕様を変更したい」
- 「設計を見直したい」
- アーキテクチャに影響する変更

**通常の会話で対応（要件変更フロー不要）**:
- パラメータ変更（ポート番号、タイムアウト値など）
- UI微調整（色、サイズ、配置）
- バグ修正
- ドキュメント修正
- 小さなリファクタリング

---

### フロー

#### Phase 0: 作業の一時保存

**メインClaude Agentが実行**:
1. 現在の作業状態を確認
2. キリの良いところまで進める（必要なら）
   - 例: 実装中の関数を完成させる
   - 例: 現在のテストケースを完了させる
3. 一時保存を推奨
   ```bash
   git add .
   git commit -m "wip: 要件変更前の一時保存"
   ```

---

#### Phase 1: 要件ヒアリング（Case A相当）

**メインClaude Agentが質問**:
1. 変更・追加したい機能は何ですか？（具体的に）
2. 想定ユーザーは誰ですか？（管理者/一般ユーザー/etc.）
3. 既存機能との関連は？（独立/既存機能拡張/既存機能変更）
4. 優先度は？（高/中/低）
5. 期限はありますか？

---

#### Phase 2: planner実行

```bash
Task:planner(prompt: "以下の要件に基づいて変更計画を立ててください
- 変更内容: {回答1}
- 想定ユーザー: {回答2}
- 既存機能との関連: {回答3}
- 優先度: {回答4}
- 期限: {回答5}
")
```

**planner内部動作**:
1. 要件不足チェック実行
2. **要件不足検出時**:
   ```markdown
   # 📋 Requirements Validation Report

   ## ❌ 要件不足検出

   ### 不足している情報
   1. **機能の目的・ビジネス価値** が不明確
   2. **技術的実現可能性** の判断に必要な情報不足

   ### 追加で質問すべき項目
   - Q1: この機能で解決したい課題は何ですか？
   - Q2: 既存のどの機能に影響しますか？

   ## 📌 次のアクション
   メインClaude Agent: 上記の質問をユーザーに行ってください。
   回答取得後、再度 Task:planner を実行してください。
   ```
3. メインAgentが追加質問 → planner再実行
4. 要件充足 → 変更計画生成

---

#### Phase 3: 計画確認・承認

**メインClaude Agentが実行**:
1. plannerが生成した変更計画をユーザーに提示
2. 既存実装への影響を説明
3. ユーザーの承認を得る

---

#### Phase 4: 作業再開

**再開パターン**:

**A. 中断作業の続きから再開**（計画変更なし）
```bash
# 例: Task 2/5 完了 → 要件変更（新機能追加） → Task 3 から再開
Task:impl-dev-backend(prompt: "Task 3: ...")
```

**B. 計画変更に準拠して再開**（実装計画変更あり）
```bash
# 例: Task 2/5 完了 → 要件変更（仕様変更） → Task 3 が不要に → Task 4 から再開
# planner が新しい実装順序を提示
Task:impl-dev-backend(prompt: "変更後の Task 4: ...")
```

**C. 最初から実装し直し**（大幅な設計変更）
```bash
# 例: 既存実装を破棄 → 新設計で実装開始
git checkout -b feat-redesigned-feature
Task:impl-dev-backend(prompt: "新設計の Task 1: ...")
```

---

### ベストプラクティス

**要件変更前の確認**:
- [ ] 現在の作業をキリの良いところで止める
- [ ] git commit で一時保存（ブランチも考慮）
- [ ] 既存実装への影響範囲を理解する

**要件変更後の確認**:
- [ ] 変更計画を十分に理解する
- [ ] 既存テストが壊れていないか確認
- [ ] ドキュメントの更新が必要か確認

---

## エージェント一覧

### 汎用エージェント（横断的・14体）

#### 計画（Planning）
- **planner** - 要件からEpic+詳細タスク+API契約を一括生成（project-planner + sub-planner統合）

#### 実装（Implementation）
- **impl-dev-frontend** - フロントエンド実装（React/Next.js/TypeScript）
- **impl-dev-backend** - バックエンド実装（Python/FastAPI）

#### テスト（Testing）
- **qa-unit** - ユニットテスト作成（pytest/Jest）
- **qa-integration** - 統合テスト作成（API統合・DBトランザクション）

#### 品質保証（Quality Assurance）
- **lint-fix** - Lint/フォーマット（ESLint/Prettier/Black/Ruff）
- **sec-scan** - セキュリティスキャン（脆弱性検出・レポート作成）
- **code-reviewer** - AI設計レビュー（アーキテクチャ・ロジック・パフォーマンス・型定義整合性）
  - 自動修正: Critical (10回, 7回目で相談), High (3回), Medium (1回)
  - FE/BE型定義整合性チェック（旧integrator機能を統合）
  - 未解決問題: [reports/technical-debt.md](./reports/technical-debt.md) 自動記録

#### Playwright専用（E2Eテスト）
- **playwright-test-planner** - E2E探索・テスト計画作成
- **playwright-test-generator** - テストコード自動生成
- **playwright-test-healer** - 自己修復 + AI完全自律実行システム

**E2Eテスト実行方法**:
```bash
# ❌ 非推奨: /e2e-full（planner → generator → healer 連続実行）
# 理由: 既存テストの上書き、柔軟性の欠如、時間の無駄

# ✅ 推奨: 各エージェントを個別に実行
Task:playwright-test-planner(prompt: "新機能のテスト計画作成")    # テスト計画作成
Task:playwright-test-generator(prompt: "計画書からコード生成")   # テストコード生成
Task:playwright-test-healer(prompt: "既存テストを実行・修復")    # テスト実行・修復

# ✅ 既存テストの修復のみ（Phase 2/3検証）
Task:playwright-test-healer(prompt: "Phase 2 Conservative Healing実行")
```

#### ドキュメント・リリース
- **doc-writer** - ドキュメント更新（差分ベース）
- **release-manager** - CHANGELOG/タグ生成・リリースノート作成

#### デプロイ（Deployment）
- **deployment-agent** - デプロイ全般（要件定義→推奨→ファイル生成→デプロイ実行→検証）
  - deploy-manager + infra-validator統合

#### プロジェクト固有スラッシュコマンド
- **/docs-sync** - ドキュメント同期（Serenaメモリ → 公式Docs）
- **/pre-commit-check** - コミット前チェック（lint-fix → sec-scan → code-reviewer）

### エージェント使用例（Case A: 機能追加）

```bash
# Phase 0: 要件ヒアリング（あなたが実行）
# 1. 追加したい機能は何ですか？→ ユーザーロール管理機能
# 2. 想定ユーザーは誰ですか？→ 管理者
# 3. 既存機能との関連は？→ 既存ユーザー管理の拡張
# 4. 優先度は？→ 高
# 5. 期限はありますか？→ 2週間後

# Phase 1: Planning
Task:planner(prompt: "以下の要件に基づいて計画を立ててください
- 機能: ユーザーロール管理機能
- 想定ユーザー: 管理者
- 既存機能との関連: 既存ユーザー管理の拡張
- 優先度: 高
- 期限: 2週間後
")

# Phase 2: Implementation
Task:impl-dev-backend(prompt: "ユーザーロールAPI実装")
Task:impl-dev-frontend(prompt: "ユーザーロール表示UI実装")
# Phase 2.3: FE/BE整合性チェックは code-reviewer が自動実行

# Phase 3: Testing
Task:qa-unit(prompt: "get_user_role関数のユニットテスト作成")
Task:qa-integration(prompt: "ユーザーロールAPI統合テスト作成")

# E2Eテスト（新機能の場合）
Task:playwright-test-planner(prompt: "ユーザーロール管理のテスト計画作成")
Task:playwright-test-generator(prompt: "user-role-management.md からテストコード生成")
Task:playwright-test-healer(prompt: "新規テストを実行・修復")

# Phase 4: Quality Assurance（Auto-Fix付き）
/pre-commit-check  # lint-fix → sec-scan → code-reviewer 一括実行

# Auto-Fix動作:
# - Critical: 7回目で相談、最大10回
# - High: 3回まで（未解決なら Technical Debt 登録）
# - Medium: 1回のみ
# 未解決問題: reports/technical-debt.md

# Phase 5: Documentation
Task:doc-writer(prompt: "変更箇所のドキュメント更新")
/docs-sync

# Phase 6: Release
Task:release-manager(prompt: "v1.3.0リリース準備")
git commit & PR作成 → マージ
```

### エージェント使用例（Case C: デプロイ）

```bash
# Phase 0: デプロイ要件定義・プラットフォーム推奨
# プロジェクト開始時に実行
Task:deployment-agent(prompt: "Vercel + Supabase構成で要件確認とプラットフォーム推奨")

# Phase 1: 設定ファイル自動生成
Task:deployment-agent(prompt: "Vercel + Supabase構成で設定ファイルを生成（Dockerfile, CI/CD, .env等）")

# Phase 2: デプロイ前検証
Task:deployment-agent(prompt: "デプロイ前最終チェック - 環境変数・セキュリティ検証")

# Phase 3: 初回デプロイ
Task:deployment-agent(prompt: "Vercel + Supabase構成で初回デプロイ実行")

# Phase 4: CI/CD設定
Task:deployment-agent(prompt: "Vercel用のGitHub Actions設定を生成")

# Phase 5: デプロイ後確認
Task:deployment-agent(prompt: "デプロイ後ヘルスチェック実行")

# トラブル時: ロールバック
Task:deployment-agent(prompt: "前バージョンへロールバック")
```

---

## MCPサーバー（有効化済み）

### 横断的MCPサーバー（全プロジェクト共通）

- **github** - GitHub操作（PR/Issue管理） → [ワークフロー統合](./ai-rules/WORKFLOW.md)
- **serena** - コードベース解析・シンボル操作 → [ワークフロー統合](./ai-rules/WORKFLOW.md)
- **playwright** - ブラウザ自動化（E2Eテスト） → [ワークフロー統合](./ai-rules/WORKFLOW.md)
- **desktop-commander** - ファイルシステム操作 → [ワークフロー統合](./ai-rules/WORKFLOW.md)
- **context7** - ライブラリドキュメント取得 → [ワークフロー統合](./ai-rules/WORKFLOW.md)

---

## Permissions & Hooks

設定ファイル: [.claude/settings.json](./.claude/settings.json)

### Permissions（権限管理）
- **defaultMode**: `allow`（基本的に許可）
- **denyScopes**（禁止操作）:
  - `Bash:rm -rf /*` - 全削除禁止
  - `Bash:git push --force main` - mainブランチへのforce push禁止
  - `Write:.env*` - 環境変数ファイル書き込み禁止

### Hooks（自動トリガー）
- **prevent-main-branch-direct-commit**: mainブランチへの直接コミット防止
- **auto-test-suggestion**: 実装後のテスト推奨

### Stop条件（自動停止）
- **critical-test-failure**: E2Eテスト10件以上失敗で停止
- **security-vulnerability-detected**: Critical脆弱性検出で警告

---

## テスト方針（TDD）

### テスト3層構造
1. **単体テスト**: pytest（バックエンド）/ Jest（フロントエンド）
2. **統合テスト**: APIエンドポイント間の連携テスト
3. **E2Eテスト**: Playwright（フロントエンド）

### カバレッジ目標
- バックエンド: 100%
- フロントエンド: E2Eで主要フロー網羅

---

## E2Eテスト失敗時のフロー（重要）

### 原則: テスト失敗 = アプリケーションのバグ

**学習**:
> "最初に建てたテスト計画を変えてテスト通すのおかしくないか それ通すためのテストになってひんしつちぇっくにならないよね"

**解釈**:
- ✅ **テスト失敗 = アプリケーションにバグがある**
- ❌ **テスト失敗 = テストが間違っている** ではない
- → まず backend logs 確認 → 根本原因修正 → テスト再実行

---

### application_bug 修正フロー（ループ検出システム）

E2Eテストで `application_bug` が検出された場合、以下のフローで修正します。

**重要**: 同じエラーパターン（同じ `pattern_XXX`）が3回連続で解決しない場合のみ停止します。
- ✅ **正常動作**: バグA → バグB → バグC（異なるバグを順次修正）→ 続行
- ❌ **ループ**: バグA → バグA → バグA（同じバグで3回失敗）→ 停止・報告

#### Step 1: エラー分類

```bash
# Healer が Learning Memory に記録
{
  "id": "pattern_XXX",
  "errorType": "application_bug",  # ← アプリケーション側のバグ
  "rootCause": "...",
  "resolved": false,
  "fixAttempts": []  # ← 修正試行を記録
}
```

**エラータイプ分類**:
- `test_code_bug` → Healer が修正（同一パターン3回まで）
- `application_bug` → Claude Agent が修正（同一パターン3回まで）
- `infrastructure` → ユーザーに相談
- `potential_application_bug` → 追加調査

---

#### Step 2: Claude Agent による修正試行（同一パターン3回まで）

1. Backend logs 確認
2. 根本原因分析
3. アプリケーションコード修正
4. E2Eテスト再実行
5. Learning Memory 更新

---

#### Step 3: ループ検出時 → ユーザーに相談

**同じ `pattern_XXX` が3回連続で解決しない場合、Claude Agent が自動で停止し、ユーザーに相談**

---

### 責任者

| Error Type | 責任者 | 修正回数制限 | 備考 |
|-----------|--------|------------|------|
| `test_code_bug` | Healer | 同一パターン3回 | テストコードのみ修正 |
| `application_bug` | Claude Agent (impl-dev-backend / impl-dev-frontend) | 同一パターン3回 | アプリケーションコード修正 |
| `infrastructure` | ユーザー | - | Docker, DB, Network問題 |
| `potential_application_bug` | Healer → Claude | - | 追加調査後に分類 |

---

### 統合ルール: /pre-commit-check と E2E Test

**Combined Retry Limits**:
- `/pre-commit-check` の Auto-Fix: 最大10回（Critical: 7回相談）
- E2E Test の application_bug修正: 最大3回
- **合計**: 最大13回の修正試行

**Force-Stop Condition**:
- 同一エラーで13回修正しても解決しない場合
- → ユーザーに相談
- → Technical Debt 登録（`reports/technical-debt.md`）

---

## セッション完了時（自動化・必須）

**タスク完了後、必ず以下を実行してください**:

### ① **テストKPI計算・記録**

**E2Eテスト実行**:
```bash
cd frontend && npm run test:e2e
```

**KPI計算** (テスト結果から手動計算):
```markdown
📊 Session KPI

- ✅ **Pass Rate**: XX.X% (前回: YY.Y% / 差分: ±Z.Z%)
  - 合格: XXテスト
  - 失敗: XXテスト
  - 全体: XXXテスト

- 📉 **Test Debt Ratio**: XX.X% (前回: YY.Y%)

- 🔄 **Regression Count**: X件
  - (セッション前に合格していたが、修正後に失敗したテスト数)
```

**計算方法**:
- Pass Rate = 合格テスト数 / 全テスト数 × 100%
- Test Debt Ratio = 失敗テスト数 / 全テスト数 × 100%
- Regression Count = 新規失敗テスト数

---

### ② Serenaメモリ更新
```bash
mcp__serena__write_memory(
  memory_name: "project/session{番号}_{内容}.md",
  content: "# Session {番号} 完了報告..."
)
```

**記載内容**:
- **📊 Session KPI** (上記で計算した値を記載)
  - Pass Rate (前回比)
  - Test Debt Ratio
  - Regression Count
  - KPI分析コメント
- 達成内容サマリー
- テスト結果（テスト数・カバレッジ）
- 学んだベストプラクティス
- 次回推奨タスク
- 実装詳細

### ③ next_session_prompt.md更新
```bash
Write:next_session_prompt.md
```

**記載内容**:
- **📊 前回のテストKPI** (上記で計算した値を記載)
  - Pass Rate
  - Test Debt Ratio
  - Regression Count
- 前回の成果（テスト数・カバレッジ）
- 今セッションの推奨タスク（優先度付き）

### ④ Git commit & PR作成

**🚨 重要**: コミット前に `/pre-commit-check` を実行してください（Claude Agentは自動実行）

**コミットメッセージのPrefix**:
- `feat:` - 新機能（**レビュー必須**）
- `fix:` - バグ修正（**レビュー必須**）
- `refactor:` - リファクタリング（**レビュー必須**）
- `test:` - テストコードのみ修正（**レビュースキップ**）
- `docs:` - ドキュメントのみ修正（**レビュースキップ**）

```bash
# ブランチ作成
git checkout -b docs-session{番号}

# 変更をステージング
git add .serena/memories/project/*.md
git add next_session_prompt.md
git add <実装ファイル>

# コミット前チェック（Claude Agentは自動実行）
/pre-commit-check  # test: と docs: 以外は必須

# コミット & プッシュ & PR作成
git commit -m "docs: session{番号}完了報告 - {内容}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin docs-session{番号}

mcp__github__create_pull_request(
  owner: "{{GITHUB_OWNER}}",
  repo: "{{REPO_NAME}}",
  title: "docs: session{番号}完了報告 - {内容}",
  body: "## Summary\n- 達成内容\n\n## Test\n- [x] ドキュメント更新のみ",
  head: "docs-session{番号}",
  base: "main"
)

# PR確認後、マージ
mcp__github__merge_pull_request(
  owner: "{{GITHUB_OWNER}}",
  repo: "{{REPO_NAME}}",
  pullNumber: {PR番号},
  merge_method: "squash"
)
```

**⚠️ 重要**:
- mainブランチへの直接pushは絶対禁止（ドキュメント更新含む）
- `docs:` コミットは `/pre-commit-check` 不要（Hook発動しない）
- `test:` コミットも `/pre-commit-check` 不要（ループ防止）

---

## ドキュメント構造（MECE）

### 開発プロセス（HOW TO DEVELOP）
- [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md) - 開発フロー詳細
- [ai-rules/CONVENTIONS.md](./ai-rules/CONVENTIONS.md) - 命名規則・コミット規約
- [ai-rules/README.md](./ai-rules/README.md) - ai-rules概要

### ツール設定
- [.claude/settings.json](./.claude/settings.json) - Permissions & Hooks設定
- [.claude/workflows/](././claude/workflows/) - ワークフローテンプレート（Case A/B/C）
- [.claude/agents/](./.claude/agents/) - 汎用エージェント（16体）
- [.claude/commands/](./.claude/commands/) - プロジェクト固有スラッシュコマンド
- [.github/workflows/](./.github/workflows/) - CI/CDテンプレート（Vercel/Railway/Render）

### AI向け技術詳細（WHY/HOW for AI）
- [.serena/memories/specifications/](./.serena/memories/specifications/) - 技術仕様（API/DB/アーキテクチャ）
- [.serena/memories/project/](./.serena/memories/project/) - プロジェクト状態管理・セッション記録

### 人間向けドキュメント（WHAT/HOW TO USE for Human）
- [docs/api/API.md](./docs/api/API.md) - APIリファレンス
- [docs/database/DATABASE.md](./docs/database/DATABASE.md) - データベーススキーマ
- [docs/project/](./docs/project/) - プロジェクト管理ドキュメント

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

## Technical Debt 管理

未解決のコードレビュー問題: [reports/technical-debt.md](./reports/technical-debt.md)

**自動管理**:
- `/pre-commit-check`実行時に自動更新
- 解決済み問題は自動削除
- Critical相談時に参照

**問題の優先度**:
- 🚨 **Critical**: 修正必須（7回目でユーザー相談）
- ⚠️ **High**: 3回試行後、未解決ならTechnical Debt登録
- 💡 **Medium**: 1回のみ試行
- 📝 **Low**: Warning表示のみ

**相談時の選択肢**（Critical 7回目）:
1. 続行する（さらに3回試行、最大10回まで）
2. 手動で修正する（コミットブロック）
3. Technical Debt登録（コミット許可、Issue作成）

---

## セキュリティ設定

### Tool Permissions管理

**基本方針**: 危険な操作前にユーザー確認を徹底

**禁止事項**:
- `--dangerously-skip-permissions` は絶対使用禁止
- main/masterブランチへの直接push禁止
- 本番環境での実験的操作禁止

**詳細**: [.claude/settings.json](./.claude/settings.json) 参照

---

## Phase Rollout System（AI自律システム）

**3段階デプロイ戦略による安全なAI自律システム導入**

AI完全自律E2Eテストシステムを、Observer → Conservative → Full Autonomousの3フェーズで段階的に導入します。

### Phase 1: Observer Mode（Week 1-2）
- **目的**: 停止ルール検知精度測定・エラーパターン収集
- **機能**: 監視のみ（修復なし）
- **実行方法**:
  ```bash
  ./.claude/scripts/switch-phase.sh 1
  /e2e-full
  ```
- **成功基準**:
  - 停止ルール検知精度 >95%
  - False Positive Rate <5%
  - エラーパターン蓄積 >=10件

### Phase 2: Conservative Healing（Week 3-4）
- **目的**: 既知処方の有効性検証
- **機能**: Learning Memoryの既知処方のみ適用
- **成功基準**:
  - MTTR <20min
  - Recurrence Rate <10%

### Phase 3: Full Autonomous（Week 5+）
- **目的**: 完全自律化
- **機能**: 仮説処方含む全機能有効化
- **成功基準**:
  - MTTR <15min
  - False Positive Rate <3%

**詳細ガイド**: [.claude/phases/ROLLOUT_GUIDE.md](./.claude/phases/ROLLOUT_GUIDE.md)

---

## 参考リンク

- **ワークフロー詳細**: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)
- **命名規則**: [ai-rules/CONVENTIONS.md](./ai-rules/CONVENTIONS.md)
- **Case A テンプレート**: [.claude/workflows/case-a-existing-project.md](./.claude/workflows/case-a-existing-project.md)
- **Case B テンプレート**: [.claude/workflows/case-b-new-project.md](./.claude/workflows/case-b-new-project.md)
- **Case C テンプレート**: [.claude/workflows/case-c-deployment.md](./.claude/workflows/case-c-deployment.md)
- **Phase Rollout Guide**: [.claude/phases/ROLLOUT_GUIDE.md](./.claude/phases/ROLLOUT_GUIDE.md)
- **GitHub Actions**: [.github/workflows/README.md](./.github/workflows/README.md)
