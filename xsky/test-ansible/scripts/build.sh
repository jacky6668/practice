#!/bin/bash

#./scripts/ansible-playbook cluster-bootstrap.yml "$@"
./scripts/ansible-playbook cluster-build.yml --extra-vars "${extra_vars}" "$@"
