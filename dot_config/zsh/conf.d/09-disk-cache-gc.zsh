# ============================================================================
# Disk Cache Garbage Collection
# ============================================================================
# Caps the macOS wallpaper renderer cache, which grows without bound (~9GB/day
# with a rotating wallpaper source) and once filled this disk to 273MB free.
#
# Why from the shell rather than a LaunchAgent: reading another app's
# ~/Library/Containers/<id>/Data needs Full Disk Access. A LaunchAgent has
# none and gets EPERM; the terminal normally does. The LaunchAgent still runs
# the caches that need no special access. See ADR-0010.
#
# Cost at startup: none. The call is deferred, throttled by a stamp file, and
# backgrounded, so at most one real run every 6 hours and never in the
# foreground.
# ============================================================================

_disk_cache_gc_maybe() {
  # Interactive shells only — no reason to fire from scripts or subshells
  [[ -o interactive ]] || return 0
  command -v disk-cache-gc &>/dev/null || return 0

  # 6h throttle is enforced inside disk-cache-gc via its stamp file
  ( disk-cache-gc --throttle 21600 --quiet &>/dev/null & ) 2>/dev/null
}

zsh-defer _disk_cache_gc_maybe

# Manual entry points
alias disk-gc='disk-cache-gc'
alias disk-gc-deep='disk-cache-gc --deep'
alias disk-gc-check='disk-cache-gc --dry-run'
