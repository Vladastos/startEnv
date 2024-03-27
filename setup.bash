#!/bin/bash
# shellcheck disable=SC2124
# shellcheck disable=SC2027
function log() {
  local log_level=$1
  shift
  local message="$*"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp [$log_level] $message"
}

function prompt_user_and_execute() {
  local question=$1
  local command=$2
  echo -e "\n"
  read -r -p "$question [Y/n] " response
  echo -e "\n"
  case $response in
    [yY][eE][sS]|[yY])
      eval "$command"
      ;;
    *)
      exit 1
      ;;
  esac
}

function download_single_file(){
    local file=$1
    local file_name
    file_name=$(basename "$file")
    log "INFO" "Downloading $file_name..."
    local max_attempts=3
    local current_attempt=0
    until wget -q "$file" || [ $current_attempt -eq $max_attempts ]; do
        ((current_attempt++))
        log "WARN" "Failed to download file. Retrying ($current_attempt/$max_attempts)"
        sleep 1
    done
    if [ $current_attempt -eq $max_attempts ]; then
        log "ERROR" "Failed to download file after $max_attempts attempts"
    fi
}

function download_scripts(){
  function download_bash_scripts(){
    local scripts=("$@")
    mkdir -p "$SCRIPTS_DIR"
    cd  "$SCRIPTS_DIR" || exit
    log "INFO" "Downloading bash scripts..."
    for script in "${scripts[@]}"; do
      download_single_file "$script"
    done
  }

  function download_python_scripts(){
    local scripts=("$@")
    mkdir -p "$SCRIPTS_DIR/python"
    cd "$SCRIPTS_DIR/python" || exit
    log "INFO" "Downloading python scripts..."
  
    for script in "${scripts[@]}"; do
      download_single_file "$script"
    done
  }

  function create_virtual_environment(){
    cd "$SCRIPTS_DIR"/python || exit
    log "INFO" "Creating virtual environment..."
    python3 -m venv venv > /dev/null
    # shellcheck disable=SC1091
    . venv/bin/activate
    log "INFO" "Installing python requirements..."
    pip install -r requirements.txt > /dev/null
  }

  local bash_scripts=(
    "$REMOTE_SCRIPTS_DIR/start.bash"
    "$REMOTE_SCRIPTS_DIR/consts.bash"
  )
  local python_scripts=(
    "$REMOTE_SCRIPTS_DIR/python/startEnv.py"
    "$REMOTE_SCRIPTS_DIR/python/requirements.txt"
  )
  
  download_bash_scripts "${bash_scripts[@]}"

  download_python_scripts "${python_scripts[@]}"

  create_virtual_environment

  
}

function install_dependencies(){
  log "INFO" "Installing dependencies..."
  for dep in "${DEPENDENCIES[@]}"; do
    if ! (command -v "$dep" &> /dev/null) then
    log "INFO" "Installing $dep..."
    sudo apt-get --yes install "$dep" > /dev/null
  else :
    log "INFO" "$dep already installed"
  fi
  done
}

#TODO: add tmux config 
function create_tmux_config(){
  log "INFO" "Creating tmux config..."
  mkdir -p "$TMUX_CONFIG_DIR"
  cd "$TMUX_CONFIG_DIR" || exit
  download_single_file "$REMOTE_TMUX_CONFIG_DIR/tmux.conf"
  #install tpm
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    log "INFO" "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

function create_alias(){
  if ! grep -q "startEnv()" "$HOME/.bash_aliases"; then
    log "INFO" "Creating alias..."
    echo "startEnv(){ bash /home/vlad/.config/startEnv/scripts/start.bash \$@ ;}" >> "$HOME"/.bash_aliases
  else :
    log "INFO" "Alias already exists"
  fi

}

function download_config(){
  log "INFO" "Downloading config..."
  if [ ! -f "${CONFIG_DIR}/config.json" ]; then
    mkdir -p "$CONFIG_DIR"
    cd "$CONFIG_DIR" || exit
    download_single_file "$REMOTE_CONFIG_DIR/config.json"
  fi
}

function get_latest_version() {
  remote_consts=$(wget -qO- "https://raw.githubusercontent.com/Vladastos/startEnv/main/scripts/consts.bash")
  # shellcheck disable=SC1090
  source <(echo "$remote_consts")
}


function cleanup_on_error() {
  local exit_code=$?
  if [ "$exit_code" -ne 0 ]; then
    log "ERROR" "Something went wrong, cleaning up..."
    rm -rf "$STARTENV_DIR"
    sed -i "/startEnv()/d" "$HOME/.bash_aliases"
    log "ERROR" "Clean up completed"
  fi
}

function welcome_screen(){
  function write_separator() {
    echo " "
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '='
    echo " "

  }
  function center_lines() {
    local lines_to_print=("$@")
    for line in "${lines_to_print[@]}"; do
      local line_length=${#line}
      local padding=$(((( COLUMNS - line_length) / 2 )-1))
      printf "%*s" "$padding" ""
      printf "%s" "$line"
      printf "%*s" "$padding" ""
      printf "\n"
    done

  }
  write_separator
  center_lines "Welcome to"
  figlet -t -c startEnv
  center_lines "Version $VERSION "
  write_separator
}

function main(){
  get_latest_version
  echo 
  log "INFO" "Installing startEnv version $VERSION..."
  prompt_user_and_execute "Do you want to install dependencies?" install_dependencies
  prompt_user_and_execute "Do you want to download all the necessary scripts?" download_scripts
  prompt_user_and_execute "Do you want startEnv to create it's own tmux config?" create_tmux_config
  create_alias
  download_config
  welcome_screen
}

trap cleanup_on_error EXIT

main

