# DevContainer トラブルシューティングガイド

## 🐛 よくあるエラーと解決策

### エラー1: `git config user.email: exit status 1`

#### 症状
```
chezmoi: template: chezmoi.toml:21:77: executing "chezmoi.toml" at <output "git" "config" "user.email">: error calling output: /usr/local/bin/git config user.email: exit status 1
[ERROR] Failed to initialize dotfiles
```

#### 原因
- コンテナ内で git config が設定されていない
- `.chezmoi.toml.tmpl` が git config の取得でエラー

#### 解決済み（2025-11-01）
`.chezmoi.toml.tmpl` を修正して、git config が未設定でもエラーにならないように変更しました：

**Before:**
```toml
{{- $email = or (env "EMAIL") (output "git" "config" "user.email" | trim) "codespace@example.com" -}}
```

**After:**
```toml
{{- $gitEmail := "" -}}
{{- if lookPath "git" -}}
{{-   $gitEmail = output "git" "config" "--global" "user.email" | trim | default "" -}}
{{- end -}}
{{- $email = env "EMAIL" | default $gitEmail | default "devcontainer@localhost" -}}
```

**変更点:**
- `lookPath "git"` で git コマンドの存在確認
- `default ""` でエラー時に空文字を返す
- フォールバックチェーンで安全にデフォルト値を設定

---

### エラー2: `Extension 'twpayne.vscode-chezmoi' not found`

#### 症状
```
[04:59:04] Extension 'twpayne.vscode-chezmoi' not found.
Make sure you use the full extension ID, including the publisher, e.g.: ms-dotnettools.csharp
```

#### 原因
- 拡張機能 ID が間違っているか、存在しない
- Marketplace で利用できない

#### 解決済み（2025-11-01）
devcontainer.json から削除しました。chezmoi 拡張機能は不要です（CLI で十分）。

---

### エラー3: `ENOTEMPTY: directory not empty, rename`

#### 症状
```
[04:59:24] Error while installing the extension github.copilot-chat ENOTEMPTY: directory not empty, rename '/home/vscode/.vscode-server/extensions/.xxx' -> '/home/vscode/.vscode-server/extensions/github.copilot-chat-0.32.4'
```

#### 原因
- VS Code Server の拡張機能インストールの競合
- 複数の拡張機能が同時にインストールされようとしている

#### 影響
- **軽微**: 拡張機能のインストール失敗だが、コンテナ自体は動作する
- 通常は次回コンテナ起動時に自動的に解決される

#### 手動解決方法
```bash
# コンテナ内で
rm -rf /home/vscode/.vscode-server/extensions/.tmp*
# VS Code をリロード
```

または：
```bash
# コンテナを完全再ビルド
# F1 → "Dev Containers: Rebuild Container Without Cache"
```

---

## 🔧 予防策

### 1. Git 設定を事前にする

**ローカル環境:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**DevContainer で自動設定:**
`.devcontainer/devcontainer.json` に追加:
```json
"postCreateCommand": "git config --global user.name 'DevContainer User' && git config --global user.email 'dev@localhost' && bash ${containerWorkspaceFolder}/.devcontainer/scripts/setup-dotfiles.sh"
```

### 2. 環境変数で明示的に設定

`.devcontainer/devcontainer.json`:
```json
"containerEnv": {
  "EMAIL": "your.email@example.com",
  "GITHUB_USER": "your-username"
}
```

---

## 🧪 テスト手順

### 完全にクリーンな状態からテスト

```bash
# 1. すべてのコンテナを削除
docker ps -a | grep chezmoi | awk '{print $1}' | xargs docker rm -f

# 2. すべてのイメージを削除（オプション）
docker images | grep devcontainers | awk '{print $3}' | xargs docker rmi -f

# 3. VS Code で再度開く
code ~/.local/share/chezmoi
# F1 → "Dev Containers: Rebuild Container Without Cache"
```

### 期待される動作

1. コンテナビルド（3-5分）
2. postCreateCommand 実行
   ```
   [INFO] Installing chezmoi...
   [INFO] ✅ chezmoi installed to /home/vscode/.local/bin
   [INFO] Initializing dotfiles from https://github.com/lv416e/dotfiles.git...
   [INFO] ✅ Dotfiles initialized and applied successfully
   ```
3. 拡張機能インストール（並列、一部失敗は許容）
4. コンテナ起動完了

### 検証コマンド

コンテナ内で実行:
```bash
# 1. Shell 確認
echo $SHELL
# 期待: /usr/bin/zsh

# 2. chezmoi 確認
chezmoi --version
# 期待: chezmoi version 2.66.1 以上

# 3. 管理ファイル確認
chezmoi managed | wc -l
# 期待: 50以上

# 4. 環境変数確認
chezmoi execute-template "{{ .is_container }}"
# 期待: true

chezmoi execute-template "{{ .email }}"
# 期待: devcontainer@localhost または設定したメール

# 5. Git 設定確認
git config --global user.email
# 期待: 設定されたメールアドレス（またはエラーなし）
```

