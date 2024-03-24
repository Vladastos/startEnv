# Version 0.1.0 - Roadmap

Incoming features and development plans.

## Custom tmux config (0.0.2) 
Add a custom tmux config file to the repository. This file will be downloaded into the startEnv folder, thus not interfering with the default config.
It will be loaded at the start of every tmux session started by startEnv.
The custom tmux config will be enabled by default and can be disabled with the `disable_custom_tmux_config` flag in the config file.
Possibly also add an option to download the config file to the user's tmux config directory.

## Venv for startEnv(0.0.3)
Add commands to create and activate a virtual environment for startEnv on installation.


### Use argparse instead of manual parsing 


### Move all directory paths to scripts/.env



## Healthcheck for startEnv
Add an intermediary script that runs the healthcheck command before starting the tmux session. This can be used to check if the environment is ready to start.

## Update flag for startEnv
Add an update flag for startEnv that can be used to update the environment.

## Delete flag for startEnv
Add a delete flag for startEnv that can be used to delete the environment.

## Autocomplete for environments
Probably going to use argcomplete for this
