---
name: daily-report
description: GitHub、Google Calendar、Gmail、Notion、ローカル Git の日次アクティビティを取得し、Obsidian Daily Note の Memo セクションに作業ログとして書き出す。ユーザーが「今日の作業まとめ」「daily report」「作業ログ」「/daily-report」と言ったときに使用する。
---

# Daily Report

複数データソースから日次アクティビティを取得し、Obsidian Daily Note に構造化された作業ログとして書き出す。

## Usage

```
/daily-report              # 今日のアクティビティ
/daily-report 2026-02-20   # 指定日のアクティビティ
```

引数なしの場合は当日（currentDate）を対象とする。日付が引数として渡された場合はその日を対象とする。

## Data Sources

| ソース | ツール | 用途 |
|--------|--------|------|
| GitHub | `gh` CLI | Issues, PRs の Open/Close/Merge |
| Google Calendar | `mcp__claude_ai_Google_Calendar__*` | 会社 + 個人のイベント |
| Gmail | `mcp__claude_ai_Gmail__*` | 会社メールのサマリ |
| Notion | `mcp__claude_ai_Notion__*` | ワークスペース更新ページ |
| ローカル Git | `git log` | 未 push コミットの走査 |

## Workflow

### Step 1: データ収集（並列実行）

以下の全データソースを**可能な限り並列で**取得する。

#### 1a. GitHub

```bash
gh api user --jq '.login'
```

対象日を `$DATE` として 4 クエリを並列実行:

```bash
gh search issues --author=$USER --created=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50
gh search issues --author=$USER --closed=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50
gh search prs --author=$USER --created=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50
gh search prs --author=$USER --closed=$DATE --json title,url,state,repository,createdAt,closedAt --limit 50
```

#### 1b. Google Calendar

以下の 3 カレンダーからイベントを並列取得:

| calendarId | 種別 |
|------------|------|
| `primary`（= `matsushima@a1a.co.jp`） | 会社 |
| `ryo169116961@gmail.com` | 個人 |
| `t25c25@gmail.com` | 個人 |

各カレンダーで `gcal_list_events` を呼び出す:
- `timeMin`: `$DATE T00:00:00`
- `timeMax`: `$DATE T23:59:59`
- `timeZone`: `Asia/Tokyo`

#### 1c. Gmail（会社）

`gmail_search_messages` で対象日のメールを取得:
- クエリ: `after:$PREV_DATE before:$NEXT_DATE -category:promotions -category:updates -category:social`
- `maxResults`: 20

カレンダー招待の自動返信（`承諾:` / `辞退:` / `仮承諾:`）は除外してよい。

#### 1d. Notion（会社）

`notion-search` で DB `collection://2ac4cfaf-30e6-807f-b7b5-000b93dde2d1`（🔬 Procurement AI Lab Tech Notes）を対象に検索:

```
{
  "data_source_url": "collection://2ac4cfaf-30e6-807f-b7b5-000b93dde2d1",
  "filters": {
    "created_date_range": { "start_date": "$DATE", "end_date": "$NEXT_DATE" },
    "created_by_user_ids": ["29bd872b-594c-815c-95c0-000292feb9fe"]
  }
}
```

- `created_by_user_ids` で自分（松島）が作成したページのみに絞り込む
- **EditedAt（編集日）フィルタは API 上存在しないため、自分が編集したが作成していないページは notion-search では拾えない**
- 結果が空の場合はセクションごと省略する

**編集ページの補足（常時実行）**: notion-search と並行して、Gmail で `from:notify@mail.notion.so after:$PREV_DATE before:$NEXT_DATE` を検索し、Notion 更新通知から自分が関わった更新（編集・コメント含む）を取得する。notion-search の結果と重複するページは統合して 1 件として扱う。

**ページ内容の要約**: 検索でヒットしたページは `notion-fetch` でコンテンツを取得し、Daily Note には以下を記載する:
- ページタイトル・タグ・URL（見出しリンク形式）
- 内容の要点を 3〜5 行で要約（MTG ノートなら議題の背景・決定事項・次アクション、Research ノートなら目的・主要定義・結論）
- コンテンツが動画のみ・空の場合は「ビジュアル資料のみ」と記載しファイル名を列挙する

#### 1e. ローカル Git

`ghq` 配下のリポジトリから未 push コミットを走査:

```bash
# ghq 配下の全リポジトリを列挙
find ~/ghq -name .git -type d -maxdepth 5

# 各リポジトリで対象日のコミットを取得
git -C $REPO_DIR log --all --oneline --since="$DATE 00:00" --until="$NEXT_DATE 00:00" --author="$(git -C $REPO_DIR config user.name)"
```

