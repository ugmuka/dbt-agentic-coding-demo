# dbt-agentic-coding-demo

dbt を Claude Code で開発するためのデモ環境。

[dbt-labs/jaffle-shop](https://github.com/dbt-labs/jaffle-shop) (v3.0.0) をベースにした EC サイトのデモデータパイプライン。marts モデルを意図的に空にしており、Claude Code による開発プロセスを体験できる構成になっている。

## 前提条件

- Python 3.x
- [Taskfile](https://taskfile.dev/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI)

## セットアップ

```bash
task load    # venv作成 → 依存インストール → seed生成 → ロード → クリーン
```

個別ステップ:

```bash
task venv       # Python仮想環境を作成
task install    # pip依存 + dbt-core + dbt-duckdb をインストール
task gen        # jafgen でシードデータ生成
task seed       # dbt seed --full-refresh でシードをロード
```

dbt コマンド:

```bash
source .venv/bin/activate
dbt deps     # パッケージインストール（初回必須）
dbt build    # run + test
```

## cc-sdd を利用した開発手順

cc-sdd（Claude Code Spec-Driven Development）は、Kiro-style Spec Driven Development を AI-DLC（AI Development Life Cycle）上に実装した開発フレームワーク。設定は `.kiro/` ディレクトリに格納されている。

### ワークフロー

| Phase | 内容 | コマンド |
|-------|------|---------|
| Phase 0 (任意) | Steering 設定 | `/kiro:steering` |
| Phase 1 | Specification | `/kiro:spec-init` → `/kiro:spec-requirements` → `/kiro:spec-design` → `/kiro:spec-tasks` |
| Phase 2 | Implementation | `/kiro:spec-impl` |

- 各フェーズ間でユーザー承認が必要
- `/kiro:spec-status` で進捗確認

### 使用例

```
# 新しいmartモデルの仕様を初期化
/kiro:spec-init "顧客の注文サマリーを集計するmartモデルを追加する"

# 要件定義を生成
/kiro:spec-requirements new-mart-model

# 技術設計を生成
/kiro:spec-design new-mart-model

# 実装タスクを生成
/kiro:spec-tasks new-mart-model

# 実装を実行
/kiro:spec-impl new-mart-model
```

## マルチエージェントアーキテクチャ

`/dbt-dev` コマンドで、4 つの専門エージェントによるマルチエージェント開発を実行できる。エージェント定義は `.claude/agents/` に格納されている。

| エージェント | 役割 | 権限 |
|-------------|------|------|
| dbt-developer | オーケストレーター | タスクルーティング |
| dbt-analyst | データディスカバリー | 読み取り専用 |
| dbt-architect | 技術設計 | 読み取り専用 |
| dbt-analytics-engineer | SQL/YAML 実装 | 書き込み可 |

### パイプラインフロー

```
Analyst（データ調査） → Architect（設計） → Analytics Engineer（実装）
```

各フェーズ間で dbt-developer がコンテキストを引き継ぎ、ユーザー承認を挟んで次のフェーズに進む。

## プロジェクト構成

```
├── models/
│   ├── staging/    # ソースに1:1対応するview
│   └── marts/      # ビジネスロジック（開発対象）
├── .claude/
│   ├── agents/     # エージェント定義
│   ├── commands/   # スキル定義（kiro/, dbt-dev）
│   └── settings.*  # 権限・プラグイン設定
├── .kiro/
│   ├── steering/   # プロジェクトコンテキスト
│   ├── specs/      # フィーチャー仕様
│   └── settings/   # ルール・テンプレート
└── seeds/          # 合成CSVデータ
```

## 参考

- [dbt-labs/jaffle-shop](https://github.com/dbt-labs/jaffle-shop) — ベースプロジェクト
- https://www.youtube.com/watch?v=NolqjHDl9UM — エージェントアーキテクチャの参照元
