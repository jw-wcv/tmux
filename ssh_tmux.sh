# SSH Tmux Session for Key Management
#!/bin/bash


SESSION_NAME="ssh"

# Check if session exists
tmux has-session -t $SESSION_NAME 2>/dev/null
if [ $? != 0 ]; then
  # Create new tmux session
  tmux new-session -d -s $SESSION_NAME -n main
  
  # Left Pane (YubiKey Manager)
  tmux send-keys -t $SESSION_NAME "bash /Users/JJ/Documents/Projects/yubikey-manager/key_manager.sh" C-m

  # Split horizontally into top and bottom right panes
  tmux split-window -h -t $SESSION_NAME
  tmux split-window -v -t $SESSION_NAME:.1

  # Top Right Pane (Midnight Commander)
  tmux send-keys -t $SESSION_NAME:.1 'mc' C-m

  # Bottom Right Pane (Resource Monitor)
  tmux send-keys -t $SESSION_NAME:.2 'btm' C-m

  # Select the left pane (where key manager script is running)
  tmux select-pane -t $SESSION_NAME:.0
fi

# Attach to the tmux session
tmux attach-session -t $SESSION_NAME

