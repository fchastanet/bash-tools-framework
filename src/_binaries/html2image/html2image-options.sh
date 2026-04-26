#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionDefaultOutputDir="doc/images"
declare -a defaultFormatsIfNoneProvided=("webp")
declare -a argHtml2imageFiles=()
declare stdinInput=0
readonly PUPPETEER_TIMEOUT=$((30 * 24 * 3600)) # 1 month

unknownArgument() {
  if [[ ! -f "$1" ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - file not found: '$1'"
    return 1
  fi
  argHtml2imageFiles+=("$1")
}

html2imageCallback() {
  # Check for stdin input (non-TTY on stdin)
  if [[ ! -t 0 ]]; then
    stdinInput=1
  fi

  # Validate incompatible options
  local -i outputOptionsCount=0
  # shellcheck disable=SC2154
  [[ "${sameDirectoryOption}" = "1" ]] && outputOptionsCount=$((outputOptionsCount + 1))
  [[ -n "${optionOutputDir}" && "${optionOutputDir}" != "${optionDefaultOutputDir}" ]] && outputOptionsCount=$((outputOptionsCount + 1))
  [[ -n "${optionOutput}" ]] && outputOptionsCount=$((outputOptionsCount + 1))

  if ((outputOptionsCount > 1)); then
    Log::displayError "Command ${SCRIPT_NAME} - options --same-dir, --output-dir, and --output are mutually exclusive"
    return 1
  fi

  # --output requires either stdin input or exactly one input file
  if [[ -n "${optionOutput}" ]]; then
    if [[ "${stdinInput}" = "0" && ${#argHtml2imageFiles[@]} -ne 1 ]]; then
      Log::displayError "Command ${SCRIPT_NAME} - option --output requires exactly one input file when not reading from stdin"
      return 1
    fi
    if [[ "${stdinInput}" = "1" && ${#argHtml2imageFiles[@]} -ne 0 ]]; then
      Log::displayError "Command ${SCRIPT_NAME} - option --output cannot be used with input files when reading from stdin"
      return 1
    fi
  fi

  # Require --output for stdin input
  if [[ "${stdinInput}" = "1" ]]; then
    if [[ -z "${optionOutput}" ]]; then
      Log::displayError "Command ${SCRIPT_NAME} - option --output is required when reading from stdin"
      return 1
    fi
    if [[ "${#argHtml2imageFiles[@]}" -ne 0 ]]; then
      Log::displayError "Command ${SCRIPT_NAME} - input files cannot be used when reading from stdin"
      return 1
    fi
  fi

  # Set default formats if none provided
  # shellcheck disable=SC2154
  if ((${#optionFormats[@]} == 0)); then
    optionFormats=("${defaultFormatsIfNoneProvided[@]}")
  fi

  # Normalize JPEG format
  local -a normalizedFormats=()
  for format in "${optionFormats[@]}"; do
    if [[ "${format}" = "jpeg" ]]; then
      normalizedFormats+=("jpg")
    else
      normalizedFormats+=("${format}")
    fi
  done
  optionFormats=("${normalizedFormats[@]}")

  # Set default output directory if not specified
  if [[ -z "${optionOutputDir}" ]]; then
    optionOutputDir="${optionDefaultOutputDir}"
  fi

  # Create output directory if needed and not using same-dir or explicit output
  if [[ ! -d "${optionOutputDir}" && "${sameDirectoryOption}" = "0" && -z "${optionOutput}" ]]; then
    if ! mkdir -p "${optionOutputDir}"; then
      Log::displayError "Command ${SCRIPT_NAME} - failed to create output directory '${optionOutputDir}'"
      return 1
    fi
  fi

  # Validate viewport format (empty means auto-fit to content)
  # shellcheck disable=SC2154
  if [[ -n "${optionViewport}" && ! "${optionViewport}" =~ ^[0-9]+x[0-9]+$ ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - invalid viewport format '${optionViewport}'. Use WIDTHxHEIGHT (e.g., 1920x1080)"
    return 1
  fi

  # Validate quality
  # shellcheck disable=SC2154
  if [[ ! "${optionQuality}" =~ ^[0-9]+$ ]] || ((optionQuality < 0 || optionQuality > 100)); then
    Log::displayError "Command ${SCRIPT_NAME} - quality must be a number between 0 and 100"
    return 1
  fi

  # Validate wait-for-render
  # shellcheck disable=SC2154
  if [[ ! "${optionWaitForRender}" =~ ^[0-9]+$ ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - --wait-for-render must be a non-negative integer (milliseconds)"
    return 1
  fi

  # Validate inject-css file exists if provided
  # shellcheck disable=SC2154
  if [[ -n "${optionInjectCss}" && ! -f "${optionInjectCss}" ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - CSS file not found: '${optionInjectCss}'"
    return 1
  fi

  return 0
}

html2imageOutputDirCallback() {
  return 0
}

optionHelpCallback() {
  html2imageCommandHelp
  exit 0
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}This command(${SCRIPT_NAME}) version: ${__RESET_COLOR}{{ .RootData.binData.commands.default.version }}"
  exit 0
}
