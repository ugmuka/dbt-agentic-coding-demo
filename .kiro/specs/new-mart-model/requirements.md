# Requirements Document

## Introduction

本仕様は、jaffle_shop プロジェクトの marts レイヤーモデルの実装要件を定義する。staging レイヤー（stg_customers, stg_orders, stg_order_items, stg_products, stg_supplies）は完成済みであり、これらを `ref()` で結合・集計してビジネスロジックを含む分析用テーブルを構築する。

対象モデル: **orders**, **customers**

## Requirements

### Requirement 1: 注文マートモデル（orders）

**Objective:** データアナリストとして、注文ごとの詳細情報（アイテム集計・原価・カテゴリフラグ・顧客内注文順序）を含む注文テーブルが欲しい。これにより、注文内容と顧客行動の両面から分析を行える。

#### Acceptance Criteria
1. The orders model shall `ref()` で stg_orders, stg_order_items, stg_products, stg_supplies を結合し、注文ごとに1行のテーブルを出力する
2. The orders model shall order_items を order_id 単位で集計し、注文ごとのアイテム数、原価合計（supply_cost）、食品アイテム数、飲料アイテム数を算出する
3. The orders model shall 注文に食品が含まれるかどうかのフラグ（is_food_order）と飲料が含まれるかどうかのフラグ（is_drink_order）をブーリアンカラムとして含める
4. The orders model shall customer_id ごとに ordered_at で昇順に並べた連番（customer_order_number）を付与し、その顧客にとって何回目の注文かを示す
5. The orders model shall subtotal, tax_paid, order_total の金額をドル単位で提供する
6. The orders model shall order_id を主キーとし、not_null かつ unique であることを保証する
7. The orders model shall table としてマテリアライズされる

### Requirement 2: 顧客マートモデル（customers）

**Objective:** データアナリストとして、顧客ごとの購買履歴を集約したテーブルが欲しい。これにより、顧客セグメンテーションやリテンション分析を効率的に行える。

#### Acceptance Criteria
1. The customers model shall `ref()` で stg_customers と orders（mart モデル）を結合し、顧客ごとに1行のテーブルを出力する
2. The customers model shall 顧客ごとの注文回数（count_orders）、初回注文日（first_ordered_at）、最終注文日（last_ordered_at）、累計売上金額（lifetime_spend_pretax）、累計税込金額（lifetime_spend）を集計カラムとして含める
3. The customers model shall 注文回数が2回以上の顧客を "returning"、それ以外を "new" と判定する customer_type カラムを含める
4. The customers model shall customer_id を主キーとし、not_null かつ unique であることを保証する
5. The customers model shall table としてマテリアライズされる

### Requirement 3: データ品質とテスト

**Objective:** データエンジニアとして、mart モデルのデータ品質を保証するテストが欲しい。これにより、パイプラインの信頼性を担保できる。

#### Acceptance Criteria
1. The jaffle_shop pipeline shall 全 mart モデルに対して主キーの not_null・unique テストを YAML で定義する
2. The jaffle_shop pipeline shall mart モデル間の外部キー関係に relationships テストを定義する（例: orders.customer_id → customers.customer_id）
3. The jaffle_shop pipeline shall `dbt build` で全モデルのビルドとテストがエラーなく完了する
4. The jaffle_shop pipeline shall 各 mart モデルに YAML スキーマ定義（description、columns）を持つ

### Requirement 4: 命名規則とプロジェクト構造

**Objective:** dbt 開発者として、プロジェクトの既存規約に従った一貫性のあるモデル構成が欲しい。これにより、保守性と可読性を維持できる。

#### Acceptance Criteria
1. The mart models shall `models/marts/` ディレクトリに配置される
2. The mart models shall エンティティ名をそのままモデル名とする（`orders.sql`, `customers.sql`）
3. The mart models shall 各 SQL ファイルに対応する同名の `.yml` スキーマファイルを持つ
4. The mart models shall staging モデルのみを `ref()` で参照し、`source()` を直接使用しない（customers は orders mart を ref() で参照可）
5. The mart models shall 金額は staging で変換済みのドル単位カラムをそのまま利用する
