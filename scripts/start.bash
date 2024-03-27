#!/bin/bash
# shellcheck source=/dev/null
source "${HOME}"/.config/startEnv/consts.bash

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
function uninstall(){
    prompt_user_and_execute "Do you want to delete the scripts?" "rm -rf $SCRIPTS_DIR" 
    prompt_user_and_execute "Do you want to delete your config files?" "rm -rf $HOME/.config/startEnv"
    prompt_user_and_execute "Do you want to delete the alias from .bash_aliases?" "sed -i '/^startEnv()/d' $HOME/.bash_aliases"
    source "$HOME"/.bashrc
    exit 0
}

function update(){
    function get_remote_version(){
        local remote_version
        remote_version=$(wget -qO- "$REMOTE_DIR"/consts.bash | grep -m1 "VERSION=" | cut -d "=" -f2)
    }

    local installed_version="$VERSION"
    local remote_version
    remote_version=$(get_remote_version)
    if [ "$installed_version" != "$remote_version" ]; then
        prompt_user_and_execute "Do you want to update the scripts?" "rm -rf $SCRIPTS_DIR && wget -qO- $REMOTE_DIR | bash"
    fi

}
function main(){
    if [ "$1" == "--uninstall" ]; then
        uninstall
    fi
    if [ "$1" == "--update" ]; then    
        update
    fi

    check_dependencies

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

}

main "$@"