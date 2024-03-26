#!/bin/bash
# shellcheck source=/dev/null

STARTENV_DIR="$HOME/.config/startEnv"
SCRIPTS_DIR="$STARTENV_DIR/scripts"

function prompt_user_and_execute(){
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


if [ "$1" == "--uninstall" ] || [ "$1" == "-u" ]; then
    prompt_user_and_execute "Do you want to delete the scripts?" "rm -rf $SCRIPTS_DIR" 
    prompt_user_and_execute "Do you want to delete your config files?" "rm -rf $HOME/.config/startEnv"
    prompt_user_and_execute "Do you want to delete the alias from .bash_aliases?" "sed -i '/^startEnv()/d' $HOME/.bash_aliases"
    exit 0
fi

# create and activate the venv
if [ ! -d "${SCRIPTS_DIR}"/python/venv ]; then
    python3 -m venv "$SCRIPTS_DIR/python/venv"
    . "${SCRIPTS_DIR}"/python/venv/bin/activate
    pip install -r "${SCRIPTS_DIR}/python/requirements.txt"
else
    . "${SCRIPTS_DIR}"/python/venv/bin/activate
fi

# start the script
python3 "${SCRIPTS_DIR}"/python/startEnv.py "$@"