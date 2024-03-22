#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import os
import sys

argument = sys.argv[1] if len(sys.argv) > 1 else None
if argument is None:
    print("Please provide an environment name")
    sys.exit(1)

def log(message, level='info'):
    """
    Log a message with the specified level.

    Parameters:
    - message (str): The message to log.
    - level (str): The level of the log message (default: 'info').

    Returns:
    - None
    """
    valid_levels = ['debug', 'info', 'warning', 'error', 'critical']
    if level not in valid_levels:
        level = 'info'
    print('[{}] {}'.format(level.upper(), message))

def splitPanes(number):
    print(f"Splitting {number} panes")
    for i in range(number):
        if i > 0:
            os.system(f'tmux split-window -h')
    
    os.system(f'tmux select-layout tiled')

def sendCommands(windows):
    for windowNumber, window in enumerate(windows):
        pane_name=window['name']
        pane_style=window['style']
        os.system(f'tmux select-pane -t {window["name"]} -T {pane_name}')
        for commandNumber, command in enumerate(window['cmd']):
            log(f"Sending command '{command}' to pane '{window['name']}'")
            os.system(f'tmux send-keys -t {windowNumber} "{command}" C-m')

def setTitleScreen(titleOptions):
    log(f"Setting title screen to '{titleOptions}'")
    os.system(f'tmux split-window -v -f -b -p 25')
    os.system(f'tmux select-pane -t 0 -T {titleOptions["title"]}')
    os.system(f'tmux send-keys -t 0 "figlet {titleOptions["title"]} -t -c" C-m')
    #os.system(f'tmux send-keys -t 0 "figlet -d ~/figlet/figlet-fonts-master -f 3d  {titleOptions["title"]} -t -c" C-m')

def readConfig():
    log('Reading config file')
    if not os.path.exists(os.path.expanduser('~/.config/startEnv/config/config.json')):
        log('config folder does not exist, creating it')
        os.makedirs(os.path.expanduser('~/.config/startEnv/config'), exist_ok=True)
    with open(os.path.expanduser('~/.config/startEnv/config/config.json'), 'r') as config_file:
        config = json.load(config_file)
    return config
    
config_data = readConfig()

if not config_data or not 'environments' in config_data:
    log('config file is empty')
    config_data = {}

for environment in config_data['environments']:
    if environment['environmentName'] == argument:
        # Check if tmux has session named environmentName
        if not os.system(f'tmux has-session -t {environment["environmentName"]} 2>/dev/null') == 0:
            log(f"Session '{environment['environmentName']}' does not exist, creating it")
            # Create a new tmux session
            os.system(f'tmux new-session -d -s {environment["environmentName"]}')
            splitPanes(len(environment['windows']))
            # Send commands
            sendCommands(environment['windows'])
            #Set title pane
            if 'titleScreen' in environment['options']:
                setTitleScreen(environment['options']['titleScreen'])
        log(f"Attaching to session '{environment['environmentName']}'")
        os.system(f'tmux attach -t {environment["environmentName"]}')