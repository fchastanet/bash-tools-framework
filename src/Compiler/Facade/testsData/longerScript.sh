#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/installFacadeExample
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# VAR_MAIN_FUNCTION_VAR_NAME=installFacadeExampleMainFunctionName
# IMPLEMENT Install::InstallInterface
# FACADE

# shellcheck disable=SC2034
HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} build files using build.sh
and check if bin file has been updated, if yes return exit code > 0

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--ignore-missing]

    --ignore-missing  do not exit with error for missing files
                      useful when committing because were not existing before

INTERNAL TOOL

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
