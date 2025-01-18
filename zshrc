# =========================
# Zsh Configuration (Enhanced Logging)
# =========================

# -------------------------
# Path and Environment
# -------------------------
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"  # Prioritize Homebrew and local binaries
export PATH="$HOME/bin:$PATH:/usr/local/sbin"         # Add personal bin and sbin paths
export EDITOR='vim'                                   # Set default editor
export LANG=en_US.UTF-8                               # Language and encoding

# PyEnv Config
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
    eval "$(pyenv virtualenv-init -)"
fi

LOG_FILE=~/zsh_debug.log
echo "[$(date)] - Zsh configuration loaded" >> "$LOG_FILE"

# -------------------------
# Aliases (Quality of Life)
# -------------------------
alias ll='ls -la'
alias gs='git status'
alias gc='git commit -m'
alias gp='git push'
alias update='brew update && brew upgrade'
alias cls='clear'
alias dev='cd ~/Documents/Projects'
# alias pip="python3 -m pip"


echo "[$(date)] - Aliases loaded" >> "$LOG_FILE"

# Quick Navigation Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

echo "[$(date)] - Navigation aliases loaded" >> "$LOG_FILE"

# -------------------------
# wd: Jump back to the top-level folder in key directories
# -------------------------
wd_func() {
  # Add or remove key directories here:
  local KEY_DIRS=(
    "$HOME/Documents"
    "$HOME/Projects"
    "$HOME/Etc"
    # "$HOME/Work"
  )

  for base_dir in "${KEY_DIRS[@]}"; do
    if [[ "$PWD" == "$base_dir"* ]]; then
      local subpath="${PWD#"$base_dir"}"
      subpath="${subpath#"/"}"    # remove leading slash if any
      local top="${subpath%%/*}"  # everything before the first slash

      if [[ -z "$subpath" || "$top" == "$subpath" ]]; then
        echo "Already at the top level of $base_dir or cannot detect subfolder."
      else
        cd "$base_dir/$top"
      fi
      return
    fi
  done

  echo "You are not in any of the key directories: ${KEY_DIRS[*]}."
}

alias wd='wd_func'

# -------------------------
# If we're already in Tmux, force TERMINAL_MODE="tmux"
# -------------------------
if [ -n "$TMUX" ]; then
  export TERMINAL_MODE="tmux"
fi

# -------------------------
# Only prompt if TERMINAL_MODE is still not set
# -------------------------
if [ -z "$TERMINAL_MODE" ]; then
  echo
  echo "Choose your terminal mode:"
  echo "1) Tmux session"
  echo "2) Normal terminal"
  echo -n "Enter choice [1 or 2]: "
  read term_choice

  case "$term_choice" in
    1) export TERMINAL_MODE="tmux";;
    *) export TERMINAL_MODE="normal";;
  esac

  echo "[$(date)] - User chose: $TERMINAL_MODE" >> "$LOG_FILE"
fi

# -------------------------
# Tmux-Related Logic
# -------------------------
if [ "$TERMINAL_MODE" = "tmux" ]; then
  # If we're not already in a tmux session (i.e. first time choosing Tmux)...
  if [ -z "$TMUX" ]; then
    # Check for your custom tmux_launcher.sh script
    if [ -f ~/Documents/Projects/tmux/tmux_launcher.sh ]; then
      echo "[$(date)] - Tmux launcher found. Running..." >> "$LOG_FILE"
      bash ~/Documents/Projects/tmux/tmux_launcher.sh
    else
      echo "[$(date)] - Tmux launcher not found at expected path." >> "$LOG_FILE"
      # Fallback: attach to 'default' session, or create one if it doesn't exist
      tmux new-session -A -s default
      echo "[$(date)] - Attached to or created 'default' tmux session." >> "$LOG_FILE"
    fi
  else
    echo "[$(date)] - Already inside a tmux session. Skipping auto-start." >> "$LOG_FILE"
  fi
else
  echo "[$(date)] - User opted for normal terminal mode. Skipping tmux logic." >> "$LOG_FILE"
fi

# -------------------------
# Prompt Customization
# -------------------------
autoload -Uz colors && colors
export PROMPT='%F{cyan}%n%f@%m %F{yellow}%~%f %# '  # User@host path with color
echo "[$(date)] - Prompt customization applied" >> "$LOG_FILE"

# -------------------------
# Plugins & Completions
# -------------------------
autoload -Uz compinit
compinit
echo "[$(date)] - Plugins and completions loaded" >> "$LOG_FILE"

# -------------------------
# Improve History Behavior
# -------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS      # Ignore consecutive duplicates
setopt HIST_FIND_NO_DUPS     # Avoid showing dupes in reverse-i-search
setopt INC_APPEND_HISTORY    # Append to the history file immediately
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

echo "[$(date)] - History settings applied" >> "$LOG_FILE"

# -------------------------
# Greeting (Optional)
# -------------------------
echo "Welcome, $(whoami)! Terminal ready at $(date +'%Y-%m-%d %H:%M:%S')."
echo "[$(date)] - Greeting displayed" >> "$LOG_FILE"
echo ""
cat << "EOF"
  /$$$$$$$$ /$$$$$$   /$$$$$$  /$$   /$$  /$$$$$$ 
| $$_____//$$__  $$ /$$__  $$| $$  | $$ /$$__  $$
| $$     | $$  \ $$| $$  \__/| $$  | $$| $$  \__/
| $$$$$  | $$  | $$| $$      | $$  | $$|  $$$$$$ 
| $$__/  | $$  | $$| $$      | $$  | $$ \____  $$
| $$     | $$  | $$| $$    $$| $$  | $$ /$$  \ $$
| $$     |  $$$$$$/|  $$$$$$/|  $$$$$$/|  $$$$$$/
|__/      \______/  \______/  \______/  \______/ 
EOF
echo ""
echo ""
echo "[$(date)] - ASCII art rendered" >> "$LOG_FILE"

# -------------------------
# Override 'wc' to support 'wc -h' custom help
# -------------------------
function wc() {
  if [[ "$1" == "-h" ]]; then
    cat <<EOF

========================================
         Custom Terminal Commands
========================================

Aliases you can run:
  ll      -> ls -la (long listing with hidden files)
  gs      -> git status
  gc      -> git commit -m
  gp      -> git push
  update  -> brew update && brew upgrade
  cls     -> clear screen
  dev     -> cd ~/Documents/Projects
  ..      -> cd ..
  ...     -> cd ../..
  ....    -> cd ../../..

Special functions:
  wd      -> Jump back to the top-level folder if you're inside:
             * ~/Documents
             * ~/Projects
             * ~/Etc
             (Add more directories in wd_func() if desired)

Tmux logic:
  On new shell startup, you're prompted:
    1) Tmux session
    2) Normal terminal

  If you choose "1) Tmux session", it either:
    * Runs ~/Documents/Projects/tmux/tmux_launcher.sh if found, OR
    * Attaches/creates a 'default' tmux session.

========================================
Note: 'wc -h' is overridden for custom help.
For the normal 'wc' usage, run: command wc --help
EOF
  else
    # For any other usage, call the real wc
    command wc "$@"
  fi
}
