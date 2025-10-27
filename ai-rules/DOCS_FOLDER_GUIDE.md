# プロジェクト資料フォルダガイド

ユーザー提供の資料（要件定義書、仕様書、設計資料等）を格納するフォルダ構成です。

---

## 📁 docs/ フォルダ構成

```
docs/
├── requirements/          # 要件定義書
│   ├── project-requirements.md
│   ├── user-stories.md
│   └── functional-requirements.xlsx
│
├── specs/                # 技術仕様書
│   ├── api-spec.yaml
│   ├── database-schema.sql
│   └── screen-wireframes.pdf
│
├── designs/              # 設計資料
│   ├── architecture-diagram.png
│   ├── ui-mockup.fig
│   └── sequence-diagram.mmd
│
└── references/           # 参考資料
    ├── competitor-analysis.md
    ├── market-research.pdf
    └── best-practices.md
```

---

## 使い方

### 1. 要件定義書を配置
- `docs/requirements/` に要件定義書を格納
- AI が参照して実装計画を立てます

### 2. 仕様書を配置
- `docs/specs/` にAPI仕様、DB設計等を格納
- AI が実装時に参照します

### 3. 設計資料を配置
- `docs/designs/` にアーキテクチャ図、UIモックアップ等を格納
- AI が設計資料を参照して実装します

### 4. 参考資料を配置
- `docs/references/` に競合分析、技術調査等を格納
- AI が技術選定時に参考にします

---

## 要件変更時の注意

要件定義書を更新した場合、Phase開始時に自動検知されます。

詳細: [REQUIREMENTS_CHANGE.md](./REQUIREMENTS_CHANGE.md)
