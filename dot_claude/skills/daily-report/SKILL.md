---
name: daily-report
description: GitHub の日次アクティビティ（Issues, PRs の Open/Close/Merge）を取得し、Obsidian Daily Note の Memo セクションに作業ログとして書き出す。ユーザーが「今日の作業まとめ」「daily report」「作業ログ」「/daily-report」と言ったときに使用する。
---

# Daily Report

GitHub の日次アクティビティを取得し、Obsidian Daily Note に構造化された作業ログとして書き出す。

## Usage

```
/daily-report              # 今日のアクティビティ
/daily-report 2026-02-20   # 指定日のアクティビティ
```

引数なしの場合は当日（currentDate）を対象とする。日付が引数として渡された場合はその日を対象とする。

## Workflow

### Step 1: GitHub ユーザー名の取得

```bash
gh api user --jq '.login'
```

### Step 2: アクティビティの取得

対象日を `$DATE` として、以下の4クエリを**並列実行**する:

```bash
# 作成した Issues
gh search issues --author=$USER --created=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50

# Close した Issues
gh search issues --author=$USER --closed=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50

# 作成した PRs
gh search prs --author=$USER --created=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50

# Close/Merge された PRs
gh search prs --author=$USER --closed=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50
```

### Step 3: 詳細情報の取得

各 PR と Issue の詳細を取得する。

**PR の詳細**（全 PR について取得）:
```bash
gh pr view $NUMBER --repo $REPO --json title,body,additions,deletions,files,commits \
  --jq '{title, additions, deletions, commits: .commits | length, files: [.files[].path], body: .body[:500]}'
```

**Issue の詳細**（作成した Issue + body が充実している Close 済み Issue について取得）:
```bash
gh issue view $NUMBER --repo $REPO --json title,body,labels \
  --jq '{title, labels: [.labels[].name], body: .body[:400]}'
```

### Step 4: Daily Note の読み込みと更新

1. Daily Note のパスを決定: `/Users/mary/ghq/github.com/lv416e/vault-of-obsidian/Daily Note/$DATE.md`
2. ファイルを Read して既存の内容を確認する
3. `## Memo` セクション内のプレースホルダー（`### Topic 1` / `#### sub topic 1`）を GitHub Activity に置き換える
4. 既に GitHub Activity が書かれている場合は、内容を更新する

## Output Format

`## Memo` セクション内に以下の構造で書き出す。リポジトリが複数ある場合はリポジトリごとにセクションを分ける。

```markdown
### GitHub Activity (`owner/repo`)

---

#### Pull Requests

##### Merged: [#番号](URL) タイトル
- **+追加行 / -削除行** | ファイル数 files | コミット数 commits
- 変更の要点（PR body から要約）
  - サブポイント（大きな変更の場合はカテゴリ別に整理）
- Closes #関連Issue（ある場合）

##### Open: [#番号](URL) タイトル
- （同上の形式）

---

#### Issues - 新規 Open

##### [#番号](URL) タイトル
- Issue の概要（body から要約。body が空なら1行で簡潔に）

---

#### Issues - Close（完了）

| # | タイトル | 概要 | 対応 PR |
|---|---------|------|---------|
| [#番号](URL) | タイトル | 概要 | #PR番号 |
```

### 記述ルール

- PR の状態は `Merged` > `Open` > `Closed` の順で記述する
- PR の要約は body の内容を元に日本語で記述する（body が英語でも日本語に変換）
- `**+行数 / -行数**` のメトリクスは必ず含める
- Close した Issue には対応 PR を紐付ける（PR body の `Closes #N` から判定）
- 重複 Issue（作成即 Close → 再作成）は末尾にまとめて記述する
- アクティビティが無い場合は「本日の GitHub アクティビティはありません」と記述する
