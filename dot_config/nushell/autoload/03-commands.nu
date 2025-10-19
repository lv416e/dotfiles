# ========================================
# Custom Commands
# ========================================
#
# Nushell-enhanced custom commands
# Loaded automatically at startup

# ===== History Commands (zsh-compatible) =====

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

# ===== tmux Commands =====

# Kill current tmux window (tmux window kill)
def twk [] {
    let result = (^tmux display -p '#{window_id}' | complete)
    if $result.exit_code != 0 {
        print $"(ansi red)tmux内で実行してください(ansi reset)"
        return
    }
    let id = ($result.stdout | str trim)
    ^tmux kill-window -t $id
}

# ===== Directory & Git Operations =====

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

# ===== File Operations =====

# Find and delete files larger than specified size
def find-large [size: filesize] {
    ls **/*
    | where type == file
    | where size > $size
    | sort-by size --reverse
}

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

# Find file by name (fuzzy)
def ff [pattern: string] {
    ls **/* | where name =~ $pattern
}

# Find file by name and type
def fft [pattern: string, type: string] {
    ls **/* | where name =~ $pattern | where type == $type
}

# ===== System Operations =====

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

# Show system info summary
def sysinfo [] {
    print $"(ansi cyan_bold)System Information:(ansi reset)"
    print $"OS: (sys host | get name)"
    print $"Kernel: (sys host | get kernel_version)"
    print $"Uptime: (sys host | get uptime)"
    print $"CPU: (sys cpu | length) cores"
    print $"Memory: (sys mem | get total | into string)"
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

# ===== Git Enhanced Commands =====

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

# ===== Utility Commands =====

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

# ===== Startup Tips =====

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
