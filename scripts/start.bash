#!/bin/bash
# shellcheck source=/dev/null
. /home/vlad/startEnv/scripts/consts.bash

function log(){
    local log_level=$1
    shift
    local message="$*"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp [$log_level] $message"
    if [ "$log_level" == "ERROR" ] || [ "$log_level" == "CRITICAL" ]; then
        exit 1
    fi
}
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

function check_dependencies() {

    # shellcheck disable=SC2154
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            log "ERROR" "$file not found"
        fi
    done

    # shellcheck disable=SC2154
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log "ERROR" "$dep not found"
        fi
    done
}
if [ "$1" == "--uninstall" ]; then
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

check_dependencies

# start the script
python3 "${SCRIPTS_DIR}"/python/startEnv.py "$@"