#!/bin/bash

echo "Installing startEnv..."
#check if startEnv is already installed
if [ -d ~/.config/startEnv ] ; then
    echo "startEnv already installed"
    exit
fi
#if not clone the repo 
if [ ! -d ~/.config/startEnv ] ; then
    echo "cloning startEnv repo..."
    git clone https://github.com/Vladastos/startEnv/scripts/startEnv.py ~/.config/startEnv
    chmod +x ~/.config/startEnv/startEnv.py
else :
    echo "startEnv already installed"
fi

#check if config file is present, if not clone from repo
if [ ! -f .config/startEnv/config.json ]; then
    echo "Config file not found, cloning from repo..."
    git clone https://github.com/Vladastos/startEnv/config/config.json ~/.config/startEnv 
else :
    echo "Config file found"
fi


#check if alias is present in .bash_aliases, if not create
if ! grep -q "startEnv()" ~/.bash_aliases; then
    echo "alias startEnv='~/.config/startEnv/startEnv.py'" >> ~/.bash_aliases
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
