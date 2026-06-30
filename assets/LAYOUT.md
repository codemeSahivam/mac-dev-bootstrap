# Ghostty dashboard layout (auto on startup)

On macOS, Ghostty opens with a **vertical split** matching the reference riced terminal:

| Left pane | Right pane |
|---|---|
| `btop` (system monitor) | `zsh` + `fastfetch` on login |

## How it works

Ghostty does not support split layouts in config alone. mac-dev-bootstrap uses:

1. `initial-command` → runs a small launcher script
2. **AppleScript** → creates a new window, splits vertically, runs `btop` left and `zsh` right
3. Closes the temporary bootstrap window

Files (deployed on install):

```text
~/.config/mac-dev-bootstrap/ghostty/dashboard.applescript
~/.config/mac-dev-bootstrap/bin/ghostty-dashboard-init.sh
```

## First launch

macOS will ask for **Automation** permission (Ghostty controlling Ghostty). Allow it in:

**System Settings → Privacy & Security → Automation**

## Disable auto dashboard

```bash
./install.sh --no-dashboard
```

Or remove this line from `~/.config/ghostty/config`:

```ini
initial-command = ...
```

## Manual layout (same as Cmd+D)

```text
Cmd+D          split right (vertical)
Cmd+Shift+D    split down (horizontal)
Cmd+Ctrl+←→↑↓  focus panes
Cmd+W          close pane
```
