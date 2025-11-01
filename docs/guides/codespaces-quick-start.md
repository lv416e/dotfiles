# GitHub Codespaces & DevContainer - Quick Start

## 🚀 Quick Setup (2 Minutes)

### For GitHub Codespaces

**1. Enable dotfiles in GitHub Settings:**

Go to: https://github.com/settings/codespaces

- ✅ Check "Automatically install dotfiles"
- Select repository: `lv416e/dotfiles`
- Save

**2. Create a Codespace:**

```
Any repository → Code → Codespaces → Create codespace
```

**3. Done!**

Your zsh environment with all dotfiles will be ready automatically.

---

### For Local DevContainers

**1. Install VS Code Extension:**

```
Ext: "Dev Containers" (ms-vscode-remote.remote-containers)
```

**2. Open in Container:**

```
F1 → "Dev Containers: Reopen in Container"
```

**3. Done!**

Wait 3-5 minutes for first build (cached after that).

---

## ✅ Verification

```bash
# Check shell
echo $SHELL
# Expected: /usr/bin/zsh

# Check dotfiles
chezmoi managed | head

# Check environment
chezmoi execute-template "{{ .is_codespaces }}"
```

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Terminal is bash | Reload VS Code window (`F1` → Reload Window) |
| Tools missing | Rebuild container (`F1` → Rebuild Container) |
| Dotfiles not applied | Check `install` script is executable: `chmod +x install` |

---

## 📖 Full Documentation

See: [`docs/guides/codespaces-devcontainer-setup.md`](./codespaces-devcontainer-setup.md)

---

## 🎯 What You Get

- ✅ **zsh** with Powerlevel10k prompt
- ✅ **All dotfiles** from your chezmoi repository
- ✅ **Non-interactive setup** (no prompts in cloud)
- ✅ **Fast startup** (3-5 min vs 15-20 min without optimization)
- ✅ **Local & cloud parity** (same experience everywhere)

---

## 🔐 Secrets in Codespaces

**Don't use 1Password in Codespaces!** Use GitHub Secrets instead:

1. Go to: https://github.com/settings/codespaces (Secrets tab)
2. Add secrets (e.g., `GITHUB_TOKEN`, `NPM_TOKEN`)
3. Automatically available in all your Codespaces

Templates automatically use `{{ env "GITHUB_TOKEN" }}` as fallback.

---

## 💡 Pro Tips

1. **First terminal is always bash** (Codespaces web) → Just open a new terminal
2. **Fonts:** Install Nerd Font on your local machine for Powerlevel10k glyphs
3. **Performance:** Packages are installed via DevContainer Features (fast & cached)
4. **Brewfile skipped** in containers automatically (saves 10+ minutes)

---

## 🔄 Update Dotfiles

```bash
# In any Codespace/DevContainer
chezmoi update
```

Changes apply immediately!

---

## 📚 Learn More

- [Full Setup Guide](./codespaces-devcontainer-setup.md)
- [chezmoi Documentation](https://www.chezmoi.io/)
- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [DevContainers Spec](https://containers.dev/)
