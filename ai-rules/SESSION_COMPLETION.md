# セッション完了時の手順

タスク完了後に必ず実行する手順。

---

## ① Serenaメモリ更新（必須）

### 実行方法

```bash
mcp__serena__write_memory(
  memory_name: "project/session{番号}_{内容}.md",
  content: "セッション完了報告の内容"
)
```

### 記載内容

**テンプレート**:

```markdown
# Session {番号} 完了報告

## 📊 Session KPI

- ✅ **Pass Rate**: XX.X% (前回: YY.Y% / 差分: ±Z.Z%)
  - 合格: XXテスト
  - 失敗: XXテスト
  - 全体: XXXテスト

- 📉 **Test Debt Ratio**: XX.X% (前回: YY.Y%)

- 🔄 **Regression Count**: X件
  - (セッション前に合格していたが、修正後に失敗したテスト数)

### KPI分析コメント
- ...

## 達成内容サマリー

- 機能A実装完了
- 機能B実装完了

## テスト結果

- ユニットテスト: XX件合格 / YY件
- 統合テスト: XX件合格 / YY件
- E2Eテスト: XX件合格 / YY件
- カバレッジ: XX%

## 学んだベストプラクティス

- ...

## 次回推奨タスク

1. タスクA（優先度: 高）
2. タスクB（優先度: 中）
3. タスクC（優先度: 低）

## 実装詳細

### 変更ファイル
- backend/app/api/users.py - ユーザーAPI実装
- frontend/src/app/users/page.tsx - ユーザー一覧UI実装

### 技術的な判断
- ...
```

### KPI計算方法

**E2Eテスト実行**:

```bash
cd frontend && npm run test:e2e
```

**計算式**:

- **Pass Rate** = 合格テスト数 / 全テスト数 × 100%
- **Test Debt Ratio** = 失敗テスト数 / 全テスト数 × 100%
- **Regression Count** = 新規失敗テスト数（前回合格 → 今回失敗）

---

## ② next_session_prompt.md更新（必須）

### 実行方法

```bash
Write:next_session_prompt.md
```

### 記載内容

**テンプレート**:

```markdown
# Next Session Prompt

## 📊 前回のテストKPI

- **Pass Rate**: XX.X%
- **Test Debt Ratio**: XX.X%
- **Regression Count**: X件

## 前回の成果

- 機能A実装完了
- ユニットテスト: XX件合格 / YY件
- E2Eテスト: XX件合格 / YY件
- カバレッジ: XX%

## 今セッションの推奨タスク

### 🔴 優先度: 高
1. タスクA - 説明

### 🟡 優先度: 中
1. タスクB - 説明

### 🟢 優先度: 低
1. タスクC - 説明

## 未解決の課題

- 課題A（Technical Debt登録済み）
- 課題B

## 参考情報

- [前回セッション記録](./.serena/memories/project/session{番号}_{内容}.md)
- [Technical Debt](../reports/technical-debt.md)
```

---

## ③ MCP設定（新サービス追加時のみ）

### 実行タイミング

以下の場合にMCP設定を実施:
- Phase 0.1.5（新規プロジェクト立ち上げ時）
- 開発途中で新しい外部サービスを追加した場合（例: Stripe決済追加）

### 実行方法

```bash
Task:mcp-finder(prompt: "{追加サービス名}に対応するMCPサーバーを検索して設定")

# 例: Stripe追加時
Task:mcp-finder(prompt: "Stripeに対応するMCPサーバーを検索して設定")
```

### mcp-finder 完了後の対応

mcp-finder がファイル生成を完了したら、**メインエージェントが以下を実施**:

#### 1. ユーザーへの提示

```markdown
MCP検索が完了しました！

以下のサービスに対応するMCPサーバーが見つかりました:
- Stripe（決済処理）⭐⭐⭐ 公式

詳細: mcp_search_report.md

Stripe MCPを設定しますか？（Y/n/後で設定）
```

#### 2. APIキー発行確認

```markdown
user: Y

A: Stripe MCP設定を開始します。

【必要な認証情報】
- STRIPE_SECRET_KEY（必須）

Stripe APIキーを発行済みですか？

未発行の場合は、以下の手順で発行してください:
1. https://dashboard.stripe.com/test/apikeys にアクセス
2. 「Create secret key」をクリック
3. キー名を入力（例: "claude-code-dev"）
4. シークレットキー（sk_test_...）をコピー

詳細: docs/mcp_setup_guide.md#stripe-mcp

（はい / いいえ / 後で設定）
```

#### 3. APIキー受け取り・設定

```markdown
user: はい

A: Stripeのシークレットキー（sk_test_...）を教えてください。
※ このキーは .env ファイルにのみ保存され、Gitには含まれません。

user: sk_test_abc123xyz...

A: （メインエージェントが実行）

1. .env ファイル更新
   ```bash
   # .env に追記
   STRIPE_SECRET_KEY=sk_test_abc123xyz...
   ```

2. .mcp.json 生成
   ```bash
   # .mcp.json.template から .mcp.json を生成
   # 環境変数参照形式で設定
   ```

3. .gitignore 確認
   ```bash
   # .env が .gitignore に含まれているか確認
   # 未登録の場合は自動追加
   ```

✅ Stripe MCP設定完了
```

#### 4. 接続テスト

```markdown
A: 接続テストを実行します...

（実行コマンド）
npx -y @stripe/mcp --api-key=%STRIPE_SECRET_KEY%

✅ Stripe MCP接続成功！

利用可能なツール:
- create_payment_link
- list_payment_links
- retrieve_payment_link
...
```

