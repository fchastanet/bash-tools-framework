#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionDefaultOutputDir="doc/images"
declare -a defaultFormatsIfNoneProvided=("png")
declare -a plantumlOptions=()
declare -a argPlantumlFiles=()
readonly PLANTUML_PULL_TIMEOUT=$((7 * 24 * 3600))

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

includePathOptionCallback() {
  if [[ -z "${plantumlIncludePathsOption}" ]]; then
    return 0
  fi

  # Parse comma-separated paths
  IFS=',' read -ra paths <<<"${plantumlIncludePathsOption}"
  declare -a validatedPaths=()

  local path
  for path in "${paths[@]}"; do
    # Trim leading/trailing whitespace
    path="$(echo "${path}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [[ ! -d "${path}" ]]; then
      Log::displayError "Command ${SCRIPT_NAME} - include path does not exist: '${path}'"
      return 1
    fi

    validatedPaths+=("$(realpath "${path}")")
  done

  # Store validated paths back (now absolute paths)
  plantumlIncludePathsOption="$(
    IFS=','
    echo "${validatedPaths[*]}"
  )"
}

downloadElkJarIfNeeded() {
  local elkJarPath="${PERSISTENT_TMPDIR}/elk-full.jar"
  local elkJarUrl="http://beta.plantuml.net/elk-full.jar"
  local maxAge=$((30 * 24 * 3600)) # 1 month in seconds
  local hadOldVersion=0

  # Check if file exists and is recent enough
  if [[ -f "${elkJarPath}" ]]; then
    local fileAge
    fileAge=$(File::elapsedTimeSinceLastModification "${elkJarPath}")
    if ((fileAge < maxAge)); then
      Log::displayInfo "Using cached ELK jar (age: $(Log::computeDuration "${fileAge}"))"
      return 0
    fi
    Log::displayInfo "ELK jar is older than 1 month, re-downloading..."
    hadOldVersion=1
  else
    Log::displayInfo "ELK jar not found, downloading..."
  fi

  # Download the jar with retry
  if Retry::parameterized 3 2 "Downloading ELK jar from ${elkJarUrl}" \
    File::downloadFile "${elkJarUrl}" "${elkJarPath}"; then
    Log::displayInfo "ELK jar downloaded successfully"
    return 0
  else
    # Download failed after retries
    if ((hadOldVersion == 1)); then
      Log::displayWarning "Failed to download ELK jar after 3 attempts, using old version"
      return 0
    else
      Log::displayWarning "Failed to download ELK jar after 3 attempts, proceeding without ELK support"
      return 0
    fi
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
  if [[ ! -d "${optionOutputDir}" && "${sameDirectoryOption}" = "0" ]]; then
    if ! mkdir -p "${optionOutputDir}"; then
      Log::displayError \
        "Command ${SCRIPT_NAME} - failed to create output directory '${optionOutputDir}'"
      return 1
    fi
  fi

  # Download ELK jar if --elk option is set
  # shellcheck disable=SC2154
  if [[ "${optionElk}" = "1" ]]; then
    downloadElkJarIfNeeded
  fi
}

pullPlantumlImageIfNeeded() {
  if [[ ! -f "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull" ]] ||
    (($(File::elapsedTimeSinceLastModification "${PERSISTENT_TMPDIR}/plantUmlLastDockerPull") > PLANTUML_PULL_TIMEOUT)) ||
    ! docker image ls plantuml/plantuml &>/dev/null; then
    Log::displayInfo "Pulling latest plantuml/plantuml docker image ..."
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

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}This command(${SCRIPT_NAME}) version: ${__RESET_COLOR}{{ .RootData.binData.commands.default.version }}"
  pullPlantumlImageIfNeeded >/dev/null
  docker run --rm plantuml/plantuml -version
  exit 0
}
