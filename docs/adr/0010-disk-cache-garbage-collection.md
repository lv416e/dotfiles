# ADR-0010: Disk cache garbage collection

## Status

Accepted

## Context

On 2026-08-22 this machine reached 273MB of free space on a 494GB volume. The
cause was `~/Library/Containers/com.apple.wallpaper.agent/Data/Library/Caches`,
which held **109GB** across 3,964 files.

macOS renders each wallpaper it displays into a full-resolution, *uncompressed*
BMP (3840x2486, ~29MB each) and caches it under the wallpaper agent's container.
It never evicts these. With a rotating wallpaper source — here the Unsplash
Wallpapers app, with `updateFrequency = 1` and `isUpdateAllScreensEnabled = 1` —
the cache grew from empty on 2026-08-10 to 109GB in twelve days, roughly
**9GB/day**.

Apple exposes no size limit, retention policy, or `defaults` key for this cache,
and "Manage Storage" does not list it as purgeable. The growth is unbounded and
silent: the first symptom is a full disk.

Two further caches were found large but well-behaved (they prune on demand):
`~/.cache/uv` at 21GB and Homebrew's download cache at ~11GB.

### The TCC constraint

The obvious implementation — a LaunchAgent on a timer — was built first and
**did not work**. Reading another app's `~/Library/Containers/<id>/Data`
requires the calling process to hold Full Disk Access. A LaunchAgent holds
none, and `find` fails with `Operation not permitted`:

```
$ launchctl bootstrap gui/501 probe.plist   # probe running as the same user
ls: .../com.apple.wallpaper.caches: Operation not permitted
```

Worse, the failure is indistinguishable from success at a glance: zero files
readable reports as "nothing to prune". A terminal, by contrast, normally holds
Full Disk Access and reads the directory without issue.

Attributing Full Disk Access to a shell script is not a real option: TCC
attributes to the interpreter, so it would mean granting `/bin/bash` blanket
access to the whole filesystem for every script it ever runs.

This splits the work by trust context, and the design has to follow.

## Decision Drivers

- **Bounded by construction**: the disk must not fill again by simply waiting
- **No behaviour loss**: the wallpaper in use must keep working; rotation stays
- **Works within TCC**: no Full Disk Access grant to a shell interpreter
- **Fails loudly**: a permission denial must not read as "nothing to do"
- **Survives sleep**: a laptop is asleep at most fixed wall-clock times
- **Zero startup cost**: must not slow down opening a shell
- **Declarative**: reproducible on a new machine via `chezmoi apply`
- **Reversible**: one command to disable, no system files touched

## Considered Options

1. **Do nothing, clean up manually when the disk fills**
2. **Stop rotating wallpapers** — set a static wallpaper, uninstall Unsplash
3. **Lower the rotation frequency** in the Unsplash app
4. **Replace the cache directory with a symlink to a sink**
5. **LaunchAgent only** — timer job doing all the pruning
6. **Grant Full Disk Access to `/bin/bash`** so Option 5 can work
7. **Split by trust context** — shell hook for the container cache, LaunchAgent
   for everything else

## Decision Outcome

**Chosen option**: Split by trust context (Option 7).

Option 5 was implemented and empirically rejected: TCC blocks it (see Context).
Option 6 would fix it by granting every bash script on the machine unrestricted
filesystem access — a large, permanent security concession to prune a cache.

So the wallpaper cap runs where the access already exists: a deferred,
throttled, backgrounded call from the interactive shell. The LaunchAgent is kept
for the caches that need no special access (`uv`, Homebrew), where a timer is
genuinely the right trigger.

Options 2 and 3 trade away something the user wants and, in the case of 3, only
slow the bleeding — at one rotation per hour the cache still reaches double-digit
GB within a month. Option 4 fights the OS: the agent recreates its container
layout, and a broken cache path risks a wallpaper agent that spins or crashes.

### Implementation

**Components**:

1. **GC script** (`dot_local/bin/executable_disk-cache-gc`):
   - Prunes a directory to a byte budget, deleting **oldest-first** by mtime,
     so assets currently on screen are the ones kept
   - Wallpaper budget defaults to 512MB (~17 renders), overridable via
     `DISK_CACHE_GC_WALLPAPER_MB`
   - Probes readability with `ls` before pruning, so a TCC denial reports as
     `🔒 permission denied` instead of a silent no-op
   - `--throttle SECONDS` against a stamp file, so the shell hook can call it
     on every new shell while doing real work at most once per window
   - `--dry-run` reports what it would remove; `--quiet` for the hook;
     `--deep` additionally runs `uv cache prune` and `brew cleanup --prune=all`
   - Warns and lists the top consumers when free space drops under 10GB

2. **Shell hook** (`dot_config/zsh/conf.d/09-disk-cache-gc.zsh`):
   - Handles the wallpaper cache, in the one context that can read it
   - `zsh-defer` + `--throttle 21600` + backgrounded subshell: no measurable
     startup cost, at most one real run every 6 hours
   - Interactive shells only; provides `disk-gc`, `disk-gc-deep`,
     `disk-gc-check` aliases