#### 5. セキュリティチェック

**メインエージェントが自動で実施**:

```markdown
1. ✅ .env が .gitignore に含まれているか確認
2. ✅ .env.example にプレースホルダーのみ記載されているか確認
   例: STRIPE_SECRET_KEY=sk_test_YOUR_KEY_HERE
3. ✅ APIキーがソースコードにハードコードされていないか警告
   - grep で "sk_test_", "sk_live_" 等を検索
   - 検出された場合は警告
4. ✅ README.md に「⚠️ .env ファイルを絶対にコミットしないこと」を明記
```

### 「後で設定」を選択した場合

```markdown
user: 後で設定

A: 了解しました。Stripe MCPは後で設定します。

✅ .env.example に STRIPE_SECRET_KEY プレースホルダー追加
✅ docs/mcp_setup_guide.md にセットアップ手順を記載
✅ README.md にセットアップ手順へのリンク追加

後で設定する際は、以下のコマンドを実行してください:
```bash
# .env ファイルに追記
STRIPE_SECRET_KEY=sk_test_YOUR_ACTUAL_KEY
```

詳細: docs/mcp_setup_guide.md#stripe-mcp
```

### 重要事項

- ⚠️ **mcp-finder はファイル生成のみ** - 実際のAPIキー設定はメインエージェントが担当
- ⚠️ **.env ファイルを絶対にGitにコミットしない** - .gitignore に必ず追加
- ⚠️ **テスト環境キーを使用** - 開発中は `sk_test_...` を使用
- ⚠️ **APIキーをソースコードにハードコードしない** - 必ず環境変数から読み込む

---

## ④ Git commit & PR作成（必須）

### 🚨 重要: 両リポジトリへのコミット&プッシュ

**テンプレート開発時は必ず両方のリポジトリにコミット&プッシュしてください**:

1. **テンプレートリポジトリ** (`claude-code-template/`)
2. **開発用リポジトリ** (`claude-code-dev/`) - サブモジュール更新

### コミット前チェック

**🚨 重要**: コミット前に `/pre-commit-check` を実行してください（`test:` と `docs:` 以外は必須）

```bash
/pre-commit-check
```

**スキップ可能なケース**:
- `test:` - テストコードのみ修正
- `docs:` - ドキュメントのみ修正

### コミットメッセージのPrefix

- `feat:` - 新機能（**レビュー必須**）
- `fix:` - バグ修正（**レビュー必須**）
- `refactor:` - リファクタリング（**レビュー必須**）
- `test:` - テストコードのみ修正（**レビュースキップ**）
- `docs:` - ドキュメントのみ修正（**レビュースキップ**）
- `chore:` - テンプレート更新・ビルド設定等（**レビュースキップ**）

### 実行コマンド

#### ① テンプレートリポジトリへのコミット&プッシュ

```bash
# テンプレートディレクトリに移動
cd claude-code-template

# ブランチ作成（未作成の場合）
git checkout -b <type>-<機能名>

# 変更をステージング
git add .

# コミット前チェック（test: と docs: 以外は必須）
/pre-commit-check

# コミット & プッシュ
git commit -m "feat: {内容}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin main
```

#### ② 開発用リポジトリへのサブモジュール更新

```bash
# 開発用リポジトリのルートに移動
cd ..

# サブモジュール更新
git submodule update --remote claude-code-template

# 変更をステージング
git add claude-code-template

# コミット & プッシュ
git commit -m "chore: テンプレート更新（{内容}）

サブモジュール claude-code-template を最新版に更新

## 更新内容

{テンプレートリポジトリのコミットメッセージ概要}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin main
```

### PR作成

```bash
mcp__github__create_pull_request(
  owner: "{{GITHUB_OWNER}}",
  repo: "{{REPO_NAME}}",
  title: "feat: {内容}",
  body: "## Summary
- 達成内容

## Test
- [x] Unit Test (100%)
- [x] Integration Test
- [x] E2E Test",
  head: "<type>-<機能名>",
  base: "main"
)
```

### PRマージ

```bash
# PR確認後、マージ
mcp__github__merge_pull_request(
  owner: "{{GITHUB_OWNER}}",
  repo: "{{REPO_NAME}}",
  pullNumber: {PR番号},
  merge_method: "squash"
)
```

### ⚠️ 重要

- **mainブランチへの直接pushは絶対禁止**（ドキュメント更新含む）
- `docs:` コミットは `/pre-commit-check` 不要（Hook発動しない）
- `test:` コミットも `/pre-commit-check` 不要（ループ防止）
- **テンプレート開発時**: 必ず両リポジトリ（template + dev）にコミット&プッシュ

---

## チェックリスト

### セッション完了前の確認

- [ ] Serenaメモリ更新完了（Session KPI含む）
- [ ] next_session_prompt.md更新完了
- [ ] `/pre-commit-check` 実行完了（test:/docs: 以外）
- [ ] 全テスト合格確認
- [ ] Git commit & PR作成完了
- [ ] mainブランチへの直接push回避確認
- [ ] **テンプレート開発時**: 両リポジトリ（template + dev）へのコミット&プッシュ完了

---

## 関連ドキュメント

- [WORKFLOW.md](./WORKFLOW.md) - 開発フロー詳細
- [CONVENTIONS.md](./CONVENTIONS.md) - 命名規則・コミット規約
- [planner.md](../.claude/agents/planner.md) - 計画エージェント
