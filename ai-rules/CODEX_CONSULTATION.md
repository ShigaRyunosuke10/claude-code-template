# Codex AI相談フロー

エラーループ時に、ユーザー相談の前に**Codex MCP (OpenAI Codex CLI Wrapper)** に自動相談し、AI支援による問題解決を試みるガイドライン。

---

## 📋 概要

### Codex MCPとは

- **パッケージ**: `@trishchuk/codex-mcp-tool`
- **機能**: OpenAI Codex CLIをMCP経由でClaude Codeから利用可能にするラッパー
- **提供ツール**:
  - `mcp__codex__codex(prompt, sessionId?)` - AIコーディングアシスタント
  - `mcp__codex__listSessions()` - アクティブセッション一覧
  - `mcp__codex__ping()` - 接続テスト
  - `mcp__codex__help()` - ヘルプ情報

### 使用目的

エラーループ（同一バグパターン3回失敗）時に、以下の問題解決をCodex AIに相談：

1. **バグ修正支援** - エラーメッセージのデバッグ、根本原因分析
2. **コード改善提案** - リファクタリング、パフォーマンス最適化
3. **セキュリティ分析** - 脆弱性検出、修正提案
4. **テスト修復** - E2Eテスト失敗の原因特定・修正

---

## 🚨 相談トリガー条件

### 1. impl-dev-backend / impl-dev-frontend

**条件**: 同一バグパターン (`pattern_XXX`) が3回連続で解決しない

**トリガー箇所**: `E2E application_bug 修正フロー` → 試行制限

**相談内容**:
- バックエンド/フロントエンドのバグ修正
- エラーログ解析
- データベースクエリ最適化
- API実装の改善

### 2. playwright-test-healer

**条件**: HEALING仮説処方が失敗（同一テスト修正3回まで到達）

**トリガー箇所**: `Mode 3: HEALING` → Step 3.5

**相談内容**:
- E2Eテスト失敗の根本原因分析
- セレクタ修正提案
- 待機戦略の改善
- テストコードのリファクタリング

### 3. code-reviewer

**条件**: Critical問題（ブロック）を検出

**トリガー箇所**: `Workflow` → ブロック判定後

**相談内容**:
- アーキテクチャ違反の修正方法
- セキュリティリスクの対処法
- データ整合性問題の解決
- 型定義不一致の修正

---

## 📝 相談フォーマット

### 基本テンプレート

```markdown
# Codex AI相談リクエスト

## エラー詳細
- **パターンID**: pattern_XXX (該当する場合)
- **エラー種別**: application_bug / test_flakiness / critical_issue
- **エラーメッセージ**:
\`\`\`
[エラーメッセージ全文]
\`\`\`

## コード（該当箇所）
**ファイル**: `backend/app/api/users.py:45`

\`\`\`python
# 問題のコード（10-20行程度のコンテキスト含む）
async def get_user_role(user_id: int, db=Depends(get_supabase_client)):
    response = db.table("users").select("role").eq("id", user_id).execute()
    # ❌ エラーハンドリング欠落
    return response.data[0]
\`\`\`

## 試行履歴
1. **試行1**: エラーハンドリング追加 (`try-except`) → 失敗（同じエラー再発）
2. **試行2**: テーブル名修正 (`users` → `user_profiles`) → 失敗（テーブル存在せず）
3. **試行3**: ログ出力追加 → 失敗（根本原因未解決）

## 技術スタック
- **言語**: Python 3.13 / TypeScript 5.x
- **フレームワーク**: FastAPI / Next.js
- **データベース**: PostgreSQL (Supabase)
- **テスト**: Playwright / Pytest

## 質問
このバグの根本原因と、最も効果的な修正方法を教えてください。
試行履歴から、まだ試していないアプローチがあれば提案してください。
\`\`\`

### セッション管理

**継続相談時**（同じ問題で複数回相談）:
```bash
# 初回相談
mcp__codex__codex(prompt: "[上記フォーマット]")
# → sessionId: "abc123" を取得

