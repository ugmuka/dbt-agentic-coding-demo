# Technology Stack

## Architecture

レイヤードデータ変換アーキテクチャ。raw CSV seeds → staging views → mart tables の3層構成。各層は `source()` / `ref()` マクロで疎結合に接続される。

## Core Technologies

- **Language**: SQL (Jinja テンプレート) + Python (ツーリング)
- **Framework**: dbt >= 1.5.0
- **Adapter**: DuckDB（デフォルト）、BigQuery / PostgreSQL / Fabric 対応
- **Task Runner**: [Taskfile](https://taskfile.dev/) (`task` コマンド)

## Key Libraries

- `dbt_utils` — surrogate key 生成、式ベーステストなどのユーティリティ
- `dbt_date` — タイムゾーン対応の日付操作
- `dbt-audit-helper` — データ監査ヘルパー
- `jafgen` — Jaffle Shop 用合成データジェネレーター

## Development Standards

### マクロ設計
- `adapter.dispatch()` によるクロスDB互換性パターン
- DB 固有ロジックは `{adapter}__{macro_name}` 命名で分離
- フォールバックは `default__` 実装

### テスト戦略
- **data tests**: YAML 内 `data_tests:` でカラム・モデルレベルの整合性検証（`not_null`, `unique`, `relationships`, `expression_is_true`）
- **unit tests**: dbt ネイティブ unit test（`given` / `expect` 構造）
- **テストパス**: `data-tests/` ディレクトリ

### 型変換
- 金額は内部でセント保持 → `cents_to_dollars` マクロで表示時にドル変換
- タイムゾーン: `America/Los_Angeles`（dbt_date 設定）

## Development Environment

### Required Tools
- Python 3.x + venv
- dbt-core >= 1.5.0 + adapter package
- Taskfile 3.x
- jafgen >= 0.4.11（データ生成用）

### Common Commands
```bash
task load          # 環境セットアップ一式（venv → install → gen → seed → clean）
dbt run            # 全モデル実行
dbt test           # 全テスト実行
dbt build          # run + test
```

## Key Technical Decisions

- **DuckDB デフォルト**: ゼロセットアップのローカル開発を優先。本番は profile 切り替えで対応
- **スキーマルーティング**: `generate_schema_name` マクロで seed は常に `raw`、prod は `{default}_{custom}` 方式
- **Seed の条件付きロード**: `load_source_data` 変数（デフォルト false）で制御し、意図しない本番ロードを防止
- **Semantic Layer**: MetricFlow 対応の semantic models / metrics 定義を将来的にサポート

---
_Document standards and patterns, not every dependency_
