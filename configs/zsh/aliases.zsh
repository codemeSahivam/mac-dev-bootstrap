# ── Git ───────────────────────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'

# ── Docker ────────────────────────────────────────────────────────────────────
alias dps='docker ps'
alias dimg='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dbash='docker run -it --rm'

# ── Docker Compose ────────────────────────────────────────────────────────────
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dcps='docker compose ps'

# ── Kubernetes ────────────────────────────────────────────────────────────────
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kctx='kubectx'
alias kns='kubens'
alias klogs='kubectl logs -f'
alias kexec='kubectl exec -it'
alias kdesc='kubectl describe'

# ── System / modern CLI ───────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ll='eza -lah --icons'
  alias la='eza -a --icons'
  alias tree='eza --tree --icons'
  alias ls='eza --icons'
fi

if command -v bat &>/dev/null; then
  alias cat='bat'
fi

if command -v rg &>/dev/null; then
  alias grep='rg'
fi

alias ports='lsof -i -P -n | grep LISTEN'
alias top='btop'
alias mon='btop'
alias cls='clear'

# Shortcuts
alias v='nvim'
alias ..='cd ..'
alias reload='source ~/.zshrc && echo "↻ reloaded"'
