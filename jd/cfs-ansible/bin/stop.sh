#!/bin/bash

./bin/ansible-playbook cluster-stop.yml --extra-vars "${extra_vars}" "$@"