# 2回目以降（同じセッションで追加質問）
mcp__codex__codex(
  prompt: "前回の提案「X」を試しましたが、Yのエラーが出ました。次の手は？",
  sessionId: "abc123"
)
```

---

## 🔍 Codex回答の解析

### 推奨修正の抽出

Codex回答から以下を抽出：

1. **根本原因**: 問題の本質的な原因
2. **推奨修正**: 具体的なコード変更
3. **代替案**: 他のアプローチ
4. **注意点**: 修正時の留意事項

### 適用可能性の判定

```typescript
function isApplicableFix(codexResponse: string): boolean {
  // 以下の条件をすべて満たす場合、適用可能
  return (
    codexResponse.includes('```') &&  // コードブロック含む
    !codexResponse.includes('不明') && // 不確実性が低い
    !codexResponse.includes('情報不足') // 十分な情報がある
  );
}
```

### 修正適用手順

1. **Codex推奨修正を抽出**: コードブロック（```）部分を取得
2. **影響範囲を確認**: 変更が他の箇所に影響しないか検証
3. **修正適用**: Editツールでコードを変更
4. **テスト実行**: 修正後、該当テスト/ビルドを再実行
5. **Learning Memory更新**: 試行結果を記録

---

## 🔄 フロー図

### エラーループ時の処理フロー（Codex統合版）

```
エラー3回連続失敗
  ↓
Codex AI相談 (自動)
  │
  ├─ [Codex接続成功]
  │    ↓
  │  Codex推奨修正を取得
  │    ↓
  │  推奨修正を適用
  │    ↓
  │  テスト再実行
  │    ├─ [Pass] → 次のPhaseへ ✅
  │    │
  │    └─ [Fail] → Codex再相談（最大2回まで）
  │              ↓
  │          [2回目も失敗] → ユーザー相談へ
  │
  └─ [Codex接続失敗/タイムアウト]
       ↓
     ユーザー相談（従来フロー）
       ├─ 選択肢1: 続行（最大6回）
       ├─ 選択肢2: 手動修正
       └─ 選択肢3: Technical Debt登録
```

---

## ⚙️ 実装例

### impl-dev-backend: E2E application_bug修正

```typescript
// Step 6.1: Codex AI相談（3回失敗後）
if (failedAttempts === 3) {
  const codexPrompt = `
# Codex AI相談リクエスト

## エラー詳細
- **パターンID**: ${patternId}
- **エラー種別**: application_bug
- **エラーメッセージ**:
\`\`\`
${errorMessage}
\`\`\`

## コード（該当箇所）
**ファイル**: \`${failedFile}\`

\`\`\`python
${codeContext}
\`\`\`

## 試行履歴
${fixAttempts.map((a, i) => `${i+1}. **試行${i+1}**: ${a.action} → ${a.result}`).join('\n')}

## 技術スタック
- **言語**: Python 3.13
- **フレームワーク**: FastAPI
- **データベース**: PostgreSQL (Supabase)

## 質問
このバグの根本原因と、最も効果的な修正方法を教えてください。
  `;

  const codexResponse = await mcp__codex__codex({ prompt: codexPrompt });

  if (isApplicableFix(codexResponse)) {
    // Codex推奨修正を適用
    const recommendedFix = extractCodeBlock(codexResponse);
    await applyFix(failedFile, recommendedFix);

    // E2Eテスト再実行
    const testResult = await runE2ETests();

    if (testResult.passed) {
      // 成功 → Learning Memory更新
      await updateLearningMemory(patternId, {
        fixedBy: 'codex',
        recommendation: codexResponse,
        success: true
      });
      return 'RESOLVED';
    } else {
      // Codex推奨修正でも失敗 → ユーザー相談
      return 'ESCALATE_TO_USER';
    }
  } else {
    // Codex回答が不明確 → ユーザー相談
    return 'ESCALATE_TO_USER';
  }
}
```

### playwright-test-healer: HEALING失敗時

```typescript
// Step 3.5: Codex AI相談（仮説処方失敗後）
if (!hasAttemptedHypothesis(failure.testId)) {
  // 既存の仮説処方
} else {
  // Codex相談を試行
  const codexPrompt = `
# Codex AI相談リクエスト

## エラー詳細
- **エラー種別**: test_flakiness
- **エラー署名**: ${failure.errorSignature}
- **失敗テスト**: ${failure.testName}

## テストコード
\`\`\`typescript
${testCode}
\`\`\`

## 試行履歴
${fixAttempts.map((a, i) => `${i+1}. ${a.type}: ${a.description} → ${a.result}`).join('\n')}

## 質問
このE2Eテスト失敗の根本原因を教えてください。
セレクタ、待機戦略、テストロジックのどこに問題がありますか？
  `;

  const codexResponse = await mcp__codex__codex({ prompt: codexPrompt });

  if (isApplicableFix(codexResponse)) {
    const codexFix = extractRecommendedFix(codexResponse);
    await applyFix(codexFix);
    markCodexAttempted(failure.testId);
    transitionTo('SMOKE');
  } else {
    // Codex失敗 → QUARANTINE
    transitionTo('QUARANTINE');
  }
}
```

### code-reviewer: Critical問題検出時

```typescript
// Step 6: Codex AI相談（Critical問題検出時）
if (criticalIssues.length > 0) {
  for (const issue of criticalIssues) {
    const codexPrompt = `
# Codex AI相談リクエスト

## エラー詳細
- **エラー種別**: critical_issue
- **問題**: ${issue.title}
- **影響**: ${issue.impact}

## コード（該当箇所）
**ファイル**: \`${issue.file}:${issue.line}\`

\`\`\`${issue.language}
${issue.currentCode}
\`\`\`

## 質問
この${issue.category}（${issue.title}）の修正方法を教えてください。
ベストプラクティスに沿った実装例を提示してください。
    `;

    const codexResponse = await mcp__codex__codex({ prompt: codexPrompt });

    // レビューレポートに「Codex推奨修正」セクション追加
    issue.codexRecommendation = codexResponse;
  }

  // レポート生成（Codex推奨含む）
  await generateReviewReport(criticalIssues);
}
```

---

## 🛡️ 安全ガード

### タイムアウト設定

```typescript
const CODEX_TIMEOUT = 60000; // 60秒

