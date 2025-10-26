# Zsh Modular Configuration

## Overview

This repository uses a modular Zsh configuration structure for better maintainability, organization, and XDG Base Directory compliance.

## Directory Structure

```
~/.zshenv                      # Bootstrap file (sets ZDOTDIR)
~/.config/zsh/                 # Main configuration directory (ZDOTDIR)
├── .zshenv                    # Environment variables & XDG paths
├── .zshrc                     # Modular loader
└── conf.d/                    # Configuration modules
    ├── 01-init.zsh            # Core initialization (Homebrew, Prompt)
    ├── 02-plugins.zsh         # Plugin management (Sheldon, zsh-defer)
    ├── 03-tools.zsh           # Tool configuration & deferred loading
    ├── 04-env.zsh             # Environment variables
    ├── 05-aliases.zsh         # All aliases
    ├── 06-functions.zsh       # Utility & shell management functions
    └── 07-repo.zsh            # Repository management functions
```

## Module Descriptions

### 01-init.zsh
**Purpose**: Core system initialization
**Dependencies**: None
**Contents**:
- Homebrew setup (ARM64/x86 detection)
- Prompt theme configuration (P10k/Starship)
- P10K instant prompt setup

### 02-plugins.zsh
**Purpose**: Plugin management
**Dependencies**: sheldon
**Contents**:
- zsh-autosuggestions configuration
- Sheldon plugin loading with caching
- Loads: zsh-defer, zsh-completions, zsh-autosuggestions, fast-syntax-highlighting

### 03-tools.zsh
**Purpose**: Tool configuration and deferred loading
**Dependencies**: zsh-defer (from plugins), fzf, zoxide, atuin, mise
**Contents**:
- FZF configuration (deferred)
- Completion system (24-hour cache)
- Deferred tool initialization (zoxide, atuin, mise)
- FZF key bindings (deferred)
- Amazon Q integration (optional)

### 04-env.zsh
**Purpose**: Environment variables and PATH configuration
**Dependencies**: HOMEBREW_PREFIX (from 01-init.zsh)
**Contents**:
- Development tools PATH (slack, gnu-time, llvm)
- C++ development environment (deferred)
- Alacritty + Hammerspoon PATH

### 05-aliases.zsh
**Purpose**: All shell aliases
**Dependencies**: nvim, eza, bat, rg, btm, dust, duf, procs, trash, tmux, chezmoi
**Contents**:
- Editor aliases (vim → nvim)
- File operations (eza-based)
- Modern CLI tool aliases
- Navigation shortcuts
- History utilities
- Tmux shortcuts
- Nushell aliases
- Chezmoi shortcuts
- Git shortcuts
- Repository shortcuts
- Miscellaneous utilities

### 06-functions.zsh
**Purpose**: Utility and shell management functions
**Dependencies**: navi, bat, ag, jq, gron, claude, tmux, sheldon
**Contents**:
- ch/cht: Cheat sheet viewer (navi + tldr)
- agg: Code search with bat
- jgrep: JSON grep utility
- hg/hc: History utilities
- ask: Claude multi-line prompt
- twk: Kill current tmux window
- zsh-refresh: Clear caches and restart
- switch-prompt: Toggle between Starship and P10k

### 07-repo.zsh
**Purpose**: Repository management with ghq and tmux integration
**Dependencies**: ghq, fzf, bat, eza, tmux-nvim, zsh-defer
**Contents**:
- repo(): Repository navigation with fzf
- clone(): Clone with ghq
- tmux-repo(): Launch tmux-nvim in repository
- ghq-stats(): Repository statistics
- Completions for repo commands

## Loading Mechanism

The main `.zshrc` uses a simple glob-based loader:

```zsh
for config_file in ${ZDOTDIR:-$HOME/.config/zsh}/conf.d/*.zsh(N); do
  source "$config_file"
done
unset config_file
```

Modules are loaded in numerical order (01-07), ensuring proper dependency resolution.

## XDG Base Directory Compliance

### Bootstrap Process

1. `~/.zshenv` sets `ZDOTDIR` to `~/.config/zsh`
2. Zsh automatically sources `$ZDOTDIR/.zshenv`
3. `$ZDOTDIR/.zshenv` sets XDG variables
4. Zsh sources `$ZDOTDIR/.zshrc` for interactive shells
5. `.zshrc` loads all modules from `conf.d/`

### XDG Variables

Set in `~/.config/zsh/.zshenv`:

```zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
```

### Local Overrides

Machine-specific overrides (not managed by chezmoi):

- `~/.config/zsh/.zshenv.local` - Environment variable overrides
- Used by `switch-prompt` to change prompt themes

## Performance

### Benchmark Results

**Test Environment** (zsh -d -f with isolated config):
- Single file (477 lines): 48.9ms
- Modular (7 files): 41.1ms
- **Improvement**: -7.8ms (16% faster)

**Real Environment** (with plugins and full config):

| Version | Mean | Min | Max | Optimization |
|---------|------|-----|-----|--------------|
| Modular (no defer) | ~57ms | ~57ms | - | Baseline |
| **Modular + defer** | **55.1ms** | **48.7ms** | 178ms* | **-8.3ms (15% faster)** |

*Statistical outliers detected - represents background system load

