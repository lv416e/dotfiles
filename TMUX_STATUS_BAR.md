# Tmux Status Bar Configuration

## Overview

This dotfiles repository includes a custom, lightweight tmux status bar that displays real-time system information while maintaining excellent performance.

## Features

- **Claude Code Usage**: Real-time token usage tracking (⚡)
- **CPU Usage**: Current CPU utilization with color coding (💚/⚙️/🔥)
- **RAM Usage**: Memory consumption in GB (💾/📊/🧠)
- **Battery Status**: Battery percentage with charging indicator (🔋/🪫/⚡/🔌)
- **Date & Time**: Current time and date

## Performance

All scripts are optimized for minimal performance impact:

| Script | Average Execution Time | Cache Duration |
|--------|----------------------|----------------|
| `tmux-claude-usage.sh` | 15ms | 60 seconds |
| `tmux-cpu-usage.sh` | 31ms (14ms cached) | 5 seconds |
| `tmux-battery.sh` | 37ms | N/A |
| `tmux-ram-usage.sh` | 91ms | N/A |

**Total overhead**: ~175ms per update (15-second interval = 1.17% overhead)

## Configuration

### Status Bar Settings

```tmux
set -g status-position bottom
set -g status-style 'bg=green,fg=black'
set -g status-interval 15

set -g status-left-length 20
set -g status-left '#[bg=green,fg=black,bold] [#{session_name}] '

set -g status-right-length 120
set -g status-right '#[bg=green,fg=black]#(~/.local/bin/tmux-claude-usage.sh) | #(~/.local/bin/tmux-cpu-usage.sh) | #(~/.local/bin/tmux-ram-usage.sh) | #(~/.local/bin/tmux-battery.sh) | %H:%M %d-%b-%y '
```

### Color Scheme

- **Background**: Green
- **Foreground**: Black
- **Current window**: Black background, green foreground, bold

### Update Interval

The status bar updates every 15 seconds (`status-interval 15`), which provides a good balance between responsiveness and performance.

## Scripts

### tmux-claude-usage.sh

Displays Claude Code token usage for today.

**Caching**: 60 seconds
**Output format**: `⚡{tokens}k` or `⚡N/A`

**Features**:
- Parses `ccusage --today` output
- Formats large numbers (e.g., "12k" for 12,000 tokens)
- Includes 3-second timeout to prevent hanging
- Uses cached results to minimize API calls

### tmux-cpu-usage.sh

Shows current CPU usage percentage with emoji indicators.

**Caching**: 5 seconds
**Output format**: `{emoji}{percentage}%`

**Emoji indicators**:
- 💚 (green heart): Normal usage (<50%)
- ⚙️ (gear): Medium usage (50-80%)
- 🔥 (fire): High usage (>80%)

**Optimization**: Uses `iostat` instead of `top` for 52x faster execution.

### tmux-ram-usage.sh

Displays current RAM usage in GB.

**Output format**: `{emoji}{usage}G`

**Emoji indicators**:
- 💾 (floppy disk): Normal usage (<60%)
- 📊 (chart): Medium usage (60-80%)
- 🧠 (brain): High usage (>80%)

**Method**: Parses `vm_stat` output for accurate memory calculation.

### tmux-battery.sh

Shows battery percentage and charging status.

**Output format**: `{emoji}{percentage}%`

**Emoji indicators**:
- 🔋 (battery): >50% and discharging
- 🪫 (low battery): 20-50% and discharging
- ⚠️ (warning): <20% and discharging
- ⚡ (lightning): AC power connected
- 🔌 (plug): Currently charging

**Note**: Automatically hidden if no battery is detected (e.g., desktop Mac).

## Customization

### Adjusting Update Frequency

Edit `~/.tmux.conf`:

```tmux
set -g status-interval 10  # Update every 10 seconds (more responsive)
# or
set -g status-interval 30  # Update every 30 seconds (less overhead)
```

### Modifying Cache Duration

Edit individual script files in `~/.local/bin/`:

```bash
# tmux-claude-usage.sh
CACHE_MAX_AGE=120  # Cache for 2 minutes

# tmux-cpu-usage.sh
CACHE_MAX_AGE=10   # Cache for 10 seconds
```

### Changing Colors

Edit `~/.tmux.conf`:

```tmux
# Example: Blue background with white text
set -g status-style 'bg=blue,fg=white'
set -g status-left '#[bg=blue,fg=white,bold] [#{session_name}] '
set -g status-right '#[bg=blue,fg=white]#(~/.local/bin/tmux-claude-usage.sh) | ...'
```

### Adding/Removing Modules

Edit the `status-right` setting in `~/.tmux.conf`:

```tmux
# Remove Claude usage
set -g status-right '#[bg=green,fg=black]#(~/.local/bin/tmux-cpu-usage.sh) | #(~/.local/bin/tmux-ram-usage.sh) | #(~/.local/bin/tmux-battery.sh) | %H:%M %d-%b-%y '

# Add custom script
set -g status-right '#[bg=green,fg=black]#(~/.local/bin/tmux-claude-usage.sh) | #(~/.local/bin/custom-script.sh) | %H:%M %d-%b-%y '
```

## Installation

These scripts are managed by chezmoi and are automatically installed when you run:

```bash
chezmoi apply
```

## Refreshing the Status Bar

After making changes:

```bash
# Reload tmux configuration (inside tmux)
tmux source-file ~/.tmux.conf

# Or use the prefix key
# Prefix (Ctrl+g) + : then type:
source-file ~/.tmux.conf
```

## Troubleshooting

### Status bar not updating

1. Check if scripts are executable:
   ```bash
   ls -l ~/.local/bin/tmux-*.sh
   ```

2. Test scripts manually:
   ```bash
   ~/.local/bin/tmux-cpu-usage.sh
   ~/.local/bin/tmux-ram-usage.sh
   ```

3. Check tmux status-interval:
   ```bash
   tmux show-options -g status-interval
   ```

### Performance issues

1. Increase cache duration in scripts
2. Increase `status-interval` to reduce update frequency
3. Remove expensive modules (e.g., Claude usage if ccusage is slow)

### Claude usage shows "N/A"

1. Verify ccusage is installed:
   ```bash
   which ccusage
   ccusage --version
   ```

2. Check if you've used Claude Code today:
   ```bash
   ccusage --today
   ```

3. Verify cache file permissions:
   ```bash
   ls -l /tmp/tmux-claude-usage.cache
   ```

## Future Enhancements

Potential additions for the status bar:

- Network usage (upload/download speed)
- Disk usage (percentage or GB free)
- Current playing music (Spotify/Music.app)
- Weather information (with API caching)
- Git repository status (if in repo)
- Docker container count
- Kubernetes context
