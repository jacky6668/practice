#!/bin/bash

./bin/ansible-playbook cluster-rebuild.yml --extra-vars "${extra_vars}" "$@"
