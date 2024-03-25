#!/bin/bash
# shellcheck source=/dev/null

SCRIPTS_DIR="scripts"
# create and activate the venv


if [ ! -d "${SCRIPTS_DIR}"/python/venv ]; then
    python3 -m venv "$SCRIPTS_DIR/python/venv"
    . "${SCRIPTS_DIR}"/python/venv/bin/activate

    pip install -r "scripts/python/requirements.txt"
    eval"$(register-python-argcomplete ~/.config/scripts/python/startEnv.py)"
else
    . "${SCRIPTS_DIR}"/python/venv/bin/activate
fi

# install requirements

# start the script
python3 "${SCRIPTS_DIR}"/python/startEnv.py "$@"