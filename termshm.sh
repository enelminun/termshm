#!/bin/bash

SHORTCUTS_FILE="$HOME/.termshm_shortcuts"

show_help() {
  echo "TERMShM - Terminal Shortcut Manager"
  echo ""
  echo "Usage:"
  echo "  termshm set <path/to/file>       Set a shortcut"
  echo "  termshm run id:[id]             Run a shortcut"
  echo "  termshm remove <id>             Remove a shortcut"
  echo "  termshm list                    List all set shortcuts"
  echo "  termshm help                    Show help commands"
  echo "without 'termshm' tag"
  echo ""
}

init_shortcuts() {
  if [[ ! -f "$SHORTCUTS_FILE" ]]; then
    touch "$SHORTCUTS_FILE"
  fi
}

set_shortcut() {
  local shortcut_path=$1
  local id=$(wc -l < "$SHORTCUTS_FILE")
  ((id++))
  
  echo "$shortcut_path" >> "$SHORTCUTS_FILE"
  echo "Shortcut set with ID $id."
}

run_shortcut() {
  local id=$1
  local shortcut_path=$(sed -n "${id}p" "$SHORTCUTS_FILE")
  
  if [[ -z "$shortcut_path" ]]; then
    echo "Invalid ID or shortcut not found."
    exit 1
  fi
  
  if [[ "$shortcut_path" == *.jar ]]; then
    echo "Running: $shortcut_path"
    java -jar "$shortcut_path"
  elif [[ "$shortcut_path" == *.py ]]; then
    echo "Python file detected. Creating virtual environment..."
    local venv_dir=$(dirname "$shortcut_path")/.venv
    
    if [[ ! -d "$venv_dir" ]]; then
      python3 -m venv "$venv_dir"
      echo "Virtual environment created: $venv_dir"
    fi

    source "$venv_dir/bin/activate"
    echo "Running: $shortcut_path"
    python "$shortcut_path"
    deactivate
  elif [[ "$shortcut_path" == *.exe ]]; then
    echo "Running with Wine: $shortcut_path"
    wine "$shortcut_path"
  elif [[ "$shortcut_path" == *.png ]]; then
    echo "Opening with Gwenview: $shortcut_path"
    gwenview "$shortcut_path"
  elif [[ "$shortcut_path" == *.mp4 || "$shortcut_path" == *.mkv || "$shortcut_path" == *.avi ]]; then
    echo "Playing video with VLC: $shortcut_path"
    vlc "$shortcut_path"
  else
    echo "Running: $shortcut_path"
    "$shortcut_path"
  fi
}

remove_shortcut() {
  local id=$1
  
  if [[ ! -n "$(sed -n "${id}p" "$SHORTCUTS_FILE")" ]]; then
    echo "Invalid ID, shortcut not found."
    exit 1
  fi
  
  sed -i "${id}d" "$SHORTCUTS_FILE"
  sed -i ':a;N;$!ba;s/\n/\n/g' "$SHORTCUTS_FILE"
  echo "Shortcut $id removed."
}

list_shortcuts() {
  if [[ ! -s "$SHORTCUTS_FILE" ]]; then
    echo "No shortcuts set yet."
    return
  fi
  
  echo -e "ID\t\tPath/To/File"
  echo -e "---------------------------------------------"
  
  local id=1
  while IFS= read -r shortcut; do
    echo -e "$id\t\t$shortcut"
    ((id++))
  done < "$SHORTCUTS_FILE"
}

interactive_shell() {
  while true; do
    echo -n "termshm > "
    read -r command args
    
    case "$command" in
      set)
        if [[ -z "$args" ]]; then
          echo "Please provide a file path."
        else
          set_shortcut "$args"
        fi
        ;;
      remove)
        if [[ -z "$args" ]]; then
          echo "Please provide an ID."
        else
          remove_shortcut "$args"
        fi
        ;;
      list)
        list_shortcuts
        ;;
      run)
        if [[ -z "$args" || ! "$args" =~ ^id:[0-9]+$ ]]; then
          echo "Invalid command. Format: termshm run id:[id]"
        else
          id="${args#id:}"
          run_shortcut "$id"
        fi
        ;;
      help)
        show_help
        ;;
      clear)
        clear
        ;;
      exit)
        echo "Exiting..."
        break
        ;;
      *)
        echo "Invalid command. Use 'help' for assistance."
        ;;
    esac
  done
}

main() {
  init_shortcuts
  list_shortcuts
  interactive_shell
}

main "$@"
