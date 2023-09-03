#!/usr/bin/env bash
###############################################################################
# GENERATED FACADE FROM <% $REPOSITORY_URL %>/tree/master/<% $SRC_FILE_PATH %>
# DO NOT EDIT IT
###############################################################################
# shellcheck disable=SC2288,SC2034
%# FACADE_HEADERS here the headers of original script file will be copied
.INCLUDE "${FACADE_HEADERS_FILE}"
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_mandatoryHeader.sh"
%# BEGIN MANDATORY HEADERS
SCRIPT_NAME=${0##*/}
REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
CURRENT_DIR="$(cd "$(readlink -e "${REAL_SCRIPT_FILE%/*}")" && pwd -P)"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_commonHeader.sh"
%# END MANDATORY HEADERS

# FUNCTIONS

<% ${MAIN_FUNCTION_NAME} %>() {
.DELIMS stmt="%"
%
  if [[ -n "${RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR}" ]]; then
    % FRAMEWORK_ROOT_DIR="$(cd "${CURRENT_DIR}/<% ${RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR} %>" && pwd -P)"
    % FRAMEWORK_SRC_DIR="${FRAMEWORK_ROOT_DIR}/src"
    % FRAMEWORK_BIN_DIR="${FRAMEWORK_ROOT_DIR}/bin"
    % FRAMEWORK_VENDOR_DIR="${FRAMEWORK_ROOT_DIR}/vendor"
    % FRAMEWORK_VENDOR_BIN_DIR="${FRAMEWORK_ROOT_DIR}/vendor/bin"
  fi
%
.RESET-DELIMS
# REQUIRES

%# FACADE_CONTENT here the content script part of the facade will be copied as is
.INCLUDE "${FACADE_CONTENT_FILE}"

%# GENERATED_FACADE_CHOICE_SCRIPT
.INCLUDE "${FACADE_CHOICE_SCRIPT_FILE}"
}

% if [[ -n "${MAIN_FUNCTION_VAR_NAME}" ]]; then
  # if file is sourced avoid calling main function
  # shellcheck disable=SC2178
  BASH_SOURCE=".$0" # cannot be changed in bash
  # shellcheck disable=SC2128
  test ".$0" != ".${BASH_SOURCE}" || <% ${MAIN_FUNCTION_NAME} %> "$@"

  export <% ${MAIN_FUNCTION_VAR_NAME} %>="<% ${MAIN_FUNCTION_NAME} %>"
% else
  <% ${MAIN_FUNCTION_NAME} %> "$@"
% fi
