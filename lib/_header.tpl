#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM <% $SRC_FILE_PATH %>
# DO NOT EDIT IT
#####################################

CURRENT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)
ROOT_DIR="$(cd "${CURRENT_DIR}/<% ${BIN_FILE_RELATIVE2ROOT_DIR} %>" && pwd -P)"
# shellcheck disable=SC2034
LIB_DIR="<%% echo '${ROOT_DIR}/lib' %>"

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

# FUNCTIONS
