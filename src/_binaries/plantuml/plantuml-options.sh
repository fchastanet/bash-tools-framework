#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionDefaultOutputDir="doc/images"
declare -a defaultFormatsIfNoneProvided=("png")
declare -a plantumlOptions=()
declare -a argPlantumlFiles=()
readonly PLANTUML_PULL_TIMEOUT=$((30 * 24 * 3600))

unknownOption() {
  plantumlOptions+=("$1")
}

plantumlArgFileCallback() {
  if [[ ! -f "$1" ]]; then
    plantumlOptions+=("$1")
  else
    argPlantumlFiles+=("$1")
  fi
}

optionLimitSizeCallback() {
  if [[ -n "${optionLimitSize}" && ! "${optionLimitSize}" =~ ^[0-9]+$ ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - invalid limit size value '$2'"
    return 1
  fi
}

plantumlCallback() {
  if ((${#optionFormats[@]} == 0)); then
    optionFormats=("${defaultFormatsIfNoneProvided[@]}")
  fi
  # shellcheck disable=SC2154
  if [[ -n "${optionOutputDir}" && "${sameDirectoryOption}" = "1" ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - option --same-dir and --output-dir are incompatible"
    return 1
  fi
  if [[ -z "${optionOutputDir}" ]]; then
    optionOutputDir="${optionDefaultOutputDir}"
  fi
  if [[ ! -d "${optionOutputDir}" ]]; then
    Log::displayError \
      "Command ${SCRIPT_NAME} - output directory '${optionOutputDir}' does not exists"
    return 1
  fi
}

pullPlantumlImageIfNeeded() {
  if [[ ! -f "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull" ]] ||
    (($(File::elapsedTimeSinceLastModification "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull") > PLANTUML_PULL_TIMEOUT)) ||
    ! docker image ls plantuml/plantuml &>/dev/null; then
    docker pull plantuml/plantuml
    touch "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull"
  fi
}

optionHelpCallback() {
  local plantumlHelpFile
  plantumlHelpFile="$(Framework::createTempFile "hadolintHelp")"

  if command -v docker &>/dev/null; then
    pullPlantumlImageIfNeeded >/dev/null
    docker run --rm plantuml/plantuml -help >"${plantumlHelpFile}"
  else
    echo "docker was not available while generating this documentation" >"${plantumlHelpFile}"
  fi
  plantumlCommandHelp |
    sed -E \
      -e "/@@@PLANTUML_HELP@@@/r ${plantumlHelpFile}" \
      -e "/@@@PLANTUML_HELP@@@/d"
  exit 0
}
