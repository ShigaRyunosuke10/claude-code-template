# Phase開始時の手順（自律実行）

Phase開始時に**自動的に**実行する手順。ユーザー介入なしで「計画 → 実装 → まとめ」の流れを開始します。

---

## セッション自律実行フロー

```
Phase開始
  ↓
① 計画フェーズ（自動）
  ↓
② 実装フェーズ（自動）
  ↓
③ まとめフェーズ（自動）
  ↓
Phase完了（ピポパ音♪）
```

---

## ⚠️ Phase間遷移チェックリスト（必須確認）

**Phase N完了 → Phase N+1 開始の際、このチェックリストを実行**

### ✅ Step 1: 現状確認
- [ ] `git status` で作業ツリー状態確認
- [ ] Phase N 完了報告を `.serena/memories/project/` から読み込み
- [ ] 未コミットファイルがある場合、コミット完了を確認

### ✅ Step 2: 手動作業の確認

**Phase 0.3 → Phase 1 の場合**:
- [ ] Supabaseプロジェクト作成完了？
- [ ] APIキー取得完了？
- [ ] backend/.env 設定完了？
- [ ] frontend/.env.local 設定完了？

**その他のPhase遷移**:
- [ ] 前Phase完了報告で提示した「次のステップ（手動作業）」が完了しているか確認

### ✅ Step 3: ユーザー意図の確認

**ユーザーの指示が曖昧な場合（"続き", "次", "お願いします"）**:

必ず質問:
```markdown
Phase {N} が完了しました。次のステップについて確認させてください：

【選択肢】
A. 手動作業の手順案内（まだ完了していない場合）
B. Phase {N+1} 実行（手動作業完了済みの場合）
C. Phase {N} の見直し・修正
D. その他

どちらをご希望ですか？
```

### ✅ Step 4: Plan Mode使用（必須）

**Phase {N+1} が大規模作業（10+ファイル作成等）の場合**:
1. Plan Mode開始
2. 上記Step 1-3を実行
3. ユーザー回答を受けて実装計画作成
4. `ExitPlanMode` で計画提示
5. ユーザー承認後に実行開始

---

## ① 計画フェーズ（自動実行）

### Phase 0.0: GitHubリポジトリ初期化チェック（自動・Phase 0 のみ）

**実行タイミング**: Phase 0（プロジェクト基盤構築）の最初のみ実行

**実行内容**:
```bash
# リモートURLの存在チェック
git config --get remote.origin.url
```

**リモートURLが存在しない場合**:
→ GitHubリポジトリを作成します

---

#### 1. プロジェクト情報ヒアリング

**メインClaude Agentが質問**:
```markdown
GitHubリポジトリが未設定です。新規作成しますか？

【質問】
1. プロジェクト名は？（例: my-awesome-app）
2. リポジトリ名は？（デフォルト: プロジェクト名と同じ）
3. リポジトリの可視性は？（public / private）
4. リポジトリの説明は？（省略可）
5. GitHubオーナー名は？（例: YourUsername）

【選択肢】
A. 新規作成する（推奨）
B. 後で手動で作成する
C. 既存リポジトリを使う
```

**選択肢Aを選んだ場合**:
→ 以下のステップを自動実行

**選択肢Bを選んだ場合**:
→ スキップ（Phase 0 を継続）

**選択肢Cを選んだ場合**:
→ リモートURLの入力を求める
```bash
git remote add origin {{ユーザー提供のURL}}
git branch -M main
git push -u origin main
```

---

#### 2. CLAUDE.md プレースホルダー置換

**実行内容**:
```bash
# プレースホルダーを実際の値に置換
sed -i 's/{{PROJECT_NAME}}/my-awesome-app/g' CLAUDE.md
sed -i 's/{{GITHUB_OWNER}}/YourUsername/g' CLAUDE.md
sed -i 's/{{REPO_NAME}}/my-awesome-app/g' CLAUDE.md
sed -i 's/{{FRONTEND_PORT}}/3000/g' CLAUDE.md  # デフォルト値
sed -i 's/{{BACKEND_PORT}}/8000/g' CLAUDE.md   # デフォルト値

# Windows の場合
# powershell -c "(Get-Content CLAUDE.md) -replace '{{PROJECT_NAME}}', 'my-awesome-app' | Set-Content CLAUDE.md"
```

**ポート番号の確認**:
```markdown
フロントエンドポート: 3000（デフォルト）でよろしいですか？
バックエンドポート: 8000（デフォルト）でよろしいですか？

変更する場合は番号を入力してください。
```

---

#### 3. GitHubリポジトリ作成（GitHub MCP使用）

**前提条件**:
- **環境変数 `GITHUB_TOKEN` が設定されていること**
- `.mcp.json` でGitHub MCPサーバーが有効化されていること

**環境変数チェック**:
```bash
# GITHUB_TOKEN の存在確認
echo $GITHUB_TOKEN | head -c 10

# 未設定の場合は以下のメッセージを表示
```

