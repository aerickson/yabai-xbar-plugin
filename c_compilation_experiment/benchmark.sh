#!/usr/bin/env bash

set -e

. ./common.sh

ITERATIONS=100

echo "iterations: ${ITERATIONS}"
echo ""
echo "/// c"
time ./looper.sh ${ITERATIONS} "./${COMPILED_SCRIPT}"
echo ""
echo "/// bash"
time ./looper.sh ${ITERATIONS} "../${BASH_SCRIPT}"