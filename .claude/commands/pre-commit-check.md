---
description: コミット前の品質チェック（Auto-Fix付き）
allowed-tools: Task(lint-fix:*), Task(sec-scan:*), Task(code-reviewer:*), Write(reports/technical-debt.md), Read(reports/technical-debt.md)
---

# Pre-Commit Quality Check

コミット前の自動品質チェックと修正を実行します。

## 🎯 Purpose

1. **lint-fix**: 構文エラー・スタイル整形（0エラーまで自動修正）
2. **sec-scan**: セキュリティ脆弱性検出（Critical/High自動修正）
3. **code-reviewer**: 設計レビュー（優先度別自動修正）

---

## 📂 Review Scope

### ✅ レビュー対象（アプリケーションコードのみ）

- `backend/app/**/*.py` - バックエンドアプリケーションコード
- `frontend/src/**/*.{ts,tsx}` - フロントエンドアプリケーションコード
- `frontend/app/**/*.{ts,tsx}` - Next.js App Router

### ❌ レビュー対象外（自動スキップ）

**テストコード**:
- `backend/tests/**/*.py` - バックエンドテスト
- `frontend/tests/**/*.spec.ts` - E2Eテスト（Playwright）
- `frontend/src/**/*.test.ts` - ユニットテスト（Jest）

**ドキュメント**:
- `*.md` - Markdownファイル
- `docs/**/*` - ドキュメントディレクトリ
- `.serena/memories/**/*.md` - Serenaメモリ

**設定ファイル**:
- `*.json` - 設定ファイル（package.json, tsconfig.json等）
- `*.yaml`, `*.yml` - YAML設定ファイル

### 🎯 スキップ理由

| カテゴリ | 品質担保方法 | レビュー不要の理由 |
|---------|------------|------------------|
| テストコード | テスト実行結果 | 動けばOK、ループ防止 |
| ドキュメント | 手動レビュー | typo程度、重要度低 |
| 設定ファイル | Lint/Validate | 構文チェックで十分 |

### 🔄 コミットメッセージによる自動判定

```bash
git commit -m "feat: add feature"     # ← Hook発動、レビュー実行
git commit -m "fix: fix bug"          # ← Hook発動、レビュー実行
git commit -m "refactor: refactor"    # ← Hook発動、レビュー実行

git commit -m "test: fix test"        # ← Hook発動しない、レビューなし
git commit -m "docs: update README"   # ← Hook発動しない、レビューなし
```

**判定ロジック** (`.claude/settings.json:52`):
```json
"argsPattern": "git commit -m \"(?!test:|docs:).*\""
```

- `test:` で始まるコミット → Hook発動しない
- `docs:` で始まるコミット → Hook発動しない
- それ以外 → Hook発動、`/pre-commit-check` 実行

---

## 🔄 Auto-Fix Strategy

### Retry Limits by Priority

| Priority | Max Retries | Consultation | Failure Behavior |
|----------|-------------|--------------|------------------|
| 🚨 Critical | 10 | ✅ 7回目に相談 | ❌ Block (相談後選択) |
| ⚠️ High | 3 | ❌ なし | 📝 Technical Debt登録 |
| 💡 Medium | 1 | ❌ なし | ⚠️ Warning |
| 📝 Low | 0 | ❌ なし | ⚠️ Warning |

### Loop Detection

以下の場合、7回目でユーザーに相談:

1. **同じ問題3回連続**: 同一エラーメッセージが3回連続
2. **Issue数増加**: 修正後に問題数が増加

---

## 📝 Execution Flow

### 1. lint-fix (構文・スタイル)

```bash
Task:lint-fix(prompt: "変更ファイルのLint修正")
```

**動作**:
- ESLint, Prettier, Ruff, Black実行
- エラー0件になるまで自動修正
- 失敗時はブロック

---

### 2. sec-scan (セキュリティ)

```bash
Task:sec-scan(prompt: "セキュリティスキャン実行")
```

**動作**:
- npm audit, pip-audit実行
- Critical/High脆弱性を最大3回自動修正
- 未解決はTechnical Debt登録

---

### 3. code-reviewer (設計レビュー)

```bash
Task:code-reviewer(prompt: "設計レビュー実行")
```

**動作**:
- アーキテクチャ、ロジック、パフォーマンスレビュー
- Critical: 7回目で相談、最大10回
- High: 3回まで、未解決ならTechnical Debt
- Medium: 1回のみ

---

## 💬 Critical問題の相談プロンプト (7回目)

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

## 📂 Technical Debt Management

**File**: [reports/technical-debt.md](../reports/technical-debt.md)

**自動更新タイミング**:
- `/pre-commit-check`実行時
- 解決済み問題は自動削除
- 未解決のHigh問題を追加

**フォーマット**:
```markdown
## ⚠️ High (2件)

### [HIGH] N+1クエリ問題
**File**: `backend/app/api/invoices.py:78`
**Function**: `get_all_invoices()`
**Issue**: ループ内でDB問い合わせ
**Status**: 3回試行失敗
**First Detected**: 2025-10-24
**Recommendation**: `joinedload`使用

---
```

---

## ✅ Success Criteria

- [ ] lint-fix: 0 errors
- [ ] sec-scan: Critical/High 0件 or Technical Debt登録
- [ ] code-reviewer: Critical 0件 or Technical Debt登録
- [ ] Technical Debt file更新済み

---

## 🚫 Skip Option

ドキュメントのみの変更の場合:

```bash
git commit --no-verify -m "docs: update README"
```

**注意**: 実装コード変更時は必ず `/pre-commit-check` 実行してください。

---

## 使用例

### 通常の実装コミット

```bash
# 実装完了後
/pre-commit-check

# 全てパスした場合
git commit -m "feat: add user role management"
git push
```

### Critical相談時の対応

```
選択肢1を選択 → さらに3回自動修正試行
選択肢2を選択 → コミットブロック、手動で修正後に再度 /pre-commit-check
選択肢3を選択 → Technical Debt登録、コミット許可
```

---

## Notes

- **実行時間**: 通常5-10分（問題なしの場合）
- **失敗時**: 最大20分（Critical 10回試行の場合）
- **通知音**: セッション終了時に"pipopa"サウンド再生
