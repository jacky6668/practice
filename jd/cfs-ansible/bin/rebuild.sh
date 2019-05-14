#!/bin/bash

./bin/ansible-playbook cluster-rebuild.yml --extra-vars "${extra_vars}" "$@"
#./bin/ansible-playbook xuanyun.yml --extra-vars "${extra_vars}" "$@"
