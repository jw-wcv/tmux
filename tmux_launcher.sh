#!/bin/bash

TMUX_DIR=~/Documents/Projects/tmux
SESSION_NAME="tmux_launcher"
EXCLUDE_SCRIPTS=("tmux_launcher.sh" "config_tmux.sh")

# Force terminal to use 256 colors
export TERM=xterm-256color

# Tmux terminal settings
tmux set-option -g default-terminal "xterm-256color"
tmux set -as terminal-overrides ",xterm-256color:Tc"

# ANSI Color Codes
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Function to center text dynamically
center_text() {
  local term_width=$(tput cols)
  local text_length=$(echo -e "$1" | wc -c)
  local padding=$(( (term_width - text_length) / 2 ))
  printf '%*s%s\n' "$padding" '' "$1"
}

# Function to strip color codes and calculate visual length
strip_colors() {
  echo -e "$1" | sed 's/\x1B\[[0-9;]*m//g'
}

# Function to center the menu dynamically
center_menu_item() {
  local term_width=$(tput cols)
  local stripped_line_length=$(strip_colors "$(printf "%-3s %-30s %s" "$1" "$2" "$3")" | wc -c)
  local padding=$(( (term_width - stripped_line_length) / 2 ))
  printf '%*s%s %s %s\n' "$padding" '' "$1" "$2" "${CYAN}$3${RESET}"
}

# Function to print centered block
center_block() {
  local term_width=$(tput cols)
  local lines=("$@")
  for line in "${lines[@]}"; do
    local padding=$(( (term_width - ${#line}) / 2 ))
    printf '%*s%s\n' "$padding" '' "$line"
  done
}

# Clear screen
clear

# Welcome Banner
banner=(
"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
"@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@"
"@@@#+#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#=*@@@"
"@@@@*#**%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%***+@@@@"
"@@@@@*%@#+%@@@@@@@@@@@@@@@@@##@@@@@@@@@@@@@@@@@#+#@%+%@@@@"
"@@@@@%*@@@%*#@@@@@@@@@@@@@#+%%+#@@@@@@@@@@@@@#+#@@@*%@@@@@"
"@@@@@@##@@@@%**%@@@@@@@@#*%@@@@%*#%@@@@@@@%**%@@@@#*@@@@@@"
"@@@@@@%*%@%#@@%#*%@@@@**%@@%**%@@%**@@@@%+*%@@##@%+%@@@@@@"
"@@@@@@@%*@@=.*@@@%+#**@@@%+====+%@@@**#+#@@@*.=@@+%@@@@@@@"
"@@@@@@@@#*@%- .=%@@%%@@%*===++===+%@@%%@@%=..-%@*#@@@@@@@@"
"@@@@@@@@@##@%.  .-#@@%+===*%@@%*===+%@@%-.  .%@#*@@@@@@@@@"
"@@@@@@@@@%*%@@:    .#@@**@@#:.#@@*+@@#:.   :%@%*%@@@@@@@@@"
"@@@@@@@@@@%*%@@%=.   .+%%+.    .+%%*.   .=%@@@*#@@@@@@@@@@"
"@@@@@@@@@@@##@@%+=-.   ..  ....  ...  .+%@%@@#*@@@@@@@@@@@"
"@@@@@@@@@@@@*%@%*=#@#.    .#@@#.    .#@@++@@%+@@@@@@@@@@@@"
"@@@@@@@@@@@@%+@@%+=*%@%--#@@@@@@%--%@%+==%@@+%@@@@@@@@@@@@"
"@@@@@@@@@@@@@%*@@#===*%@@@@@@@@@@@@%+===#@@*%@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@##@@%+===+%@@@@@@@@%+====#@@##@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@%*%@@@#+===+%@@@@%+====#@@@%*%@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@@@#*%@@@#+===+##+====#@@@%*#%@@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@@@@@#*%@@@#========#@@@%*#@@@@@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@@@@@@@#*%@@@*====*@@@%+#@@@@@@@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@@@@@@@@@#*%@@@*#@@@%*#@@@@@@@@@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@@@@@@@@@@@%*%@@@@%*#@@@@@@@@@@@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@@@@@@@@@@@@@%+#%+%@@@@@@@@@@@@@@@@@@@@@@@@@@"
"@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
)

center_block "${banner[@]}"
echo ""
center_text "$(echo -e "${CYAN}=========================================${RESET}")"
center_text "$(echo -e "✨ ${YELLOW}Welcome, $(whoami)!${RESET} ✨")"
center_text "$(echo -e "Today is ${GREEN}$(date +'%A, %B %d %Y')${RESET}.")"
center_text "$(echo -e "Your terminal is ready to power your productivity!")"
center_text "$(echo -e "${CYAN}=========================================${RESET}")"
echo ""

# Ensure tmux directory exists
if [ ! -d "$TMUX_DIR" ]; then
  center_text "$(echo -e "📁 Tmux directory not found. Creating $TMUX_DIR...")"
  mkdir -p "$TMUX_DIR"
  center_text "$(echo -e "✅ Directory created.")"
  echo ""
fi

# Collect scripts and exclude launcher
SCRIPTS=($(ls "$TMUX_DIR"/*.sh 2>/dev/null | grep -v -f <(printf '%s\n' "${EXCLUDE_SCRIPTS[@]}")))
if [ ${#SCRIPTS[@]} -eq 0 ]; then
  center_text "$(echo -e "🚫 No tmux scripts found in $TMUX_DIR.")"
  center_text "$(echo -e "💡 Tip: Add your tmux scripts to kickstart your workflow!")"
  exit 1
fi

# Display menu header
center_text "$(echo -e "${YELLOW}🚀 Available Tmux Sessions 🚀${RESET}")"
center_text "$(echo -e "${CYAN}=========================================${RESET}")"

# Display tmux options
for i in "${!SCRIPTS[@]}"; do
  DESCRIPTION=$(head -n 1 "${SCRIPTS[$i]}" | sed 's/^#//')
  SCRIPT_NAME=$(basename "${SCRIPTS[$i]}")
  DISPLAY_NAME=$(echo "$SCRIPT_NAME" | sed 's/_tmux//; s/\.sh//')
  center_text "$(echo -e "$(center_menu_item "[$i]" "$DISPLAY_NAME" "$DESCRIPTION")")"
done

center_text "$(echo -e "${CYAN}=========================================${RESET}")"
center_text "$(echo -e "✨ Tip: Select a session by entering its number.")"
echo ""

read -p "$(center_text "$(echo -e "🔢 Select a session to launch: ")")" CHOICE
echo ""

tmux resize-pane -Z  # Maximize the pane when the session starts

if [[ -n "${SCRIPTS[$CHOICE]}" ]]; then
  SELECTED_SCRIPT="${SCRIPTS[$CHOICE]}"
  center_text "$(echo -e "🚀 Launching: $(basename "$SELECTED_SCRIPT")")"
  bash "$SELECTED_SCRIPT"
else
  center_text "$(echo -e "${RED}❌ Invalid selection. Please try again!${RESET}")"
  exit 1
fi