async function consultCodexWithTimeout(prompt: string): Promise<string | null> {
  try {
    const response = await Promise.race([
      mcp__codex__codex({ prompt }),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('Timeout')), CODEX_TIMEOUT)
      )
    ]);
    return response as string;
  } catch (error) {
    if (error.message === 'Timeout') {
      logger.warn('Codex consultation timed out');
    } else {
      logger.error('Codex consultation failed', error);
    }
    return null; // フォールバック: ユーザー相談へ
  }
}
```

### 試行回数制限

- **Codex相談**: 同一問題につき最大2回まで
- **ユーザー相談**: Codex失敗後、従来通り最大6回まで

### エラーハンドリング

```typescript
// Codex MCP接続エラー時の処理
try {
  const codexResponse = await mcp__codex__codex({ prompt });
} catch (error) {
  if (error.code === 'MCP_SERVER_NOT_FOUND') {
    logger.warn('Codex MCP not configured. Skipping AI consultation.');
    // フォールバック: ユーザー相談
    return escalateToUser();
  } else if (error.code === 'OPENAI_API_KEY_MISSING') {
    logger.warn('OpenAI API key not configured. Skipping AI consultation.');
    return escalateToUser();
  } else {
    throw error;
  }
}
```

---

## 📊 Learning Memory記録

### パターンファイル更新

Codex相談の結果を `.serena/memories/testing/e2e_patterns.json` に記録：

```json
{
  "id": "pattern_015_backend_auth_error",
  "errorType": "application_bug",
  "rootCause": "JWT検証ロジックのバグ",
  "fixAttempts": [
    {
      "attempt": 1,
      "action": "エラーハンドリング追加",
      "result": "failure"
    },
    {
      "attempt": 2,
      "action": "ログ出力追加",
      "result": "failure"
    },
    {
      "attempt": 3,
      "action": "トークン検証ロジック修正",
      "result": "failure"
    },
    {
      "attempt": 4,
      "action": "Codex AI相談 → JWT署名アルゴリズム修正",
      "codexRecommendation": "HS256 → RS256に変更",
      "result": "success",
      "fixedBy": "codex",
      "timestamp": "2025-10-27T14:00:00Z"
    }
  ],
  "resolved": true
}
```

---

## ✅ 成功基準

- [ ] Codex MCP接続が正常に機能
- [ ] エラーループ時に自動的にCodex相談が開始
- [ ] Codex推奨修正が適切に適用される
- [ ] Codex失敗時にユーザー相談へフォールバック
- [ ] Learning Memoryに相談結果が記録される
- [ ] タイムアウト・エラーハンドリングが機能

---

## 🚨 注意事項

1. **Codex CLI設定が必須**
   - OpenAI APIキーが設定されていない場合、Codex相談はスキップ
   - README.md「Step 0.5」を参照

2. **コスト管理**
   - Codex相談はOpenAI APIを使用（有料）
   - 同一問題につき最大2回までの制限でコスト抑制

3. **セキュリティ**
   - コードスニペットをOpenAI APIに送信
   - 機密情報（API キー、パスワード等）は相談内容から除外

4. **適用範囲**
   - Codex推奨修正は必ず検証してから適用
   - 盲目的な適用は禁止（テスト実行で確認）

---

## 📚 参考リンク

- [Codex MCP GitHub](https://github.com/tuannvm/codex-mcp-server)
- [OpenAI Codex CLI ドキュメント](https://developers.openai.com/codex/)
- [Model Context Protocol 仕様](https://modelcontextprotocol.io/)

---

## 📊 深刻度別Codex相談基準

エラーの深刻度に応じて、Codex相談のタイミングを調整します。

### 深刻度分類

| 深刻度 | 説明 | 例 |
|--------|------|-----|
| 🚨 **Critical** | ブロック（修正必須） | アーキテクチャ違反、セキュリティリスク、データ整合性、致命的バグ、型定義不一致 |
| ⚠️ **High** | 強く推奨 | パフォーマンス問題、エラーハンドリング欠落、型安全性 |
| 💡 **Medium** | 推奨 | 可読性、保守性、命名規則 |
| 📝 **Low** | 提案 | ドキュメント欠落、スタイル改善 |

詳細: [.claude/agents/code-reviewer.md](../.claude/agents/code-reviewer.md)

---

### Codex相談タイミング

| 深刻度 | Codex相談タイミング | ユーザー相談 | 理由 |
|--------|-------------------|------------|------|
| 🚨 Critical | **初回発生時** | Codex 2回失敗後 | 致命的な問題は即座にAI支援 |
| ⚠️ High | **初回発生時** | Codex 2回失敗後 | 重要な問題は早期解決 |
| 💡 Medium | 3回失敗後 | Codex 2回失敗後 | 通常フロー |
| 📝 Low | 相談なし（自動修正のみ） | - | 軽微な問題は自動対応 |

---

### 実装例

#### code-reviewer: Critical/High問題検出時

```typescript
// Critical/High問題検出時は即座にCodex相談
if (criticalIssues.length > 0 || highIssues.length > 0) {
  for (const issue of [...criticalIssues, ...highIssues]) {
    const codexPrompt = `
# Codex AI相談リクエスト（深刻度: ${issue.severity}）

## エラー詳細
- **深刻度**: ${issue.severity}
- **問題**: ${issue.title}
- **影響**: ${issue.impact}

## コード（該当箇所）
**ファイル**: \`${issue.file}:${issue.line}\`

\`\`\`${issue.language}
${issue.currentCode}
\`\`\`

## 質問
この${issue.category}（${issue.title}）の修正方法を教えてください。
深刻度が${issue.severity}なので、優先的に対処したいです。
    `;

    const codexResponse = await mcp__codex__codex({ prompt: codexPrompt });
    issue.codexRecommendation = codexResponse;
  }
}
```

#### impl-dev-backend/frontend: 深刻度判定

```typescript
// エラーの深刻度を判定
function assessSeverity(error: Error, context: string): Severity {
  // Critical判定
  if (error.message.includes('NullPointerException') ||
      error.message.includes('SecurityException') ||
      error.message.includes('DataIntegrityViolation')) {
    return 'Critical';
  }
  
  // High判定
  if (error.message.includes('PerformanceWarning') ||
      error.message.includes('UnhandledPromiseRejection')) {
    return 'High';
  }
  
  // Medium判定
  if (error.message.includes('DeprecationWarning') ||
      error.message.includes('CodeStyleViolation')) {
    return 'Medium';
  }
  
  // Low判定
  return 'Low';
}

