#!/bin/bash

DEPENDENCIES=("python3" "pip" "git" "wget" "tmux" "figlet")

HOME_CONFIG_DIR="/home/$(logname)/.config/startEnv"
REMOTE_DIR="https://raw.githubusercontent.com/Vladastos/startEnv/main"
SCRIPTS_DIR="${HOME_CONFIG_DIR}/scripts"
REMOTE_SCRIPTS_DIR="${REMOTE_DIR}/scripts"
CONFIG_DIR="${HOME_CONFIG_DIR}/config"
REMOTE_CONFIG_DIR="$REMOTE_DIR/config"
TMUX_CONFIG_DIR="${HOME_CONFIG_DIR}/tmux"
REMOTE_TMUX_CONFIG_DIR="${REMOTE_DIR}/tmux"
ALIAS="
startEnv(){
  bash ${SCRIPTS_DIR}/start.bash \"\$1\"
}"
function log() {
  local log_level=$1
  shift
  local message="$*"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp [$log_level] $message"
}

function download_script(){
  mkdir -p "$SCRIPTS_DIR"
  cd  "$SCRIPTS_DIR" || exit
  wget -q "$REMOTE_SCRIPTS_DIR/start.bash"
  mkdir -p "$SCRIPTS_DIR/python"
  cd "$SCRIPTS_DIR/python" || exit
  log "INFO" "Downloading startEnv..."
  wget -q "$REMOTE_SCRIPTS_DIR/python/startEnv.py"
  wget -q "$REMOTE_SCRIPTS_DIR/python/requirements.txt"
}


function prompt_user_and_execute() {
  local question=$1
  local command=$2
  read -r -p "$question [Y/n] " response
  case $response in
    [yY][eE][sS]|[yY])
      eval "$command"
      ;;
    *)
      exit 0
      ;;
  esac
}

function install(){
  local package=$1
  if ! (command -v "$package" &> /dev/null) then
    log "INFO" "Installing $1..."
    sudo apt-get --yes install "$1" > /dev/null
  else :
    log "INFO" "$1 already installed"
  fi
}

function install_dependencies(){
  log "INFO" "Installing dependencies..."
  for dep in "${DEPENDENCIES[@]}"; do
    install "$dep"
  done
}

#TODO: add tmux config 
function create_tmux_config(){
  log "INFO" "Creating tmux config..."
  mkdir -p "$TMUX_CONFIG_DIR"
  cd "$TMUX_CONFIG_DIR" || exit
  wget -q "$REMOTE_TMUX_CONFIG_DIR/tmux.conf"
  #install tpm
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

prompt_user_and_execute "Do you want to install dependencies?" install_dependencies
log "INFO" "Starting setup..."


if [ ! -f "${SCRIPTS_DIR}/startEnv.py" ]; then
  prompt_user_and_execute "Do you want to download startEnv.py?" download_script
fi

if [ ! -f "${CONFIG_DIR}/config.json" ]; then
  mkdir -p "$CONFIG_DIR"
  cd "$CONFIG_DIR" || exit
  wget -q "$REMOTE_CONFIG_DIR/config.json"
fi

if ! grep -q "startEnv()" "$HOME/.bash_aliases"; then
  echo "$ALIAS" >> "$HOME"/.bash_aliases
fi

prompt_user_and_execute "Do you want startEnv to create it's own tmux config? (it will be placed in a separate folder and will not interfere with your config)" create_tmux_config


log "INFO" "startEnv installed successfully!"
