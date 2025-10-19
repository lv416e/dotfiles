# Nushell Environment Config File
# version = "0.108.0"

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# ========================================
# Custom Environment Variables
# ========================================

# Editor
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Language
$env.LANG = "ja_JP.UTF-8"
$env.LC_ALL = "ja_JP.UTF-8"

# XDG Base Directory
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
$env.XDG_DATA_HOME = ($env.HOME | path join ".local" "share")
$env.XDG_CACHE_HOME = ($env.HOME | path join ".cache")

# PATH Configuration
# Add custom paths while preserving existing PATH
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend ($env.HOME | path join ".local" "bin")
    | prepend "/opt/homebrew/bin"
    | prepend "/opt/homebrew/sbin"
    | uniq
)

# Homebrew
$env.HOMEBREW_PREFIX = "/opt/homebrew"

# Starship Prompt (if you want to use Starship with Nushell)
$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_SESSION_KEY = (random chars -l 16)

# mise (rtx) - if using mise with Nushell
# mise activate will be called in config.nu
