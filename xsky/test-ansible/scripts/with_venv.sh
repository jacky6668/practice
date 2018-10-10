#!/bin/bash
SCRIPTS_PATH=${SCRIPTS_PATH:-$(dirname $0)/../}
VENV_PATH=${VENV_PATH:-${SCRIPTS_PATH}/.tox}
VENV_DIR=${VENV_DIR:-venv}
VENV=${VENV:-${VENV_PATH}/${VENV_DIR}}
source ${VENV}/bin/activate && "$@"
