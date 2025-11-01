# DevContainer Configuration

このディレクトリには2種類の devcontainer 設定が含まれています。

## 📁 ファイル構成

```
.devcontainer/
├── devcontainer.json          # dotfiles リポジトリ用（このリポジトリで使用）
├── devcontainer-template.json # 他のプロジェクト用テンプレート
├── scripts/
│   └── setup-dotfiles.sh      # dotfiles セットアップスクリプト
└── README.md                  # このファイル
```

## 🎯 使い分け

### 1. `devcontainer.json` - Dotfiles リポジトリ用

**用途:**
- この dotfiles リポジトリ自体を編集する時
- chezmoi の設定やスクリプトをメンテナンスする時

**特徴:**
- 自動的に dotfiles を適用
- テスト・検証用の環境

**使い方:**
```bash
# このリポジトリで
code .
# F1 → "Dev Containers: Reopen in Container"
```

---

### 2. `devcontainer-template.json` - プロジェクト用テンプレート

**用途:**
- 他のプロジェクトで devcontainer を作る時
- チームで共有する開発環境

**使い方:**

#### Step 1: プロジェクトにコピー
```bash
cd /path/to/your-project
mkdir -p .devcontainer
cp ~/.local/share/chezmoi/.devcontainer/devcontainer-template.json \
   .devcontainer/devcontainer.json
mkdir -p .devcontainer/scripts
cp ~/.local/share/chezmoi/.devcontainer/scripts/setup-dotfiles.sh \
   .devcontainer/scripts/
```

#### Step 2: カスタマイズ
`.devcontainer/devcontainer.json` を編集:

```json
{
  "name": "Your Project Name",
  "containerEnv": {
    "DOTFILES_REPO": "https://github.com/YOUR_USERNAME/dotfiles.git"
  }
}
```

#### Step 3: 使用
```bash
# VS Code で開く
code .
# F1 → "Dev Containers: Reopen in Container"
```

---

## 🔧 カスタマイズ方法

### Dotfiles リポジトリを変更

**方法1: 環境変数で指定（推奨）**
```json
"containerEnv": {
  "DOTFILES_REPO": "https://github.com/YOUR_USERNAME/dotfiles.git"
}
```

**方法2: スクリプトを直接編集**
`.devcontainer/scripts/setup-dotfiles.sh` の先頭:
```bash
DOTFILES_REPO="https://github.com/YOUR_USERNAME/dotfiles.git"
```

### 言語・ツールを追加

`features` セクションに追加:
```json
"features": {
  "ghcr.io/devcontainers/features/java:1": {
    "version": "17"
  }
}
```

利用可能な Features: https://containers.dev/features

### VS Code 拡張機能を追加

`customizations.vscode.extensions` に追加:
```json
"extensions": [
  "dbaeumer.vscode-eslint",
  "ms-vscode.vscode-typescript-next"
]
```

---

## 🚀 パフォーマンス最適化のヒント

### 1. Features を使う（最速）
```json
"features": {
  "ghcr.io/devcontainers/features/node:1": {}
}
```
✅ Docker のレイヤーキャッシュが効く

### 2. postCreateCommand（1回だけ実行）
```json
"postCreateCommand": "npm install"
```
✅ コンテナ作成時のみ実行

### 3. postStartCommand（毎回実行）
```json
"postStartCommand": "echo 'Ready!'"
```
⚠️ 軽い処理のみ推奨

---

## 🐛 トラブルシューティング

### ターミナルが bash のまま
**解決策:**
1. VS Code をリロード（`F1` → "Reload Window"）
2. 新しいターミナルを開く

### dotfiles が適用されない
**確認:**
```bash
# コンテナ内で
ls -la ~/.local/share/chezmoi
cat ~/.config/chezmoi/chezmoi.toml
chezmoi managed
```

**再適用:**
```bash
chezmoi apply -v
```

### スクリプトが見つからない
**エラー:**
```
bash: .devcontainer/scripts/setup-dotfiles.sh: No such file or directory
```

**解決策:**
1. スクリプトが存在するか確認
2. 実行権限を確認: `chmod +x .devcontainer/scripts/setup-dotfiles.sh`
3. コンテナを再ビルド

---

## 📚 参考リンク

- [DevContainers 公式ドキュメント](https://containers.dev/)
- [VS Code DevContainers](https://code.visualstudio.com/docs/devcontainers/containers)
- [chezmoi + Containers](https://www.chezmoi.io/user-guide/machines/containers-and-vms/)
- [DevContainer Features](https://containers.dev/features)

---

## 💡 ベストプラクティス

### DO ✅
- Features でパッケージをインストール（キャッシュが効く）
- プロジェクト固有の設定は devcontainer.json に
- ユーザー設定は chezmoi dotfiles に
- スクリプトはバージョン管理する

### DON'T ❌
- postCreateCommand で重い処理（Homebrew インストールなど）
- dotfiles と devcontainer で役割を混同
- 環境変数をハードコード
- セキュリティ情報をコミット

---

## 🔐 シークレット管理

### ローカル DevContainer
```json
"containerEnv": {
  "API_KEY": "${localEnv:API_KEY}"
}
```

ホストの環境変数を参照できる。

### GitHub Codespaces
GitHub Settings → Codespaces → Secrets で管理。

### チーム共有
`.env` ファイル（gitignore）:
```bash
# .env (git ignored)
API_KEY=xxx
```

devcontainer.json:
```json
"runArgs": ["--env-file", ".env"]
```

---

## 📝 メンテナンス

### 更新手順
1. Features のバージョンを定期的に更新
2. 不要な拡張機能を削除
3. スクリプトをテスト
4. ドキュメントを更新

### テスト方法
```bash
# コンテナを完全に再ビルド
# F1 → "Dev Containers: Rebuild Container Without Cache"
```

---

このテンプレートを使って快適な開発環境を構築してください！ 🚀
