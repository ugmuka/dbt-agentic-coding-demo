# dbt 実装ルール

`/kiro:spec-impl` で dbt モデル（SQL / YAMLファイル）の実装タスクを実行する際は、直接ファイルを編集するのではなく、Agent ツールの `subagent_type: "dbt-developer"` を使って dbt マルチエージェントチームに委譲すること。

## 対象

- dbt モデル（`.sql`）の新規作成・修正
- dbt スキーマ定義（`.yml`）の新規作成・修正
- dbt テスト・seed・macro の作成・修正

## やり方

タスクの内容と、design.md / tasks.md から得たコンテキストを prompt に含めて `dbt-developer` エージェントを呼び出す。

## 対象外

- tasks.md のチェックボックス更新など、spec 管理ファイルの操作は直接行ってよい
- steering / requirements / design の読み込みも直接行ってよい
