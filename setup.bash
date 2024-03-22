#!/bin/bash

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

# Usage examples:
# log "INFO" "This is an informational message"
# log "ERROR" "This is an error message"
# log "DEBUG" "This is a debug message"

log "INFO" "Installing startEnv..."
#check if startEnv is already installed


#if not clone the repo 
if [ ! -d "$USER"/.config/startEnv/scripts ] ; then
    log "INFO" "Creating directory..."
    mkdir -p "$USER"/.config/startEnv/scripts
    cd "$USER"/.config/startEnv/scripts || exit
    log "INFO" "Downloading startEnv..."
    wget -q https://raw.githubusercontent.com/Vladastos/startEnv/main/scripts/startEnv.py
    chmod +x "$USER"/.config/startEnv/scripts/startEnv.py
else :
    log "INFO" "startEnv already installed"
fi

#check if config file is present, if not clone from repo
log "INFO" "Checking if config file is present..."
if [ ! -f "$USER".config/startEnv/config.json ]; then
    log "INFO" "Creating config file..."
    mkdir -p "$USER"/.config/startEnv/config
    cd "$USER"/.config/startEnv/config || exit
    wget -q https://raw.githubusercontent.com/Vladastos/startEnv/main/config/config.json
else :
    log "INFO" "Config file already present"
fi


#check if alias is present in .bash_aliases, if not create
log "INFO" "Checking if alias is present in .bash_aliases..."
if ! grep -q "startEnv()" "$USER"/.bash_aliases; then
    log "INFO" "Creating alias..."
    echo "alias startEnv(){python3 $USER/.config/startEnv/scripts/startEnv.py}" >> ~/.bash_aliases
fi


#install the dependencies

##check if tmux is installed, if not install
log "INFO" "Checking if tmux is installed..."
if ! (command -v tmux &> /dev/null) then
    prompt_user_and_execute "Do you want to install tmux?" "sudo apt install tmux"
    log "INFO" "tmux installed"
    else :
        log "INFO" "Tmux already installed"

fi

##check if figlet is installed, if not install
log "INFO" "Checking if figlet is installed..."
if ! (command -v figlet &> /dev/null) then
    prompt_user_and_execute "Do you want to install figlet?" "sudo apt install figlet"
    log "INFO" "figlet installed"
    else :
        log "INFO" "figlet already installed"

fi

log "INFO" "startEnv installed successfully!"