#!/usr/bin/env bash
# @embed "${FRAMEWORK_ROOT_DIR}/src/_binaries/html2image/html2image-puppeteer.js" AS html2imagePuppeteer

detectChangedAddedFiles() {
  git ls-files --exclude-standard --modified --others
}

# Convert HTML to image using Puppeteer
convertHTML() {
  local inputFile="$1"
  local outputFile="$2"
  local format="$3"
  local viewport="$4"
  local quality="$5"
  local fullPage="$6"
  local waitForRender="${7:-0}"
  local waitForSelector="${8:-}"
  local injectCss="${9:-}"
  local hideSelector="${10:-}"

  # Convert to absolute paths
  if [[ ! "${inputFile}" =~ ^/ ]]; then
    inputFile="$(pwd)/${inputFile}"
  fi
  if [[ ! "${outputFile}" =~ ^/ ]]; then
    outputFile="$(pwd)/${outputFile}"
  fi

  Log::displayInfo "Generating ${outputFile} from ${inputFile}"

  # Build Puppeteer command args
  local -a puppeteerArgs=(
    "--input" "${inputFile}"
    "--output" "${outputFile}"
    "--format" "${format}"
    "--viewport" "${viewport}"
    "--quality" "${quality}"
  )

  if [[ "${fullPage}" = "1" ]]; then
    puppeteerArgs+=("--full-page")
  fi

  if [[ -n "${waitForRender}" && "${waitForRender}" != "0" ]]; then
    puppeteerArgs+=("--wait-for-render" "${waitForRender}")
  fi

  if [[ -n "${waitForSelector}" ]]; then
    puppeteerArgs+=("--wait-for-selector" "${waitForSelector}")
  fi

  if [[ -n "${injectCss}" ]]; then
    # Convert to absolute path for puppeteer
    if [[ ! "${injectCss}" =~ ^/ ]]; then
      injectCss="$(pwd)/${injectCss}"
    fi
    puppeteerArgs+=("--inject-css" "${injectCss}")
  fi

  if [[ -n "${hideSelector}" ]]; then
    puppeteerArgs+=("--hide-selector" "${hideSelector}")
  fi

  # Execute Puppeteer script using the embedded file
  # shellcheck disable=SC2154
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi

  # Create a temp directory for puppeteer
  local tempDir
  tempDir="$(mktemp -d -p "${TMPDIR}" html2image-node-XXXXXX)"

  # run the script
  Log::displayInfo "Running Puppeteer to convert HTML to image..."
  if (cd "${tempDir}" && node "${embed_file_html2imagePuppeteer}" "${puppeteerArgs[@]}"); then
    Log::displayInfo "Successfully converted ${outputFile}"
  else
    Log::displayError "Failed to convert ${outputFile}"
    return 1
  fi

  set +x
  return 0
}

