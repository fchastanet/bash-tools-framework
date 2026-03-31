#!/usr/bin/env bash

detectChangedAddedFiles() {
  git ls-files --exclude-standard --modified --others
}

declare -a files
# shellcheck disable=SC2154
if ((${#argPlantumlFiles[@]} > 0)); then
  files=("${argPlantumlFiles[@]}")
  if ((${#files[@]} == 0)); then
    Log::fatal "Command ${SCRIPT_NAME} - no file provided"
  fi
else
  changedFilesBefore=$(detectChangedAddedFiles)
  readarray -t files < <(git ls-files --exclude-standard -c -o -m | grep -E -e '\.puml$' -e '\.plantuml$' | sort | uniq)
  if ((${#files[@]} == 0)); then
    Log::displayInfo "Command ${SCRIPT_NAME} - no file to process detected in git repository"
    exit 0
  fi
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
  local plantumlIncludePathsOption="$7"
  local optionElk="$8"
  shift 8 || true
  local -a plantumlOptions=("$@")

  local targetFile
  if [[ "${sameDirectoryOption}" = "1" ]]; then
    targetFile="${file%.*}.${format}"
  else
    local fileBasename="${file##*/}"
    targetFile="${optionOutputDir}/${fileBasename%.*}.${format}"
  fi
  Log::displayInfo "Generating ${targetFile} from ${file}"
  local -a env=()
  if [[ "${optionLimitSize}" != "0" ]]; then
    env+=(-e "PLANTUML_LIMIT_SIZE=${optionLimitSize}")
  fi

  # Handle multiple include paths
  local -a includePaths=()
  local -a containerPaths=()
  if [[ -n "${plantumlIncludePathsOption}" ]]; then
    IFS=',' read -ra includePaths <<<"${plantumlIncludePathsOption}"
    local i=0
    local path
    for path in "${includePaths[@]}"; do
      local containerPath="/data/include${i}"
      env+=(-v "${path}:${containerPath}:ro")
      containerPaths+=("${containerPath}")
      ((i++)) || true
    done
    # Join container paths with colon separator for Java classpath-style argument
    local includePathArg
    includePathArg="$(
      IFS=':'
      echo "${containerPaths[*]}"
    )"
    includePaths+=("-Dplantuml.include.path=${includePathArg}")
  else
    includePaths+=("-Dplantuml.include.path=/data/include")
    env+=(-v "${PWD}:/data/include:ro")
    containerPaths=("/data/include")
  fi

  # Mount ELK jar if option is enabled
  if [[ "${optionElk}" = "1" ]]; then
    local elkJarPath="${PERSISTENT_TMPDIR}/elk-full.jar"
    if [[ -f "${elkJarPath}" ]]; then
      env+=(-v "${elkJarPath}:/opt/elk-full.jar:ro")
    fi
  fi

  # shellcheck disable=SC2154
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi
  docker run -i --rm "${env[@]}" --entrypoint java plantuml/plantuml \
    "${includePaths[@]}" -jar /opt/plantuml.jar \
    -t"${format}" --disable-metadata -v -pipe -failfast2 -nbthread auto "${plantumlOptions[@]}" \
    >"${targetFile}" \
    <"${file}"
  set +x
  if [[ "${format}" = "svg" ]]; then
    sed -E -i 's/^<\?plantuml [0-9.]+\?>(.*)/\1/' "${targetFile}"
    echo >>"${targetFile}"
  fi
  Log::displayInfo "Converted ${targetFile}"
}
# TODO generate convertPuml as binary to avoid all these exports
export -f convertPuml File::elapsedTimeSinceLastModification Log::displayInfo Log::logInfo Log::logMessage Log::computeDuration
export BASH_FRAMEWORK_DISPLAY_LEVEL __LEVEL_INFO __INFO_COLOR __RESET_COLOR PERSISTENT_TMPDIR

(
  declare file format
  for file in "${files[@]}"; do
    Log::displayInfo "Converting ${file}"
    # shellcheck disable=SC2154
    for format in "${optionFormats[@]}"; do
      declare -a myArgs=(
        "${file}" "${sameDirectoryOption}" "${optionOutputDir}"
        "${format}" "${optionLimitSize}" "${optionTraceVerbose}"
        "${plantumlIncludePathsOption}" "${optionElk}"
        "${plantumlOptions[@]}"
      )
      printf "%s\0" "${myArgs[@]}"
    done
  done
) | xargs -0 -P0 -r -n $((8 + ${#plantumlOptions[@]})) bash -c 'convertPuml $@' _

# shellcheck disable=SC2154
if [[ "${optionContinuousIntegrationMode}" = "1" ]] && ((${#argPlantumlFiles[@]} == 0)); then
  changedFilesAfter=$(detectChangedAddedFiles)
  diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
    Log::fatal "CI mode - files have been added"
  }
fi
