# 要件定義変更フロー

開発途中に機能追加・仕様変更・設計見直しが発生した際の対応フロー。

**基本方針**:
- **独立した横断フロー** - Phase番号体系とは別の「要件定義変更モード」
- **完了済みPhaseは維持** - 新しいPhaseとして修正版を追加
- **影響範囲はplannerが自動判定** - 影響のあるPhaseのみ再計画
- **作業中Phaseは中断・保存** - 新しいPhaseとして最初から実装

---

## トリガー判定

### 要件変更フローが必要なケース

ユーザーが以下のような発言をした場合、メインClaude Agentが要件変更と判断:

- 「新機能を追加したい」
- 「機能の仕様を変更したい」
- 「設計を見直したい」
- アーキテクチャに影響する変更
- 既存機能の大幅な改修

### 通常の会話で対応（要件変更フロー不要）

以下は要件変更フローを使わず、直接対応:

- パラメータ変更（ポート番号、タイムアウト値など）
- UI微調整（色、サイズ、配置）
- バグ修正
- ドキュメント修正
- 小さなリファクタリング

---

## フロー全体像

```
Phase X.Y（作業中）
  ↓
要件変更検知（ユーザー宣言 or 自動検知）
  ↓
【要件定義変更モード発動】
  ↓
Phase 0: 作業の一時保存
Phase 1: 要件ヒアリング
Phase 2: planner 影響範囲分析
Phase 3: ユーザー承認
Phase 4: Phase階層再構築 + 復帰
  ↓
新しいPhaseに移行
```

---

## Phase 0: 要件定義変更モード発動

### トリガー

以下のいずれか:
1. ユーザーが要件変更を宣言
2. Phase開始時に要件変更を自動検知（詳細: [PHASE_START.md](./PHASE_START.md)）

### 実行内容

**メインClaude Agentが実行**:

1. **現在のPhase番号を記録**
   ```bash
   # 例: Phase 3.1
   現在のPhase: Phase 3.1（ログイン画面実装）
   ```

2. **現在の作業状態を確認**
   ```bash
   git status
   ```

3. **キリの良いところまで進める**（必要なら）
   - 例: 実装中の関数を完成させる
   - 例: 現在のテストケースを完了させる