**環境変数が未設定の場合**:
```markdown
❌ 環境変数 `GITHUB_TOKEN` が設定されていません。

【設定手順】
1. GitHubアクセストークンを取得:
   https://github.com/settings/tokens?type=beta

   必要なスコープ:
   - Repository access: All repositories
   - Repository permissions:
     - Contents: Read and write
     - Metadata: Read-only

2. 環境変数を設定:

   # Windows PowerShell
   $env:GITHUB_TOKEN = "ghp_your_token_here"

   # macOS/Linux
   export GITHUB_TOKEN="ghp_your_token_here"

   # 永続化（推奨）:
   ~/.bashrc または ~/.zshrc に追加
   export GITHUB_TOKEN="ghp_your_token_here"

3. Claude Code を再起動

詳細: README.md の「事前準備」セクションを参照
```

**選択肢**:
```markdown
A. 環境変数を設定してから再実行する（推奨）
B. 後で手動でリポジトリを作成する
C. 既存リポジトリを使う
```

**選択肢Aを選んだ場合**:
→ Phase 0 を一時中断（ユーザーが環境変数設定後に再開）

**選択肢B/Cを選んだ場合**:
→ Step 3 をスキップ（Step 4 も スキップ）

---

**環境変数が設定済みの場合**:

**実行内容**:
```bash
# GitHub MCP でリポジトリ作成
mcp__github__create_repository(
  name: "{{REPO_NAME}}",
  description: "{{説明文}}",
  private: {{true|false}},
  auto_init: false
)

# リモートURL追加
git remote add origin https://github.com/{{GITHUB_OWNER}}/{{REPO_NAME}}.git
```

**エラー時**:
- 認証エラー → 環境変数 `GITHUB_TOKEN` の値を確認
- リポジトリ名重複 → 別の名前を提案
- GitHub MCP サーバーエラー → `.mcp.json` 設定を確認

---

#### 4. git init & commit & push

**実行内容**:
```bash
# git 初期化（既に .git があればスキップ）
git init

# 全ファイルをステージング
git add .

# 初回コミット
git commit -m "chore: プロジェクト初期化

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# メインブランチにリネーム
git branch -M main

# リモートにプッシュ
git push -u origin main
```

---

#### 5. 完了メッセージ

```markdown
✅ GitHubリポジトリ作成完了

【作成されたリポジトリ】
- URL: https://github.com/{{GITHUB_OWNER}}/{{REPO_NAME}}
- 可視性: {{public|private}}

【次のステップ】
Phase 0（プロジェクト基盤構築）を開始します。
```

---

**リモートURLが既に存在する場合**:
→ スキップ（このステップは実行しない）

```markdown
✅ GitHubリポジトリは既に設定されています。

【リモートURL】
- origin: {{既存のURL}}

Phase 0 を継続します。
```

---

## Phase 0.1: 要件定義書分析・Serenaメモリ初期化（自動・Phase 0 のみ）

**実行タイミング**: Phase 0.0（GitHubリポジトリ初期化）の直後

**目的**:
- プロジェクト開始時に要件定義書（docs/requirements/）またはチャット履歴から要件を抽出
- plannerエージェントで分析し、プロジェクト計画とPhase階層を生成
- Serenaメモリに保存してプロジェクト全体で共有

---

### ⚠️ 重要: Serenaのonboardingツールとの違い

**Phase 0.1を実行すべき場合**:
- ✅ 要件定義書が `docs/requirements/` または `docs/references/` に存在する
- ✅ Serenaメモリが未初期化（`.serena/memories/` が空）
- ✅ **新規プロジェクト**でこれからコードを書く

**Serenaのonboardingツールを実行すべき場合**:
- ✅ 要件定義書が**存在しない**
- ✅ **既存のコードベース**を初めて見る
- ✅ 技術スタック、コーディング規約、テストコマンド等を**手動で調査**する必要がある

**判断フロー（疑似コード）**:
```
プロジェクト開始時
  ↓
要件定義書は存在するか？
  ├─ YES → Phase 0.1（plannerで自動生成） ← このフロー
  └─ NO → Serenaのonboarding（手動調査）
```

**❌ 絶対にやってはいけないこと**:
- Phase 0.1で `mcp__serena__onboarding` を呼ぶ（競合するため）
- 要件定義書があるのに手動でメモリを作成する（plannerを呼ぶべき）

---

### Step 0: 前提条件チェック（自動実行）

**Phase 0.1実行前に確認すること**:

1. **要件定義書の存在確認**:
```bash
Glob: "docs/requirements/**/*.{md,pdf,txt,xlsx,docx}"
Glob: "docs/references/**/*.{md,pdf,txt,xlsx,docx}"
```

2. **Serenaメモリの初期化状態確認**:
```bash
Glob: ".serena/memories/**/*.md"
```

**判断ロジック**:
- ✅ 要件定義書あり + Serenaメモリ空 → Phase 0.1実行
- ❌ 要件定義書なし → Phase 0.1スキップ（Phase 0.2へ）
- ❌ Serenaメモリ既存 → Phase 0.1スキップ（既に初期化済み）

---

