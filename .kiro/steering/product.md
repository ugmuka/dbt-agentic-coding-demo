# Product Overview

Jaffle Shop (v3.0.0) — EC サイトのデモデータパイプライン。[dbt-labs/jaffle-shop](https://github.com/dbt-labs/jaffle-shop) をベースとした、dbt のベストプラクティスを示すリファレンス実装。

## Core Capabilities

- **データ変換パイプライン**: 生の EC トランザクションデータ（注文・顧客・商品・仕入・店舗）を分析可能なテーブルに変換
- **マルチアダプター対応**: BigQuery / PostgreSQL / DuckDB / Fabric をマクロディスパッチで切り替え可能
- **データ品質保証**: data tests（整合性検証）と unit tests（ロジック検証）による多層テスト
- **合成データ生成**: jafgen による再現可能なデモデータ生成（年数指定可能）

## Target Use Cases

- dbt の変換パターンとベストプラクティスの学習・教育
- EC データのディメンショナルモデリングのリファレンス
- 顧客分析、注文分析、在庫・仕入コスト追跡、店舗パフォーマンス分析

## Value Proposition

- ゼロセットアップで動作する自己完結型パイプライン（DuckDB デフォルト）
- staging → marts のレイヤードアーキテクチャによる関心の分離
- アダプター切り替えだけで本番 DWH にデプロイ可能

---
_Focus on patterns and purpose, not exhaustive feature lists_