4. **一時保存を実行**
   ```bash
   git add .
   git commit -m "wip: 要件変更前の一時保存（Phase 3.1 中断）

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

---

## Phase 1: 要件ヒアリング

**メインClaude Agentが質問**:

1. 変更・追加したい機能は何ですか？（具体的に）
2. 想定ユーザーは誰ですか？（管理者/一般ユーザー/etc.）
3. 既存機能との関連は？（独立/既存機能拡張/既存機能変更）
4. 優先度は？（高/中/低）
5. 期限はありますか？

**回答例**:
```markdown
1. 認証方式をJWTからAuth0に変更したい
2. 全ユーザー
3. 既存機能変更（認証システム全体）
4. 高
5. 2週間以内
```

---

## Phase 2: planner 影響範囲分析

### planner 実行

```bash
Task:planner(prompt: "要件変更の影響範囲を分析してください

【変更内容】
- 変更内容: {回答1}
- 想定ユーザー: {回答2}
- 既存機能との関連: {回答3}
- 優先度: {回答4}
- 期限: {回答5}

【現在の状況】
- 現在のPhase: Phase 3.1（ログイン画面実装）
- Phase階層: [以下に現在のPhase階層を貼り付け]

Phase 2.3: 認証API実装（JWT方式）✅ 完了
Phase 2.4: トークン検証ミドルウェア（JWT）✅ 完了
Phase 3.1: ログイン画面実装 🔄 作業中（50%完了）
Phase 3.2: ダッシュボード実装 ⏳ 未着手
...
")
```

### planner 内部動作

詳細: [planner.md Step 0.5](../.claude/agents/planner.md)

1. **Step 0: 要件不足チェック**実行
2. **Step 0.5: 影響範囲分析**実行
   - 変更内容の解析
   - 現在のPhase階層の読み込み
   - 影響のあるPhaseの特定
   - 完了済み/作業中/未着手の分類
   - 再計画後のPhase階層生成

### planner の出力例

```markdown
# 影響範囲分析レポート

## 📊 要件変更サマリー

- **変更内容**: 認証方式をJWTからAuth0に変更
- **影響度**: 大（認証システム全体）
- **優先度**: 高
- **期限**: 2週間以内

---

## ✅ 影響のあるPhase（完了済み）

### Phase 2.3: 認証API実装（JWT方式）✅
- **状態**: 完了済み
- **影響**: あり（JWT → Auth0に変更）
- **対応方針**: **新しいPhaseとして修正版を作成**
  - 元のPhase 2.3は維持（JWT実装として残す）
  - Phase 4.1として Auth0版を新規作成

### Phase 2.4: トークン検証ミドルウェア（JWT）✅
- **状態**: 完了済み
- **影響**: あり（JWT → Auth0トークン検証）
- **対応方針**: **新しいPhaseとして修正版を作成**
  - 元のPhase 2.4は維持
  - Phase 4.2として Auth0版を新規作成

---

## 🔄 影響のあるPhase（作業中）

### Phase 3.1: ログイン画面実装 🔄
- **状態**: 作業中（50%完了）
- **影響**: あり（JWT → Auth0 Universal Login）
- **対応方針**: **中断・保存 → 新しいPhaseとして最初から実装**
  - 現在の作業を中断（wip commit済み）
  - Phase 4.3として Auth0版を新規作成

---

## ⏳ 影響のあるPhase（未着手）

なし

---

## ⭕ 影響のないPhase

### Phase 3.2: ダッシュボード実装 ⏳
- **状態**: 未着手
- **影響**: なし（認証後の画面、認証方式に依存しない）
- **対応方針**: **継続**（Phase番号を繰り上げて Phase 5 として継続）

### Phase 3.3: ユーザー管理画面 ⏳
- **状態**: 未着手
- **影響**: なし
- **対応方針**: **継続**（Phase番号を繰り上げて Phase 6 として継続）

---

## 🔄 再計画後のPhase階層

### 既存Phase（維持）
```
Phase 2.3: 認証API実装（JWT方式）✅ → そのまま維持
Phase 2.4: トークン検証ミドルウェア（JWT）✅ → そのまま維持
Phase 3.1: ログイン画面実装（JWT）🔄 → 中断・保存（wip commit）
```

### 新規Phase（Auth0移行）
```
Phase 4: Auth0移行 ← 新しいPhaseとして追加
  ├─ Phase 4.1: 認証API Auth0化（Phase 2.3の修正版）
  │    ├─ Phase 4.1.1: Auth0セットアップ
  │    ├─ Phase 4.1.2: Auth0 SDK統合
  │    └─ Phase 4.1.3: 認証エンドポイント実装
  │
  ├─ Phase 4.2: トークン検証 Auth0化（Phase 2.4の修正版）
  │    ├─ Phase 4.2.1: Auth0トークン検証ミドルウェア
  │    └─ Phase 4.2.2: ロールベース認可
  │
  └─ Phase 4.3: ログイン画面 Auth0化（Phase 3.1の修正版）
       ├─ Phase 4.3.1: Auth0 Universal Login統合
       └─ Phase 4.3.2: カスタムUI調整
```

### 既存Phase（継続・番号繰り上げ）
```
Phase 5: ダッシュボード実装（元 Phase 3.2）← 継続
Phase 6: ユーザー管理画面（元 Phase 3.3）← 継続
```

---

## 📌 推奨アクション

1. **Phase 4.1 から開始** - 認証API Auth0化
2. **Phase 2.3（JWT版）は削除せず維持** - 変更履歴として残す
3. **Phase 3.1（JWT・wip）は削除せず維持** - git commit済み
4. **Phase 4完了後、Phase 5以降を継続**

---

## 📅 想定スケジュール

- Phase 4.1: 3日
- Phase 4.2: 2日
- Phase 4.3: 2日
- 合計: 7日（期限2週間以内に収まる）
```

---

## Phase 3: ユーザー承認

**メインClaude Agentが実行**:

1. plannerが生成した影響範囲分析レポートをユーザーに提示
2. 再計画後のPhase階層を説明
3. ユーザーの承認を得る

**確認メッセージ例**:
```markdown
以下のPhase階層で再計画します。よろしいですか？

【完了済みPhase（維持）】
- Phase 2.3（JWT認証API）✅ → そのまま維持
- Phase 2.4（JWT検証）✅ → そのまま維持

【作業中Phase（中断・保存）】
- Phase 3.1（ログイン画面・JWT）🔄 → 中断・保存

【新規Phase（Auth0移行）】
- Phase 4: Auth0移行
  - Phase 4.1: 認証API Auth0化
  - Phase 4.2: トークン検証 Auth0化
  - Phase 4.3: ログイン画面 Auth0化

【既存Phase（継続）】
- Phase 5: ダッシュボード実装（元 Phase 3.2）
- Phase 6: ユーザー管理画面（元 Phase 3.3）

承認しますか？（はい/いいえ/修正希望）
```

---

## Phase 4: Phase階層再構築 + 復帰

### 実行内容

**メインClaude Agentが実行**:

1. **Serenaメモリ更新**
   ```bash
   mcp__serena__write_memory(
     memory_name: "project/requirements_change_{日付}.md",
     content: "影響範囲分析レポートの内容"
   )

   mcp__serena__write_memory(
     memory_name: "project/current_context.md",
     content: "新しいPhase階層 + 現在Phase（Phase 4.1）"
   )
   ```

2. **Phase階層を再計画版に置き換え**
   - plannerが生成した新しいPhase階層を記録
   - 影響のないPhaseの番号を繰り上げ

3. **next_phase_prompt.md を更新**
   ```bash
   Write: next_phase_prompt.md

   内容:
   ## 今Phaseの推奨タスク

   ### 🔴 優先度: 高
   1. Phase 4.1: 認証API Auth0化
      - Phase 4.1.1: Auth0セットアップ
      - Phase 4.1.2: Auth0 SDK統合
      - Phase 4.1.3: 認証エンドポイント実装
   ```

4. **新しいPhaseに復帰**

### 復帰後の動作

**Phase 4.1 開始メッセージ**:
```markdown
✅ 要件定義変更モード終了

Phase 4.1（認証API Auth0化）を開始します。

【Phase階層】
Phase 4: Auth0移行
  ├─ Phase 4.1: 認証API Auth0化 ← 現在ここ
  ├─ Phase 4.2: トークン検証 Auth0化
  └─ Phase 4.3: ログイン画面 Auth0化

【実装タスク】
1. Auth0セットアップ
2. Auth0 SDK統合
3. 認証エンドポイント実装

実装フェーズを開始します。
```

---

## Phase階層の変化（具体例）

### 変更前

```
Phase 2.3: 認証API実装（JWT方式）✅ 完了
Phase 2.4: トークン検証ミドルウェア（JWT）✅ 完了
Phase 3.1: ログイン画面実装 🔄 作業中（50%）
Phase 3.2: ダッシュボード実装 ⏳ 未着手
Phase 3.3: ユーザー管理画面 ⏳ 未着手
```

### 変更後

```
【維持】
Phase 2.3: 認証API実装（JWT方式）✅ 完了（維持）
Phase 2.4: トークン検証ミドルウェア（JWT）✅ 完了（維持）
Phase 3.1: ログイン画面実装（JWT）🔄 中断・保存（wip commit）

【新規追加】
Phase 4: Auth0移行 ← NEW
  ├─ Phase 4.1: 認証API Auth0化（Phase 2.3の修正版）← 現在ここ
  ├─ Phase 4.2: トークン検証 Auth0化（Phase 2.4の修正版）
  └─ Phase 4.3: ログイン画面 Auth0化（Phase 3.1の修正版）

【継続（番号繰り上げ）】
Phase 5: ダッシュボード実装（元 Phase 3.2）⏳ 未着手
Phase 6: ユーザー管理画面（元 Phase 3.3）⏳ 未着手
```

---

## ベストプラクティス

### 要件変更前の確認

- [ ] 現在の作業をキリの良いところで止める
- [ ] git commit で一時保存（ブランチも考慮）
- [ ] 既存実装への影響範囲を理解する

### 要件変更後の確認

- [ ] 新しいPhase階層を十分に理解する
- [ ] 完了済みPhaseは維持（削除しない）
- [ ] 作業中Phaseは中断・保存（wip commit）
- [ ] 影響のないPhaseは継続（番号繰り上げ）

### Phase番号の整理

**完了済みPhaseの維持理由**:
- 変更履歴が明確
- git commitで追跡可能
- ロールバック時に参照できる

**新しいPhaseとして追加する理由**:
- Phase階層の連続性を保つ
- 修正版であることが明確
- 元の実装と比較しやすい

---

## 関連ドキュメント

- [planner.md Step 0.5](../.claude/agents/planner.md) - 影響範囲分析機能
- [PHASE_START.md](./PHASE_START.md) - 要件変更自動検知
- [WORKFLOW.md](./WORKFLOW.md) - 開発フロー詳細
- [CLAUDE.md](../CLAUDE.md) - 全体設定
