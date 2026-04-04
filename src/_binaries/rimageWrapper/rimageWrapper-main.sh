#!/usr/bin/env bash

# shellcheck disable=SC2154
if [[ "${argRimageCommand}" = "help" ]]; then
  # shellcheck disable=SC2154
  "${PERSISTENT_TMPDIR}/rimage/rimage" help "${rimageOptions[@]}"
  exit 0
fi

detectChangedAddedFiles() {
  git ls-files --exclude-standard --modified --others
}

declare -a files
# shellcheck disable=SC2154
if ((${#argRimageWrapperFiles[@]} > 0)); then
  files=("${argRimageWrapperFiles[@]}")
  if ((${#files[@]} == 0)); then
    Log::fatal "Command ${SCRIPT_NAME} - no file provided"
  fi
else
  changedFilesBefore=$(detectChangedAddedFiles)
  readarray -t files < <(git ls-files --exclude-standard -c -o -m | grep -E -e '\.(jpe?g|png|webp|apng|gif)$' | sort | uniq)
  if ((${#files[@]} == 0)); then
    Log::displayInfo "Command ${SCRIPT_NAME} - no file to process detected in git repository"
    exit 0
  fi
fi

Log::displayInfo "Will generate rimage output files for these files: ${files[*]}"
Log::displayInfo "with command: ${argRimageCommand}"
Log::displayInfo "with options: ${rimageOptions[*]}"

"${RIMAGE_DIR:-${PERSISTENT_TMPDIR}/rimage}/rimage" "${argRimageCommand}" \
  "${rimageOptions[@]}" \
  "${files[@]}"

# shellcheck disable=SC2154
if [[ "${optionContinuousIntegrationMode}" = "1" ]] && ((${#argRimageWrapperFiles[@]} == 0)); then
  changedFilesAfter=$(detectChangedAddedFiles)
  diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
    Log::fatal "CI mode - files have been added"
  }
fi
