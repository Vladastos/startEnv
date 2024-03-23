#!/bin/bash

DEPENDENCIES=("python3" "git" "wget" "tmux" "figlet")

HOME_CONFIG_DIR="/home/$(logname)/.config/startEnv"
SCRIPTS_DIR="${HOME_CONFIG_DIR}/scripts"
CONFIG_DIR="${HOME_CONFIG_DIR}/config"
ALIAS="
startEnv(){
  python3 ${SCRIPTS_DIR}/startEnv.py \"\$1\"
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
  cd "$SCRIPTS_DIR" || exit
  log "INFO" "Downloading startEnv..."
  wget -q https://raw.githubusercontent.com/Vladastos/startEnv/main/scripts/startEnv.py
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

prompt_user_and_execute "Do you want to install dependencies?" install_dependencies
log "INFO" "Starting setup..."


if [ ! -f "${SCRIPTS_DIR}/startEnv.py" ]; then
  prompt_user_and_execute "Do you want to download startEnv.py?" download_script
fi

if [ ! -f "${CONFIG_DIR}/config.json" ]; then
  mkdir -p "$CONFIG_DIR"
  cd "$CONFIG_DIR" || exit
  wget -q https://raw.githubusercontent.com/Vladastos/startEnv/main/config/config.json
fi

if ! grep -q "startEnv()" "$HOME/.bash_aliases"; then
  echo "$ALIAS" >> "$HOME"/.bash_aliases
fi

log "INFO" "startEnv installed successfully!"
