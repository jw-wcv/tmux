#!/bin/bash
#
# SSH Tmux Session for Key Management
#

SESSION_NAME="ssh"

# Check if a session named "ssh" already exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null
if [ $? -eq 0 ]; then
  # The session "ssh" exists; prompt user
  echo "Session '$SESSION_NAME' already exists."
  echo -n "Attach to existing session (a) or create a new session (n)? [a/n]: "
  read -r CHOICE

  if [[ "$CHOICE" =~ ^[Nn]$ ]]; then
    # Create a new session with a unique name, e.g. "ssh_1674053437"
    NEW_SESSION_NAME="${SESSION_NAME}_$(date +%s)"
    echo "Creating a new session named '$NEW_SESSION_NAME'..."

    # Create session detached, name it NEW_SESSION_NAME
    tmux new-session -d -s "$NEW_SESSION_NAME" -n main
    
    # Left Pane: YubiKey Manager
    tmux send-keys -t "$NEW_SESSION_NAME" "bash ~/Documents/Projects/yubikey-manager/key_manager.sh" C-m

    # Split horizontally to get top-right and bottom-right
    tmux split-window -h -t "$NEW_SESSION_NAME"
    tmux split-window -v -t "$NEW_SESSION_NAME":.1

    # Top Right Pane: Midnight Commander
    tmux send-keys -t "$NEW_SESSION_NAME":.1 'mc' C-m

    # Bottom Right Pane: btm (resource monitor)
    tmux send-keys -t "$NEW_SESSION_NAME":.2 'btm' C-m

    # Select the left pane (where key_manager.sh is running)
    tmux select-pane -t "$NEW_SESSION_NAME":.0

    # Attach to the new session
    tmux attach-session -t "$NEW_SESSION_NAME"
    exit 0
  else
    # Attach to the existing "ssh"
    tmux attach-session -t "$SESSION_NAME"
    exit 0
  fi

else
  # The "ssh" session does NOT exist, so create it
  tmux new-session -d -s "$SESSION_NAME" -n main
  
  # Left Pane: YubiKey Manager
  tmux send-keys -t "$SESSION_NAME" "bash ~/Documents/Projects/yubikey-manager/key_manager.sh" C-m

  # Split horizontally to get top-right and bottom-right
  tmux split-window -h -t "$SESSION_NAME"
  tmux split-window -v -t "$SESSION_NAME":.1

  # Top Right Pane: Midnight Commander
  tmux send-keys -t "$SESSION_NAME":.1 'mc' C-m

  # Bottom Right Pane: btm (resource monitor)
  tmux send-keys -t "$SESSION_NAME":.2 'btm' C-m

  # Select the left pane (where key_manager.sh is running)
  tmux select-pane -t "$SESSION_NAME":.0

  # Attach to the "ssh" session
  tmux attach-session -t "$SESSION_NAME"
fi
