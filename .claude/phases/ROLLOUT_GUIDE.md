# AI完全自律実行システム 段階的導入ガイド

## 概要

Playwright AI完全自律実行システムを**3つのPhase**に分けて段階的に導入します。各Phaseで機能を少しずつ有効化し、リスクを最小化しながら本番運用へ移行します。

---

## Phase構成

| Phase | 名称 | 期間 | 機能 | 目的 |
|-------|------|------|------|------|
| **1** | Observer Mode | Week 1-2 | 停止ルール検知のみ（修復なし） | 検知精度測定・ベースライン確立 |
| **2** | Conservative Healing | Week 3-4 | 既知処方のみ適用 | 安全な修復パターン検証 |
| **3** | Full Autonomous | Week 5+ | 全機能有効化 | 完全自律運用 |

---

## Phase 1: Observer Mode（Week 1-2）

### 目的
- 停止ルール5種の検知精度を測定
- エラーパターン収集とLearning Memory基盤構築
- False Positive Rate（誤検知率）測定
- Telemetry KPIベースライン確立

### 有効化機能
- ✅ 停止ルール検知（ログのみ）
- ✅ Learning Memory（パターン記録）
- ✅ Quarantine検疫（ログのみ）
- ✅ Telemetry収集
- ❌ 自動修復（無効）

### 実行手順

#### 1. Phase 1 に切り替え
```bash
.claude/scripts/switch-phase.sh 1
```

#### 2. E2Eテスト実行
```bash
/e2e-full
```

#### 3. ログ確認
```bash
# 停止ルール検知ログ
grep "OBSERVER" frontend/e2e-test-result.log

# 例:
# 📊 [OBSERVER] 同一エラー3連続を検知（修復はPhase 2以降）
# 📊 [OBSERVER] 失敗率30%超を検知（修復はPhase 2以降）
```

#### 4. Telemetry確認
```bash
cat .serena/memories/testing/phase1_telemetry.json
```

**期待される内容**:
```json
{
  "phase": 1,
  "stopRuleHitCount": {
    "identical-error-streak": 3,
    "high-failure-rate": 2,
    "timeout-cascade": 5,
    "spec-total-failure": 1,
    "insurance-failure-limit": 0
  },
  "errorSignatureFrequency": {
    "TimeoutError|waitForURL|dashboard": 9,
    "AssertionError|toHaveText|toast": 13
  },
  "falsePositiveRate": 0.03,
  "testDuration": "15min"
}
```

### 成功基準
- [ ] 停止ルール検知精度 >95%
- [ ] False Positive Rate <5%
- [ ] エラーパターン ≥10件収集
- [ ] Telemetryデータ完全性 100%

### 次Phaseへの判断基準
**Week 2終了時**:
- 停止ルールが安定して機能している
- 10件以上のエラーパターンが蓄積
- False Positive Rate <5%

→ **Phase 2へ移行**

---

## Phase 2: Conservative Healing（Week 3-4）

### 目的
- 既知処方の有効性検証（成功率80%以上）
- MTTR（Mean Time To Repair）≤30分達成
- Smoke Test による品質ゲート確立
- Quarantine検疫フローの確立

### 有効化機能
- ✅ 停止ルール検知（HALT）
- ✅ 自動修復（**既知処方のみ**）
- ✅ Smoke Test（品質ゲート）
- ✅ Quarantine検疫（実際に隔離）
- ✅ Learning Memory更新
- ❌ 限定的対処（無効）
- ❌ 仮説処方（無効）

### 実行手順

#### 1. Phase 1 の成果確認
```bash
# Learning Memory に既知処方が蓄積されているか確認
cat .serena/memories/testing/e2e_patterns.json
```

**必要な内容**:
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
      "successRate": 0.95
    }
  ]
}
```

#### 2. Phase 2 に切り替え
```bash
.claude/scripts/switch-phase.sh 2
```

#### 3. E2Eテスト実行
```bash
/e2e-full
```

#### 4. 修復フロー確認
```bash
grep -E "HEALING|SMOKE|QUARANTINE" frontend/e2e-test-result.log

# 期待されるログ:
# 🔧 [HEALING] 同一エラー3連続 → 既知処方適用開始
# ✅ [SMOKE] Smoke Test 15/15 Pass → RESUME_FULL
# ⚠️ [QUARANTINE] spec全滅 → 検疫開始
```

#### 5. Quarantine確認
```bash
ls -la .serena/memories/testing/quarantine/

