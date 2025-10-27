# プロジェクト固有設定管理ガイド

テンプレートを崩さずに、プロジェクト固有の機能・ルール・ワークフローを管理する方法。

---

## 基本方針

1. **テンプレートは絶対に変更しない**（削除も含む）
2. **プロジェクト固有は明確に分離**（`.claude/project/`, `ai-rules-project/`）
3. **参照の優先順位を明示**（CLAUDE.mdに記載）
4. **不要なテンプレートは無視**（削除せず、CLAUDE.mdに明記）
5. **一つしか持てないファイルは直接編集**（`.mcp.json`, `CLAUDE.md`, `.claude/settings.json`, `.gitignore`）

---

## 編集方針の詳細

### 複数ファイル持てる場合（エージェント、ワークフロー、ルール等）

- **テンプレート**（`.claude/agents/`, `.claude/workflows/`, `ai-rules/`）: 変更禁止
- **プロジェクト固有**（`.claude/project/`, `ai-rules-project/`）: 自由に追加・削除

**例**:
- ❌ `.claude/agents/planner.md` を編集（禁止）
- ✅ `.claude/project/agents/payment-processor.md` を作成（推奨）

### 一つしか持てないファイル（設定ファイル等）

プロジェクト内で一つしか持てないファイルは**直接編集OK**:

| ファイル | 編集方針 | 例 |
|---------|---------|---|
| `.mcp.json` | 直接編集 | プロジェクト固有のMCPサーバー追加 |
| `CLAUDE.md` | プロジェクト固有セクション追加 | 「★ プロジェクト固有設定」セクション |
| `.claude/settings.json` | 直接編集 | プロジェクト固有のPermissions追加 |
| `.gitignore` | 直接編集 | プロジェクト固有の除外パターン追加 |
| `package.json` / `requirements.txt` | 直接編集 | プロジェクト固有の依存関係追加 |

**理由**: これらのファイルは複製できないため、テンプレート部分とプロジェクト固有部分を同一ファイル内で管理する。

---

## ディレクトリ構造

```
my-project/
├── CLAUDE.md                    # テンプレート + プロジェクト固有設定セクション
│
├── .claude/
│   ├── agents/                  # ★ テンプレート（14体）- 変更禁止
│   │   ├── planner.md
│   │   ├── code-reviewer.md
│   │   └── ...
│   │
│   ├── workflows/               # ★ テンプレート（動的にplannerが生成）- 変更禁止
│   │   ├── WORKFLOW.md
│   │   ├── WORKFLOW.md
│   │   └── WORKFLOW.md
│   │
│   ├── commands/                # ★ テンプレート - 変更禁止
│   │   ├── docs-sync.md
│   │   └── pre-commit-check.md
│   │
│   └── project/                 # ☆ プロジェクト固有
│       ├── agents/              # プロジェクト固有エージェント
│       ├── workflows/           # プロジェクト固有ワークフロー
│       ├── commands/            # プロジェクト固有コマンド
│       └── rules/               # プロジェクト固有ルール
│
├── ai-rules/                    # ★ テンプレート - 変更禁止
│   ├── WORKFLOW.md
│   ├── REQUIREMENTS_CHANGE.md
│   ├── PHASE_COMPLETION.md
│   └── CONVENTIONS.md
│
└── ai-rules-project/            # ☆ プロジェクト固有ルール
    ├── PAYMENT_WORKFLOW.md
    └── CUSTOM_CONVENTIONS.md
```

**凡例**:
- ★ = テンプレート（変更禁止）
- ☆ = プロジェクト固有（自由に追加・削除可能）

---

## 参照の優先順位

### CLAUDE.mdに明記

```markdown
## ★ プロジェクト固有設定

### 参照の優先順位

1. **プロジェクト固有** → `.claude/project/`, `ai-rules-project/`
2. **テンプレート（共通）** → `.claude/`, `ai-rules/`
```

### 優先順位の動作