3. **LaunchAgent** (`Library/LaunchAgents/com.github.lv416e.disk-cache-gc.plist.tmpl`):
   - Runs `disk-cache-gc --deep` daily for `uv` and Homebrew only
   - `EnvironmentVariables/PATH` set explicitly: launchd hands a job a bare
     `/usr/bin:/bin:/usr/sbin:/sbin`, where neither `uv` nor `brew` is found
   - `StartInterval` rather than `StartCalendarInterval`: launchd runs a missed
     interval job shortly after wake, so it still fires on a sleeping laptop
   - `LowPriorityIO`, `Nice 10`, logs to `~/Library/Logs/disk-cache-gc.log`

4. **Registration script** (`run_onchange_after_setup-launchd.sh.tmpl`):
   - Writing a plist is not enough; launchd only picks up a new or changed job
     when bootstrapped. Lints with `plutil`, then `bootout` + `bootstrap`
   - Re-runs whenever the plist template changes

**File structure**:

```
.
├── dot_local/bin/
│   └── executable_disk-cache-gc                    # size-capped GC
├── dot_config/zsh/conf.d/
│   └── 09-disk-cache-gc.zsh                        # wallpaper cap (has FDA)
├── Library/LaunchAgents/
│   └── com.github.lv416e.disk-cache-gc.plist.tmpl  # daily deep clean
└── run_onchange_after_setup-launchd.sh.tmpl        # launchd registration
```

At 9GB/day and a 6-hour throttle, the wallpaper cache is capped at roughly
2.8GB of transient growth between runs — comfortable on any modern disk.

## Consequences

### Positive

- The disk can no longer fill from this cache during normal use
- Wallpaper rotation is untouched; no feature is given up
- No Full Disk Access grant to a shell interpreter
- A permission denial is now visible rather than silent
- The same mechanism generalises: new runaway caches are one call away
- `disk-gc-deep` gives a single manual command for a broader reclaim
- First introduction of launchd management to these dotfiles, with a
  registration path that other agents can reuse

### Negative

- The wallpaper cap depends on opening a terminal. On a machine left running
  for days without one, growth resumes unbounded — 9GB/day buys under two
  months of headroom from a full disk
- Two mechanisms instead of one, split on a constraint (TCC) that is invisible
  in the code and only documented here
- Deleting cached renders means the OS re-renders a wallpaper it had cached,
  costing a brief CPU spike when an old wallpaper cycles back
- `Library/LaunchAgents` is now chezmoi-managed, so hand edits there are
  overwritten on the next `chezmoi apply`
- The GC trusts mtime as a proxy for "in use"; a wallpaper displayed but never
  re-rendered for a long time could in principle be evicted and re-rendered

### Neutral

- macOS only; the registration script is a no-op elsewhere
- Budgets are heuristics and may need tuning on a multi-display 5K setup
- If the terminal ever loses Full Disk Access the cap stops working, but says so

## Pros and Cons of the Options

### Option 1: Do nothing

- Good, because no code to maintain
- Bad, because the failure mode is a disk at 100% with no warning, which breaks
  builds, git operations and the OS itself
- Bad, because recovery is manual and urgent every single time

### Option 2: Stop rotating wallpapers

- Good, because it removes the cause entirely
- Good, because zero maintenance
- Bad, because it gives up a feature the user deliberately installed

### Option 3: Lower the rotation frequency

- Good, because it is a one-setting change in a GUI
- Bad, because it only slows growth; the cache is still unbounded
- Bad, because the setting lives in an app's preferences, outside chezmoi

### Option 4: Symlink the cache directory to a sink

- Good, because growth becomes structurally impossible
- Bad, because it depends on undocumented container behaviour and may be
  reset by the OS or break the wallpaper agent
- Bad, because sandbox container paths are not a stable interface

### Option 5: LaunchAgent only

- Good, because a timer is the obvious right trigger and needs no shell
- Good, because it runs whether or not anyone logs in interactively
- Bad, because **it does not work** — TCC denies the container read
- Bad, because the denial is silent without an explicit readability probe

### Option 6: Grant Full Disk Access to `/bin/bash`

- Good, because Option 5 would then work unmodified
- Bad, because every bash script on the machine inherits unrestricted
  filesystem access, permanently
- Bad, because the grant is manual GUI state, invisible to chezmoi and lost on
  a new machine

### Option 7: Split by trust context (chosen)

- Good, because each half runs where it actually has the access it needs
- Good, because growth is bounded while the feature is preserved
- Good, because it is declarative, reproducible and observable via a log
- Good, because oldest-first eviction keeps what is actually in use
- Bad, because the wallpaper cap only advances when a shell is opened
- Bad, because two mechanisms are harder to reason about than one

## References

- `dot_local/bin/executable_disk-cache-gc`
- `dot_config/zsh/conf.d/09-disk-cache-gc.zsh`
- `Library/LaunchAgents/com.github.lv416e.disk-cache-gc.plist.tmpl`
- `run_onchange_after_setup-launchd.sh.tmpl`
- ADR-0009: macOS defaults automation strategy — the sibling pattern for
  applying macOS-level configuration through chezmoi
- `launchd.plist(5)`, `launchctl(1)`
