#!/usr/bin/env bash

set -e
set -x

. ./common.sh

# TODO: check for shc
#   `brew install shc`

shc -f "../$BASH_SCRIPT" -o "$COMPILED_SCRIPT"
rm ../*.x.c
