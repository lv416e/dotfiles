# ========================================
# External Tool Integrations
# ========================================
#
# Integration with mise, zoxide, atuin, and other tools
# Loaded automatically at startup

# ===== mise - Automatic version switching for dev tools =====
if (which mise | is-not-empty) {
    ^mise activate nu | save --force ~/.config/nushell/scripts/mise.nu
    source ~/.config/nushell/scripts/mise.nu
}

# ===== zoxide - Smart directory jumping =====
if (which zoxide | is-not-empty) {
    ^zoxide init nushell | save --force ~/.config/nushell/scripts/zoxide.nu
    source ~/.config/nushell/scripts/zoxide.nu
    # Alias j for zoxide (like in zsh)
    alias j = z
}

# ===== atuin - Magical shell history =====
if (which atuin | is-not-empty) {
    ^atuin init nu | save --force ~/.config/nushell/scripts/atuin.nu
    source ~/.config/nushell/scripts/atuin.nu
}

# starship prompt is configured in main config.nu
