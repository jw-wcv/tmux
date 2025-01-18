#!/bin/bash
#
# Daily Coding and Monitoring Layout
#

SESSION_NAME="workspace"

# Check if the session "workspace" already exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Session '$SESSION_NAME' already exists."
  echo -n "Attach to existing session (a) or create a new session (n)? [a/n]: "
  read -r CHOICE

  if [[ "$CHOICE" =~ ^[Nn]$ ]]; then
    # Create a new session with a unique name, e.g., "workspace_1674053437"
    NEW_SESSION_NAME="${SESSION_NAME}_$(date +%s)"
    echo "Creating a new session named '$NEW_SESSION_NAME'..."

    # Create the new session detached with a window named "main"
    tmux new-session -d -s "$NEW_SESSION_NAME" -n main

    # Create the layout:
    # Top Full Pane for coding:
    tmux send-keys -t "$NEW_SESSION_NAME" "nvim" C-m

    # Split vertically - bottom half for monitoring & file browser:
    tmux split-window -v -t "$NEW_SESSION_NAME"

    # Bottom Left Pane - System Monitoring (btm)
    tmux send-keys -t "$NEW_SESSION_NAME:main.1" "btm" C-m

    # Split the bottom pane horizontally - Right Pane for File Browser:
    tmux split-window -h -t "$NEW_SESSION_NAME:main.1"
    tmux send-keys -t "$NEW_SESSION_NAME:main.2" "mc" C-m

    # Create a third pane in the bottom right for a shell:
    tmux split-window -v -t "$NEW_SESSION_NAME:main.2"
    tmux send-keys -t "$NEW_SESSION_NAME:main.3" "zsh" C-m

    # Finally, select the top (coding) pane:
    tmux select-pane -t "$NEW_SESSION_NAME:main.0"

    # Attach to the new session
    tmux attach -t "$NEW_SESSION_NAME"
    exit 0
  else
    # Attach to the existing "workspace" session
    tmux attach -t "$SESSION_NAME"
    exit 0
  fi
else
  # No existing "workspace" session found; create it
  tmux new-session -d -s "$SESSION_NAME" -n main

  # Create the layout:
  # Top Full Pane for coding:
  tmux send-keys -t "$SESSION_NAME" "nvim" C-m

  # Split vertically - bottom half for monitoring & file browser:
  tmux split-window -v -t "$SESSION_NAME"

  # Bottom Left Pane - System Monitoring (btm)
  tmux send-keys -t "$SESSION_NAME:main.1" "btm" C-m

  # Split bottom pane horizontally - Right Pane for File Browser:
  tmux split-window -h -t "$SESSION_NAME:main.1"
  tmux send-keys -t "$SESSION_NAME:main.2" "mc" C-m

  # Create a third pane in the bottom right for a shell:
  tmux split-window -v -t "$SESSION_NAME:main.2"
  tmux send-keys -t "$SESSION_NAME:main.3" "zsh" C-m

  # Select the top (coding) pane:
  tmux select-pane -t "$SESSION_NAME:main.0"

  # Attach to the new session
  tmux attach -t "$SESSION_NAME"
fi
