#  Setup


To install startEnv, run the following command:

`bash <(wget -qO- https://raw.githubusercontent.com/Vladastos/startEnv/main/setup.bash) && source ~/.bashrc`

It will download the latest version of startEnv to your `~/.config/startEnv` directory.

It will also create a `config.json` file in your `~/.config/startEnv/config` directory.


# Usage


To use startEnv, run the following command:
`startEnv [environment]`
Where [environment] is the name of the environment you want to start.

To list all available environments, run the following command:
`startEnv --list` or `startEnv -l`

Run `startEnv --help` or `startEnv -h` for more information.

Run `startEnv --kill` or `startEnv -k` to kill a session started by strtEnv.

Run `startEnv --uninstall` to uninstall startEnv.

Run `startEnv --update` to see the version of startEnv.

Remember to configure your environment before starting it.


# Tmux config


By default, startEnv will not use your tmux config, it will instad download and use it's own config.

To use startEnv with your tmux config, set the `disable_custom_tmux_config` option to `true` in your `config/config.json` file.


# Configuration


On installation, it will create `config/config.json` in your `.config/startEnv` directory.

You can configure environments in `config/config.json`.

startEnv comes with an empty `config/config.json` file that you can edit.

the `config/config.json` file is structured as follows:


```json
{
    "environments": [
        {
            "environmentName": "string",
            "panes": [
                {
                    "name": "string",
                    "cmd": [
                        "string"
                    ],
                    "pane_style": "string" //(not yet implemented)
                }
            ],
            "environment_options": {
                "titleScreen": { //Title pane, if not set, it will not be created
                    "title":"string",
                    "style":"" //(not yet implemented)
                } 
            }
        }
    ],
    "options":{
        "disable_custom_tmux_config": false //(not yet implemented)
    }
}
```
