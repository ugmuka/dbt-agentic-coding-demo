# Research & Design Decisions

## Summary
- **Feature**: `new-mart-model`
- **Discovery Scope**: Extension（既存 dbt プロジェクトへの mart レイヤー追加）
- **Key Findings**:
  - staging モデルが全て完成済みで、金額はドル変換済み。mart では再変換不要
  - stg_supplies は product_id に対して N:1 ではなく多対一（コスト変動で複数行）。集計前に product_id 単位で事前集計が必要
  - dbt_project.yml で marts の materialization は table に設定済み。追加設定不要

## Research Log

### supplies の結合粒度
- **Context**: orders モデルで order_items → products → supplies を結合する際、行の膨張を防ぐ必要がある
- **Sources Consulted**: stg_supplies.yml の description（"One row per supply cost, not per supply"）、stg_supplies.sql の実装
- **Findings**:
  - stg_supplies は supply_uuid が PK（supply_id + sku の surrogate key）
  - 同一 product_id に対して複数の supply レコードが存在する（コスト変動時に新行追加）
  - supply_cost はドル変換済み
- **Implications**: product_id 単位で supply_cost を SUM した CTE を先に作り、order_items と結合する設計が必要

### customer_order_number の実装方式
- **Context**: 顧客ごとの注文順序番号を付与する
- **Sources Consulted**: DuckDB の window 関数サポート
- **Findings**: `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ordered_at)` で実装可能
- **Implications**: orders モデルの最終 CTE で window 関数を適用

### customers の orders 参照
- **Context**: customers mart が orders mart を ref() で参照する DAG 依存
- **Sources Consulted**: dbt のモデル間依存解決
- **Findings**: dbt は ref() の DAG を自動解決し、orders → customers の順にビルドする
- **Implications**: customers.sql で `ref('orders')` を使用すれば、ビルド順序は自動管理される

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| CTE チェーン | 各モデル内で CTE を連鎖させて段階的に変換・集計 | dbt の標準パターン、可読性が高い | CTE が多くなると複雑化 | staging 層の既存パターンと一致 |

## Design Decisions

### Decision: supplies の事前集計
- **Context**: order_items と supplies を直接結合すると行が膨張する
- **Alternatives Considered**:
  1. order_items → products → supplies を直接 JOIN し、最後に GROUP BY
  2. supplies を product_id 単位で事前集計してから JOIN
- **Selected Approach**: Option 2 — supplies を product_id 単位で事前集計
- **Rationale**: 集計を早い段階で行うことで中間結果の行数を抑え、可読性も向上する
- **Trade-offs**: CTE が1つ増えるが、意図が明確になる
- **Follow-up**: dbt build で行数・金額の整合性を検証

### Decision: customers が mart の orders を参照
- **Context**: customers モデルは注文集計を必要とするが、staging の stg_orders を直接使うか mart の orders を使うか
- **Alternatives Considered**:
  1. stg_orders を直接集計
  2. orders mart を ref() で利用
- **Selected Approach**: Option 2 — orders mart を利用
- **Rationale**: orders mart には既にアイテム集計・原価・フラグが含まれており、ロジックの重複を防げる。要件でも orders mart の参照が指定されている
- **Trade-offs**: orders → customers の DAG 依存が生まれるが、dbt が自動管理する
- **Follow-up**: dbt build で正しいビルド順序を確認

## Risks & Mitigations
- supplies の多対一結合による行膨張 — product_id 単位の事前集計 CTE で対処
- orders → customers の DAG 依存 — dbt の ref() 自動解決で管理。循環参照なし