---

## 📊 ログの見方

### エラーログの場所

**VS Code Output パネル:**
- View → Output → "Dev Containers" を選択

**重要なログポイント:**

```
[INFO] Installing chezmoi...
→ chezmoi インストール開始

info installed /home/vscode/.local/bin/chezmoi
→ インストール成功

[INFO] Initializing dotfiles from https://github.com/lv416e/dotfiles.git...
→ dotfiles 初期化開始

Cloning into '/home/vscode/.local/share/chezmoi'...
→ リポジトリクローン中

[INFO] ✅ Dotfiles initialized and applied successfully
→ **成功！**

chezmoi: template: chezmoi.toml:XX:XX: executing...
→ **テンプレートエラー（要修正）**

[ERROR] Failed to initialize dotfiles
→ **致命的エラー**
```

### 正常なログの例

```
[INFO] ===================================================================
[INFO] DevContainer Dotfiles Setup
[INFO] ===================================================================
[INFO] Repository: https://github.com/lv416e/dotfiles.git
[INFO]
[INFO] Installing chezmoi...
info found chezmoi version 2.66.1 for latest/linux/arm64
info installed /home/vscode/.local/bin/chezmoi
[INFO] ✅ chezmoi installed to /home/vscode/.local/bin
[INFO] Initializing dotfiles from https://github.com/lv416e/dotfiles.git...
Cloning into '/home/vscode/.local/share/chezmoi'...
remote: Enumerating objects: 2123, done.
[INFO] ✅ Dotfiles initialized and applied successfully
[INFO]
[INFO] ===================================================================
[INFO] Verification
[INFO] ===================================================================
[INFO] Managed files: 87
[INFO] Current SHELL: /usr/bin/zsh
[INFO] Default shell: /usr/bin/zsh
[INFO] zsh: zsh 5.9 (aarch64-ubuntu-linux-gnu)
[INFO]
[INFO] ===================================================================
[INFO] ✅ Setup Complete!
[INFO] ===================================================================
```

---

## 🔍 デバッグテクニック

### スクリプトを手動実行

コンテナ内で:
```bash
# setup-dotfiles.sh を直接実行
bash /workspaces/chezmoi/.devcontainer/scripts/setup-dotfiles.sh

# verbose モードで chezmoi を実行
chezmoi init --apply --verbose https://github.com/lv416e/dotfiles.git
```

### テンプレート確認

```bash
# コンテナ内で
chezmoi execute-template < /workspaces/chezmoi/.chezmoi.toml.tmpl

# 特定の変数を確認
chezmoi execute-template "{{ .is_container }}"
chezmoi execute-template "{{ .email }}"
chezmoi execute-template "{{ .name }}"
```

### Git 設定を確認

```bash
# グローバル設定
git config --global --list

# ユーザー設定
git config --global user.name
git config --global user.email

# 設定ファイルの場所
cat ~/.gitconfig
```

---

## 🚨 緊急対応

### 完全にリセット

```bash
# 1. コンテナを停止・削除
docker stop $(docker ps -a -q --filter ancestor=vsc-chezmoi-*)
docker rm $(docker ps -a -q --filter ancestor=vsc-chezmoi-*)

# 2. イメージを削除
docker rmi $(docker images -q vsc-chezmoi-*)

# 3. chezmoi 設定を削除（オプション）
# コンテナ内で
rm -rf ~/.local/share/chezmoi
rm -rf ~/.config/chezmoi

# 4. VS Code キャッシュをクリア
# F1 → "Dev Containers: Clean Up Dev Containers..."
```

### 最小構成でテスト

devcontainer.json を最小化:
```json
{
  "name": "Minimal Test",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true
    }
  },
  "postCreateCommand": "echo 'Test successful'"
}
```

成功したら、徐々に機能を追加していく。

---

## 📞 サポート情報

### 問題が解決しない場合

1. **GitHub Issue を作成**
   - リポジトリ: https://github.com/lv416e/dotfiles/issues
   - テンプレート: Bug Report

2. **必要な情報:**
   ```bash
   # システム情報
   docker version
   code --version

   # エラーログ（VS Code Output パネルから）
   # 全文コピー
   ```

3. **確認事項:**
   - [ ] `.chezmoi.toml.tmpl` の最新版を使用
   - [ ] `.devcontainer/` の最新版を使用
   - [ ] Docker Desktop が最新版
   - [ ] VS Code が最新版
   - [ ] Dev Containers 拡張機能が最新版

---

## 📚 関連ドキュメント

- [Codespaces & DevContainer Setup Guide](./codespaces-devcontainer-setup.md)
- [Quick Start](./codespaces-quick-start.md)
- [DevContainer README](../../.devcontainer/README.md)

---

**最終更新: 2025-11-01**
