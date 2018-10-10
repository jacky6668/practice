#!/bin/bash

extra_vars=""
if [[ $1 == "all" ]]; then
    cleanup_docker=1
    extra_vars="cleanup_docker=true"
    shift
fi

./scripts/ansible-playbook cluster-clear.yml --extra-vars "${extra_vars}" "$@" 
