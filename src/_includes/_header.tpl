#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM <% $REPOSITORY_URL %>/tree/master/<% $SRC_FILE_PATH %>
# DO NOT EDIT IT
#####################################

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}
REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC2034
CURRENT_DIR="$(cd "$(readlink -e "${REAL_SCRIPT_FILE%/*}")" && pwd -P)"
# shellcheck disable=SC2034
COMMAND_BIN_DIR="${CURRENT_DIR}"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_colors.sh"
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_commonHeader.sh"