### Step 1: 要件定義書の検出

**検出対象**:
1. `docs/requirements/` 配下のファイル
2. `docs/references/` 配下のファイル（要件定義書.md等）
3. チャット履歴（ユーザーが直接記述した要件）

**検出方法**:
```bash
# Markdown/PDF/テキストファイルを検出
Glob: "docs/requirements/**/*.{md,pdf,txt,xlsx,docx}"
Glob: "docs/references/**/*.{md,pdf,txt,xlsx,docx}"
```

**検出結果例**:
```
docs/requirements/project-requirements.md
docs/requirements/user-stories.md
docs/references/要件定義書.md
docs/specs/api-spec.yaml
```

---

### Step 2: 要件の読み込み

**ファイルがある場合**:
```bash
# 要件定義書を読み込み
Read: docs/requirements/project-requirements.md
Read: docs/references/要件定義書.md

# 仕様書も読み込み（ある場合）
Read: docs/specs/api-spec.yaml
Read: docs/specs/database-schema.sql
```

**ファイルがない場合**:
```markdown
要件定義書が見つかりませんでした。

【質問】
1. 要件定義書はありますか？
   A. ある → ファイルパスを教えてください
   B. ない → 口頭で要件を教えてください
   C. 後で追加する → Phase 0.1 をスキップ
```

**選択肢Bの場合（口頭要件）**:
```markdown
プロジェクトの要件を教えてください：

【質問項目】
1. プロジェクトの目的は？（何を実現したいか）
2. 主要機能は？（3-5個）
3. 想定ユーザーは？（管理者/一般ユーザー/外部ユーザー等）
4. 技術スタックの希望は？（フロントエンド/バックエンド/DB）
5. 非機能要件は？（パフォーマンス/セキュリティ/スケーラビリティ等）
```

---

### Step 3: plannerエージェント呼び出し

**planner実行**:
```bash
Task:planner(prompt: "
以下の要件定義書を分析し、プロジェクト計画を作成してください。

【要件定義書】
{ファイル内容 または ユーザー回答内容}

【分析タスク】
1. プロジェクト概要・目的を抽出
2. 主要機能一覧を整理
3. 技術的要件・非機能要件を特定
4. Phase階層を生成（Phase 0 → Phase 1 → ...）
5. 各Phaseの推定工数を算出
6. API契約の初期版を作成（可能な範囲で）
7. データベーススキーマの初期版を作成（可能な範囲で）

【成果物】
- .serena/memories/project/project_overview.md
- .serena/memories/project/requirements_summary.md
- .serena/memories/specifications/api_contracts.md
- .serena/memories/specifications/database_schema.md
- .serena/memories/project/phase_hierarchy.md
")
```

---

### Step 4: Serenaメモリへの保存

**plannerが以下のファイルを生成**:

#### 1. `.serena/memories/project/project_overview.md`
```markdown
# プロジェクト概要

## プロジェクトの目的
{目的}

## 主要機能
1. {機能1}
2. {機能2}
...

## 想定ユーザー
- 管理者: {役割}
- 一般ユーザー: {役割}

## 技術スタック（推奨）
- Frontend: {技術}
- Backend: {技術}
- Database: {技術}
```

#### 2. `.serena/memories/project/requirements_summary.md`
```markdown
# 要件サマリー

## 機能要件
...

## 非機能要件
...

## 画面一覧
...

## データベーステーブル
...
```

#### 3. `.serena/memories/project/phase_hierarchy.md`
```markdown
# Phase階層（プロジェクト固有）

## Phase 0: プロジェクト基盤構築
- Phase 0.0: GitHubリポジトリ初期化
- Phase 0.1: 要件定義書分析
- Phase 0.2: 技術スタック決定
- Phase 0.3: 環境変数・MCP設定

## Phase 1: {機能グループ1}
- Phase 1.1: {サブ機能}
- Phase 1.2: {サブ機能}

## Phase 2: {機能グループ2}
...
```

#### 4. `.serena/memories/specifications/api_contracts.md`（初期版）
```markdown
# API契約（初期版）

## 認証API
### POST /api/auth/login
Request: ...
Response: ...

...
```

#### 5. `.serena/memories/specifications/database_schema.md`（初期版）
```markdown
# データベーススキーマ（初期版）

## users テーブル
...

...
```

---

### Step 5: 完了メッセージ

```markdown
✅ Phase 0.1 完了: 要件定義書分析・Serenaメモリ初期化

【成果物】
- プロジェクト概要: .serena/memories/project/project_overview.md
- 要件サマリー: .serena/memories/project/requirements_summary.md
- Phase階層: .serena/memories/project/phase_hierarchy.md
- API契約（初期版）: .serena/memories/specifications/api_contracts.md
- DB設計（初期版）: .serena/memories/specifications/database_schema.md

【次のステップ】
Phase 0.2: 技術スタック決定を開始します。
```

---

### ユースケース

#### ケース1: 要件定義書ファイルがある場合
```
docs/requirements/project-requirements.md が存在
  ↓
ファイルを読み込み
  ↓
plannerで分析
  ↓
Serenaメモリに保存
  ↓
Phase 0.2へ
```

