#!/bin/bash

#check if startEnv is already installed
if (command -v startEnv) then
    echo "startEnv already installed"
    exit
fi
#if not clone the repo 
if [ ! -d startEnv ] ; then
    echo "cloning startEnv repo..."
    git clone https://github.com/Vladastos/startEnv/scripts/startEnv.py ~/.config/startEnv
    chmod +x ~/.config/startEnv/startEnv.py
fi

#check if config file is present, if not clone from repo
if [ ! -f .config/startEnv/config.json ]; then
    echo "Config file not found, cloning from repo..."
    git clone https://github.com/Vladastos/startEnv/config/config.json ~/.config/startEnv 
fi


#check if alias is present in .bash_aliases, if not create
if ! grep -q "startEnv" ~/.bash_aliases; then
    echo 'startEnv() {
    python3 ~/.config/startEnv/startEnv.py "$1"
}' >> ~/.bash_aliases
fi


#install the dependencies

##check if tmux is installed, if not install
if ! (command -v tmux &> /dev/null) then
    echo "tmux not installed, installing..."
    sudo apt install tmux

fi

##check if figlet is installed, if not install
if ! (command -v figlet &> /dev/null) then
    echo "figlet not installed, installing..."
    sudo apt install figlet

fi
