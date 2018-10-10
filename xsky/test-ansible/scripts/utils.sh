#!/bin/bash

ansible_docker() {
    image=$(get_ansible_image)
    if [[ -z $image ]]; then
        echo "ansible image not found"
        exit 1
    fi
    docker run --net host --rm -t \
        -v $(pwd):/root/ansible \
        -v ~/.ssh:/root/.ssh \
        $image "$@"
}

get_docker_image_version () {
    cmd=$(echo "\$1 ~ \"${1}\" {print \$2}")
    docker images ${1} | tail -1 | awk "${cmd}"
}

get_ansible_image() {
    version=$(get_docker_image_version sds/ansible)
    if [[ -n $version ]]; then
        echo sds/ansible:${version}
        return
    fi
    version=$(get_docker_image_version ansible)
    if [[ -n $version ]]; then
        echo ansible:${version}
        return
    fi
    return
}

check_docker() {
    local use_docker=0
    which docker &> /dev/null
    code=$?
    if [[ ${code} -eq 0 ]]; then
        image=$(get_ansible_image)
        if [[ -n ${image} ]]; then
            use_docker=1
        fi
    fi
    echo ${use_docker}
}

run() {
    ret=$(check_docker)
    if [[ ${ret} -eq 1 ]]; then
        ansible_docker "$@"
    else
        ./scripts/with_venv.sh "$@"
    fi
}

ansible_playbook() {
    run ansible-playbook "$@"
}

ansible() {
    run ansible "$@"
}