# Process a single file
processFile() {
  local file="$1"
  local sameDirectoryOption="$2"
  local optionOutputDir="$3"
  local format="$4"
  local optionTransformCmd="$5"
  local viewport="$6"
  local quality="$7"
  local fullPage="$8"
  local explicitOutput="$9"
  local waitForRender="${10:-0}"
  local waitForSelector="${11:-}"
  local injectCss="${12:-}"
  local hideSelector="${13:-}"

  local htmlFile="${file}"
  local tempHtmlFile=""

  # Apply transform command if specified
  if [[ -n "${optionTransformCmd}" ]]; then
    Log::displayInfo "Applying transform command to ${file}"

    # Create temp file with .html extension so browsers recognize the MIME type
    # when loading via file:// URL (browsers need extension to determine content type)
    tempHtmlFile="$(mktemp -p "${TMPDIR}" --suffix=".html" "html2image-transform-XXXXXX")"

    # Replace %tempFile% placeholder with actual temp file path
    local transformCmd="${optionTransformCmd//%tempFile%/${tempHtmlFile}}"

    # Execute transform command with input file
    if ! eval "${transformCmd}" "${file}"; then
      Log::displayError "Transform command failed for ${file}"
      rm -f "${tempHtmlFile}"
      return 1
    fi

    htmlFile="${tempHtmlFile}"
  fi

  # Determine output file path
  local targetFile
  if [[ -n "${explicitOutput}" ]]; then
    # Use explicit output path
    targetFile="${explicitOutput}"
  elif [[ "${sameDirectoryOption}" = "1" ]]; then
    targetFile="${file%.*}.${format}"
  else
    local fileBasename="${file##*/}"
    targetFile="${optionOutputDir}/${fileBasename%.*}.${format}"
  fi

  # Convert HTML to image
  if ! convertHTML "${htmlFile}" "${targetFile}" "${format}" "${viewport}" "${quality}" "${fullPage}" "${waitForRender}" "${waitForSelector}" "${injectCss}" "${hideSelector}"; then
    [[ -n "${tempHtmlFile}" ]] && rm -f "${tempHtmlFile}"
    return 1
  fi

  # Clean up temp file
  [[ -n "${tempHtmlFile}" ]] && rm -f "${tempHtmlFile}"
  return 0
}

installPuppeteerIfNeeded() {
  # Get npm global root
  local npmGlobalRoot
  npmGlobalRoot="$(npm root -g)"

  # Install puppeteer globally if not already installed (to speed up subsequent runs by using global cache)
  local installPuppeteer=0
  local puppeteerPackageJson="${npmGlobalRoot}/puppeteer/package.json"
  if [[ ! -f "${puppeteerPackageJson}" ]]; then
    Log::displayInfo "puppeteer is not installed globally, installing now (this may take a moment)..."
    installPuppeteer=1
  fi
  if (($(File::elapsedTimeSinceLastModification "${puppeteerPackageJson}") > PUPPETEER_TIMEOUT)); then
    Log::displayInfo "puppeteer binary is older than 30 days, checking for updates"
    installPuppeteer=1
  fi
  if [[ "${installPuppeteer}" = "1" ]]; then
    if ! npm install --silent -g puppeteer; then
      Log::displayError "Failed to install puppeteer globally"
      return 1
    fi
    touch "${puppeteerPackageJson}" # Update modification time
  fi

  # require puppeteer globally
  export NODE_PATH="${npmGlobalRoot}"
}

# Main execution logic
installPuppeteerIfNeeded || Log::fatal "Failed to ensure puppeteer is installed"

# shellcheck disable=SC2154
if [[ "${stdinInput}" = "1" ]]; then
  # Handle stdin input
  Log::displayInfo "Reading HTML from stdin"

  # Read stdin to temp file with .html extension (required for browser file:// URL MIME detection)
  local stdinTempFile
  stdinTempFile="$(mktemp -p "${TMPDIR}" --suffix=".html" "html2image-stdin-XXXXXX")"
  cat >"${stdinTempFile}"

  # Use first format for stdin
  local format="${optionFormats[0]}"

  # shellcheck disable=SC2154
  if ! convertHTML "${stdinTempFile}" "${optionOutput}" "${format}" "${optionViewport}" "${optionQuality}" "${optionFullPage}" "${optionWaitForRender}" "${optionWaitForSelector}" "${optionInjectCss}" "${optionHideSelector}"; then
    rm -f "${stdinTempFile}"
    Log::fatal "Failed to convert stdin input"
  fi

  rm -f "${stdinTempFile}"
  exit 0
fi

