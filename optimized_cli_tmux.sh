# Ultimate Single Pane CLI w/ Mouse Support 

#!/bin/bash

SESSION_NAME="optimized_cli"

# Start a new tmux session or attach if it already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
  # Create new tmux session
  tmux new-session -d -s $SESSION_NAME

  # Set up environment tweaks for clarity and productivity
  tmux set-option -g status off                     # Remove status bar for clean view
  tmux set-option -g mouse on                       # Enable mouse support for scroll
  tmux set-option -g history-limit 100000           # Large scrollback for reviewing
  tmux set-option -g renumber-windows on            # Renumber windows dynamically
  tmux set-option -g automatic-rename on            # Rename windows by active process
  tmux set-option -g pane-border-status off         # Hide borders
  tmux set-option -g set-titles on                  # Show session name in terminal title
  tmux set-option -g display-panes-time 1000        # Longer display time when switching panes
  tmux set-option -g aggressive-resize on           # Resize based on terminal changes

  # Visual tweaks for enhanced readability
  tmux set-option -g status-bg black                # Dark status bar background
  tmux set-option -g status-fg green                # Green text for status
  tmux set-option -g status-left " CLI Session "    # Static left status
  tmux set-option -g message-style bg=black,fg=green # Green popup messages
  tmux set-option -g pane-active-border-style fg=green # Highlight active pane in green

  # Keybindings
  tmux bind r source-file ~/.tmux.conf \; display-message "Config Reloaded!"  # Reload config
  tmux bind-key h split-window -h                                              # Horizontal split
  tmux bind-key v split-window -v                                              # Vertical split
  tmux bind-key c new-window                                                   # New window
  tmux bind-key k kill-pane                                                    # Kill pane
  tmux bind-key Space next-layout                                              # Switch layouts
  
  # Start in normal CLI
  tmux send-keys -t $SESSION_NAME "clear" C-m
fi

# Attach to the session
tmux attach-session -t $SESSION_NAME
