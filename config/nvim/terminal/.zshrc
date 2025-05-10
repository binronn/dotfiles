
# Enable Powerlevel10k instant prompt.
# Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set up proxy settings
export http_proxy="http://127.0.0.1:10808"
export https_proxy="http://127.0.0.1:10808"
# --- LS_COLORS --- #
export LS_COLORS='di=34;1:ln=36;1:so=32;1:pi=33;1:ex=31;1:bd=34;46;1:cd=34;43;1:su=30;41;1:sg=30;46;1:tw=30;42;1:ow=30;43;1:'

# Load private configurations
source "$HOME/.zshrc_pri"

# --- Golang Environment --- #
export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# --- Zinit Plugin Manager --- #
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# --- zoxide: fast directory navigation --- #
if ! command -v zoxide &> /dev/null; then
    echo "zoxide 未安装，正在尝试使用 apt 安装..."
    sudo apt update && sudo apt install -y zoxide fzf
fi

# Initialize zoxide for zsh
autoload -U compinit && compinit -u
eval "$(zoxide init zsh --cmd j)" # j <dir> for quick directory switching

# --- Syntax Highlighting --- #
zinit ice lucid wait='1' atinit='zpcompinit'
zinit light zdharma-continuum/fast-syntax-highlighting

# --- Auto Suggestions --- #
zinit ice lucid wait="1" atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# --- Completions --- #
zinit light zsh-users/zsh-completions

zinit light marlonrichert/zsh-autocomplete
zstyle ':autocomplete:*' delay 0.01  # Set delay to 0.01 seconds
zstyle ':autocomplete:*history*:*' insert-unambiguous yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':autocomplete:*' min-input 3
zstyle ':autocomplete:*' ignored-input '..##'

# --- Asynchronous Plugin Loading --- #
zinit load djui/alias-tips
zinit load romkatv/powerlevel10k

# --- Powerlevel10k Theme --- #
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Proxy Aliases --- #
alias curlp="curl -x http://127.0.0.1:10808"
alias wgetp="wget -e http_proxy='http://127.0.0.1:10808'"

# --- Git Aliases --- #
alias ga="git add"
alias gaa="git add ."
alias gct="git commit"
alias gcm="git commit -m"
alias gph="git push"
alias gpl="git pull"
alias gss="git status"
alias gsh="git stash"
alias gco="git checkout"
alias gbh="git branch"
alias grt="git remote"
alias gdf="git diff"
alias gl="git log"
alias gcl="git clone"

# --- Other Aliases --- #
alias vim=nvim
alias tmux="tmux -u"
alias ls="ls --color=auto"

# --- History Settings --- #
setopt HIST_IGNORE_ALL_DUPS # Remove duplicate entries
setopt INC_APPEND_HISTORY   # Append to history immediately after each command
setopt SHARE_HISTORY        # Share history across terminals
export HISTFILE="$HOME/.zsh_history"

# Set history size
HISTSIZE=3000
SAVEHIST=3000


# --- Zinit Annexes --- #
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# --- Unalias zi --- #
unalias zi 2>/dev/null

# --- pipx --- #
export PATH="$PATH:/home/byron/.local/bin"


# --- Fix delete key --- #
bindkey '^[[3~' delete-char
bindkey -M viins '^[[3~' delete-char
bindkey -M vicmd '^[[3~' delete-char


# --- Tmux --- #
# if command -v tmux &> /dev/null && ! tmux list-sessions &> /dev/null; then
#   exec tmux
# fi