# Determine files to process
declare -a files
# shellcheck disable=SC2154
if ((${#argHtml2imageFiles[@]} > 0)); then
  files=("${argHtml2imageFiles[@]}")
  if ((${#files[@]} == 0)); then
    Log::fatal "Command ${SCRIPT_NAME} - no file provided"
  fi

  # When using --output with file arguments, only process first file with first format
  # shellcheck disable=SC2154
  if [[ -n "${optionOutput}" ]]; then
    # shellcheck disable=SC2154
    if ! processFile "${files[0]}" "${sameDirectoryOption}" "${optionOutputDir}" \
      "${optionFormats[0]}" "${optionTransformCmd}" "${optionViewport}" \
      "${optionQuality}" "${optionFullPage}" "${optionOutput}" \
      "${optionWaitForRender}" "${optionWaitForSelector}" \
      "${optionInjectCss}" "${optionHideSelector}"; then
      Log::fatal "Failed to process ${files[0]}"
    fi
    exit 0
  fi
else
  # Store changed files before processing (for CI mode check)
  changedFilesBefore=$(detectChangedAddedFiles)

  # Get HTML files from git repository
  readarray -t files < <(git ls-files --exclude-standard -c -o -m | grep -E -e "${optionFileFilter}" | sort | uniq)
  if ((${#files[@]} == 0)); then
    Log::displayInfo "Command ${SCRIPT_NAME} - no HTML file to process detected in git repository"
    exit 0
  fi
fi

Log::displayInfo "Will generate image output files for these files: ${files[*]}"

# Export functions and variables for parallel execution
export -f \
  convertHTML \
  processFile \
  File::elapsedTimeSinceLastModification \
  Framework::createTempFile \
  Log::displayInfo \
  Log::displayError \
  Log::logInfo \
  Log::logMessage \
  Log::computeDuration
export BASH_FRAMEWORK_DISPLAY_LEVEL __LEVEL_INFO __INFO_COLOR __RESET_COLOR __ERROR_COLOR
export embed_file_html2imagePuppeteer optionWaitForRender optionWaitForSelector optionInjectCss optionHideSelector

# Process files in parallel
(
  declare file format
  for file in "${files[@]}"; do
    if [[ ! -f "${file}" ]]; then
      Log::displayWarning "File ${file} does not exist or has been deleted"
      continue
    fi

    Log::displayInfo "Processing ${file}"
    # shellcheck disable=SC2154
    for format in "${optionFormats[@]}"; do
      declare -a processArgs=(
        "${file}"
        "${sameDirectoryOption}"
        "${optionOutputDir}"
        "${format}"
        "${optionTransformCmd}"
        "${optionViewport}"
        "${optionQuality}"
        "${optionFullPage}"
        "" # explicitOutput (empty for batch processing)
        "${optionWaitForRender}"
        "${optionWaitForSelector}"
        "${optionInjectCss}"
        "${optionHideSelector}"
      )
      printf "%s\0" "${processArgs[@]}"
    done
  done
) | xargs -0 -P4 -r -n 13 bash -c 'processFile "$@"' _

# CI mode: check for changed files
# shellcheck disable=SC2154
if [[ "${optionContinuousIntegrationMode}" = "1" ]] && ((${#argHtml2imageFiles[@]} == 0)); then
  changedFilesAfter=$(detectChangedAddedFiles)

  # Check if specified extensions exist for each processed file
  # shellcheck disable=SC2154
  if [[ -n "${optionCiCheckExtensions}" ]]; then
    IFS=',' read -ra checkExtensions <<<"${optionCiCheckExtensions}"
    declare -i missingCount=0

    for file in "${files[@]}"; do
      local baseName="${file%.*}"
      for ext in "${checkExtensions[@]}"; do
        local expectedFile
        if [[ "${sameDirectoryOption}" = "1" ]]; then
          expectedFile="${baseName}.${ext}"
        else
          local fileBasename="${file##*/}"
          expectedFile="${optionOutputDir}/${fileBasename%.*}.${ext}"
        fi

        if [[ ! -f "${expectedFile}" ]]; then
          Log::displayError "CI mode - expected file missing: ${expectedFile}"
          ((missingCount++))
        fi
      done
    done

    if ((missingCount > 0)); then
      Log::fatal "CI mode - ${missingCount} expected image file(s) missing"
    fi
  fi

  # Check for new files
  diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
    Log::fatal "CI mode - files have been added or modified"
  }
fi
