#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/installDevRequirements
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

.INCLUDE "${TEMPLATE_DIR}/_includes/executedAsUser.sh"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} installs all requirements
unit testing, fchastanet/bash-tools
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME}
EOF
)"
Args::defaultHelp "${HELP}" "$@"

Git::shallowClone \
  "https://github.com/bats-core/bats-core.git" \
  "${ROOT_DIR}/vendor/bats" \
  "master" \
  "FORCE_DELETION"

# last revision 2019
Git::shallowClone \
  "https://github.com/bats-core/bats-support.git" \
  "${ROOT_DIR}/vendor/bats-support" \
  "master" \
  "FORCE_DELETION"

Git::shallowClone \
  "https://github.com/bats-core/bats-assert.git" \
  "${ROOT_DIR}/vendor/bats-assert" \
  "master" \
  "FORCE_DELETION"

Git::shallowClone \
  "https://github.com/Flamefire/bats-mock.git" \
  "${ROOT_DIR}/vendor/bats-mock-Flamefire" \
  "master" \
  "FORCE_DELETION"
