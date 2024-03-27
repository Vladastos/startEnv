#!/usr/bin/env python3
import json
import os
import sys
import argparse

def log(message, level='info'):
    valid_levels = ['debug', 'info', 'warning', 'error', 'critical']
    if level not in valid_levels:
        level = 'info'
    print('[{}] {}'.format(level.upper(), message))

def readConfig():
    if not os.path.exists(os.environ['CONFIG_FILE']):
        return None
    with open(os.environ['CONFIG_FILE'], 'r') as config_file:
        config = json.load(config_file)
    return config

def getEnvironmentList(config):
    environments = []
    for environment in config['environments']:
        environments.append(environment['environmentName'])
    return environments

def getEnvironment(config, environmentName):
    for environment in config['environments']:
        if environment['environmentName'] == environmentName:
            return environment
    return None

config_data = readConfig()

class KillAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        print(f'tmux -L startEnv kill-session -t {values[0]}')
        os.system(f'tmux -L startEnv kill-session -t {values[0]}')
        sys.exit(0)

class ListAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        environments = getEnvironmentList(config_data)
        if len(environments) == 0:
            log('No environments found in config file')
            sys.exit(0)
        log(f'Environments found: {len(environments)}')
        for environment in environments:
            print(environment)
        sys.exit(0)

class MainAction(argparse.Action):
    def tmuxSplitPanes (number):
        print(f"Splitting {number} panes")
        for i in range(number):
            if i > 0:
                os.system(f'tmux -L startEnv split-window -h')
        os.system(f'tmux -L startEnv select-layout tiled')

    def tmuxSetTitleScreen(titleOptions, environmentName):
        if 'title' not in titleOptions or titleOptions['title'] == '':
            titleOptions['title'] = environmentName
        os.system(f'tmux -L startEnv split-window -v -f -b -p 25')
        os.system(f'tmux -L startEnv select-pane -t 0 -T {titleOptions["title"]}')
        os.system(f'tmux -L startEnv send-keys -t 0 "figlet {titleOptions["title"]} -t -c" C-m')
        #os.system(f'tmux -L startEnv send-keys -t 0 "figlet -d ~/figlet/figlet-fonts-master -f 3d  {titleOptions["title"]} -t -c" C-m')

    def tmuxSendCommands(windows):
        for windowNumber, window in enumerate(windows):
            pane_name=window['name']
            pane_style=window['pane_style']
            os.system(f'tmux -L startEnv select-pane -T "{pane_name}" -t {windowNumber} ')
            for commandNumber, command in enumerate(window['cmd']):
                if command == '':
                    continue
                os.system(f'tmux -L startEnv send-keys -t {windowNumber} "{command}" C-m')

    def __call__(self, parser, namespace, values, option_string=None):

        environment = getEnvironment(config_data, values)
        # Check if config file is empty
        if not config_data or not 'environments' in config_data:
            log('config file is empty')
            sys.exit(1)
        # Check if environment exists
        if not environment:
            log('No environment with given name found in config file')
            sys.exit(1)

        # Check if tmux has session named environmentName
        if not os.system(f'tmux -L startEnv has-session -t {environment["environmentName"]} 2>/dev/null') == 0:
            log(f"Creating session '{environment['environmentName']}'")
            # Create a new tmux session
            os.system(f'tmux -f ~/.config/startEnv/tmux/tmux.conf -L startEnv new-session -d -s {environment["environmentName"]}')
            MainAction.tmuxSplitPanes(len(environment['panes']))
            # Send commands
            MainAction.tmuxSendCommands(environment['panes'])
            #Set title pane
            if 'titleScreen' in environment['environment_options']:
                MainAction.tmuxSetTitleScreen(environment['environment_options']['titleScreen'], environment['environmentName'])
        log(f"Attaching to session '{environment['environmentName']}'")
        os.system(f'tmux -L startEnv attach -t {environment["environmentName"]}')

parser = argparse.ArgumentParser( prog = 'startEnv', description='Start environments with tmux', epilog='For more information, visit https://github.com/Vladastos/startEnv')
parser.add_argument('environment', action=MainAction, type=str, help='Name of the environment')
parser.add_argument('-v', '--version', action='version', version='%(prog)s 0.1.0')
parser.add_argument('--uninstall', action='store_true', help='Uninstall startEnv')
parser.add_argument('-k', '--kill', action=KillAction, nargs=1, metavar='session', help='Kill a session started by startEnv')
parser.add_argument('-l', '--list', action=ListAction, nargs=0, default=False, help='List environments')
args = parser.parse_args()

