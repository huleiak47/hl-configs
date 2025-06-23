# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
# ZSH_THEME="fino"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(z extract zsh-interactive-cd zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode)

# if use zsh-vi-mode, set this to supress `zvm_cursor_style:33: failed to compile regex: trailing backslash` error
setopt re_match_pcre

# DISABLE_AUTO_UPDATE=true
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZVM_VI_SURROUND_BINDKEY=classic

[ -f ~/.cargo/env ] && source ~/.cargo/env

if [ -d ~/toolchains ]; then
    for dir in `ls ~/toolchains`;
    do
        export PATH=~/toolchains/$dir/bin:$PATH
    done
fi

if [ -d ~/bin ]; then
    export PATH=~/bin:$PATH
fi

if [ -d ~/local/bin ]; then
    export PATH=~/local/bin:$PATH
fi

if [ "$(command -v gitui)" ]; then
    alias gu=gitui
fi

if [ "$(command -v lsd)" ]; then
    alias ls='lsd'
    alias ll='lsd -lh --date "+%Y/%m/%d-%H:%M:%S"'
    alias la='lsd -A'
    alias lla='lsd -lAh --date "+%Y/%m/%d-%H:%M:%S"'
fi

if [ "$(command -v bat)" ]; then
  unalias -m 'cat'
  alias cat='bat -pp'
fi

if [ "$(command -v yazi)" ]; then
  alias y=yazi
fi

if [ "$(command -v nvim)" ]; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

function fzf_init() {
    if [ "$(command -v fzf)" ]; then
        eval "$(fzf --zsh)"
    fi
}

function mcfly_init() {
    if [ "$(command -v mcfly)" ]; then
        export MCFLY_FUZZY=2
        export MCFLY_RESULTS=50
        export MCFLY_RESULTS_SORT=LAST_RUN
        export MCFLY_HISTORY_LIMIT=10000
        export MCFLY_KEY_SCHEME=vim

        eval "$(mcfly init zsh)"
    fi
}

zvm_after_init_commands+=(fzf_init mcfly_init)

# preexec() {
#     timer=`python3 -c 'import time; print(time.time())'`
# }

# precmd() {
#     exit_code=$?
#     if [[ -n $timer ]]; then
#         python3 -c "import time; now = time.time(); now_show = time.strftime('%H:%M:%S'); t = now - float($timer); t_show = f'{t:.3f} s' if t > 1.0 else f'{int(t*1000)} ms'; color='\033[92m' if $exit_code==0 else '\033[91m'; print(f'{color}[[ Exit code: $exit_code | Execution time: {t_show} | {now_show} ]]\033[0m')"
#         unset timer
#     fi
#     unset exit_code
# }

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

alias make="make -j"
alias vim=nvim

# for windows
if (( $+USERPROFILE )); then
    alias gnvim="start wezterm-gui start nvim"
    alias fd="fd --path-separator '//'"
    alias pc=proxychains
    export UV_LINK_MODE=copy
    export SRV='hul@192.168.8.141'
    export PATH=/bin:/usr/bin:$PATH
else
    alias pc=proxychains4
    function fgg() {
        _JOBS=`jobs`
        _LINES=`echo $_JOBS | wc -l`

        if [ "$_LINES" = "0" ]; then
            echo no jobs
            return
        fi

        if [ "$_LINES" = "1" ]; then
            fg
            return
        fi

        _JOB=`echo $_JOBS | fzf --header "jobs" | grep -E '^\[[0-9]+\]' -o | grep -E '[0-9]+' -o`

        if [ -z $_JOB ]; then
            return
        fi

        fg %$_JOB
    }
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

