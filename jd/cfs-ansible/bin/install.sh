#!/bin/bash

./bin/ansible-playbook cluster-install.yml --extra-vars "${extra_vars}" "$@"
