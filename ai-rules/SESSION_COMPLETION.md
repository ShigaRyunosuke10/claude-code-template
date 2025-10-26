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

## ③ Git commit & PR作成（必須）

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

### 実行コマンド

```bash
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

git push -u origin <type>-<機能名>
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

---

## チェックリスト

### セッション完了前の確認

- [ ] Serenaメモリ更新完了（Session KPI含む）
- [ ] next_session_prompt.md更新完了
- [ ] `/pre-commit-check` 実行完了（test:/docs: 以外）
- [ ] 全テスト合格確認
- [ ] Git commit & PR作成完了
- [ ] mainブランチへの直接push回避確認

---

## 関連ドキュメント

- [WORKFLOW.md](./WORKFLOW.md) - 開発フロー詳細
- [CONVENTIONS.md](./CONVENTIONS.md) - 命名規則・コミット規約
- [planner.md](../.claude/agents/planner.md) - 計画エージェント
