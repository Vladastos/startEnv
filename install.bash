#!/bin/bash

function log() {
  local log_level=$1
  shift
  local message="$*"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp [$log_level] $message"
}

# Usage examples:
# log "INFO" "This is an informational message"
# log "ERROR" "This is an error message"
# log "DEBUG" "This is a debug message"

log "INFO" "Installing startEnv..."
#check if startEnv is already installed
if [ -d ~/.config/startEnv ] ; then
    echo "startEnv already installed"
    exit
fi
#if not clone the repo 
if [ ! -d ~/.config/startEnv ] ; then
    log "INFO" "Creating directory..."
    mkdir -p ~/.config/startEnv/scripts
    cd ~/.config/startEnv/scripts || exit
    log "INFO" "Downloading startEnv..."
    wget https://raw.githubusercontent.com/Vladastos/startEnv/main/scripts/startEnv.py
    chmod +x ~/.config/startEnv/startEnv.py
else :
    echo "startEnv already installed"
fi

#check if config file is present, if not clone from repo
log "INFO" "Checking if config file is present..."
if [ ! -f .config/startEnv/config.json ]; then
    log "INFO" "Creating config file..."
    cd ~/.config/startEnv || exit
    mkdir -p ~/.config/startEnv/config
    wget https://raw.githubusercontent.com/Vladastos/startEnv/main/config/config.json
else :
    log "INFO" "Config file already present"
    echo "Config file found"
fi


#check if alias is present in .bash_aliases, if not create
log "INFO" "Checking if alias is present in .bash_aliases..."
if ! grep -q "startEnv()" ~/.bash_aliases; then
    log "INFO" "Creating alias..."
    echo "alias startEnv(){python3 ~/.config/startEnv/scripts/startEnv.py}" >> ~/.bash_aliases
fi


#install the dependencies

##check if tmux is installed, if not install
log "INFO" "Checking if tmux is installed..."
if ! (command -v tmux &> /dev/null) then
    log "INFO" "Tmux not installed, installing..."
    echo "tmux not installed, installing..."
    sudo apt install tmux

fi

##check if figlet is installed, if not install
log "INFO" "Checking if figlet is installed..."
if ! (command -v figlet &> /dev/null) then
    echo "figlet not installed, installing..."
    sudo apt install figlet

fi
log "INFO" "startEnv installed successfully!"