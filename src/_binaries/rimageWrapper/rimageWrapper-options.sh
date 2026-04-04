#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionDefaultOutputDir="."
declare -a rimageOptions=()
declare -a argRimageWrapperFiles=()
readonly RIMAGE_PULL_TIMEOUT=$((7 * 24 * 3600))

rimageInstallCallback() {
  local file="$1"
  local targetFile="$2"
  local version="$3"
  local tempDir
  tempDir="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-framework-rimage-$$-XXXXXX)"
  (
    cd "${tempDir}" || exit 1
    tar -xzf "${file}" --strip-components=1 >&2
    mv "rimage" "${targetFile}"
    chmod +x "${targetFile}"
    rm -f "${file}" || true
  )
}

beforeParseCallback() {
  Linux::requireJqCommand
  UI::requireTheme
  if [[ "${SKIP_RIMAGE_PULL:-0}" = "1" ]]; then
    Log::displayInfo "SKIP_RIMAGE_PULL is set to 1, skipping rimage pull"
    return
  fi
  # ensure rimage is available
  local rimageDir="${RIMAGE_DIR:-${PERSISTENT_TMPDIR}/rimage}"
  mkdir -p "${rimageDir}"
  INSTALL_CALLBACK=rimageInstallCallback Github::upgradeRelease \
    "${rimageDir}/rimage" \
    "https://github.com/vlad-salone/rimage/releases/download/v@latestVersion@/rimage-@latestVersion@-x86_64-unknown-linux-gnu.tar.gz"
  export PATH="${rimageDir}:${PATH}"
}

unknownOption() {
  rimageOptions+=("$1")
}

unknownArgument() {
  if [[ -f "$1" ]]; then
    argRimageWrapperFiles+=("$1")
  else
    rimageOptions+=("$1")
  fi
}

rimageWrapperCallback() {
  # shellcheck disable=SC2154
  optionOutputDir=$(File::createOutputDir "${optionOutputDir}" "${optionDefaultOutputDir}") || return 1
}

optionHelpCallback() {
  local rimageHelpFile
  rimageHelpFile="$(Framework::createTempFile "rimageHelp")"

  "${RIMAGE_DIR:-${PERSISTENT_TMPDIR}/rimage}/rimage" --help >"${rimageHelpFile}"
  rimageWrapperCommandHelp |
    sed -E \
      -e "/@@@RIMAGE_HELP@@@/r ${rimageHelpFile}" \
      -e "/@@@RIMAGE_HELP@@@/d"
  exit 0
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}This command(${SCRIPT_NAME}) version: ${__RESET_COLOR}{{ .RootData.binData.commands.default.version }}"
  echo -e "${__HELP_TITLE_COLOR}rimage version: ${__RESET_COLOR}$("${RIMAGE_DIR:-${PERSISTENT_TMPDIR}/rimage}/rimage" --version)"
  exit 0
}
