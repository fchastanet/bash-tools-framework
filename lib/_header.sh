#!/usr/bin/env bash

LIB_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd)
# shellcheck disable=SC2034
ROOT_DIR="$(cd "${LIB_DIR}/.." && pwd)"

# shellcheck disable=SC2034
((failures = 0)) || true

shopt -s expand_aliases
set -o pipefail
set -o errexit
# a log is generated when a command fails
set -o errtrace
# use nullglob so that (file*.php) will return an empty array if no file matches the wildcard
shopt -s nullglob
export TERM=xterm-256color

#avoid interactive install
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
