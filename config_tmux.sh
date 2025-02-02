# Install Homebrew Packages (if not installed)

CURRENT_DIR=$(pwd)
ZSHRC_SOURCE="$CURRENT_DIR/zshrc"
ZSHRC_TARGET="$HOME/.zshrc"
TMUX_CONF_SOURCE="$CURRENT_DIR/tmux.conf"
TMUX_CONF_TARGET="$HOME/.tmux.conf"
BACKUP_NAME=".zshrc.backup.$(date +%Y%m%d%H%M%S)"
BACKUP_PATH="$CURRENT_DIR/backups/$BACKUP_NAME"

if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

arch -arm64 brew install tmux
arch -arm64 brew install neovim
arch -arm64 brew install bottom
arch -arm64 brew install mc
arch -arm64 brew install zellij
arch -arm64 brew install yazi
arch -arm64 brew install neomutt
arch -arm64 brew install newsboat
arch -arm64 brew install glances
arch -arm64 brew install ranger
arch -arm64 brew install task
arch -arm64 brew install taskwarrior
arch -arm64 brew install ncmpcpp
arch -arm64 brew install mpv
arch -arm64 brew install wtfutil
arch -arm64 brew install nethack
arch -arm64 brew install kubectl
arch -arm64 brew install ctop
arch -arm64 brew install pyenv pyenv-virtualenv
arch -arm64 brew install openssl readline zlib xz
arch -arm64 brew install asciiquarium
arch -arm64 brew install vtop



# Prompt user for confirmation
echo "Do you want to update your ~/.zshrc file? (yes/no)"
read -r response

if [[ "$response" =~ ^[Yy] ]]; then
    # Backup existing .zshrc if it exists
    if [ -f "$ZSHRC_TARGET" ]; then
        echo "Backing up existing ~/.zshrc to $BACKUP_PATH..."
        cp "$ZSHRC_TARGET" "$BACKUP_PATH"
        echo "Backup completed: $BACKUP_NAME"
    fi

    # Overwrite ~/.zshrc with zshrc from current directory
    if [ -f "$ZSHRC_SOURCE" ]; then
        echo "Overwriting ~/.zshrc with $ZSHRC_SOURCE..."
        cp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
        echo "Zsh configuration updated successfully."
    else
        echo "Error: zshrc file not found in the current directory."
        exit 1
    fi

    # Overwrite ~/.tmux.conf with tmux.conf from the current directory
    if [ -f "$TMUX_CONF_SOURCE" ]; then
        echo "Overwriting ~/.tmux.conf with $TMUX_CONF_SOURCE..."
        cp "$TMUX_CONF_SOURCE" "$TMUX_CONF_TARGET"
        echo "Tmux configuration updated successfully."
    else
        echo "Error: tmux.conf file not found in the current directory."
        exit 1
    fi


    # Reload Zsh configuration
    echo "Reloading Zsh configuration..."
    source "$ZSHRC_TARGET"
    echo "Zsh configuration reloaded."
else
    echo "Operation canceled. No changes made."
fi