# Project Structure

## Organization Philosophy

**レイヤードアーキテクチャ**: データの流れに沿った層分離。各層は責務が明確に分かれ、上位層は下位層のみを参照する。

```
seeds (raw CSV) → source() → staging (views) → ref() → marts (tables)
```

## Directory Patterns

### Staging Layer
**Location**: `models/staging/`
**Purpose**: ソーステーブルに 1:1 対応する view。カラムリネーム・型変換のみ。ビジネスロジックや集計は含めない。
**Materialization**: `view`
**Example**:
```sql
with source as (select * from {{ source('ecom', 'raw_orders') }})
renamed as (select id as order_id, ... from source)
select * from renamed
```

### Marts Layer
**Location**: `models/marts/`
**Purpose**: ビジネスロジックを含む分析用テーブル。staging モデルを `ref()` で結合・集計。
**Materialization**: `table`

### Seeds
**Location**: `seeds/jaffle-data/`
**Purpose**: jafgen で生成された合成 CSV データ。`dbt seed` で `raw` スキーマにロード。
**Config**: `load_source_data` 変数で有効化制御

### Macros
**Location**: `macros/`
**Purpose**: 共有変換ロジック。アダプターディスパッチによるクロス DB 対応。

## Naming Conventions

- **Staging モデル**: `stg_{entity}` — ソーステーブル名に対応（例: `stg_orders`, `stg_customers`）
- **Mart モデル**: エンティティ名そのまま（例: `customers`, `orders`）
- **ソース定義**: `__sources.yml`（ダブルアンダースコアプレフィックス）
- **YAML スキーマ**: SQL と同名の `.yml` ファイルで 1:1 ペアリング（例: `stg_orders.sql` + `stg_orders.yml`）
- **Seeds**: `raw_{entity}.csv` プレフィックス
- **マクロ**: snake_case、アダプター固有は `{adapter}__{macro_name}`

## CTE パターン

Staging モデルは統一された3段 CTE 構成:

1. **`source`**: `{{ source() }}` による生データ取得
2. **`renamed`**: カラムリネーム・型変換・基本的な値変換
3. **Final select**: `select * from renamed`

## YAML 構造パターン

```yaml
models:
  - name: stg_model_name
    description: モデルの説明
    columns:
      - name: column_name
        description: カラムの説明
        data_tests:
          - not_null
          - unique

unit_tests:
  - name: test_name
    given: [...]
    expect: [...]
```

## Code Organization Principles

- **1:1 マッピング**: staging モデルはソーステーブルと 1:1 対応を厳守
- **上方向参照のみ**: marts → staging → source の方向でのみ参照。逆方向・同一層間参照は禁止
- **集計の遅延**: staging では raw 粒度を維持。集計は marts 層で実施
- **ソース定義の集約**: 全ソースを `__sources.yml` に一元管理

---
_Document patterns, not file trees. New files following patterns shouldn't require updates_
