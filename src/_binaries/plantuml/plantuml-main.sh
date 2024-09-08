#!/usr/bin/env bash

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
Log::displayInfo "Will generate plantuml output files for ${files[*]}"

pullPlantumlImageIfNeeded
convertPuml() {
  local file="$1"
  local sameDirectoryOption="$2"
  local optionOutputDir="$3"
  local format="$4"
  local optionLimitSize="$5"
  local optionTraceVerbose="$6"
  shift 6 || true
  local -a plantumlOptions=("$@")

  local targetFile
  if [[ "${sameDirectoryOption}" = "1" ]]; then
    targetFile="${file%.*}.${format}"
  else
    local fileBasename="${file##*/}"
    targetFile="${optionOutputDir}/${fileBasename%.*}.${format}"
  fi
  pullPlantumlImageIfNeeded
  Log::displayInfo "Generating ${targetFile} from ${file}"
  local -a env=()
  if [[ -n "${optionLimitSize}" ]]; then
    env+=(-e "PLANTUML_LIMIT_SIZE=${optionLimitSize}")
  fi
  # shellcheck disable=SC2154
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi
  docker run -i --rm "${env[@]}" plantuml/plantuml \
    -t"${format}" -v -pipe -failfast2 -nbthread auto "${plantumlOptions[@]}" \
    >"${targetFile}" \
    <"${file}"
  set +x
  if [[ "${format}" = "svg" ]]; then
    echo >>"${targetFile}"
  fi
  Log::displayInfo "Converted ${targetFile}"
}
# TODO generate convertPuml as binary to avoid all these exports
export -f convertPuml Log::displayInfo Log::logInfo Log::logMessage Log::computeDuration
export BASH_FRAMEWORK_DISPLAY_LEVEL __LEVEL_INFO __INFO_COLOR __RESET_COLOR

(
  declare file format
  for file in "${files[@]}"; do
    Log::displayInfo "Converting ${file}"
    # shellcheck disable=SC2154
    for format in "${optionFormats[@]}"; do
      declare -a myCmd=(
        "convertPuml"
        "${file}" "${sameDirectoryOption}" "${optionOutputDir}"
        "${format}" "${optionLimitSize}" "${optionTraceVerbose}"
        "${plantumlOptions[@]}"
      )
      printf "'%s' " "${myCmd[@]}"
    done
  done
) | xargs -P0 -r -L 1 bash -c 'convertPuml "$@"'

# shellcheck disable=SC2154
if [[ "${optionContinuousIntegrationMode}" = "1" ]] && ((${#argPlantumlFiles[@]} == 0)); then
  changedFilesAfter=$(detectChangedAddedFiles)
  diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
    Log::fatal "files have been added"
  }
fi