// 深刻度に応じたCodex相談
const severity = assessSeverity(error, codeContext);

if (severity === 'Critical' || severity === 'High') {
  // 初回発生時に即座にCodex相談
  const codexResponse = await consultCodex(error, severity);
  applyFix(codexResponse);
} else if (severity === 'Medium') {
  // 3回失敗後にCodex相談（従来フロー）
  if (failedAttempts >= 3) {
    const codexResponse = await consultCodex(error, severity);
    applyFix(codexResponse);
  }
} else {
  // Low: 自動修正のみ（Codex相談なし）
  autoFix(error);
}
```

---

### Learning Memory記録（深刻度含む）

```json
{
  "id": "pattern_020_critical_null_pointer",
  "errorType": "application_bug",
  "severity": "Critical",
  "rootCause": "Null参照エラー（ユーザー認証後のセッション取得）",
  "fixAttempts": [
    {
      "attempt": 1,
      "action": "Codex AI相談（深刻度: Critical → 即座に相談）",
      "codexRecommendation": "Optional chaining (?.) を使用してnullチェック",
      "result": "success",
      "fixedBy": "codex",
      "timestamp": "2025-10-27T16:00:00Z"
    }
  ],
  "resolved": true
}
```

---

### メリット

1. **Critical/High問題の早期解決**: 致命的な問題は初回からAI支援
2. **開発効率向上**: 重要な問題を優先的に解決
3. **コスト最適化**: Low問題はCodex相談なし（自動修正のみ）
4. **学習効果**: 深刻度別の相談履歴をLearning Memoryに蓄積