**Defer Optimization (October 2025)**:
- Implemented module-level deferred loading for 05-aliases, 06-functions, 07-repo
- Deferred PATH additions in 04-env (slack, gnu-time, llvm, alacritty)
- Reduced startup time from ~57ms to **48.7ms minimum** (15% improvement)
- Based on 2025 best practices from romkatv/zsh-defer

### Performance Characteristics

**Advantages**:
- Better code organization
- Easier maintenance
- Selective module loading possible
- XDG compliance
- **Deferred module loading** - aliases/functions load asynchronously after prompt

**Trade-offs**:
- Minimal - deferred modules load within ~100-200ms after prompt appears
- zsh-defer overhead: ~0.63ms for 14 deferred calls (negligible)

### Optimization Techniques Used

1. **Sheldon caching**: Plugin sources cached to single file
2. **zsh-defer module sourcing**: Aliases, functions, repo management loaded asynchronously
3. **zsh-defer tool loading**: FZF, zoxide, atuin, mise, C++ env loaded asynchronously
4. **Deferred PATH additions**: Development tool PATHs loaded after prompt
5. **24-hour completion cache**: Skip security checks when fresh
6. **P10K instant prompt**: Show prompt before full initialization
7. **Fast plugins**: fast-syntax-highlighting instead of zsh-syntax-highlighting

### zprof Analysis (with defer optimization)

**Top bottlenecks** (after optimization):
1. `_p9k_init_ssh`: 11.34ms (48%) - P10K SSH detection
2. `P10k theme loading`: 5.87ms (25%) - Theme initialization
3. `_p9k_preinit`: 2.08ms (9%) - P10K pre-initialization
4. `zsh-defer`: 0.63ms (3%) - 14 deferred calls overhead

**Deferred components** (not counted in startup time):
- Aliases (05-aliases.zsh) - ~2.3KB
- Functions (06-functions.zsh) - ~3.0KB
- Repository management (07-repo.zsh) - ~4.3KB
- PATH additions (slack, gnu-time, llvm, alacritty)
- C++ environment variables

## Maintenance

### Adding New Modules

To add a new module:

1. Create file in `conf.d/` with numbered prefix (e.g., `08-custom.zsh`)
2. Add description header with dependencies
3. Module will be auto-loaded on next shell start

### Disabling Modules

To disable a module without deleting:

```bash
mv conf.d/05-aliases.zsh conf.d/05-aliases.zsh.disabled
```

Or rename without `.zsh` extension:

```bash
mv conf.d/05-aliases.zsh conf.d/05-aliases.disabled
```

### Refreshing Configuration

After changes:

```bash
# Quick reload
exec zsh

# Or clear caches and reload
zsh-refresh
```

## Comparison with Nushell Configuration

This modular Zsh structure mirrors the Nushell configuration approach:

**Nushell** (`~/.config/nushell/`):
```
├── config.nu              # Core settings
├── env.nu                 # Environment
└── autoload/              # Auto-loaded modules
    ├── 01-theme.nu
    ├── 02-aliases.nu
    ├── 03-commands.nu
    └── 04-integrations.nu
```

**Zsh** (`~/.config/zsh/`):
```
├── .zshrc                 # Loader
├── .zshenv                # Environment
└── conf.d/                # Configuration modules
    ├── 01-init.zsh
    ├── 02-plugins.zsh
    ├── 03-tools.zsh
    ├── 04-env.zsh
    ├── 05-aliases.zsh
    ├── 06-functions.zsh
    └── 07-repo.zsh
```

Both configurations emphasize:
- Clear separation of concerns
- Numbered module loading
- Easy extensibility
- Comprehensive documentation

## Troubleshooting

### Functions not found

If functions like `repo`, `ch`, or `ask` are not found:

1. Check ZDOTDIR is set: `echo $ZDOTDIR`
2. Verify modules exist: `ls $ZDOTDIR/conf.d/`
3. Check for errors: `zsh -x -i -c exit 2>&1 | less`
4. Reload shell: `exec zsh`

### Slow startup

To profile startup time:

1. Uncomment zprof lines in `~/.config/zsh/.zshrc`
2. Start new shell
3. View profile output
4. Comment out zprof lines when done

### Module loading errors

Check for syntax errors:

```bash
for f in ~/.config/zsh/conf.d/*.zsh; do
  echo "Checking $f..."
  zsh -n "$f" && echo "  OK" || echo "  ERROR"
done
```

## Migration from Monolithic Configuration

The old monolithic `~/.zshrc` (477 lines) has been preserved as `dot_zshrc.tmpl` in the repository for reference. The modular configuration is a complete replacement.

To revert to monolithic configuration if needed:

1. Remove `ZDOTDIR` setting from `~/.zshenv`
2. Restore old `.zshrc` from git history
3. Remove `~/.config/zsh/` directory

## Future Enhancements

Potential improvements:

1. **Conditional module loading**: Load modules based on context (e.g., skip repo.zsh if ghq not installed)
2. **Profile-based loading**: Different module sets for work/personal/minimal profiles
3. **Autoload functions**: Convert large functions to autoloadable files
4. **Dynamic module discovery**: Plugin system for custom modules
5. **Performance monitoring**: Built-in benchmarking and profiling tools

## References

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Zsh Startup Files](https://zsh.sourceforge.io/Intro/intro_3.html)
- [Sheldon Plugin Manager](https://sheldon.cli.rs/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
