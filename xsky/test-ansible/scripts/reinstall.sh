#!/bin/bash

version=$1
shift
./scripts/cleanup.sh $@
./scripts/build.sh $version $@
./scripts/install.sh $@
