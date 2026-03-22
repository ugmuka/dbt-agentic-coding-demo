# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

dbt project `jaffle_shop` (v3.0.0) — ECサイトのデモデータパイプライン。[dbt-labs/jaffle-shop](https://github.com/dbt-labs/jaffle-shop) ベース。dbt >= 1.5.0 が必要。

## Commands

タスクランナーとして [Taskfile](https://taskfile.dev/) を使用（`task` コマンド）。

```bash
# 環境セットアップ（venv作成 → 依存インストール → seed生成 → ロード → クリーン）
task load

# 個別ステップ
task venv        # Python仮想環境を作成
task install     # pip依存 + dbt-core + dbt-duckdb をインストール
task gen         # jafgen でシードデータ生成（デフォルト6年分）
task seed        # dbt seed --full-refresh でシードをロード
task clean       # 生成データ削除 + dbt アンインストール
```

dbt コマンドは venv を有効化して実行:
```bash
source .venv/bin/activate
dbt deps                     # パッケージインストール（初回必須）
dbt run                      # 全モデル実行
dbt run -s model_name        # 単一モデル実行
dbt test                     # 全テスト実行
dbt test -s model_name       # 単一モデルのテスト
dbt build                    # run + test
```

Python 依存管理は `uv pip compile requirements.in -o requirements.txt`。

## Architecture

### Model Layers

- **staging** (`models/staging/`) — ソーステーブルに 1:1 対応する view。`source()` マクロでrawデータを参照し、カラムのリネームと型変換を行う。
- **marts** (`models/marts/`) — ビジネスロジックを含む table。staging モデルを `ref()` で結合・集計。

### Data Flow

```
seeds (raw CSV) → source ecom.raw_* → stg_* (staging views) → marts (tables)
                                                                ├── customers
                                                                ├── orders
                                                                ├── order_items
                                                                ├── locations
                                                                ├── products
                                                                └── supplies
```

### Key Macros

- `cents_to_dollars` — セント→ドル変換。`adapter.dispatch` で DB ごとに実装が分岐（default / postgres / bigquery / fabric）。
- `generate_schema_name` — スキーマルーティング: seed は常に `raw`、prod は `{default}_{custom}`、それ以外は default schema。

### Configuration

- **DWH**: DuckDB（`jaffle_shop.duckdb`）。Taskfile の `DB` 変数で変更可能
- **Profile**: `jaffle_shop`（プロジェクトルートの `profiles.yml`）
- **dbt packages**: `dbt_utils`, `dbt_date`, `dbt-audit-helper`
- **Semantic models / Metrics**: `customers.yml`, `orders.yml` に定義済み（MetricFlow 対応）

### Testing

- **data_tests**: `customers.yml` / `orders.yml` で `dbt_utils.expression_is_true` 等のデータ整合性テスト
- **unit_tests**: `orders.yml` に unit test 定義あり（`test_order_items_compute_to_bools_correctly`）
- テストパスは `data-tests/` ディレクトリ

## Gotchas

- seed ロードは `--vars '{"load_source_data": true}'` が必要（`task seed` は自動付与）
- `task load` の `clean` ステップで dbt がアンインストールされる — 以降は手動で `pip install dbt-core dbt-duckdb` が必要
- marts/ は現在空（staging 完了済、mart 開発はこれから）


# AI-DLC and Spec-Driven Development

Kiro-style Spec Driven Development implementation on AI-DLC (AI Development Life Cycle)

## Project Context

### Paths
- Steering: `.kiro/steering/`
- Specs: `.kiro/specs/`

### Steering vs Specification

**Steering** (`.kiro/steering/`) - Guide AI with project-wide rules and context
**Specs** (`.kiro/specs/`) - Formalize development process for individual features

### Active Specifications
- Check `.kiro/specs/` for active specifications
- Use `/kiro:spec-status [feature-name]` to check progress

## Development Guidelines
- Think in English, generate responses in Japanese. All Markdown content written to project files (e.g., requirements.md, design.md, tasks.md, research.md, validation reports) MUST be written in the target language configured for this specification (see spec.json.language).

## Minimal Workflow
- Phase 0 (optional): `/kiro:steering`, `/kiro:steering-custom`
- Phase 1 (Specification):
  - `/kiro:spec-init "description"`
  - `/kiro:spec-requirements {feature}`
  - `/kiro:validate-gap {feature}` (optional: for existing codebase)
  - `/kiro:spec-design {feature} [-y]`
  - `/kiro:validate-design {feature}` (optional: design review)
  - `/kiro:spec-tasks {feature} [-y]`
- Phase 2 (Implementation): `/kiro:spec-impl {feature} [tasks]`
  - `/kiro:validate-impl {feature}` (optional: after implementation)
- Progress check: `/kiro:spec-status {feature}` (use anytime)

## Development Rules
- 3-phase approval workflow: Requirements → Design → Tasks → Implementation
- Human review required each phase; use `-y` only for intentional fast-track
- Keep steering current and verify alignment with `/kiro:spec-status`
- Follow the user's instructions precisely, and within that scope act autonomously: gather the necessary context and complete the requested work end-to-end in this run, asking questions only when essential information is missing or the instructions are critically ambiguous.

## Steering Configuration
- Load entire `.kiro/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/kiro:steering-custom`)
