---
description: dbt開発タスクをマルチエージェントチームで実行する
---

BLOCKING REQUIREMENT: 以下のルールに従い、必ず Agent ツールで `dbt-developer` を呼び出すこと。スキップ・直接回答は禁止。

## タスク内容

$ARGUMENTS

## ルール

Agent ツールの `subagent_type` に `dbt-developer` を指定し、`prompt` パラメータには上記「タスク内容」セクションに展開された実際のテキストをそのまま渡すこと。

think hard
