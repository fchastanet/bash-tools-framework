#!/usr/bin/env bash

#####################################
# GENERATED FACADE FROM <% $REPOSITORY_URL %>/tree/master/<% $SRC_FILE_PATH %>
# DO NOT EDIT IT
#####################################

%# FACADE_HEADERS here the headers of original script file will be copied
.INCLUDE "${FACADE_HEADERS_FILE}"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/facadeDefault/_mandatoryHeaders.tpl"

# FUNCTIONS

<% ${MAIN_FUNCTION_NAME} %>() {
  # REQUIRES

  %# FACADE_CONTENT here the content script part of the facade will be copied as is
  .INCLUDE "${FACADE_CONTENT_FILE}"

  %# GENERATED_FACADE_CHOICE_SCRIPT
  .INCLUDE "${FACADE_CHOICE_SCRIPT_FILE}"
}

% if [[ -n "${MAIN_FUNCTION_VAR_NAME}" ]]; then
  # if file is sourced avoid calling main function
  BASH_SOURCE=".$0" # cannot be changed in bash
  test ".$0" != ".$BASH_SOURCE" || <% ${MAIN_FUNCTION_NAME} %> "$@"

  export <% ${MAIN_FUNCTION_VAR_NAME} %>="<% ${MAIN_FUNCTION_NAME} %>"
% else
  <% ${MAIN_FUNCTION_NAME} %> "$@"
% fi
