#!/bin/bash

if [[ $# -gt 0 ]]; then
	args="-e \"version=$1\""
    shift
else
    echo "Usage: ./scripts/download.sh 2.3.0 -i inventories/xxx.host"
    exit 1
fi
eval "./scripts/ansible-playbook sds-download.yml $args" "$@"
