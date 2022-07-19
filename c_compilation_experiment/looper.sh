#!/usr/bin/env bash

set -e
# set -x

#
# usage: $0 <iterations> <command>
#

ITERATIONS=$1
COMMAND=$2

for i in $(seq 1 $ITERATIONS); do
  # echo $i
  ${COMMAND} >/dev/null 2>&1
done
