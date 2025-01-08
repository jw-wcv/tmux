# Daily Coding and Monitoring Layout
#!/bin/bash

SESSION_NAME="workspace"

# Check if session exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
  tmux attach -t $SESSION_NAME
else
  # Create new tmux session
  tmux new-session -d -s $SESSION_NAME -n main

  # Create main coding pane (Top Full Pane)
  tmux send-keys -t $SESSION_NAME "nvim" C-m

  # Split horizontally - Bottom Half for Monitoring and File Browser
  tmux split-window -v -t $SESSION_NAME

  # Bottom Left - System Monitoring (btm)
  tmux send-keys -t $SESSION_NAME:main.1 "btm" C-m

  # Split Bottom Right Pane (50% of Bottom for File Browser)
  tmux split-window -h -t $SESSION_NAME:main.1
  tmux send-keys -t $SESSION_NAME:main.2 "mc" C-m

  # Create third pane at bottom for shell
  tmux split-window -v -t $SESSION_NAME:main.2
  tmux send-keys -t $SESSION_NAME:main.3 "zsh" C-m

  # Start in the top coding pane
  tmux select-pane -t $SESSION_NAME:main.0
  tmux attach -t $SESSION_NAME
fi

