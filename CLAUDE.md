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
task install     # pip依存 + dbt-core + dbt-bigquery をインストール
task gen         # jafgen でシードデータ生成（デフォルト6年分）
task seed        # dbt seed --full-refresh でシードをロード
```

dbt コマンドは venv を有効化して実行:
```bash
source .venv/bin/activate
dbt run                      # 全モデル実行
dbt run -s model_name        # 単一モデル実行
dbt test                     # 全テスト実行
dbt test -s model_name       # 単一モデルのテスト
dbt build                    # run + test
dbt deps                     # パッケージインストール
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

- **DWH**: BigQuery（Taskfile の `DB` 変数で変更可能）
- **Profile**: `default`（`~/.dbt/profiles.yml` で設定）
- **dbt packages**: `dbt_utils`, `dbt_date`, `dbt-audit-helper`
- **Semantic models / Metrics**: `customers.yml`, `orders.yml` に定義済み（MetricFlow 対応）

### Testing

- **data_tests**: `customers.yml` / `orders.yml` で `dbt_utils.expression_is_true` 等のデータ整合性テスト
- **unit_tests**: `orders.yml` に unit test 定義あり（`test_order_items_compute_to_bools_correctly`）
- テストパスは `data-tests/` ディレクトリ
