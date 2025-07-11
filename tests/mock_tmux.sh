#!/bin/bash

# Initialize TMUX_BINDS array to track binds
if [[ -z "${TMUX_BINDS+x}" ]]; then
  declare -a TMUX_BINDS
  export TMUX_BINDS
fi

# Main function to handle tmux commands
handle_tmux_command() {
  case "$*" in
    "list-panes -F #{pane_id} #{pane_current_command}")
      echo "%1 nvim"
      echo "%2 bash"
      echo "%3 nvim"
      ;;
    "send-keys -t %1 :echo 'Hello from tmux!' Enter")
      echo "Command sent to Neovim pane"
      ;;
    "select-pane -t %1")
      echo "Focused pane %1"
      ;;
    show-option\ -gqv\ @*)
      # Extract the option name and convert to environment variable format
      option=$(echo "$*" | sed 's/.*@//' | sed 's/-/_/g')
      env_var="TMUX_OPTION_$option"
      # Return the value if set in environment variable, otherwise empty
      if [[ -n "${!env_var}" ]]; then
        echo "${!env_var}"
      else
        echo ""
      fi
      ;;
    bind\ *)
      # Extract the key being bound
      key=$(echo "$*" | sed 's/bind //' | cut -d' ' -f1 | sed "s/'//g")
      TMUX_BINDS+=("$key")
      export TMUX_BINDS
      ;;
    *)
      echo "Unknown tmux command: $*" >&2
      exit 1
      ;;
  esac
}

# If called as a script, handle the command directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  handle_tmux_command "$@"
fi

# Define tmux function for when sourced
tmux() {
  handle_tmux_command "$@"
}
