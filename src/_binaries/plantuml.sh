#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/plantuml
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.plantuml.tpl)"

plantumlCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

detectChangedAddedFiles() {
  git ls-files --exclude-standard --modified --others
}

declare -a files
# shellcheck disable=SC2154
if ((${#argPlantumlFiles[@]} > 0)); then
  files=("${argPlantumlFiles[@]}")
else
  changedFilesBefore=$(detectChangedAddedFiles)
  files=("**/*.puml")
fi

if ((${#files[@]} == 0)); then
  Log::displayError "Command ${SCRIPT_NAME} - no file provided"
fi
# shellcheck disable=SC2154
for format in "${optionFormats[@]}"; do
  # shellcheck disable=SC2154
  docker run --rm -v "$(pwd -P)":/app/project plantuml/plantuml \
    -u "$(id -u):$(id -g)" -t"${format}" -failfast \
    -o "/app/project/${optionOutputDir}" "${files[@]/#/\/app\/project\/}"
done
if ((${#argPlantumlFiles[@]} == 0)); then
  changedFilesAfter=$(detectChangedAddedFiles)
  diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
    Log::fatal "files have been added"
  }
fi
