# Claude Code - {{PROJECT_NAME}}

エージェントベースの開発設定

---

## 基本設定

- **回答**: 日本語
- **リポジトリ**: {{GITHUB_OWNER}}/{{REPO_NAME}}
- **ポート**: フロントエンド {{FRONTEND_PORT}}、バックエンド {{BACKEND_PORT}}
- **タスク管理**: TodoWriteツールで進捗可視化（必須）

---

## セッション開始フロー

### 1. 引き継ぎ情報確認

```bash
# 優先順位: next_session_prompt.md → Serenaメモリ
mcp__serena__activate_project(project: "{{PROJECT_NAME}}")
mcp__serena__read_memory(memory_file_name: "project/current_context.md")
```

### 2. ワークフロー選択

- **Case A: 既存プロジェクト機能拡張** → [.claude/workflows/case-a-existing-project.md](./.claude/workflows/case-a-existing-project.md)
- **Case B: 新規プロジェクト立ち上げ** → [.claude/workflows/case-b-new-project.md](./.claude/workflows/case-b-new-project.md)
- **Case C: デプロイ** → [.claude/workflows/case-c-deployment.md](./.claude/workflows/case-c-deployment.md)

**重要**: 各Caseでワークフローファイルに記載の要件ヒアリングを実施してください。

### 3. 計画フェーズ（実装前・必須）

詳細: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)

1. **Explore**: 関連ファイルを読む
2. **Analyze**: 影響範囲を分析
3. **Plan**: TodoWriteで実装計画作成
4. **Approve**: ユーザーに計画提示して承認

---

## 要件変更フロー

開発途中に「新機能追加」「仕様変更」「設計見直し」等の発言があった場合、要件変更フローを開始。

詳細: [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md)

**簡易フロー**:
1. 作業一時保存 (`git commit -m "wip: ..."`)
2. 要件ヒアリング
3. planner実行（要件検証 → 計画生成）
4. 作業再開

**要件変更フロー不要なケース**: パラメータ変更、UI微調整、バグ修正、ドキュメント修正

---

## セッション完了時

詳細: [ai-rules/SESSION_COMPLETION.md](./ai-rules/SESSION_COMPLETION.md)

1. **Serenaメモリ更新**（Session KPI含む）
2. **next_session_prompt.md更新**
3. **Git commit & PR作成**（`/pre-commit-check` 実行）

**⚠️ 重要**: mainブランチへの直接pushは禁止

---

## エージェント一覧（14体）

詳細: [.claude/agents/](./.claude/agents/)

- **planner** - Epic+タスク+API契約生成
- **impl-dev-frontend** / **impl-dev-backend** - 実装
- **code-reviewer** - レビュー+FE/BE整合性チェック
- **qa-unit** / **qa-integration** - テスト作成
- **playwright-test-planner** / **playwright-test-generator** / **playwright-test-healer** - E2E
- **lint-fix** / **sec-scan** - 品質保証
- **doc-writer** / **release-manager** - ドキュメント・リリース
- **deployment-agent** - デプロイ全般

### プロジェクト固有コマンド

- **/docs-sync** - Serenaメモリ → 公式Docs同期
- **/pre-commit-check** - コミット前チェック（lint → sec-scan → code-reviewer）

---

## MCPサーバー

- **github** - PR/Issue管理
- **serena** - コードベース解析
- **playwright** - E2Eテスト
- **desktop-commander** - ファイルシステム操作
- **context7** - ライブラリドキュメント取得

詳細: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)

---

## ドキュメント構造

### 開発プロセス
- [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md) - 開発フロー詳細
- [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md) - 要件変更フロー
- [ai-rules/SESSION_COMPLETION.md](./ai-rules/SESSION_COMPLETION.md) - セッション完了手順
- [ai-rules/CONVENTIONS.md](./ai-rules/CONVENTIONS.md) - 命名規則・コミット規約

### ツール設定
- [.claude/settings.json](./.claude/settings.json) - Permissions & Hooks
- [.claude/workflows/](./.claude/workflows/) - ワークフローテンプレート（Case A/B/C)
- [.claude/agents/](./.claude/agents/) - エージェント定義（14体）
- [.claude/phases/ROLLOUT_GUIDE.md](./.claude/phases/ROLLOUT_GUIDE.md) - AI自律システム段階導入

### AI向け技術詳細
- [.serena/memories/specifications/](./.serena/memories/specifications/) - API/DB/アーキテクチャ仕様
- [.serena/memories/project/](./.serena/memories/project/) - セッション記録

### 人間向けドキュメント
- [docs/api/API.md](./docs/api/API.md) - APIリファレンス
- [docs/database/DATABASE.md](./docs/database/DATABASE.md) - データベーススキーマ

---

## Permissions & Hooks

設定: [.claude/settings.json](./.claude/settings.json)

**禁止事項**:
- `rm -rf /*` - 全削除禁止
- `git push --force main` - mainへのforce push禁止
- `.env*` ファイルへの書き込み禁止

**Hooks**:
- mainブランチへの直接コミット防止
- 実装後のテスト推奨
- E2Eテスト10件以上失敗で停止
- Critical脆弱性検出で警告

---

## Technical Debt 管理

未解決の問題: [reports/technical-debt.md](./reports/technical-debt.md)

`/pre-commit-check`実行時に自動更新。

---

## 参考リンク

- **ワークフロー詳細**: [ai-rules/WORKFLOW.md](./ai-rules/WORKFLOW.md)
- **要件変更**: [ai-rules/REQUIREMENTS_CHANGE.md](./ai-rules/REQUIREMENTS_CHANGE.md)
- **セッション完了**: [ai-rules/SESSION_COMPLETION.md](./ai-rules/SESSION_COMPLETION.md)
- **Case A/B/C**: [.claude/workflows/](./.claude/workflows/)
- **Phase Rollout**: [.claude/phases/ROLLOUT_GUIDE.md](./.claude/phases/ROLLOUT_GUIDE.md)