#### ケース2: チャットで要件を記述した場合
```
ユーザー: 「工数管理システムを作りたい...」
  ↓
要件定義書ファイルなし検出
  ↓
チャット履歴から要件を抽出
  ↓
plannerで分析
  ↓
Serenaメモリに保存
  ↓
（オプション）docs/requirements/project-requirements.md を生成
  ↓
Phase 0.2へ
```

#### ケース3: 要件定義書を後で追加する場合
```
Phase 0.1 をスキップ
  ↓
Phase 0.2, 0.3 を完了
  ↓
Phase 1 開始前にユーザーが要件定義書を追加
  ↓
Phase 1 開始時に「要件定義変更検知」が発動
  ↓
planner再実行
```

---


### Step 0: 要件定義変更検知（自動）

**実行内容**:
```bash
# project_requirements.md と system_state.md を読み込み
Read: project_requirements.md
Read: .serena/memories/system/system_state.md

# 前回Phase完了時の要件と比較
Read: .serena/memories/project/phase{前回番号}_*.md
```

**要件変更検知条件**:
- `project_requirements.md` に新しい要件が追加されている
- 技術スタックが変更されている（例: JWT → Auth0）
- アーキテクチャ変更が記載されている
- 既存機能の大幅な仕様変更

**検知時の動作**:
```markdown
⚠️ 要件定義変更を検知しました。

【変更内容】
- 認証方式: JWT → Auth0

【影響の可能性】
- Phase 2.3: 認証API実装（影響あり）
- Phase 2.4: トークン検証（影響あり）
- Phase 3.1: ログイン画面（影響あり）

要件定義変更フローを発動しますか？
1. はい - REQUIREMENTS_CHANGE.md のフローに移行
2. いいえ - 現在のPhaseを継続（非推奨）
3. 後で - Technical Debt登録 + 現在のPhaseを継続
```

**選択肢の処理**:

**1. 「はい」選択時**:
→ [REQUIREMENTS_CHANGE.md](./REQUIREMENTS_CHANGE.md) のフローに移行

**2. 「いいえ」選択時**:
→ 現在のPhaseを継続（要件変更を無視）

**3. 「後で」選択時**:
→ Technical Debt登録
```bash
Write: reports/technical-debt.md

追加内容:
## 要件定義変更（未対応）

- **登録日**: 2025-01-27
- **変更内容**: 認証方式 JWT → Auth0
- **影響Phase**: Phase 2.3, 2.4, 3.1
- **優先度**: 高
- **対応予定**: Phase 5完了後
```

---

### Step 1: 前回の引き継ぎ情報を読み込み

**優先順位**:
1. `next_phase_prompt.md` があれば読む
2. なければSerenaメモリ `project/current_context.md` を確認

```bash
# next_phase_prompt.md を読む
Read: next_phase_prompt.md

# ない場合はSerenaメモリ確認
mcp__serena__activate_project(project: "{{PROJECT_NAME}}")
mcp__serena__read_memory(memory_file_name: "project/current_context.md")
```

### Step 2: 推奨タスクを自動選択

**next_phase_prompt.md の形式**:
```markdown
## 今セッションの推奨タスク

### 🔴 優先度: 高
1. ユーザーロール管理API実装
2. バグ修正: ログイン画面のバリデーション

### 🟡 優先度: 中
1. E2Eテスト追加: ダッシュボード

### 🟢 優先度: 低
1. ドキュメント更新
```

**自動選択ロジック**:
- **優先度: 高** の最初のタスクを選択
- 高がなければ **優先度: 中** の最初のタスク
- 中もなければ **優先度: 低** の最初のタスク

### Step 3: 詳細計画を自動作成（TodoWrite）

選択したタスクに基づいて、詳細な実装計画を自動作成します。

**計画作成手順**:
1. **Explore（探索）**: 関連ファイルを読む
2. **Analyze（分析）**: 影響範囲を特定
3. **Plan（計画）**: TodoWriteで実装ステップをリスト化

**TodoWrite例**:
```markdown
TodoWrite:
1. backend/app/api/users.py の CRUD API実装
2. backend/tests/test_users.py のテスト作成（TDD）
3. frontend/src/app/users/page.tsx の UI実装
4. E2Eテスト実行・確認
5. コードレビュー（code-reviewer）
6. セキュリティスキャン（sec-scan）
7. コミット&PR作成
```

### Step 4: 自動的に実装フェーズへ移行

**重要**: ユーザー承認は不要。計画作成後、自動的に実装を開始します。

**移行時のログ出力**:
```markdown
✅ 計画フェーズ完了

今セッションの目標: ユーザーロール管理API実装

実装タスク:
1. backend/app/api/users.py の CRUD API実装
2. backend/tests/test_users.py のテスト作成（TDD）
...

実装フェーズを開始します。
```

---

## ② 実装フェーズ（自動実行）

詳細: [ai-rules/WORKFLOW.md](./WORKFLOW.md)

