# Nushell Config File
# version = "0.108.0"

# ========================================
# Theme (must be defined before $env.config)
# ========================================

let dark_theme = {
    # color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    # Closures can be used to choose colors for specific values.
    # The value (in this case, a bool) is piped into the closure.
    # eg) {|| if $in { 'light_cyan' } else { 'light_gray' } }
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: {bg: red fg: white}
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: white bg: red attr: b}
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
}

# ========================================
# General Settings
# ========================================

# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false  # true or false to enable or disable the welcome banner at startup

    ls: {
        use_ls_colors: true # use the LS_COLORS environment variable to colorize output
        clickable_links: true # enable or disable clickable links. Your terminal has to support links.
    }

    rm: {
        always_trash: false # always act as if -t was given. Can be overridden with -p
    }

    table: {
        mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
        show_empty: true # show 'empty list' and 'empty record' placeholders for command output
        padding: { left: 1, right: 1 } # a left right padding of each column in a table
        trim: {
            methodology: wrapping # wrapping or truncating
            wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
            truncating_suffix: "..." # A suffix used by the 'truncating' methodology
        }
        header_on_separator: false # show header text on separator/border line
    }

    explore: {
        status_bar_background: {fg: "#1D1F21", bg: "#C4C9C6"},
        command_bar_text: {fg: "#C4C9C6"},
        highlight: {fg: "black", bg: "yellow"},
        status: {
            error: {fg: "white", bg: "red"},
            warn: {}
            info: {}
        },
        table: {
            split_line: {fg: "#404040"},
            selected_cell: {bg: light_blue},
            selected_row: {},
            selected_column: {},
        },
    }

    history: {
        max_size: 100_000 # Session has to be reloaded for this to take effect
        sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
        file_format: "sqlite" # "sqlite" or "plaintext"
        isolation: false # only available with sqlite file_format. true enables history isolation, false disables it. true will allow the history to be isolated to the current session using up/down arrows. false will allow the history to be shared across all sessions.
    }

    completions: {
        case_sensitive: false # set to true to enable case-sensitive completions
        quick: true    # set this to false to prevent auto-selecting completions when only one remains
        partial: true    # set this to false to prevent partial filling of the prompt
        algorithm: "prefix"    # prefix or fuzzy
        external: {
            enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
            max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
            completer: null # check 'carapace_completer' above as an example
        }
        use_ls_colors: true # set this to true to enable file/path/directory completions using LS_COLORS
    }

    cursor_shape: {
        emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
        vi_insert: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
        vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
    }

    color_config: $dark_theme
    footer_mode: 25 # always, never, number_of_rows, auto
    float_precision: 2 # the precision for displaying floats in tables
    buffer_editor: "nvim" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
    use_ansi_coloring: true
    bracketed_paste: true # enable bracketed paste, currently useless on windows
    edit_mode: emacs # emacs, vi
    shell_integration: {
        # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
        osc2: true
        # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
        osc7: true
        # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links
        osc8: true
        # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
        osc9_9: false
        # osc133 is several escapes invented by Final Term which include the supported ones below.
        # 133;A - Mark prompt start
        # 133;B - Mark prompt end
        # 133;C - Mark pre-execution
        # 133;D;exit - Mark execution finished with exit code
        # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
        osc133: true
        # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
        # 633;A - Mark prompt start
        # 633;B - Mark prompt end
        # 633;C - Mark pre-execution
        # 633;D;exit - Mark execution finished with exit code
        # 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
        # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
        # and also helps with the run recent menu in vscode
        osc633: true
        # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
        reset_application_mode: true
    }
    render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
    use_kitty_protocol: false # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
    highlight_resolved_externals: false # true enables highlighting of external commands in the repl resolved by which.
    recursion_limit: 50 # the maximum number of times nushell allows recursion before stopping it

    plugins: {} # Per-plugin configuration. See https://www.nushell.sh/contributor-book/plugins.html#configuration

    plugin_gc: {
        # Configuration for plugin garbage collection
        default: {
            enabled: true # true to enable stopping of inactive plugins
            stop_after: 10sec # how long to wait after a plugin is inactive before stopping it
        }
        plugins: {
            # alternate configuration for specific plugins, by name, for example:
            #
            # gstat: {
            #     enabled: false
            # }
        }
    }

    menus: [
        # Configuration for the default menus
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: ide_completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: ide
                min_completion_width: 0
                max_completion_width: 50
                max_completion_height: 10 # will be limited by the available lines in the terminal
                padding: 0
                border: true
                cursor_offset: 0
                description_mode: "prefer_right"
                min_description_width: 0
                max_description_width: 50
                max_description_height: 10
                description_offset: 1
                # If true, the cursor pos will be corrected, so the suggestions match up with the typed text
                #
                # C:\> str
                #      str join
                #      str trim
                #      str split
                correct_cursor_pos: false
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]

    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: ide_completion_menu
            modifier: control
            keycode: char_n
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: ide_completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: help_menu }
        }
    ]
}

