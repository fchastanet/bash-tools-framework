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

unknownArgument() {
  mermaidOptions+=("$1")
}

mermaidCallback() {
  local -i optionIdx=0
  local -a newMermaidOptions=()
  # parse mermaid options
  while (("${optionIdx}" < "${#mermaidOptions[@]}")); do
    local option="${mermaidOptions[optionIdx]}"
    case "${option}" in
      --theme | -t | \
        --width | -w | \
        --height | -H | \
        --backgroundColor | -b | \
        --configFile | -c | \
        --cssFile | -C | \
        --svgId | -I | \
        --scale | -s | \
        --pdfFit | -f | \
        --quiet | -q | \
        -p | --puppeteerConfigFile)
        newMermaidOptions+=("${option}")
        ((++optionIdx))
        newMermaidOptions+=("${mermaidOptions[optionIdx]}")
        ;;
      --iconPacks | --iconPacksNamesAndUrls)
        newMermaidOptions+=("${option}")
        ((++optionIdx))
        while ((optionIdx < ${#mermaidOptions[@]})) && [[ ! "${mermaidOptions[optionIdx]}" =~ ^- ]]; do
          newMermaidOptions+=("${mermaidOptions[optionIdx]}")
          ((++optionIdx))
        done
        ((optionIdx--)) # step back to reprocess the next option in the next loop iteration
        ;;
      --input | -i)
        ((++optionIdx))
        if [[ ! -f "${mermaidOptions[optionIdx]}" ]]; then
          Log::displayError "Command ${SCRIPT_NAME} - file '${mermaidOptions[optionIdx]}' does not exist for option ${option}"
          exit 1
        fi
        argMermaidFiles+=("${mermaidOptions[optionIdx]}")
        ;;
      --output | -o)
        Log::displayError "Command ${SCRIPT_NAME} - option ${option} is not supported, output file is automatically determined based on the input file and --same-dir and --output-dir options"
        return 1
        ;;
      --outputFormat | -e)
        ((++optionIdx))
        optionFormats+=("${mermaidOptions[optionIdx]}")
        ;;
      *)
        if [[ -f "${option}" ]]; then
          argMermaidFiles+=("${option}")
        else
          newMermaidOptions+=("${option}")
        fi
        ;;
    esac
    ((++optionIdx))
  done
  mermaidOptions=("${newMermaidOptions[@]}")
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

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}This command(${SCRIPT_NAME}) version: ${__RESET_COLOR}{{ .RootData.binData.commands.default.version }}"
  echo -e "${__HELP_TITLE_COLOR}@mermaid-js/mermaid-cli version: ${__RESET_COLOR}$(npx -y @mermaid-js/mermaid-cli --version)"
  exit 0
}
