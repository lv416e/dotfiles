# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/)

## 新規セットアップ

### 前提条件

このdotfilesはgit configから名前とメールアドレスを動的に取得します。
まず、git configを設定してください：

```sh
git config --global user.name "your-name"
git config --global user.email "your-email@example.com"
```

### インストール

```sh
chezmoi init --apply lv416e/dotfiles
```

## 既存環境での使い方

### 設定を変更する

```sh
chezmoi edit ~/.zshrc
```

### 設定を適用する

```sh
chezmoi apply
```

### 変更をコミット・プッシュ

```sh
chezmoi cd
git add .
git commit -m "Update configuration"
git push
```
