#!/bin/bash

function log() {
  local log_level=$1
  shift
  local message="$*"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp [$log_level] $message"
}

function download_script(){
  mkdir -p "/home/$(logname)"/.config/startEnv/scripts
  cd "/home/$(logname)"/.config/startEnv/scripts || exit
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

function install_tmux(){
  log "INFO" "Installing tmux..."
  sudo apt-get --yes install tmux > /dev/null
}

function install_figlet(){
  log "INFO" "Installing figlet..."
  sudo apt-get --yes install figlet > /dev/null 
}

# Usage examples:
# log "INFO" "This is an informational message"
# log "ERROR" "This is an error message"
# log "DEBUG" "This is a debug message"

log "INFO" "Installing startEnv..."


#if not clone the repo 
if [ ! -f /home/"$(logname)"/.config/startEnv/scripts/startEnv.py  ] ; then
    log "INFO" "startEnv not installed"
    prompt_user_and_execute "Do you want to clone the repo?" download_script
else :
    log "INFO" "startEnv.py already installed"
fi
#check if config file is present, if not clone from repo

log "INFO" "Checking if config file is present..."
if [ ! -f /home/"$(logname)"/.config/startEnv/config/config.json ] ; then
    log "INFO" "Creating config file..."
    mkdir -p "/home/$(logname)"/.config/startEnv/config
    cd "/home/$(logname)"/.config/startEnv/config || exit
    wget -q https://raw.githubusercontent.com/Vladastos/startEnv/main/config/config.json
else :
  log "INFO" "Config file already present"
fi

#check if alias is present in .bash_aliases, if not create
log "INFO" "Checking if alias is present in .bash_aliases..."
if ! grep -q "startEnv()" "/home/$(logname)"/.bash_aliases; then
  echo "
  startEnv(){
    python3 /home/$(logname)/.config/startEnv/scripts/startEnv.py \"\$1\"
  }" >> "/home/$(logname)"/.bash_aliases
else :
    log "INFO" "Alias already present"
fi

#install the dependencies

##check if tmux is installed, if not install
log "INFO" "Checking if tmux is installed..."
if ! (command -v tmux &> /dev/null) then
    prompt_user_and_execute "Do you want to install tmux?" install_tmux
    else :
        log "INFO" "Tmux already installed"

fi



##check if figlet is installed, if not install
log "INFO" "Checking if figlet is installed..."
if ! (command -v figlet &> /dev/null) then
    log "INFO" "figlet not installed"
    prompt_user_and_execute "Do you want to install figlet?" install_figlet
else :
    log "INFO" "figlet already installed"
fi

log "INFO" "startEnv installed successfully!"