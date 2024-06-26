export VERSION="0.2.1"
export DEPENDENCIES=(tmux python3 pip git wget figlet)

export STARTENV_DIR="$HOME/.config/startEnv"
export SCRIPTS_DIR="$STARTENV_DIR/scripts"

export CONFIG_DIR="${STARTENV_DIR}/config"
export CONFIG_FILE="$STARTENV_DIR/config/config.json"
export START_ENV_PY="$SCRIPTS_DIR/python/startEnv.py"
export VENV_DIR="$SCRIPTS_DIR/python/venv"
export REQUIREMENTS_TXT="$SCRIPTS_DIR/python/requirements.txt"
export TMUX_CONFIG_DIR="${STARTENV_DIR}/tmux"
export TMUX_CONF="$STARTENV_DIR/tmux/tmux.conf"
export CONFIG_SCHEMA="$CONFIG_DIR/schema.json"

export FONTS_DIR="$STARTENV_DIR/figlet-fonts"
declare -A FONTS=(
    [3d]="3d.flf"
    [ansi_shadow]="ANSI_Shadow.flf"
)
export FONTS

export REMOTE_DIR="https://raw.githubusercontent.com/Vladastos/startEnv/main"
export REMOTE_SCRIPTS_DIR="${REMOTE_DIR}/scripts"
export REMOTE_CONFIG_DIR="$REMOTE_DIR/config"
export REMOTE_TMUX_CONFIG_DIR="${REMOTE_DIR}/tmux"
export REMOTE_FONTS_DIR="${REMOTE_DIR}/figlet-fonts"