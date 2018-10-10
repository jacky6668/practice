#!/bin/bash

#./scripts/ansible-playbook cluster-bootstrap.yml "$@"
./scripts/ansible-playbook cluster-install.yml --extra-vars "${extra_vars}" "$@"