### 実行内容

TodoWriteで作成した計画に沿って、順次実装を進めます。

**エージェント自動呼び出し**:
- バックエンド実装 → `impl-dev-backend`
- フロントエンド実装 → `impl-dev-frontend`
- テスト作成 → `qa-unit` / `qa-integration`
- E2Eテスト → `playwright-test-planner` → `playwright-test-generator`
- コードレビュー → `code-reviewer`
- セキュリティスキャン → `sec-scan`

### エラー時の自動修復（ループ対策あり）

**E2Eテスト失敗**:
- 同一パターン3回まで自動修復
- 3回失敗 → QUARANTINE（隔離）

**セキュリティ脆弱性**:
- Critical: 7回目で相談、最大10回
- High: 最大3回
- Medium: 1回のみ

**アプリケーションバグ**:
- 同一パターン3回まで自動修復
- 3回失敗 → ユーザー相談（6回まで延長可能）

### 実装完了条件

以下のすべてを満たしたら実装フェーズ完了:
- [ ] TodoWriteのタスクがすべて完了
- [ ] テストがすべて合格（E2E含む）
- [ ] Lintエラーなし
- [ ] セキュリティスキャン完了（Critical/High問題なし）

**完了時のログ出力**:
```markdown
✅ 実装フェーズ完了

達成内容:
- ユーザーロール管理API実装完了
- ユニットテスト: 15件合格 / 15件
- E2Eテスト: 3件合格 / 3件
- セキュリティスキャン: Critical 0件、High 0件

まとめフェーズを開始します。
```

---

## ③ まとめフェーズ（自動実行）

詳細: [ai-rules/PHASE_COMPLETION.md](./PHASE_COMPLETION.md)

### 実行内容

1. **達成内容サマリー作成**
2. **KPI記録**（Pass Rate、Test Debt Ratio等）
3. **学んだこと整理**
4. **次回推奨タスク作成**
5. **Serenaメモリ更新**
6. **システム状態更新**（技術スタック変更時）
7. **Git commit & PR作成**

### 自動完了

まとめフェーズ完了後、自動的にセッション終了。

**完了時のログ出力**:
```markdown
✅ Phase完了

今回の成果:
- ユーザーロール管理API実装完了
- Pass Rate: 95.2%（前回: 92.1% / +3.1%）
- Test Debt Ratio: 4.8%

次回推奨タスク:
1. 🔴 高: フロントエンドUI実装
2. 🟡 中: E2Eテスト追加

Serenaメモリ更新完了
next_phase_prompt.md 更新完了
Git commit & PR作成完了

次回のセッションで会いましょう！
```

**音声通知**: Phase完了時に「ピポパ」音が鳴ります（600Hz → 800Hz → 1000Hz）

---

## ユーザー介入が必要な場合

以下の場合のみ、ユーザーに相談します：

### 1. Critical問題が7回試行後も解決しない
```markdown
❓ Critical問題を7回試行しましたが解決できません。

【問題】
- CVE-2025-12345: 依存パッケージの脆弱性

【試行内容】
1. パッケージ更新（失敗: 破壊的変更あり）
2. 代替パッケージ検討（失敗: 該当なし）
...

【選択肢】
1. 続行する（さらに3回試行、最大10回まで）
2. Technical Debt登録（後で対応）
3. セッション停止（手動で対応）

どうしますか？
```

### 2. 同一バグが3回連続失敗
```markdown
❓ 同じバグが3回連続で修正できませんでした。

【バグ】
- pattern_042: TimeoutError in /dashboard

【試行内容】
1. waitForLoadState追加（失敗）
2. timeout延長（失敗）
3. セレクタ変更（失敗）

【選択肢】
1. 続行する（さらに3回、最大6回まで）
2. 手動で修正
3. Technical Debt登録

どうしますか？
```

### 3. QUARANTINE（隔離）発生
```markdown
⚠️ E2Eテストを隔離しました。

【隔離理由】
- Smoke Test失敗（修復後の検証で問題発生）

【隔離期間】
- 推奨: 3日（人間が修正PRを作成するまで）

【隔離ファイル】
- .serena/memories/testing/quarantine/dashboard_20250127.md

次回セッションでは、このテストをスキップします。
人間が修正PR作成後、quarantine/*.md を削除してください。
```

---

## 関連ドキュメント

- [ai-rules/WORKFLOW.md](./WORKFLOW.md) - 実装フェーズ詳細
- [ai-rules/PHASE_COMPLETION.md](./PHASE_COMPLETION.md) - まとめフェーズ詳細
- [ai-rules/REQUIREMENTS_CHANGE.md](./REQUIREMENTS_CHANGE.md) - 途中で要件変更が発生した場合
- [CLAUDE.md](../CLAUDE.md) - 全体設定

---

## トラブルシューティング

### Q: next_phase_prompt.md がない場合は？

A: Serenaメモリ `project/current_context.md` を確認し、前回の作業内容から推測して自動的にタスクを選択します。

### Q: 推奨タスクがすべて完了している場合は？