- エージェント呼び出し時、プロジェクト固有が存在すればそちらを優先
- プロジェクト固有が存在しなければテンプレートを使用
- 両方存在する場合は、CLAUDE.mdの記載に従う

---

## プロジェクト固有エージェントの追加

### 追加フロー

1. **要件ヒアリング**（ユーザーが要望）
   - 「決済処理専用のエージェントを作りたい」
   - 「Stripe API連携を標準化したい」

2. **ファイル作成**
   ```bash
   touch .claude/project/agents/payment-processor.md
   ```

3. **ファイル内容作成**

   ```markdown
   # payment-processor

   決済処理専用エージェント

   ## 責任

   - Stripe API連携
   - 決済ログ記録
   - 決済エラーハンドリング
   - PCI DSS準拠の確認

   ## 使用タイミング

   - 決済機能の実装・変更時
   - 決済関連のバグ修正時
   - 決済フロー見直し時

   ## 呼び出し方法

   \`\`\`bash
   Task:payment-processor(prompt: "Stripe決済フローの実装")
   \`\`\`

   ## テンプレートエージェントとの連携

   - **planner**: 決済機能の計画立案時に連携
   - **impl-dev-backend**: 決済APIの実装時に連携
   - **code-reviewer**: 決済コードのレビュー時に連携

   ## プロジェクト固有ルール参照

   - [決済セキュリティルール](../.claude/project/rules/PAYMENT_RULES.md)
   ```

4. **CLAUDE.md更新**

   ```markdown
   ### プロジェクト固有エージェント

   - **payment-processor** - 決済処理専用エージェント
     - 詳細: [.claude/project/agents/payment-processor.md](../.claude/project/agents/payment-processor.md)
     - 責任: Stripe API連携、決済ログ記録、PCI DSS準拠確認
     - 連携: planner, impl-dev-backend, code-reviewer
   ```

5. **Git commit**
   ```bash
   git add .claude/project/agents/payment-processor.md CLAUDE.md
   git commit -m "feat: payment-processor エージェント追加

   - Stripe API連携専用エージェント
   - 決済フローの標準化
   - PCI DSS準拠確認機能

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

---

## プロジェクト固有ワークフローの追加

### 追加フロー

1. **要件ヒアリング**
   - 「決済処理の標準フローを定義したい」

2. **ファイル作成**
   ```bash
   touch .claude/project/workflows/payment-flow.md
   ```

3. **ファイル内容作成**

   ```markdown
   # 決済フロー（プロジェクト固有）

   Stripe連携の標準ワークフロー

   ## Phase 0: 要件定義

   **メインClaude Agentが質問**:
   1. 決済方法は？（クレジットカード / デビットカード / 口座振替）
   2. 決済タイミングは？（即時 / 定期 / 手動）
   3. 金額は？（固定 / 変動）

   ## Phase 1: 計画

   \`\`\`bash
   Task:planner(prompt: "決済機能の計画立案")
   \`\`\`

   ## Phase 2: 実装

   \`\`\`bash
   Task:payment-processor(prompt: "Stripe決済API実装")
   Task:impl-dev-frontend(prompt: "決済UI実装")
   \`\`\`

   ## Phase 3: セキュリティチェック

   \`\`\`bash
   Task:sec-scan(prompt: "決済コードのセキュリティスキャン")
   Task:code-reviewer(prompt: "PCI DSS準拠確認")
   \`\`\`
   ```

4. **CLAUDE.md更新**

   ```markdown
   ### プロジェクト固有ワークフロー

   - **決済フロー** - Stripe連携の標準ワークフロー
     - 詳細: [.claude/project/workflows/payment-flow.md](../.claude/project/workflows/payment-flow.md)
     - 使用タイミング: 決済機能の追加・変更時
   ```

---

## プロジェクト固有ルールの追加

### 追加フロー

1. **ファイル作成**
   ```bash
   touch .claude/project/rules/PAYMENT_RULES.md
   # または
   touch ai-rules-project/CUSTOM_CONVENTIONS.md
   ```

