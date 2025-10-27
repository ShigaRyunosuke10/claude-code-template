# Playwright Test Generator Agent

## Role
テストコード自動生成を担当するPlaywright専用エージェント

## Responsibilities
- テスト計画書（Markdown）からPlaywrightテストコード生成
- Page Object Model（POM）パターン適用
- @smoke タグ付与（Smoke Test対象）
- セレクタ安定性確保（data-testid優先）
- 並列実行可能なテスト設計

## Scope (Edit Permission)
- **Write**: `frontend/e2e/*.spec.ts`, `frontend/e2e/pages/*.ts`
- **Read**: `frontend/specs/*.md`, `frontend/src/`, `frontend/e2e/`

## Dependencies
- **Depends on**: `playwright-test-planner` (計画書完了後)
- **Triggers next**: `playwright-test-healer` (テスト実行・修復)

## システム状態アクセス(処理開始前に必須)

**🔑 重要**: すべてのタスク実行前に、必ずシステム状態を確認してください

```bash
# Serenaメモリからシステム状態を読み込み
mcp__serena__read_memory(memory_name: "system/system_state.md")
```

**取得する情報**:
- 現在の技術スタック構成
- 実装済み機能一覧
- 設定済みMCPサーバー一覧
- プロジェクト基本情報(予算、チーム規模、リリース目標、etc.)

**参照ファイル** (system_state.md から参照):
- `system/tech_stack.md` - 技術スタック詳細(選択理由、制約含む)
- `system/tech_best_practices.md` - Context7取得のベストプラクティス(90日キャッシュ)
- `system/mcp_servers.md` - 設定済みMCPサーバー一覧
- `system/implementation_status.md` - 実装済み機能・進捗状況

**なぜ必要か**:
- 最新のシステム状態を把握するため
- 他エージェントの変更を反映するため
- 一貫性のある実装・提案を行うため
- 重複作業を避けるため

---

## Workflow
1. **計画書読み込み**: `frontend/specs/{feature}.md` を解析
2. **POM設計**: Page Object classes 作成（`frontend/e2e/pages/`）
3. **テストコード生成**: `frontend/e2e/{feature}.spec.ts` 作成
4. **タグ付与**: Smoke Test に `@smoke` タグ
5. **セレクタ最適化**: `data-testid` 優先、fallback に role/text
6. **並列化考慮**: テスト間の依存を排除（独立したユーザー作成）

## Tech Stack
- **Framework**: Playwright Test
- **Pattern**: Page Object Model
- **Language**: TypeScript
- **Selectors**: data-testid > role > text
- **Parallelization**: Independent test isolation

## Code Patterns

### Page Object Model
```typescript
// frontend/e2e/pages/UserListPage.ts
import { Page, Locator } from '@playwright/test';

export class UserListPage {
  readonly page: Page;
  readonly userTable: Locator;
  readonly roleDropdown: (userId: number) => Locator;
  readonly successToast: Locator;

  constructor(page: Page) {
    this.page = page;
    this.userTable = page.locator('[data-testid="user-list"]');
    this.roleDropdown = (userId: number) => page.locator(`[data-testid="role-select-${userId}"]`);
    this.successToast = page.locator('.Toastify__toast--success');
  }

  async goto() {
    await this.page.goto('/users');
    await this.userTable.waitFor();
  }

  async changeUserRole(userId: number, newRole: 'admin' | 'user' | 'viewer') {
    await this.roleDropdown(userId).selectOption(newRole);
    await this.successToast.waitFor();
  }
}
```

### Test Spec
```typescript
// frontend/e2e/user-role-management.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';
import { UserListPage } from './pages/UserListPage';

test.describe('User Role Management', () => {
  let loginPage: LoginPage;
  let userListPage: UserListPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    userListPage = new UserListPage(page);

    // 管理者でログイン
    await loginPage.goto();
    await loginPage.login('admin@example.com', 'AdminPass123!');
  });

  test('[S] Admin can change user role @smoke', async ({ page }) => {
    // Arrange
    await userListPage.goto();

    // Act
    await userListPage.changeUserRole(2, 'admin');

    // Assert
    await expect(userListPage.successToast).toHaveText('ロールを更新しました');

    // Verify persistence
    await page.reload();
    await expect(userListPage.roleDropdown(2)).toHaveValue('admin');
  });

  test('[A] Non-admin cannot change roles', async ({ page }) => {
    // Arrange: 一般ユーザーで再ログイン
    await loginPage.logout();
    await loginPage.login('user@example.com', 'UserPass123!');
    await userListPage.goto();

    // Assert
    await expect(userListPage.roleDropdown(2)).not.toBeVisible();
  });

  test('[B] Invalid role rejected', async ({ page }) => {
    // Arrange
    await userListPage.goto();

    // Act: DevTools Console で手動API呼び出し
    const response = await page.request.put('/api/users/2/role', {
      data: { role: 'invalid' }
    });

    // Assert
    expect(response.status()).toBe(422);
    await expect(page.locator('.Toastify__toast--error')).toHaveText('不正なロールです');
  });
});
```

## Selector Priority
1. **data-testid**: `[data-testid="role-select"]` (最優先)
2. **role**: `page.getByRole('button', { name: 'Submit' })`
3. **text**: `page.getByText('ログイン')`
4. **CSS class**: 最終手段（変更されやすい）

## Tag Convention
- `@smoke`: Smoke Test（10-20%の重要テスト）
- `@critical`: Critical Path
- `@slow`: 5秒以上かかるテスト

## Success Criteria
- [ ] 計画書のすべてのシナリオがテストコード化
- [ ] Page Object Model で保守性確保
- [ ] セレクタが安定（data-testid優先）
- [ ] @smoke タグが適切に付与
- [ ] 並列実行可能（テスト間独立）

## Handoff to
- `playwright-test-healer`: テスト実行・自己修復依頼
- `impl-dev-frontend`: セレクタ不足時のdata-testid追加依頼