# ========================================
# Prompt (Starship)
# ========================================

# If you want to use Starship prompt with Nushell
# Make sure Starship is installed: brew install starship

# Initialize Starship
mkdir ~/.cache/starship
$env.STARSHIP_SHELL = "nu"
def create_left_prompt [] {
    ^starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' --terminal-width (term size).columns
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# ========================================
# Aliases (zsh-compatible + Nushell enhancements)
# ========================================

# Editor
alias v = ^nvim
alias vim = ^nvim
alias vi = ^nvim

# eza (modern ls replacement) - comprehensive set
alias e = ^eza --icons --git --sort=type
alias l = ^eza --icons --git --sort=type
alias ls = ^eza --icons --git --sort=type
alias ea = ^eza -a --icons --git --sort=type
alias la = ^eza -a --icons --git --sort=type
alias ee = ^eza -aahl --icons --git --sort=type
alias ll = ^eza -aahl --icons --git --sort=type
alias et = ^eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons --sort=type
alias lt = ^eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons --sort=type
alias eta = ^eza -T -a -I 'node_modules|.git|.cache' --color=always --icons --sort=type
alias lta = ^eza -T -a -I 'node_modules|.git|.cache' --color=always --icons --sort=type

# Monitoring
alias top = ^btm
alias bottom = ^btm

# cat and less with bat
alias less = ^bat
alias cat = ^bat --paging=never

# grep with ripgrep
alias grep = ^rg -S
alias rg = ^rg -S

# Quick directory navigation
alias d = cd ~/Documents
alias dot = cd ~/.local/share/chezmoi
alias obs = cd "~/Google Drive/My Drive/obsidian/"
alias .. = cd ..
alias ... = cd ../..
alias ..1 = cd ..
alias ..2 = cd ../..
alias ..3 = cd ../../..
alias ..4 = cd ../../../..

# System utilities
alias c = clear
alias cl = ^tty-clock -sc
alias du = ^dust
alias df = ^duf
alias ps = ^procs --tree
alias rm = ^trash
alias tenki = ^http wttr.in/Tokyo

# tmux workspace shortcuts
alias twork = ^tmux-work
alias tvim = ^tmux-nvim
alias tnu = ^tmux-nu
alias tcc = ^tmux-claude
alias tw = ^tmux-work
alias tv = ^tmux-nvim
alias tn = ^tmux-nu
alias tc = ^tmux-claude
alias twk = ^tmux-work  # Added for compatibility

# Git aliases
alias gs = ^git status
alias ga = ^git add
alias gc = ^git commit
alias gp = ^git push
alias gl = ^git log --oneline --graph --decorate
alias gd = ^git diff
alias lg = ^gitui
alias ld = ^lazydocker

# chezmoi
alias cdot = ^chezmoi cd
alias adot = ^chezmoi apply
alias vzsh = ^chezmoi edit ~/.zshrc
alias vbrew = ^chezmoi edit ~/.Brewfile
alias vnu = ^chezmoi edit ~/.config/nushell/config.nu

# Modern CLI tools (explicit)
alias dust = ^dust
alias duf = ^duf
alias bat = ^bat
alias fd = ^fd
alias procs = ^procs
alias trash = ^trash
alias eza = ^eza

# ========================================
# History Commands (zsh-compatible)
# ========================================

# Show last 100 history entries with bat
def h1 [] {
    history | last 100 | reverse | to text | ^bat -l sh
}

# Show last 1000 history entries with bat
def h10 [] {
    history | last 1000 | reverse | to text | ^bat -l sh
}

# Search history interactively
def hs [search: string] {
    history | where command =~ $search | select command
}

# ========================================
# Custom Commands (Nushell-enhanced)
# ========================================

# Create directory and cd into it
def mkcd [dir: string] {
    mkdir $dir
    cd $dir
}

# Git clone and cd into the directory
def gcl [repo: string] {
    ^git clone $repo
    let dir = ($repo | path basename | str replace ".git" "")
    cd $dir
}

# Find and delete files larger than specified size
def find-large [size: filesize] {
    ls **/*
    | where type == file
    | where size > $size
    | sort-by size --reverse
}

# Show disk usage in a nice table
def diskusage [] {
    ^df -h
    | from ssv
    | select Filesystem Size Used Avail Use% "Mounted on"
}

# Quick process search with filtering
def psg [pattern: string] {
    ps | where name =~ $pattern
}

# Update all development tools
def devupdate [] {
    print $"(ansi green)Updating Homebrew...(ansi reset)"
    ^brew update
    ^brew upgrade

    print $"\n(ansi green)Updating mise tools...(ansi reset)"
    ^mise upgrade
    ^mise prune -y

    print $"\n(ansi green)Updating chezmoi...(ansi reset)"
    ^chezmoi update

    print $"\n(ansi green_bold)✨ All updates complete!(ansi reset)"
}

# ========================================
# Nushell-specific Power Commands
# ========================================

# Enhanced ls with filters
def lss [pattern: string] {
    ls | where name =~ $pattern
}

# List only directories
def lsd [] {
    ls | where type == dir
}

# List only files
def lsf [] {
    ls | where type == file
}

# Show largest files in current directory
def largest [n: int = 10] {
    ls | where type == file | sort-by size --reverse | first $n
}

# Show newest files in current directory
def newest [n: int = 10] {
    ls | sort-by modified --reverse | first $n
}

# Show oldest files in current directory
def oldest [n: int = 10] {
    ls | sort-by modified | first $n
}

# Total size of directory
def dirsize [] {
    ls | where type == file | get size | math sum
}

# Count files by extension
def count-ext [] {
    ls **/*
    | where type == file
    | get name
    | path parse
    | get extension
    | group-by $it
    | transpose key count
    | sort-by count --reverse
}

# Git status with enhanced output
def gstat [] {
    let status = (^git status --porcelain | lines)
    if ($status | is-empty) {
        print $"(ansi green)✓ Working tree clean(ansi reset)"
    } else {
        ^git status --short
    }
}

# Git log with pretty format
def glog [n: int = 10] {
    ^git log --oneline --graph --decorate --all -n $n
}

# Show git branch with additional info
def gbr [] {
    ^git branch -vv
}

# Quick git commit with message
def gcom [message: string] {
    ^git add -A
    ^git commit -m $message
}

# Git push with upstream
def gpush [] {
    let branch = (^git branch --show-current)
    ^git push -u origin $branch
}

# Find file by name (fuzzy)
def ff [pattern: string] {
    ls **/* | where name =~ $pattern
}

# Find file by name and type
def fft [pattern: string, type: string] {
    ls **/* | where name =~ $pattern | where type == $type
}

# Show system info summary
def sysinfo [] {
    print $"(ansi cyan_bold)System Information:(ansi reset)"
    print $"OS: (sys host | get name)"
    print $"Kernel: (sys host | get kernel_version)"
    print $"Uptime: (sys host | get uptime)"
    print $"CPU: (sys cpu | length) cores"
    print $"Memory: (sys mem | get total | into string)"
}

# Interactive file picker with preview
def pick [] {
    ls | select name type size modified | input list $"(ansi cyan)Select file:(ansi reset)"
}

# Quick note taking
def note [text: string] {
    let timestamp = (date now | format date "%Y-%m-%d %H:%M:%S")
    echo $"[$timestamp] ($text)" | save --append ~/Documents/notes.txt
    print $"(ansi green)✓ Note saved(ansi reset)"
}

# View notes
def notes [] {
    if (~/Documents/notes.txt | path exists) {
        open ~/Documents/notes.txt | lines | last 20
    } else {
        print $"(ansi yellow)No notes yet. Use 'note \"your text\"' to create one.(ansi reset)"
    }
}

# ========================================
# External Tool Integrations
# ========================================

# mise - Automatic version switching for dev tools
if (which mise | is-not-empty) {
    ^mise activate nu | save --force ~/.config/nushell/scripts/mise.nu
    source ~/.config/nushell/scripts/mise.nu
}

# zoxide - Smart directory jumping
if (which zoxide | is-not-empty) {
    ^zoxide init nushell | save --force ~/.config/nushell/scripts/zoxide.nu
    source ~/.config/nushell/scripts/zoxide.nu
    # Alias j for zoxide (like in zsh)
    alias j = z
}

# atuin - Magical shell history
if (which atuin | is-not-empty) {
    ^atuin init nu | save --force ~/.config/nushell/scripts/atuin.nu
    source ~/.config/nushell/scripts/atuin.nu
}

# starship - Already configured above in prompt section

# ========================================
# Startup Message & Tips
# ========================================

# Welcome message (comment out if you don't want it)
# print $"(ansi green_bold)Welcome to Nushell!(ansi reset) 🚀"
# print $"Type (ansi cyan)help commands(ansi reset) to see available commands"
# print $"Type (ansi cyan)help <command>(ansi reset) for command-specific help\n"

# Show a random tip on startup (optional)
def --env show-tip [] {
    let tips = [
        "Use 'largest 5' to see the 5 largest files"
        "Use 'newest 10' to see the 10 newest files"
        "Use 'count-ext' to count files by extension"
        "Use 'gstat' for enhanced git status"
        "Use 'j <directory>' for smart directory jumping (zoxide)"
        "Use 'h1' to see last 100 history entries"
        "Use 'hs <pattern>' to search history"
        "Use 'note \"text\"' to quickly save a note"
        "Use 'sysinfo' to see system information"
        "Use 'help commands' to see all custom commands"
    ]
    let tip = ($tips | get (random int 0..<($tips | length)))
    print $"(ansi yellow_dimmed)💡 Tip: ($tip)(ansi reset)"
}

# Uncomment to show tip on startup
# show-tip