A: 以下の優先順位で新しいタスクを自動選択:
1. Technical Debt（`reports/technical-debt.md`）から選択
2. テストカバレッジ向上（未テストの箇所）
3. ドキュメント整備
4. リファクタリング候補

### Q: エラーが多発してセッションが進まない場合は？

A: 自動修復ループ対策が働き、一定回数試行後にユーザーに相談します。ユーザーが「セッション停止」を選択すれば、その時点でまとめフェーズに移行します。

---

## セッション自律実行の哲学

### 基本原則

1. **ユーザーは見守るだけ**
   - Phase開始から完了まで、基本的にユーザー介入不要
   - エラー時のみ相談

2. **計画 → 実装 → まとめ の3段階**
   - 各フェーズを自動的に遷移
   - フェーズ間の承認不要

3. **失敗は学習の機会**
   - エラー発生時は自動修復を試みる
   - 修復失敗はLearning Memoryに記録
   - 次回セッションで同じエラーを回避

4. **安全第一**
   - ループ対策で無限実行を防ぐ
   - Critical問題は慎重に対応
   - QUARANTINE（隔離）で本番への影響を防ぐ

### 目指す世界

```
ユーザー: 「開始」

Claude: （next_phase_prompt.md読み込み）
Claude: （計画フェーズ自動実行）
Claude: （実装フェーズ自動実行）
Claude: （まとめフェーズ自動実行）
Claude: 「✅ Phase完了！」
（ピポパ♪）

ユーザー: 「おつかれ！」
```

これが理想のセッションです。

---

## Phase 0.2: 技術スタック決定（自動・Phase 0 のみ）

**実行タイミング**: Phase 0.1（要件定義書分析）の直後

**目的**:
- プロジェクトの技術スタックを決定
- デプロイプラットフォームを推奨
- 外部サービス設定手順をドキュメント化
- 技術スタックをSerenaメモリに保存

**実行エージェント**: planner + deployment-agent

---

### Step 1: deployment-agent 実行

**planner が deployment-agent を呼び出し**:
```bash
Task:deployment-agent(prompt: "要件定義書を基にデプロイ要件をヒアリングし、技術スタックとデプロイプラットフォームを推奨してください")
```

**deployment-agent の実行内容**:

#### 1-1. 要件サマリー読み込み
```bash
mcp__serena__read_memory(memory_name: "project/requirements_summary.md")
```

#### 1-2. デプロイ要件ヒアリング

deployment-agent が以下をユーザーに質問：

```markdown
## デプロイ要件ヒアリング

Phase 0.2で技術スタックを決定します。以下の質問にお答えください：

### 1. 予算
- A. 無料枠のみ
- B. $10-50/月
- C. $50以上/月
- D. おまかせ

### 2. トラフィック予測
- A. 低（〜1000 req/day）
- B. 中（〜10k req/day）
- C. 高（10k〜 req/day）
- D. おまかせ

### 3. チーム規模
- A. 個人開発
- B. 2-5人
- C. 6人以上

### 4. Docker使用希望
- A. Yes（Docker Compose使用）
- B. No（直接デプロイ）
- C. おまかせ

### 5. SLA要件
- A. スリープ許容（無料枠）
- B. 常時稼働必須
```

#### 1-3. 技術スタック推奨

deployment-agent が要件に基づいて技術スタックを推奨：

**例（無料枠 + 個人開発 + 低トラフィック）**:
```markdown
## 推奨技術スタック

### フロントエンド
- **フレームワーク**: Next.js 14.2.5 (App Router)
- **ホスティング**: Vercel（無料枠）

### バックエンド
- **フレームワーク**: FastAPI (Python 3.12)
- **ホスティング**: Render（無料枠・スリープあり）

### データベース
- **サービス**: Supabase（無料枠）
  - PostgreSQL 15
  - Auth + Storage統合

### CI/CD
- GitHub Actions（無料枠）

【推奨理由】
- 全て無料枠で構築可能
- Vercel + Supabaseは相性が良い
- Renderの無料枠はスリープするが、個人開発には十分
```

#### 1-4. ユーザー承認

```markdown
上記の技術スタックで進めてよろしいでしょうか？

【選択肢】
A. 承認（このまま進める）
B. 一部変更したい
C. 全面的に見直したい
```

#### 1-5. deployment_plan.md 生成

deployment-agent が以下のドキュメントを生成：

**`.serena/memories/deployment/deployment_plan.md`**:
```markdown
# デプロイプラン

生成日時: 2025-10-27

## 技術スタック

### フロントエンド
- Next.js 14.2.5 + Vercel

### バックエンド
- FastAPI + Render

### データベース
- Supabase (PostgreSQL + Auth + Storage)

## デプロイフロー

### Phase 1開始前の準備
1. Supabaseプロジェクト作成
2. Vercelプロジェクト接続
3. Renderプロジェクト作成

### Phase 1〜N
- GitHub Push → GitHub Actions → 自動テスト → 自動デプロイ

## 外部サービス設定手順

詳細: [ENV_SETUP_GUIDE.md](../../ai-rules/ENV_SETUP_GUIDE.md)
```

