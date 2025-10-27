# AI Rules - {{PROJECT_NAME}}

エージェントベースの開発ガイドライン

---

## 📁 ファイル構成

```
ai-rules/
├── README.md                   # 本ファイル（概要・クイックスタート）
├── WORKFLOW.md                 # 開発フロー詳細
├── REQUIREMENTS_CHANGE.md      # 要件変更フロー
├── PHASE_COMPLETION.md       # Phase完了手順
├── CONVENTIONS.md              # 命名規則・コミット規約
└── PROJECT_CUSTOMIZATION.md    # プロジェクト固有設定管理ガイド
```

---

## 🚀 クイックスタート

### 1. Phase開始

```bash
# 引き継ぎ情報確認
# 優先順位: next_phase_prompt.md → Serenaメモリ
mcp__serena__activate_project(project: "{{PROJECT_NAME}}")
mcp__serena__read_memory(memory_file_name: "project/current_context.md")
```

### 2. ワークフロー選択

- **既存プロジェクト機能拡張** → [../.claude/workflows/WORKFLOW.md](../.claude/workflows/WORKFLOW.md)
- **新規プロジェクト立ち上げ** → [../.claude/workflows/WORKFLOW.md](../.claude/workflows/WORKFLOW.md)
- **デプロイ** → [../.claude/workflows/WORKFLOW.md](../.claude/workflows/WORKFLOW.md)

### 3. 計画フェーズ（必須）

詳細: [WORKFLOW.md](./WORKFLOW.md)

1. **Explore**: 関連ファイルを読む
2. **Analyze**: 影響範囲を分析
3. **Plan**: TodoWriteで実装計画作成
4. **Approve**: ユーザーに計画提示して承認

### 4. ブランチ作成

```bash
git checkout -b <type>-<機能名>
# Type: feat-, fix-, refactor-, docs-
```

### 5. 実装

[CONVENTIONS.md](./CONVENTIONS.md) に従って命名

### 6. コミット前チェック

```bash
/pre-commit-check
```

### 7. PR作成・マージ

[WORKFLOW.md](./WORKFLOW.md) の「PR作成」を参照

### 8. Phase完了

詳細: [PHASE_COMPLETION.md](./PHASE_COMPLETION.md)

1. Serenaメモリ更新
2. next_phase_prompt.md更新
3. Git commit & PR作成

---

## ⚠️ 重要

- **mainブランチへの直接作業禁止**
- **コミット前に `/pre-commit-check` 必須**（`test:` と `docs:` 以外）
- **PR作成後に自動レビュー実行**
- **マージ後に `/docs-sync` 実行推奨**

---

## 📚 詳細ドキュメント

### 開発プロセス
- [WORKFLOW.md](./WORKFLOW.md) - 開発フロー詳細（Phase 1-6）
- [REQUIREMENTS_CHANGE.md](./REQUIREMENTS_CHANGE.md) - 要件変更フロー（開発途中の機能追加・仕様変更）
- [PHASE_COMPLETION.md](./PHASE_COMPLETION.md) - Phase完了手順（Serenaメモリ・Git・PR）
- [CONVENTIONS.md](./CONVENTIONS.md) - 命名規則・コミット規約
- [PROJECT_CUSTOMIZATION.md](./PROJECT_CUSTOMIZATION.md) - プロジェクト固有設定管理ガイド（テンプレートとの分離方法）

### ツール設定
- [../.claude/settings.json](../.claude/settings.json) - Permissions & Hooks
- [../.claude/workflows/](../.claude/workflows/) - ワークフローテンプレート（Case A/B/C）
- [../.claude/agents/](../.claude/agents/) - エージェント定義（14体）

---

## 🔗 関連リンク

- **CLAUDE.md**: [../CLAUDE.md](../CLAUDE.md) - 基本設定・Phase開始フロー
- **README.md**: [../README.md](../README.md) - プロジェクト概要・セットアップ
