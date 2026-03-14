#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionDefaultOutputDir="doc/images"
declare -a defaultFormatsIfNoneProvided=("svg")
declare -a mermaidOptions=()
declare -a argMermaidFiles=()
readonly MERMAID_PULL_TIMEOUT=$((7 * 24 * 3600))

unknownOption() {
  mermaidOptions+=("$1")
}

mermaidArgFileCallback() {
  if [[ ! -f "$1" ]]; then
    mermaidOptions+=("$1")
  else
    argMermaidFiles+=("$1")
  fi
}

mermaidCallback() {
  if ((${#optionFormats[@]} == 0)); then
    optionFormats=("${defaultFormatsIfNoneProvided[@]}")
  fi
  if [[ "${includePathOption}" = "-" ]]; then
    includePathOption="$(pwd)"
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
    fi
    return 1
  fi
}

optionHelpCallback() {
  local mermaidHelpFile
  mermaidHelpFile="$(Framework::createTempFile "mermaidHelp")"

  npx -y @mermaid-js/mermaid-cli --help >"${mermaidHelpFile}"
  mermaidCommandHelp |
    sed -E \
      -e "/@@@MERMAID_HELP@@@/r ${mermaidHelpFile}" \
      -e "/@@@MERMAID_HELP@@@/d"
  exit 0
}
