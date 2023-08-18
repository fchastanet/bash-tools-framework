#!/usr/bin/env bash
# shellcheck disable=SC2288
# shellcheck disable=SC2034

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

SCRIPT_NAME=${0##*/}
REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
CURRENT_DIR="$(cd "$(readlink -e "${REAL_SCRIPT_FILE%/*}")" && pwd -P)"
COMMAND_BIN_DIR="${CURRENT_DIR}"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_colors.sh"
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_commonHeader.sh"

.DELIMS stmt="%"
%
  if [[ -n "${RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR}" ]]; then
    % FRAMEWORK_ROOT_DIR="$(cd "${CURRENT_DIR}/${META_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR}" && pwd -P)"
    % FRAMEWORK_SRC_DIR="${FRAMEWORK_ROOT_DIR}/src"
    % FRAMEWORK_BIN_DIR="${FRAMEWORK_ROOT_DIR}/bin"
    % FRAMEWORK_VENDOR_DIR="${FRAMEWORK_ROOT_DIR}/vendor"
    % FRAMEWORK_VENDOR_BIN_DIR="${FRAMEWORK_ROOT_DIR}/vendor/bin"
  fi
%
.RESET-DELIMS
