#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <$(echo ${all_products[*]} | tr ' ' '|')> -i inventories/xxx.host"
    cat <<EOF
    Usage:
        $0 DP_Pro -i inventories/xxx.host
        $0 'X-EDP Pro' -i inventories/xxx.host
EOF
    exit 1
fi

args="-e \"product='${1}'\""
shift
eval "./scripts/ansible-playbook cluster-register-license.yml ${args} $@"
