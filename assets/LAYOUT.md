# Ghostty dashboard — reference terminal layout

On launch (macOS), Ghostty opens **maximized** with:

| Left (~52%) | Right (~48%) |
|---|---|
| **btop** — CPU, memory, network, processes | **fastfetch** — large Apple logo + system info |
| | **zsh** prompt: `user@host ~ %` |

Matches the classic riced macOS terminal look (btop + neofetch/fastfetch split).

## Requirements

- macOS with Ghostty 1.3+ (AppleScript API)
- Automation permission for Ghostty
- **Maximized window** — needed so both panes have enough width for full btop + Apple logo

## First launch

Allow **Automation** when prompted:
**System Settings → Privacy & Security → Automation**

## Manual shortcuts

```text
Cmd+D          split vertical
Cmd+Shift+D    split horizontal
Cmd+Ctrl+arrows  focus pane
```

## Disable

```bash
./install.sh --no-dashboard
```
