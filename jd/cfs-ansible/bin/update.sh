#!/bin/bash

./bin/ansible-playbook cluster-update.yml --extra-vars "${extra_vars}" "$@"
