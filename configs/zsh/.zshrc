# mac-dev-bootstrap — Zsh entrypoint
# Modular files: ~/.config/mac-dev-bootstrap/zsh/

autoload -Uz compinit
compinit -C

# History
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_VERIFY

# Completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Modular config from installer
MDB_ZSH="${HOME}/.config/mac-dev-bootstrap/zsh"
[[ -f "${MDB_ZSH}/exports.zsh"  ]] && source "${MDB_ZSH}/exports.zsh"
[[ -f "${MDB_ZSH}/aliases.zsh"  ]] && source "${MDB_ZSH}/aliases.zsh"
[[ -f "${MDB_ZSH}/functions.zsh" ]] && source "${MDB_ZSH}/functions.zsh"

# Oh My Zsh (optional)
if [[ "${MDB_USE_OH_MY_ZSH:-false}" == "true" && -d "${HOME}/.oh-my-zsh" ]]; then
  export ZSH="${HOME}/.oh-my-zsh"
  ZSH_THEME=""
  plugins=(
    git docker docker-compose kubectl helm terraform aws golang python
    history sudo command-not-found fzf
    zsh-autosuggestions zsh-syntax-highlighting
  )
  source "${ZSH}/oh-my-zsh.sh"
else
  # Plain zsh — load plugins from custom dir
  ZSH_CUSTOM="${HOME}/.config/mac-dev-bootstrap/omz-plugins"
  [[ -f "${ZSH_CUSTOM}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "${ZSH_CUSTOM}/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "${ZSH_CUSTOM}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "${ZSH_CUSTOM}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf
if command -v fzf &>/dev/null; then
  source <(fzf --zsh) 2>/dev/null || true
fi

# kubectl completion
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh) 2>/dev/null || true
  compdef k kubectl 2>/dev/null || true
fi

# docker completion
if command -v docker &>/dev/null; then
  fpath=("${HOME}/.docker/completions" $fpath)
  autoload -Uz compinit && compinit -C
fi

# Editor
export EDITOR="${EDITOR:-nvim}"

# Fastfetch on startup
if [[ "${MDB_FASTFETCH_ON_START:-true}" == "true" && -z "${SKIP_FASTFETCH:-}" ]]; then
  command -v fastfetch &>/dev/null && fastfetch
fi
