# Implementation Plan

- [x] 1. orders mart モデルの実装
- [x] 1.1 (P) 注文ごとのアイテム集計・原価・カテゴリフラグ・顧客内注文順序を含む orders SQL を作成する
  - stg_orders をベースに、stg_order_items, stg_products, stg_supplies を結合する
  - stg_supplies を product_id 単位で supply_cost を合計する事前集計 CTE を作成する
  - order_items に商品情報と原価を付与し、order_id 単位でアイテム数・原価合計・食品数・飲料数を集計する
  - 食品数・飲料数から is_food_order, is_drink_order のブーリアンフラグを導出する
  - stg_orders の金額カラム（subtotal, tax_paid, order_total）はドル変換済みのためそのまま引き継ぐ
  - customer_id ごとに ordered_at 昇順で ROW_NUMBER を使い customer_order_number を付与する
  - order_id を主キーとし、注文ごとに1行となるテーブルを出力する
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.7_

- [x] 1.2 (P) orders モデルの YAML スキーマ定義とデータテストを作成する
  - モデルの description とカラム定義（全出力カラム）を記述する
  - order_id に not_null, unique テストを定義する
  - customer_id に not_null テストと customers への relationships テストを定義する
  - _Requirements: 1.6, 3.1, 3.2, 3.4_

- [x] 2. customers mart モデルの実装
- [x] 2.1 (P) 顧客ごとの購買履歴集約と顧客タイプ判定を含む customers SQL を作成する
  - stg_customers をベースに、orders mart モデルを ref() で取得する
  - orders を customer_id 単位で集計し、注文回数・初回注文日・最終注文日・累計売上（税抜）・累計売上（税込）を算出する
  - 注文回数が2回以上の顧客を "returning"、それ以外を "new" と判定する customer_type カラムを CASE 式で追加する
  - 注文がない顧客も LEFT JOIN で残し、customer_type は "new" に分類する
  - customer_id を主キーとし、顧客ごとに1行となるテーブルを出力する
  - orders mart への依存があるため、タスク1の完了後に実行すること
  - _Requirements: 2.1, 2.2, 2.3, 2.5_

- [x] 2.2 (P) customers モデルの YAML スキーマ定義とデータテストを作成する
  - モデルの description とカラム定義（全出力カラム）を記述する
  - customer_id に not_null, unique テストを定義する
  - customer_type に accepted_values テスト（'returning', 'new'）を定義する
  - _Requirements: 2.4, 3.1, 3.4_

- [x] 3. dbt build で全 mart モデルのビルドとテストを実行し、エラーなく完了することを検証する
  - `dbt build -s orders customers` を実行し、DAG 順序（stg_* → orders → customers）でビルドされることを確認する
  - 全データテスト（PK, FK, accepted_values）がパスすることを確認する
  - エラーがあればタスク1・2に戻って修正する
  - _Requirements: 3.3, 4.1, 4.2, 4.3, 4.4, 4.5_
