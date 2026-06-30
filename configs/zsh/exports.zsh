# Environment & PATH

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="${HOME}/.local/bin:${PATH}"

# Locale
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# bat / eza
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="${BAT_THEME:-Catppuccin Mocha}"
export EZA_COLORS="da=1;34"

# Go
export GOPATH="${GOPATH:-${HOME}/go}"
export PATH="${GOPATH}/bin:${PATH}"

# Java (Homebrew openjdk)
if command -v brew &>/dev/null; then
  _jhome="$(brew --prefix openjdk 2>/dev/null)/libexec/openjdk.jdk/Contents/Home"
  if [[ -d "${_jhome}" ]]; then
    export JAVA_HOME="${_jhome}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
  fi
  unset _jhome
fi

# Kubernetes merged configs
[[ -f "${HOME}/.config/mac-dev-bootstrap/kube-env.sh" ]] && source "${HOME}/.config/mac-dev-bootstrap/kube-env.sh"

# AWS
export AWS_PAGER=""

# fzf defaults
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border --info=inline}"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

# Add secrets and project exports below (never commit tokens)
# export MY_TOKEN=""
