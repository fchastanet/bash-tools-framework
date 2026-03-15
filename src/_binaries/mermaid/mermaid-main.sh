#!/usr/bin/env bash

detectChangedAddedFiles() {
  git ls-files --exclude-standard --modified --others
}

declare -a files
# shellcheck disable=SC2154
if ((${#argMermaidFiles[@]} > 0)); then
  files=("${argMermaidFiles[@]}")
  if ((${#files[@]} == 0)); then
    Log::fatal "Command ${SCRIPT_NAME} - no file provided"
  fi
else
  changedFilesBefore=$(detectChangedAddedFiles)
  readarray -t files < <(git ls-files --exclude-standard -c -o -m | grep -E -e '\.mmd$' -e '\.mermaid$' | sort | uniq)
  if ((${#files[@]} == 0)); then
    Log::displayInfo "Command ${SCRIPT_NAME} - no file to process detected in git repository"
    exit 0
  fi
fi

Log::displayInfo "Will generate mermaid output files for these files: ${files[*]}"

convertMmd() {
  local file="$1"
  local sameDirectoryOption="$2"
  local optionOutputDir="$3"
  local format="$4"
  local optionTraceVerbose="$5"
  local optionQuiet="$6"
  shift 6 || true
  local -a mermaidOptions=("$@")

  local targetFile
  if [[ "${sameDirectoryOption}" = "1" ]]; then
    targetFile="${file%.*}.${format}"
  else
    local fileBasename="${file##*/}"
    targetFile="${optionOutputDir}/${fileBasename%.*}.${format}"
  fi
  Log::displayInfo "Generating ${targetFile} from ${file}"
  if [[ "${optionQuiet}" = "1" ]]; then
    mermaidOptions+=("--quiet")
  fi
  # shellcheck disable=SC2154
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi
  npx -y @mermaid-js/mermaid-cli \
    -i "${file}" \
    -o "${targetFile}" \
    -e "${format}" \
    "${mermaidOptions[@]}"
  set +x
  #if [[ "${format}" = "svg" ]]; then
  #  sed -E -i 's/^<\?mermaid [0-9.]+\?>(.*)/\1/' "${targetFile}"
  #  echo >>"${targetFile}"
  #fi
  Log::displayInfo "Converted ${targetFile}"
}
# TODO generate convertMmd as binary to avoid all these exports
export -f convertMmd File::elapsedTimeSinceLastModification Log::displayInfo Log::logInfo Log::logMessage Log::computeDuration
export BASH_FRAMEWORK_DISPLAY_LEVEL __LEVEL_INFO __INFO_COLOR __RESET_COLOR

(
  declare file format
  for file in "${files[@]}"; do
    Log::displayInfo "Converting ${file}"
    # shellcheck disable=SC2154
    for format in "${optionFormats[@]}"; do
      declare -a myArgs=(
        "${file}" "${sameDirectoryOption}" "${optionOutputDir}"
        "${format}" "${optionTraceVerbose}" "${optionQuiet}"
        "${mermaidOptions[@]}"
      )
      printf "%s\0" "${myArgs[@]}"
    done
  done
) | xargs -0 -P0 -r -n $((6 + ${#mermaidOptions[@]})) bash -c 'convertMmd $@' _

# shellcheck disable=SC2154
if [[ "${optionContinuousIntegrationMode}" = "1" ]] && ((${#argMermaidFiles[@]} == 0)); then
  changedFilesAfter=$(detectChangedAddedFiles)
  diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
    Log::fatal "CI mode - files have been added"
  }
fi
