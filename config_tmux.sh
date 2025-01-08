# Install Homebrew Packages (if not installed)
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

arch -arm64 brew install tmux
arch -arm64 brew install neovim
arch -arm64 brew install bottom
arch -arm64 brew install mc




# Install all necessary packages (without browsers)
brew install zellij bottom yazi neomutt newsboat glances ranger task taskwarrior ncmpcpp mpv wtfutil nethack kubectl ctop

# Create configuration directory
mkdir -p ~/cli_config

# Create tmux autostart script
cat <<EOF > ~/cli_config/tmux_autostart.sh
if [ -z "\$TMUX" ]; then
  tmux new-session -d -s terminal_desktop
  tmux split-window -h
  tmux split-window -v
  tmux send-keys -t 0 'mc' C-m
  tmux send-keys -t 1 'btm' C-m
  tmux send-keys -t 2 'glances' C-m
  tmux attach-session -t terminal_desktop
fi
EOF

# Source tmux autostart in shell configuration
if [ -f ~/.zshrc ]; then
  echo 'source ~/cli_config/tmux_autostart.sh' >> ~/.zshrc
  source ~/.zshrc
elif [ -f ~/.bash_profile ]; then
  echo 'source ~/cli_config/tmux_autostart.sh' >> ~/.bash_profile
  source ~/.bash_profile
else
  echo 'source ~/cli_config/tmux_autostart.sh' >> ~/.zshrc
  source ~/.zshrc
fi

# Reboot the system (optional, remove if not needed)
# sudo shutdown -r now

