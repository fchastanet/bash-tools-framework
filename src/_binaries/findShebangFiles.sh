#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/findShebangFiles
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Synopsis:${__HELP_NORMAL} find all shebang files of this repository

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--help] prints this help and exits.

${__HELP_TITLE}Description:${__HELP_NORMAL}
display list of all files having a bash shebang in the current repository

you can apply a command to all these files by providing arguments

${__HELP_TITLE}Example:${__HELP_NORMAL}
add execution bit to all files with a bash shebang
${SCRIPT_NAME} chmod +x

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"

Args::defaultHelp "${HELP}" "$@"

export -f File::detectBashFile
git ls-files --exclude-standard -c -o -m |
  xargs -L 1 -n 1 -I@ bash -c 'File::detectBashFile "@"' |
  xargs "$@"
