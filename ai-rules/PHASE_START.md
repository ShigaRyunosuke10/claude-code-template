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

## ① 計画フェーズ（自動実行）

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