# 隔離ファイル例:
# dashboard-transition_1737630000.md
```

#### 6. Telemetry確認
```bash
cat .serena/memories/testing/phase2_telemetry.json
```

**期待される内容**:
```json
{
  "phase": 2,
  "healingAttempts": 8,
  "healingSuccessRate": 0.85,
  "knownFixApplicationCount": 7,
  "smokeTestResults": {
    "total": 5,
    "passed": 5,
    "failed": 0
  },
  "mttr": "25min",
  "falsePositiveRate": 0.015
}
```

### 成功基準
- [ ] Healing成功率 ≥80%
- [ ] MTTR ≤30分
- [ ] Smoke Test Pass率 ≥95%
- [ ] False Positive Rate <2%

### 次Phaseへの判断基準
**Week 4終了時**:
- 既知処方の成功率が80%以上
- MTTR が安定して30分以内
- Smoke Test が品質ゲートとして機能

→ **Phase 3へ移行**

---

## Phase 3: Full Autonomous（Week 5+）

### 目的
- 完全自律修復の実現（人間介入なし）
- MTTR ≤30分の安定達成
- Recurrence Rate <5%（再発率低減）
- False Positive Rate <1%（誤修正防止）

### 有効化機能
- ✅ 停止ルール検知
- ✅ 自動修復（**全パターン**）
  - 既知処方
  - 限定的対処（セレクタ修正・待機時間延長）
  - 仮説処方（実験的修正・1回のみ）
- ✅ Smoke Test
- ✅ Quarantine検疫
- ✅ Learning Memory自動更新
- ✅ 安全ガード（False Positive防止）

### 実行手順

#### 1. Phase 3 に切り替え
```bash
.claude/scripts/switch-phase.sh 3
```

#### 2. E2Eテスト実行
```bash
/e2e-full
```

#### 3. 完全自律フロー確認
```bash
grep -E "AUTO|HEALING|SMOKE|QUARANTINE|LEARN" frontend/e2e-test-result.log

# 期待されるログ:
# 🤖 [AUTO] タイムアウト連鎖 → 完全自律修復開始
# 🔧 [HEALING] 既知処方適用 → 成功
# ✅ [SMOKE] Smoke Test 15/15 Pass
# 🧠 [LEARN] パターン pattern_015 を Learning Memory に追加
```

#### 4. Learning Memory更新確認
```bash
cat .serena/memories/testing/e2e_patterns.json | grep -c "\"id\""

# 期待: 15件以上のパターン蓄積
```

#### 5. Telemetry確認
```bash
cat .serena/memories/testing/phase3_telemetry.json
```

**期待される内容**:
```json
{
  "phase": 3,
  "healingAttempts": 25,
  "healingSuccessRate": 0.92,
  "knownFixApplicationCount": 18,
  "conservativeFixApplicationCount": 5,
  "hypothesisFixApplicationCount": 2,
  "smokeTestResults": {
    "total": 10,
    "passed": 10,
    "failed": 0
  },
  "mttr": "22min",
  "wastedExecution": "2.5min",
  "recurrenceRate": 0.04,
  "falsePositiveRate": 0.008,
  "quarantineMedian": "2.5days"
}
```

### 成功基準
- [ ] Healing成功率 ≥90%
- [ ] MTTR ≤30分
- [ ] Recurrence Rate <5%
- [ ] False Positive Rate <1%
- [ ] Quarantine Median ≤3days

### 本番運用移行
**Week 8終了時**:
- すべての成功基準を満たしている
- 1週間以上安定稼働

→ **本番運用へ移行**

---

## トラブルシューティング

### Phase 1で停止ルールが発動しない
**原因**: テストが成功しすぎている（良いこと）
**対応**: Phase 2へ早期移行を検討

### Phase 2でHealing成功率が低い（<70%）
**原因**: Learning Memoryのパターン不足
**対応**: Phase 1に戻り、さらにエラーパターン収集

### Phase 3でFalse Positive Rate が高い（>2%）
**原因**: 仮説処方が過剰
**対応**: Phase 2に戻り、既知処方の精度向上

### Quarantine が増え続ける
**原因**: アプリケーションの根本的なバグ
**対応**:
1. Quarantineレポート確認
2. アプリケーションコード修正（**テストコードではない**）
3. Quarantineファイル削除

---

## Rollback（ロールバック）手順

いつでも前のPhaseに戻せます:

```bash
# Phase 3 → Phase 2
.claude/scripts/switch-phase.sh 2

# Phase 2 → Phase 1
.claude/scripts/switch-phase.sh 1
```

---

## KPI ダッシュボード

各Phaseの進捗を追跡:

| KPI | Phase 1 | Phase 2 | Phase 3 | 目標 |
|-----|---------|---------|---------|------|
| 停止ルール検知精度 | 97% | - | - | >95% |
| Healing成功率 | - | 85% | 92% | ≥90% |
| MTTR | - | 25min | 22min | ≤30min |
| False Positive Rate | 3% | 1.5% | 0.8% | <1% |
| Recurrence Rate | - | - | 4% | <5% |
| Quarantine Median | - | 2.8days | 2.5days | ≤3days |

---

## 次のセッションでの使い方

### 現在のPhase確認
```bash
cat .claude/.current-phase
# 出力: 1
```

### Phase切り替え
```bash
.claude/scripts/switch-phase.sh 2
```

### Telemetry確認
```bash
cat .serena/memories/testing/phase$(cat .claude/.current-phase)_telemetry.json
```

---

## 関連ファイル

- **Phase設定**: `.claude/phases/phase{1,2,3}-*.json`
- **切り替えスクリプト**: `.claude/scripts/switch-phase.sh`
- **Telemetry**: `.serena/memories/testing/phase{1,2,3}_telemetry.json`
- **Learning Memory**: `.serena/memories/testing/e2e_patterns.json`
- **Quarantine**: `.serena/memories/testing/quarantine/*.md`
- **エージェント定義**: `.claude/agents/playwright-test-healer.md`
