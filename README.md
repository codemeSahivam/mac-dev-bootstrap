# mac-dev-bootstrap

Production-quality **macOS developer environment bootstrap** for Apple Silicon and Intel Macs. Clone the repo, run one command, and get a polished terminal, shell, Git, Kubernetes, and Docker workflow.

> Target: macOS Tahoe · M1/M2/M3 · Intel (where supported)

## Quick start

```bash
git clone https://github.com/YOUR_USER/mac-dev-bootstrap.git
cd mac-dev-bootstrap
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh
```

Restart your terminal or run:

```bash
exec zsh
```

## Screenshots

| Ghostty + btop + Fastfetch | Minimal prompt |
|---|---|
| _Add screenshot: `assets/screenshots/terminal.png`_ | _Add screenshot: `assets/screenshots/prompt.png`_ |

## Features

- **One-command install** — `./install.sh` with interactive prompts
- **Idempotent** — safe to rerun; skips unchanged configs
- **Backups** — creates `*.backup.YYYYMMDDHHMMSS` before overwriting
- **Modular** — configs in `configs/`, scripts in `scripts/`
- **Themes** — Catppuccin, Kanagawa, Gruvbox, Dracula
- **Optional components** — Oh My Zsh, tmux, Neovim, Fastfetch, Ghostty, btop

### Terminal (Ghostty)

- True-black background with subtle blur
- Hidden titlebar, JetBrains Mono Nerd Font
- Block cursor, clipboard integration, large scrollback
- Per-theme overrides in `themes/<name>/ghostty`

### Split-pane layout (reference look)

See [assets/LAYOUT.md](assets/LAYOUT.md):

1. Open Ghostty → `Cmd+D` (vertical split)
2. Left pane: `btop`
3. Right pane: `fastfetch` on startup (or run manually)

### System monitor (btop)

- **Carbon** theme — black background, green CPU/RAM bars
- Config: `configs/btop/btop.conf` + `configs/btop/themes/carbon.theme`

### Fastfetch

- Rainbow Apple logo (neofetch-style)
- OS, host, kernel, uptime, packages, shell, terminal, CPU, GPU, memory, color blocks

### Prompt (Starship)

**Default — minimal** (`configs/starship/starship.toml`):

```text
user@hostname ~ %
```

**Optional — full dev prompt** (`~/.config/starship.dev.toml`):

```bash
export STARSHIP_CONFIG=~/.config/starship.dev.toml
exec zsh
```

Shows Git, Go/Java/Python, Docker, Kubernetes, AWS, and command duration.

### Shell (Zsh)

```text
configs/zsh/
  .zshrc
  aliases.zsh
  functions.zsh
  exports.zsh
```

Enabled: completions, history, fzf, zoxide, autosuggestions, syntax highlighting, kubectl/docker completion.

### Oh My Zsh (optional)

Interactive choice during install:

1. Plain ZSH
2. Oh My Zsh

Plugins: `git`, `docker`, `docker-compose`, `kubectl`, `helm`, `terraform`, `aws`, `golang`, `python`, `history`, `sudo`, `command-not-found`, `fzf`, plus autosuggestions & syntax-highlighting.

## Packages installed (Homebrew)

| Category | Packages |
|---|---|
| Terminal | Ghostty |
| Shell | Starship, fzf, zoxide |
| CLI | eza, bat, fd, ripgrep, jq, yq, tree, btop, wget, curl, htop |
| Git | git-delta, lazygit |
| DevOps | kubectl, helm, kubectx, kubens, docker |
| Other | tmux, neovim, fastfetch |
| Fonts | JetBrains Mono Nerd Font |

## Customization

### Non-interactive install

```bash
./install.sh --non-interactive --theme dracula
```

### Flags

| Flag | Description |
|---|---|
| `--theme NAME` | `catppuccin`, `kanagawa`, `gruvbox`, `dracula` |
| `--plain-zsh` | Skip Oh My Zsh |
| `--no-fastfetch` | Disable Fastfetch on startup |
| `--no-tmux` | Skip tmux config |
| `--no-neovim` | Skip Neovim config |
| `--no-ghostty` | Skip Ghostty cask |

### Edit configs

| Component | Path |
|---|---|
| Ghostty | `configs/ghostty/config` + `themes/<theme>/ghostty` |
| Starship (minimal) | `configs/starship/starship.toml` |
| Starship (dev) | `configs/starship/starship.dev.toml` |
| Starship colors | `themes/<theme>/starship.toml` → `[palettes.theme]` |
| Fastfetch | `configs/fastfetch/config.jsonc` |
| btop | `configs/btop/` |
| Zsh | `configs/zsh/` |

After editing, rerun `./install.sh` to redeploy (backups created automatically).

### Kubernetes

Place kubeconfig files in `~/.kube/configs/*.yaml`. Use aliases: `kctx`, `kns`, `kx`.

## Uninstall

```bash
./uninstall.sh --restore                  # restore backups
./uninstall.sh --restore --remove-packages  # also remove brew packages
```

## Troubleshooting

### Starship palette warning

Use Starship 1.26+ palette syntax:

```toml
palette = "theme"

[palettes.theme]
fg = "#e8e8e8"
```

Do **not** use `[palette.theme]` — that causes `invalid type: map, expected a string`.

### Homebrew not found after install

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
eval "$(/usr/local/bin/brew shellenv)"      # Intel
```

### Starship icons show as boxes

Install JetBrains Mono Nerd Font and set Ghostty to **JetBrainsMono Nerd Font**.

### Docker commands fail

Start **Docker Desktop** — the bootstrap installs the CLI only.

### View install log

```bash
ls -lt ~/.mac-dev-bootstrap/logs/
```

## Project structure

```text
mac-dev-bootstrap/
├── install.sh
├── uninstall.sh
├── README.md
├── LICENSE
├── configs/
│   ├── ghostty/
│   ├── starship/
│   ├── fastfetch/
│   ├── zsh/
│   ├── git/
│   ├── tmux/
│   ├── nvim/
│   └── btop/
├── scripts/
│   ├── install_homebrew.sh
│   ├── install_packages.sh
│   ├── install_fonts.sh
│   ├── configure_ghostty.sh
│   ├── configure_starship.sh
│   ├── configure_fastfetch.sh
│   ├── configure_btop.sh
│   ├── configure_zsh.sh
│   ├── configure_git.sh
│   ├── configure_tmux.sh
│   ├── configure_neovim.sh
│   ├── configure_kubernetes.sh
│   ├── configure_docker.sh
│   ├── configure_fzf.sh
│   ├── configure_zoxide.sh
│   ├── backup_configs.sh
│   ├── logger.sh
│   └── utils.sh
├── themes/
│   ├── catppuccin/
│   ├── kanagawa/
│   ├── gruvbox/
│   └── dracula/
└── assets/
```

## Development

```bash
brew install shellcheck
shellcheck install.sh uninstall.sh scripts/*.sh
```

## License

MIT — see [LICENSE](LICENSE).
