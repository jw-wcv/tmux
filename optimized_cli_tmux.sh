#!/bin/bash
#
# Ultimate Single Pane CLI w/ Mouse Support 
#

BASE_SESSION_NAME="optimized_cli"

# Check if the base session "optimized_cli" already exists
tmux has-session -t "$BASE_SESSION_NAME" 2>/dev/null
if [ $? -eq 0 ]; then
  # The session exists; prompt user to attach or create new
  echo "Session '$BASE_SESSION_NAME' already exists."
  echo -n "Attach to existing session (a) or create a new session (n)? [a/n]: "
  read -r CHOICE

  if [[ "$CHOICE" =~ ^[Nn]$ ]]; then
    # Create a new session with a unique name, e.g. "optimized_cli_1674053437"
    NEW_SESSION_NAME="${BASE_SESSION_NAME}_$(date +%s)"
    echo "Creating a new session named '$NEW_SESSION_NAME'..."

    # Create the new session (detached)
    tmux new-session -d -s "$NEW_SESSION_NAME"

    # Session-specific environment tweaks
    tmux set-option -t "$NEW_SESSION_NAME" -g status off
    tmux set-option -t "$NEW_SESSION_NAME" -g mouse on
    tmux set-option -t "$NEW_SESSION_NAME" -g history-limit 100000
    tmux set-option -t "$NEW_SESSION_NAME" -g renumber-windows on
    tmux set-option -t "$NEW_SESSION_NAME" -g automatic-rename on
    tmux set-option -t "$NEW_SESSION_NAME" -g pane-border-status off
    tmux set-option -t "$NEW_SESSION_NAME" -g set-titles on
    tmux set-option -t "$NEW_SESSION_NAME" -g display-panes-time 1000
    tmux set-option -t "$NEW_SESSION_NAME" -g aggressive-resize on

    # Visual tweaks
    tmux set-option -t "$NEW_SESSION_NAME" -g status-bg black
    tmux set-option -t "$NEW_SESSION_NAME" -g status-fg green
    tmux set-option -t "$NEW_SESSION_NAME" -g status-left " CLI Session "
    tmux set-option -t "$NEW_SESSION_NAME" -g message-style bg=black,fg=green
    tmux set-option -t "$NEW_SESSION_NAME" -g pane-active-border-style fg=green

    # Keybindings (applied globally, rather than session-specific)
    tmux bind-key r "source-file ~/.tmux.conf; display-message 'Config Reloaded!'"
    tmux bind-key h split-window -h
    tmux bind-key v split-window -v
    tmux bind-key c new-window
    tmux bind-key k kill-pane
    tmux bind-key Space next-layout

    # Start in a normal CLI
    tmux send-keys -t "$NEW_SESSION_NAME" "clear" C-m

    # Attach to new session
    tmux attach -t "$NEW_SESSION_NAME"
    exit 0
  else
    # Attach to existing "optimized_cli"
    tmux attach -t "$BASE_SESSION_NAME"
    exit 0
  fi
else
  # "optimized_cli" does NOT exist, so create it
  tmux new-session -d -s "$BASE_SESSION_NAME"

  # Session-specific environment tweaks
  tmux set-option -t "$BASE_SESSION_NAME" -g status off
  tmux set-option -t "$BASE_SESSION_NAME" -g mouse on
  tmux set-option -t "$BASE_SESSION_NAME" -g history-limit 100000
  tmux set-option -t "$BASE_SESSION_NAME" -g renumber-windows on
  tmux set-option -t "$BASE_SESSION_NAME" -g automatic-rename on
  tmux set-option -t "$BASE_SESSION_NAME" -g pane-border-status off
  tmux set-option -t "$BASE_SESSION_NAME" -g set-titles on
  tmux set-option -t "$BASE_SESSION_NAME" -g display-panes-time 1000
  tmux set-option -t "$BASE_SESSION_NAME" -g aggressive-resize on

  # Visual tweaks
  tmux set-option -t "$BASE_SESSION_NAME" -g status-bg black
  tmux set-option -t "$BASE_SESSION_NAME" -g status-fg green
  tmux set-option -t "$BASE_SESSION_NAME" -g status-left " CLI Session "
  tmux set-option -t "$BASE_SESSION_NAME" -g message-style bg=black,fg=green
  tmux set-option -t "$BASE_SESSION_NAME" -g pane-active-border-style fg=green

  # Keybindings (applied globally, not session-specific)
  tmux bind-key r "source-file ~/.tmux.conf; display-message 'Config Reloaded!'"
  tmux bind-key h split-window -h
  tmux bind-key v split-window -v
  tmux bind-key c new-window
  tmux bind-key k kill-pane
  tmux bind-key Space next-layout

  # Start in a normal CLI
  tmux send-keys -t "$BASE_SESSION_NAME" "clear" C-m

  # Attach
  tmux attach -t "$BASE_SESSION_NAME"
fi