---

### Step 2: 技術スタックの確定

**planner が Serenaメモリに保存**:

```bash
mcp__serena__write_memory(
  memory_name: "system/tech_stack.md",
  content: "
# 技術スタック

生成日時: 2025-10-27
決定者: deployment-agent + planner

## フロントエンド
- **フレームワーク**: Next.js 14.2.5 (App Router)
- **言語**: TypeScript 5.5
- **スタイリング**: Tailwind CSS 3.4
- **UI コンポーネント**: shadcn/ui
- **状態管理**: Zustand 4.5
- **HTTP クライアント**: Axios 1.7
- **ホスティング**: Vercel（無料枠）

## バックエンド
- **フレームワーク**: FastAPI 0.111
- **言語**: Python 3.12
- **バリデーション**: Pydantic v2
- **非同期**: asyncio + httpx
- **ホスティング**: Render（無料枠）

## データベース
- **メインDB**: Supabase (PostgreSQL 15)
- **認証**: Supabase Auth
- **ストレージ**: Supabase Storage
- **ホスティング**: Supabase（無料枠）

## CI/CD
- **プラットフォーム**: GitHub Actions
- **トリガー**: main ブランチへの Push

## 選択理由
- 無料枠で構築可能
- 個人開発に最適
- Vercel + Supabase + Renderの組み合わせは相性が良い

## Phase 1開始前の準備
1. Supabaseプロジェクト作成（手動）
2. Vercelプロジェクト接続（手動）
3. Renderプロジェクト作成（手動）
4. 環境変数設定（手動）

詳細: deployment_plan.md
"
)
```

---

### Step 3: system_state.md 初期化

**実行内容**:
```bash
mcp__serena__write_memory(
  memory_name: "system/system_state.md",
  content: "
# システム状態

最終更新: {YYYY-MM-DD}

---

## 技術スタック概要

- **Frontend**: Next.js 14.2.5 (TypeScript)
- **Backend**: FastAPI 0.111 (Python 3.12)
- **Database**: Supabase (PostgreSQL 15)
- **Hosting**: Vercel + Railway

詳細: `.serena/memories/system/tech_stack.md`

---

## プロジェクト進捗

- **Phase 0**: プロジェクト基盤構築（進行中）
- **Phase 1**: 未着手
"
)
```

---

### Step 4: 次のPhaseへ

**planner が報告**:
```markdown
✅ Phase 0.2: 技術スタック決定 完了

【決定内容】
- Frontend: Next.js 14 + TypeScript + Vercel
- Backend: FastAPI + Python 3.12 + Render
- Database: Supabase (PostgreSQL + Auth + Storage)
- CI/CD: GitHub Actions

【成果物】
- .serena/memories/system/tech_stack.md
- .serena/memories/system/system_state.md
- .serena/memories/deployment/deployment_plan.md

【Phase 1開始前の準備（手動）】
Phase 0完了後、Phase 1開始前に以下の外部サービス作成が必要です：
1. Supabaseプロジェクト作成
2. Vercelプロジェクト接続
3. Renderプロジェクト作成
4. 環境変数設定

詳細な手順は deployment_plan.md および ENV_SETUP_GUIDE.md を参照してください。

【次のステップ】
Phase 0.3: 技術スタック検証・MCP設定を開始します。
```

---

## Phase 0.3: 技術スタック検証・MCP設定（自動・Phase 0 のみ）

**実行タイミング**: Phase 0.2（技術スタック決定）の直後

**目的**:
- 技術スタックの最新情報を確認・ベストプラクティス取得
- 技術スタックに対応するMCPサーバーを自動検索
- 環境変数テンプレートファイルを自動生成

**実行エージェント**: planner + tech-stack-validator + mcp-finder

---


### Step 1: tech-stack-validator 実行

**planner が tech-stack-validator を呼び出し**:
```bash
Task:tech-stack-validator(prompt: "Phase 0.2で決定した技術スタックを最新情報で検証してください")
```

**tech-stack-validator の実行内容**:

#### 1-1. 技術スタック読み込み
```bash
mcp__serena__read_memory(memory_name: "system/tech_stack.md")
```

#### 1-2. WebSearchで最新情報確認

各技術の最新バージョン・ベストプラクティスを確認：

- **Next.js**: 最新安定版、App Router推奨パターン
- **FastAPI**: 最新バージョン、Pydantic v2対応
- **Supabase**: 最新機能、Row Level Security推奨設定
- **Vercel/Render**: デプロイ最新ベストプラクティス

#### 1-3. セキュリティ脆弱性確認

CVEデータベースで既知の脆弱性をチェック

#### 1-4. tech_best_practices.md 生成

