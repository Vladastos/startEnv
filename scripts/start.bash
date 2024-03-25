#!/bin/bash
# shellcheck source=/dev/null

SCRIPTS_DIR="$HOME/.config/startEnv/scripts"
# create and activate the venv


if [ ! -d "${SCRIPTS_DIR}"/python/venv ]; then
    python3 -m venv "$SCRIPTS_DIR/python/venv"
    . "${SCRIPTS_DIR}"/python/venv/bin/activate
    pip install -r "${SCRIPTS_DIR}/python/requirements.txt"
fi

# start the script
. "${SCRIPTS_DIR}"/python/venv/bin/activate
python3 "${SCRIPTS_DIR}"/python/startEnv.py "$@"