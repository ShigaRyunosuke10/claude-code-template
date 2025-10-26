---
description: Playwright 3体オーケストレーター（planner → generator → healer）でE2E完全自律実行
allowed-tools: Task:playwright-test-planner, Task:playwright-test-generator, Task:playwright-test-healer, Bash(npm run test:e2e:*), Bash(cd frontend*), Bash(npx playwright:*)
---

# E2E完全自律実行システム

このコマンドは、Playwright 3体のエージェント（planner → generator → healer）を順次起動し、E2Eテストを**完全自律で実行・修復・学習**します。

## エージェント構成

### 1. playwright-test-planner（探索・計画）
- アプリケーションUI探索
- ユーザーシナリオ抽出
- テスト計画書（Markdown）作成
- **出力**: `frontend/specs/*.md`

### 2. playwright-test-generator（コード生成）
- テスト計画書 → Playwrightテストコード変換
- Page Object Model 適用
- @smoke タグ付与
- **出力**: `frontend/e2e/*.spec.ts`

### 3. playwright-test-healer（自己修復 + AI自律システム）
- テスト実行
- **状態機械**: RUNNING → ABORTING → HEALING → SMOKE → RESUME_FULL / QUARANTINE → LEARN
- **停止ルール5種**: 同一エラー3連続、失敗率30%、タイムアウト連鎖、spec全滅、保険
- **自動修復**: 既知処方 → 限定的対処 → 仮説処方
- **Learning Memory**: `.serena/memories/testing/e2e_patterns.json`
- **Quarantine**: `.serena/memories/testing/quarantine/*.md`

## 実行フロー

```
User: /e2e-full
  ↓
Step 1: Task:playwright-test-planner
  - UI探索 → テスト計画作成
  - 出力: specs/*.md
  ↓
Step 2: Task:playwright-test-generator
  - 計画書 → テストコード生成
  - 出力: e2e/*.spec.ts
  ↓
Step 3: Task:playwright-test-healer
  - テスト実行 → 失敗検出 → 自律修復
  - RUNNING → (失敗時) ABORTING → HEALING → SMOKE → RESUME_FULL
  - または QUARANTINE → LEARN
  ↓
Result: テスト結果 + Learning Memory更新 + (必要に応じて) Quarantineレポート
```

## 前提条件

以下が起動していることを確認してください：
- **バックエンド**: http://localhost:8000
- **フロントエンド**: http://localhost:3000
- **Docker containers**: backend, frontend, minio

### サーバー起動確認

```bash
# コンテナ確認
docker ps

# 必要に応じて起動
docker-compose up -d
```

## 使用方法

### 基本実行
```bash
/e2e-full
```

### 特定シナリオのみ実行
```bash
/e2e-full --scenario "ログイン→ダッシュボード→ログアウト"
```

### Smoke Testのみ実行
```bash
/e2e-full --smoke-only
```

## AI自律実行システムの動作

### 停止ルール（自動検知）
| # | ルール名 | 条件 | AI判断 |
|---|---------|------|--------|
| 1 | 同一エラー署名連続 | 3連続で同じエラー | ABORT → HEALING |
| 2 | 失敗率高騰 | 直近10ケースで30%超 | ABORT → HEALING |
| 3 | タイムアウト連鎖 | 5回/3分 | ABORT → HEALING |
| 4 | spec全滅 | 80%以上失敗（実行≥5） | ABORT → QUARANTINE |
| 5 | 保険 | 全体失敗≥10件 | ABORT → HEALING |

### 修復優先順
1. **既知処方**: `.serena/memories/testing/e2e_patterns.json` から強制適用
2. **限定的対処**: セレクタ修正・待機時間延長
3. **仮説処方**: 実験的修正（1回のみ）

### Learning Memory
成功した修復パターンを蓄積:
```json
{
  "patterns": [
    {
      "id": "pattern_001",
      "errorSignature": "TimeoutError|waitForURL|dashboard",
      "recommendedFix": {
        "type": "add_wait",
        "code": "await page.waitForLoadState('networkidle');"
      },
      "enforced": true,
      "recurrenceCount": 2
    }
  ]
}
```

### Quarantine（検疫）
修復不可能なテストは検疫:
- **隔離先**: `.serena/memories/testing/quarantine/{spec-name}_{timestamp}.md`
- **隔離期間**: Median 3日
- **解除**: 人間が根本原因修正後、検疫ファイル削除

## 出力レポート

### 成功時
```markdown
✅ E2E Test Complete

## Summary
- Total: 151 tests
- Passed: 151 (100%)
- Failed: 0
- Smoke: 15 tests (100% pass)

## Learning
- New patterns learned: 2
- Enforced patterns: 5

## Telemetry
- MTTR: 12min
- False Positive Rate: 0.5%
```

### 検疫発生時
```markdown
⚠️ E2E Test Quarantined

## Summary
- Total: 151 tests
- Passed: 130 (86%)
- Failed: 21 (14%)
- Quarantined: 1 spec file

## Quarantine Report
- File: `dashboard-transition.spec.ts`
- Reason: spec全滅（90%失敗）
- Location: `.serena/memories/testing/quarantine/dashboard-transition_1737630000.md`

## Next Steps
1. Check backend logs
2. Investigate application code (not test code)
3. Fix root cause
4. Delete quarantine file after fix
```

## 使用タイミング

### 必須
- 実装完了後
- PR作成前
- mainマージ前

### 推奨
- 大きな機能追加後
- リファクタリング後
- ライブラリアップグレード後

## 注意事項

### AI自律判断の原則
1. ❌ **テスト計画の変更禁止** - 計画は人間が作る
2. ❌ **アプリケーションコード修正禁止** - `backend/`, `frontend/src/` は読み取り専用
3. ✅ **テストコード修復OK** - `frontend/e2e/` のみ修正可能
4. ✅ **Learning Memory蓄積** - 成功パターンを記録

### Session 69の学習
> "最初に建てたテスト計画を変えてテスト通すのおかしくないか　それ通すためのテストになってひんしつちぇっくにならないよね"
>
> → **テスト失敗 = アプリケーションのバグ**
> → まずbackendログ確認 → 根本原因修正 → テスト再実行

### Rollout Phases（段階的導入）
- **Phase 1 (Week 1-2)**: Observer Mode（停止ルール検知のみ）
- **Phase 2 (Week 3-4)**: Conservative Healing（既知処方のみ）
- **Phase 3 (Week 5+)**: Full Autonomous（全機能有効化）

## トラブルシューティング

### テストが3連続失敗する
→ HEALINGが自動起動 → Learning Memoryから既知処方適用 → SMOKE Test → 成功なら再開

### spec全滅（80%以上失敗）
→ QUARANTINE → 検疫レポート作成 → **人間が根本原因調査**

### Learning Memoryが効いていない
→ `.serena/memories/testing/e2e_patterns.json` の `enforced: true` を確認

## CI/CD統合

`.github/workflows/e2e-agents.yml`:
```yaml
- name: E2E Full Autonomous
  run: /e2e-full --ci-mode
```

## 関連ファイル

- **エージェント定義**: `.claude/agents/playwright-test-*.md`
- **停止ルール**: `.claude/settings.json` の `stopConditions`
- **Learning Memory**: `.serena/memories/testing/e2e_patterns.json`
- **Quarantine**: `.serena/memories/testing/quarantine/*.md`
- **テストコード**: `frontend/e2e/*.spec.ts`
- **テスト計画**: `frontend/specs/*.md`
