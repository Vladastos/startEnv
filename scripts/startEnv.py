#!/usr/bin/env python3
import json
import os
import sys

argument = sys.argv[1] if len(sys.argv) > 1 else None
if argument is None or argument == "" or argument == " ":
    print("Please provide an environment name")
    sys.exit(1)
if argument == "-v":
    print("Version 0.0.2")
    sys.exit(0)

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

def sendCommands(panes):
    for paneNumber, pane in enumerate(panes):
        pane_name=pane['name']
        pane_style=pane['style']
        os.system(f'tmux select-pane -T "{pane_name}" -t {paneNumber} ')
        print(f'tmux select-pane -T "{pane_name}" -t {paneNumber} ')
        for commandNumber, command in enumerate(pane['cmd']):
            if command == '':
                continue
            os.system(f'tmux send-keys -t {paneNumber} "{command}" C-m')

def setTitleScreen(titleOptions):
    if 'title' not in titleOptions or titleOptions['title'] == '':
        titleOptions['title'] = argument
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

def getEnvironment(config, environmentName):
    for environment in config['environments']:
        if environment['environmentName'] == environmentName:
            return environment
    return None
config_data = readConfig()
environment = getEnvironment(config_data, argument)

if not config_data or not 'environments' in config_data:
    log('config file is empty')
    sys.exit(1)

if not environment:
    log('No environment with given name found in config file')
    sys.exit(1)

# Check if tmux has session named environmentName
if not os.system(f'tmux has-session -t {environment["environmentName"]} 2>/dev/null') == 0:
    log(f"Session '{environment['environmentName']}' does not exist, creating it")
    # Create a new tmux session
    os.system(f'tmux -f ~/.config/startEnv/config/tmux.conf new-session -d -s {environment["environmentName"]}')
    splitPanes(len(environment['panes']))
    # Send commands
    sendCommands(environment['panes'])
    #Set title pane
    if 'titleScreen' in environment['options']:
        setTitleScreen(environment['options']['titleScreen'])
log(f"Attaching to session '{environment['environmentName']}'")
os.system(f'tmux attach -t {environment["environmentName"]}')