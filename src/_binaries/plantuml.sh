#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/plantuml
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.plantuml.tpl)"

plantumlCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

run() {
  detectChangedAddedFiles() {
    git ls-files --exclude-standard --modified --others
  }

  declare -a files
  # shellcheck disable=SC2154
  if ((${#argPlantumlFiles[@]} > 0)); then
    files=("${argPlantumlFiles[@]}")
  else
    changedFilesBefore=$(detectChangedAddedFiles)
    readarray -t files < <(find . -name '*.puml')
  fi

  if ((${#files[@]} == 0)); then
    Log::fatal "Command ${SCRIPT_NAME} - no file provided"
  fi

  readonly PLANTUML_PULL_TIMEOUT=$((30 * 24 * 3600))
  if [[ ! -f "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull" ]] ||
    (($(File::elapsedTimeSinceLastModification "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull") > PLANTUML_PULL_TIMEOUT)); then
    docker pull plantuml/plantuml
    touch "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull"
  fi
  convertPuml() {
    local file="$1"
    local sameDirectoryOption="$2"
    local optionOutputDir="$3"
    local format="$4"
    shift 4 || true
    local -a plantumlOptions=("$@")

    local targetFile
    if [[ "${sameDirectoryOption}" = "1" ]]; then
      targetFile="${file%.*}.${format}"
    else
      local fileBasename="${file##*/}"
      targetFile="${optionOutputDir}/${fileBasename%.*}.${format}"
    fi
    Log::displayInfo "Generating ${targetFile} from ${file}"

    # shellcheck disable=SC2154
    docker run -i --rm plantuml/plantuml \
      -t"${format}" -pipe -failfast2 -nbthread auto "${plantumlOptions[@]}" \
      >"${targetFile}" \
      <"${file}"
    if [[ "${format}" = "svg" ]]; then
      echo >>"${targetFile}"
    fi
  }
  # TODO generate convertPuml as binary to avoid all these exports
  export -f convertPuml Log::displayInfo Log::logInfo Log::logMessage
  export BASH_FRAMEWORK_DISPLAY_LEVEL __LEVEL_INFO __INFO_COLOR __RESET_COLOR

  (
    local file format
    for file in "${files[@]}"; do
      # shellcheck disable=SC2154
      for format in "${optionFormats[@]}"; do
        echo "convertPuml" "${file}" "${sameDirectoryOption}" "${optionOutputDir}" "${format}" "${plantumlOptions[@]}"
      done
    done
  ) | xargs -P0 -r -L 1 bash -c '</dev/tty convertPuml "$@"'

  if ((${#argPlantumlFiles[@]} == 0)); then
    changedFilesAfter=$(detectChangedAddedFiles)
    diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
      Log::fatal "files have been added"
    }
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