GitHub に push 済みのコミットと重複する場合は省略する。未 push のコミットや、GitHub 上で PR になっていないローカル作業のみ記載する。

### Step 2: GitHub 詳細情報の取得

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

### Step 3: Daily Note の読み込みと更新

1. Daily Note のパスを決定: `/Users/mary/ghq/github.com/lv416e/vault-of-obsidian/Daily Note/$DATE.md`
2. ファイルを Read して既存の内容を確認する
3. `## Memo` セクション内のプレースホルダー（`### Topic 1` / `#### sub topic 1`）を各セクションに置き換える
4. 既にセクションが書かれている場合は、内容を更新する

### Step 4: Memory KG への書き込み

Daily Note 書き出し後、`mcp__memory__create_entities` で当日のサマリを Knowledge Graph に保存する。

- **エンティティ名**: `daily-report/$DATE`
- **エンティティタイプ**: `DailyReport`
- **observations** に以下を含める:
  - `勤務形態`: オフィス / リモート（Calendar の workingLocation や個人カレンダーの出社イベントから判定）
  - `Calendar`: 主要イベントの時刻とタイトル（簡潔に）
  - `PR Merged` / `PR Open` / `PR Closed`: 番号とタイトル
  - `Issue Open` / `Issue Close`: 番号とタイトル
  - `主な作業テーマ`: その日の作業を 1 行で要約

既にエンティティが存在する場合は `mcp__memory__add_observations` で不足分を追記する。

## Output Format

`## Memo` セクション内に以下の順序で書き出す。データが無いセクションは省略する。

### セクション順序

1. `### Calendar`
2. `### GitHub Activity`
3. `### Email Summary`
4. `### Notion Updates`
5. `### Local Git`

---

### Calendar フォーマット

```markdown
### Calendar

| 時間 | イベント | 場所 |
|------|---------|------|
| 終日 | マンジャロ投与Day 🏷️個人 | — |
| 10:00-10:30 | 🌞UPCYCLE Core Daily | — |
| 10:30-11:00 | OKR3定例 | 7F グレーMTGスペース |
| 14:00-15:00 | PEAI 開発タスク | 7F グレーMTGスペース |
```

#### Calendar 記述ルール

- 全カレンダーのイベントを**時系列順**に統合する（終日イベントは先頭）
- 個人カレンダーのイベントには `🏷️個人` を付与して区別する
- `eventType: "workingLocation"` のイベント（例: オフィス）は省略可
- `t25c25@gmail.com` は共有カレンダー。`C〇〇`（例: `C work`）はパートナーの予定なので `🏷️パートナー` を付与する。`R〇〇`（例: `R Office Day!`）は自分の予定なので `🏷️個人` を付与する
- 場所が無い場合は `—` と記載する

---

### GitHub Activity フォーマット

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

#### GitHub 記述ルール

- PR の状態は `Merged` > `Open` > `Closed` の順で記述する
- PR の要約は body の内容を元に日本語で記述する（body が英語でも日本語に変換）
- `**+行数 / -行数**` のメトリクスは必ず含める
- Close した Issue には対応 PR を紐付ける（PR body の `Closes #N` から判定）
- 重複 Issue（作成即 Close → 再作成）は末尾にまとめて記述する
- リポジトリが複数ある場合はリポジトリごとにセクションを分ける

---

### Email Summary フォーマット

```markdown
### Email Summary

- 📩 **川島さん**: 査定AIのDB共有などなど（3/10 MTG 招待）
- 📩 **Notion**: 高橋さん他 2名が A1A ワークスペースを更新
```

#### Email 記述ルール

- カレンダー招待の自動返信（承諾/辞退）は除外する
- 送信者名 + 件名の要約を 1 行で記述する
- メールが無い、またはカレンダー通知のみの場合はセクションごと省略する

---

### Notion Updates フォーマット

```markdown
### Notion Updates

- [調達AIの競合調査](https://www.notion.so/xxx) — 3/4 更新
```

#### Notion 記述ルール

- 対象日に更新されたページのみ記載する
- ページタイトル + リンク + 更新日を 1 行で記述する
- 結果が空の場合はセクションごと省略する

---

### Local Git フォーマット

```markdown
### Local Git（未 push）

- `repo-name`: `abc1234` feat: some local work
```

#### Local Git 記述ルール

- GitHub Activity と重複するコミットは記載しない
- 未 push のコミットや PR になっていないローカル作業のみ記載する
- vault-of-obsidian の自動バックアップコミット（`vault backup:`）は除外する
- 該当コミットが無い場合はセクションごと省略する

---

### 全体ルール

- データが無いセクションは省略する（空セクションを残さない）
- 全セクションにデータが無い場合は「本日のアクティビティはありません」と記述する
