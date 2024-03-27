export DEPENDENCIES=(tmux python3 pip git wget figlet)

export STARTENV_DIR="$HOME/.config/startEnv"
export SCRIPTS_DIR="$STARTENV_DIR/scripts"

export CONFIG_FILE="$STARTENV_DIR/config/config.json"
export START_ENV_PY="$SCRIPTS_DIR/python/startEnv.py"
export VENV_DIR="$SCRIPTS_DIR/python/venv"
export REQUIREMENTS_TXT="$SCRIPTS_DIR/python/requirements.txt"
export TMUX_CONF="$STARTENV_DIR/tmux/tmux.conf"

export FILES=("$CONFIG_FILE" "$START_ENV_PY" "$REQUIREMENTS_TXT" "$TMUX_CONF")
