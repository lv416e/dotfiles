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

# ============================================================================
# ghq + fzf Integration
# ============================================================================

# Quick repository navigation with fzf
# Usage: repo [--tmux]
#   repo       - Select and cd to repository
#   repo --tmux - Select, cd, and launch tmux-work
def repo [--tmux (-t)] {
  let selection = (ghq list | fzf --preview $"bat --color=always --style=header,grid (ghq root)/\{}/README.md 2>/dev/null || eza -al --tree --level=2 (ghq root)/\{}")
  if $selection != "" {
    let repo_path = $"(ghq root)/($selection)"

    if $tmux {
      # Launch tmux without changing current directory
      let repo_name = ($selection | path basename)
      with-env {LEFT_DIR: $repo_path} {
        tmux-work $repo_name
      }
    } else {
      # Change directory only when not launching tmux
      cd $repo_path
    }
  }
}

# Clone repository with ghq and cd into it
def clone [url: string] {
  ghq get $url
  let latest = (ghq list | lines | last)
  cd $"(ghq root)/($latest)"
}

# Repository navigation with tmux-work integration
# Usage: tmux-repo [repo-name]
#   tmux-repo         - If in ghq repo: launch tmux-work here
#                       Otherwise: select with fzf
#   tmux-repo <name>  - Select specific repo (fuzzy match)
def tmux-repo [repo_name?: string] {
  let repo_path = if ($repo_name != null) {
    # Argument provided: fuzzy match
    let matched = (ghq list | lines | where {|it| $it =~ $repo_name} | first)
    if ($matched | is-empty) {
      print $"No repository matching '($repo_name)' found"
      return
    }
    $"(ghq root)/($matched)"
  } else {
    # No argument: check if current dir is in ghq
    let current_path = (pwd)
    let ghq_root = (ghq root)

    if ($current_path | str starts-with $ghq_root) {
      # Already in a ghq repository
      $current_path
    } else {
      # Not in ghq: select with fzf
      let selection = (ghq list | fzf --preview $"bat --color=always --style=header,grid (ghq root)/\{}/README.md 2>/dev/null || eza -al --tree --level=2 (ghq root)/\{}")
      if ($selection | is-empty) {
        return
      }
      $"(ghq_root)/($selection)"
    }
  }

  # Launch tmux-work without changing current directory
  if ($repo_path | is-not-empty) {
    let name = ($repo_path | path basename)
    with-env {LEFT_DIR: $repo_path} {
      tmux-work $name
    }
  }
}

# List all repositories with metadata
def repos [] {
  ghq list --full-path
  | lines
  | each { |path|
      let name = ($path | path basename)
      let host = ($path | path dirname | path basename)
      let owner = ($path | path dirname | path dirname | path basename)
      let updated = (do -i { ls -l $path | get modified | first } | default (date now))

      {
        name: $name,
        owner: $owner,
        host: $host,
        path: $path,
        updated: $updated
      }
    }
  | sort-by updated --reverse
}

# Show repository statistics
def ghq-stats [] {
  let all_repos = (ghq list | lines)
  let total = ($all_repos | length)
  let github = ($all_repos | where {|it| $it =~ "github.com"} | length)
  let gitlab = ($all_repos | where {|it| $it =~ "gitlab.com"} | length)
  let bitbucket = ($all_repos | where {|it| $it =~ "bitbucket.org"} | length)

  print $"Total repositories: ($total)"
  print $"GitHub: ($github)"
  print $"GitLab: ($gitlab)"
  print $"Bitbucket: ($bitbucket)"
  print ""
  print "Most recently updated repositories:"

  repos | first 5 | each { |repo|
    print $"  ($repo.name): ($repo.updated | format date '%Y-%m-%d')"
  }
}