```bash
mcp__serena__write_memory(
  memory_name: "system/tech_best_practices.md",
  content: "
# 技術スタック ベストプラクティス

生成日時: 2025-10-27
有効期限: 2025-01-25（90日間キャッシュ）

## Next.js 14.2.5

### 推奨設定
- App Router使用
- Server Components優先
- Dynamic Imports for Client Components

### セキュリティ
- CSP設定推奨
- 環境変数は NEXT_PUBLIC_ prefix

### パフォーマンス
- Image Optimization有効化
- Metadata API使用

## FastAPI 0.111

### 推奨設定
- Pydantic v2使用
- async/await優先

### セキュリティ
- CORS設定必須
- JWT検証ミドルウェア

## Supabase

### 推奨設定
- Row Level Security (RLS)有効化
- Realtime有効化

### セキュリティ
- Service Role Key絶対非公開
- Anon Keyは公開可能だがRLSで保護

参考: WebSearch結果（URL一覧）
"
)
```

---

### Step 2: mcp-finder 実行

**planner が mcp-finder を呼び出し**:
```bash
Task:mcp-finder(prompt: "tech_stack.mdに基づいて必要なMCPサーバーを検索してください")
```

**mcp-finder の実行内容**:

#### 2-1. 技術スタックから外部サービス抽出

```bash
mcp__serena__read_memory(memory_name: "system/tech_stack.md")
```

抽出結果:
- **Supabase** → Supabase MCP必要
- **GitHub** → GitHub MCP必要（既に設定済み）
- **Vercel** → 専用MCP不要（CLI直接使用）
- **Render** → 専用MCP不要（CLI直接使用）

#### 2-2. MCP検索

Smithery.ai / npm / GitHub でMCP検索

**検索結果例**:
```markdown
## 検出されたMCPサーバー（2件）

### 1. Supabase MCP ⭐⭐⭐
- **URL**: https://mcp.supabase.com/mcp
- **認証**: OAuth（ブラウザログイン）
- **信頼性**: 公式
- **必要な設定**: なし（OAuth自動）

### 2. GitHub MCP ⭐⭐⭐
- **URL**: https://api.githubcopilot.com/mcp
- **認証**: GitHub Copilot統合
- **信頼性**: 公式
- **必要な設定**: GitHub Copilot サブスクリプション
```

#### 2-3. mcp_setup_guide.md 更新

既存の [MCP_SETUP_GUIDE.md](./MCP_SETUP_GUIDE.md) を技術スタックに応じて更新（必要に応じて）

---

### Step 3: 環境変数テンプレート作成

**planner が実行**:

#### 3-1. 技術スタックから必要な環境変数を抽出

```bash
mcp__serena__read_memory(memory_name: "system/tech_stack.md")
```

**抽出する環境変数**:
- **アプリケーション用**: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`（backend/frontend用）
- **その他**: 技術スタックに応じて

**注意**: MCP用環境変数は不要（GitHub/Supabase/Codex全てOAuth認証）

#### 3-2. テンプレートファイル生成

##### 1. `backend/.env.example`（FastAPI用）
```bash
Write: backend/.env.example
```

内容:
```env
# Supabase（Phase 1で設定）
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# JWT
JWT_SECRET=your-jwt-secret-here

# CORS
ALLOWED_ORIGINS=http://localhost:3000

# Server
HOST=0.0.0.0
PORT=8000
ENV=development
```

##### 2. `frontend/.env.local.example`（Next.js用）
```bash
Write: frontend/.env.local.example
```

内容:
```env
# Supabase（Phase 1で設定）
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# API
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api

# Environment
NEXT_PUBLIC_ENV=development
```

#### 3-3. .gitignore更新

```bash
Edit: .gitignore
```

追加内容:
```
# Environment variables
.env
.env.local
backend/.env
frontend/.env.local

# Keep templates
!.env.example
!.env.local.example
```

---

### Step 4: Git commit

```bash
git add backend/.env.example frontend/.env.local.example .gitignore .serena/memories/
git commit -m "feat: Phase 0.3完了（技術スタック検証・MCP設定）

- tech-stack-validator実行: 最新情報確認・ベストプラクティス取得
- mcp-finder実行: Supabase/GitHub MCP検出
- backend/.env.example作成（FastAPI用）
- frontend/.env.local.example作成（Next.js用）
- .gitignore更新

成果物:
- .serena/memories/system/tech_best_practices.md
- backend/.env.example
- frontend/.env.local.example

⚠️ Phase 0未完了: Phase 0.4（プロジェクト構造生成）が必要

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Step 5: 次のPhaseへ

**planner が報告**:
```markdown
✅ Phase 0.3: 技術スタック検証・MCP設定 完了

【実行内容】
- tech-stack-validator: 技術スタック最新情報確認
- mcp-finder: Supabase/GitHub MCP検出・設定
- 環境変数テンプレート作成

【成果物】
- .serena/memories/system/tech_best_practices.md
- backend/.env.example
- frontend/.env.local.example
- .gitignore更新

【検出されたMCPサーバー】
- Supabase MCP (OAuth認証)
- GitHub MCP (GitHub Copilot統合)
- Codex MCP (CLI事前ログイン)

【次のステップ】
Phase 0.4: プロジェクト構造生成を開始します。

⚠️ 重要: Phase 0.4では backend/, frontend/ ディレクトリを作成します
```

---

---

