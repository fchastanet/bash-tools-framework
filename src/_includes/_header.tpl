#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM <% $REPOSITORY_URL %>/tree/master/<% $SRC_FILE_PATH %>
# DO NOT EDIT IT
#####################################

# DEPRECATED src/_includes/_header.tpl use src/_includes/_headerNoRootDir.tpl instead

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}
REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC2034
CURRENT_DIR="$(cd "$(readlink -e "${REAL_SCRIPT_FILE%/*}")" && pwd -P)"
BIN_DIR="${CURRENT_DIR}"
ROOT_DIR="<%% echo ${ROOT_DIR_RELATIVE_TO_BIN_DIR} %>"
# shellcheck disable=SC2034
SRC_DIR="<%% echo '${ROOT_DIR}/src' %>"
# shellcheck disable=SC2034
VENDOR_DIR="<%% echo '${ROOT_DIR}/vendor' %>"
# shellcheck disable=SC2034
VENDOR_BIN_DIR="<%% echo '${ROOT_DIR}/vendor/bin' %>"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_commonHeader.sh"

# FUNCTIONS

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_colors.sh"

Env::pathPrepend "${VENDOR_BIN_DIR}"
Env::pathPrepend "${BIN_DIR}"