2. **ファイル内容作成**

   ```markdown
   # 決済セキュリティルール

   PCI DSS準拠のための開発規約

   ## 禁止事項

   - ❌ カード情報（番号、CVC、有効期限）をログに記録
   - ❌ カード情報をデータベースに平文保存
   - ❌ カード情報をURL パラメータに含める

   ## 必須事項

   - ✅ Stripe.js を使用してカード情報を直接Stripeに送信
   - ✅ 決済トークンのみをバックエンドに送信
   - ✅ 決済ログは暗号化して保存

   ## セキュリティチェックリスト

   - [ ] カード情報が平文で保存されていないか？
   - [ ] 決済API呼び出しにエラーハンドリングがあるか？
   - [ ] 決済ログに個人情報が含まれていないか？
   ```

3. **CLAUDE.md更新**

   ```markdown
   ### プロジェクト固有ルール

   - **決済セキュリティルール** - PCI DSS準拠
     - 詳細: [.claude/project/rules/PAYMENT_RULES.md](../.claude/project/rules/PAYMENT_RULES.md)
   ```

---

## 不要なテンプレート機能の明記

### 方針

- **削除しない** - テンプレートファイルは残す
- **明記する** - CLAUDE.mdに「使用しない」と明記
- **無視する** - 参照しなければ影響なし

### CLAUDE.md更新例

```markdown
### 不要なテンプレート機能（このプロジェクトでは使用しない）

- ❌ **deployment-agent** - デプロイは手動運用のため不使用
- ❌ **Case C ワークフロー** - デプロイワークフロー不使用
- ❌ **playwright-test-***  - E2Eテストは別ツール（Cypress）使用
```

---

## プロジェクト固有機能の削除

### 削除フロー

1. **影響範囲確認**
   - 他のワークフローから参照されていないか？
   - 他のエージェントから呼び出されていないか？

2. **ファイル削除**
   ```bash
   rm .claude/project/agents/payment-processor.md
   ```

3. **CLAUDE.md更新**
   - 「プロジェクト固有設定」セクションから削除

4. **Git commit**
   ```bash
   git commit -m "chore: payment-processor削除（決済機能廃止のため）"
   ```

---

## テンプレート更新時の対応

### テンプレートが更新された場合

1. **テンプレートファイルのみ更新**
   ```bash
   # テンプレートリポジトリから最新をpull
   cd ~/claude-code-template
   git pull origin main

   # プロジェクトにコピー（project/ は除外）
   rsync -av --exclude='.claude/project' \
             --exclude='ai-rules-project' \
             ~/claude-code-template/ ./
   ```

2. **プロジェクト固有は維持**
   - `.claude/project/` は触らない
   - `ai-rules-project/` は触らない
   - CLAUDE.mdの「プロジェクト固有設定」セクションは維持

3. **整合性確認**
   - 新しいテンプレートエージェントが追加されていないか？
   - 既存のテンプレートエージェントが削除されていないか？

---

## ベストプラクティス

### 1. プロジェクト固有は最小限に

- テンプレートで対応できる場合は、テンプレートを使う
- 本当に必要な場合のみプロジェクト固有を作成

### 2. ドキュメントを充実させる

- プロジェクト固有エージェント・ワークフローには詳細な説明を記載
- 使用タイミング・呼び出し方法を明記

### 3. テンプレートとの連携を明示

- プロジェクト固有エージェントがテンプレートエージェントと連携する場合は明記
- 参照するプロジェクト固有ルールがあれば明記

### 4. Git履歴を綺麗に保つ

- プロジェクト固有の追加・削除は明確なコミットメッセージ
- テンプレート更新とプロジェクト固有変更は別コミット

---

## 関連ドキュメント

- [CLAUDE.md](../CLAUDE.md) - プロジェクト固有設定セクション
- [README.md](../README.md) - テンプレート使用方法
- [WORKFLOW.md](./WORKFLOW.md) - 開発フロー詳細
