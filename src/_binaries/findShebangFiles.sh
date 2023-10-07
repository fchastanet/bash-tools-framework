#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/findShebangFiles
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.findShebangFiles.tpl)"

declare -a commandToApply=()
unknownOptionArgFunction() {
  commandToApply+=("$1")
}
findShebangFiles parse "${BASH_FRAMEWORK_ARGV[@]}"

run() {
  export -f File::detectBashFile
  export -f Assert::bashFile
  git ls-files --exclude-standard -c -o -m |
    xargs -r -L 1 -n 1 -I@ bash -c 'File::detectBashFile "@"' |
    xargs -r "${commandToApply[@]}"
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
