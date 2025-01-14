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

echo "[$(date)] - Aliases loaded" >> "$LOG_FILE"

# Quick Navigation Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

echo "[$(date)] - Navigation aliases loaded" >> "$LOG_FILE"

# -------------------------
# Configurable Tmux Auto-start
# -------------------------

# Enable or disable tmux auto-start
ENABLE_TMUX_AUTO_START=true  # Change to "false" to disable tmux auto-start

# Tmux Auto-start (Entry Point)
if [ -z "$TMUX" ]; then
    if [ -f ~/Documents/Projects/tmux/tmux_launcher.sh ]; then
        echo "[$(date)] - Tmux launcher found. Running..." >> "$LOG_FILE"
        bash ~/Documents/Projects/tmux/tmux_launcher.sh
    else
        echo "[$(date)] - Tmux launcher not found at expected path." >> "$LOG_FILE"
    fi
fi

# Tmux Session Persistence and Improved Logic
tmux_auto_start() {
    # Prevent nested tmux sessions
    if [ -z "$TMUX" ]; then
        echo "[$(date)] - No active tmux session detected." >> "$LOG_FILE"
        
        # Prompt user for whether to start or skip tmux
        read -q "use_tmux?Start a new tmux session? (y/n): "
        echo  # Move to a new line after user input
        
        if [[ "$use_tmux" =~ ^[Yy]$ ]]; then
            # Attach to the "default" session if it exists, or create a new one
            tmux new-session -A -s default
            echo "[$(date)] - Attached to or created 'default' tmux session." >> "$LOG_FILE"
        else
            echo "[$(date)] - User opted to skip tmux session." >> "$LOG_FILE"
        fi
    else
        echo "[$(date)] - Already inside a tmux session. Skipping auto-start." >> "$LOG_FILE"
    fi
}

# Call the tmux auto-start function if enabled
if [ "$ENABLE_TMUX_AUTO_START" = true ]; then
    tmux_auto_start
else
    echo "[$(date)] - Tmux auto-start is disabled." >> "$LOG_FILE"
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
setopt HIST_IGNORE_DUPS  # Ignore duplicates
setopt HIST_FIND_NO_DUPS  # Avoid showing dupes in search
setopt INC_APPEND_HISTORY  # Append immediately to history
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

