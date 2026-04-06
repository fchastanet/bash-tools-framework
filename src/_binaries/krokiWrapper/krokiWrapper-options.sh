#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionDefaultOutputDir="."
declare optionOutputFormat="svg"
declare optionServerPort="8000"
declare -a krokiOptions=()
declare -a argKrokiWrapperFiles=()
readonly KROKI_PULL_TIMEOUT=$((30 * 24 * 3600)) # 1 month

krokiInstallCallback() {
  local file="$1"
  local targetFile="$2"
  local version="$3"
  local tempDir
  tempDir="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-framework-kroki-$$-XXXXXX)"
  (
    cd "${tempDir}" || exit 1
    tar -xzf "${file}" >&2
    # The archive contains a binary named 'kroki' at the root
    if [[ -f "kroki" ]]; then
      mv "kroki" "${targetFile}"
      chmod +x "${targetFile}"
      # Touch the file to update its modification time to now
      touch "${targetFile}"
    else
      Log::fatal "Could not find kroki binary in archive"
    fi
    rm -f "${file}" || true
  )
}

detectArchitecture() {
  local arch
  arch="$(uname -m)"
  case "${arch}" in
    x86_64) echo "amd64" ;;
    aarch64 | arm64) echo "arm64" ;;
    *) echo "amd64" ;; # Default to amd64
  esac
}

# shellcheck disable=SC2317,SC2329 # if function is overridden
beforeParseCallback() {
  Linux::requireJqCommand
  UI::requireTheme
}

ensureKrokiInstalled() {
  if [[ "${SKIP_KROKI_PULL:-0}" = "1" ]]; then
    Log::displayInfo "SKIP_KROKI_PULL is set to 1, skipping kroki pull"
    return
  fi
  # ensure kroki is available
  local krokiDir="${KROKI_DIR:-${PERSISTENT_TMPDIR}/kroki}"
  mkdir -p "${krokiDir}"
  local krokiBinary="${krokiDir}/kroki"
  local arch
  arch="$(detectArchitecture)"

  # Check if kroki exists and is recent enough (unless --force-update is set)
  # shellcheck disable=SC2154
  if [[ "${optionForceUpdate:-0}" = "0" ]] && [[ -f "${krokiBinary}" ]]; then
    if (($(File::elapsedTimeSinceLastModification "${krokiBinary}") <= KROKI_PULL_TIMEOUT)); then
      Log::displayInfo "kroki binary exists and is recent (less than 30 days old), skipping download"
      export PATH="${krokiDir}:${PATH}"
      return
    else
      Log::displayInfo "kroki binary is older than 30 days, checking for updates"
    fi
  elif [[ "${optionForceUpdate:-0}" = "1" ]]; then
    Log::displayInfo "--force-update specified, forcing kroki download"
  fi

  INSTALL_CALLBACK=krokiInstallCallback Github::upgradeRelease \
    "${krokiBinary}" \
    "https://github.com/yuzutech/kroki-cli/releases/download/v@latestVersion@/kroki-cli_@latestVersion@_linux_${arch}.tar.gz"
  export PATH="${krokiDir}:${PATH}"
}

unknownOption() {
  krokiOptions+=("$1")
}

unknownArgument() {
  if [[ -f "$1" ]]; then
    argKrokiWrapperFiles+=("$1")
  else
    krokiOptions+=("$1")
  fi
}

krokiWrapperOutputDirCallback() {
  :
}

krokiWrapperCallback() {
  ensureKrokiInstalled

  # shellcheck disable=SC2154
  optionOutputDir=$(File::createOutputDir "${optionOutputDir}" "${optionDefaultOutputDir}") || return 1
}

optionHelpCallback() {
  ensureKrokiInstalled
  local krokiHelpFile
  krokiHelpFile="$(Framework::createTempFile "krokiHelp")"

  "${KROKI_DIR:-${PERSISTENT_TMPDIR}/kroki}/kroki" --help >"${krokiHelpFile}"
  krokiWrapperCommandHelp |
    sed -E \
      -e "/@@@KROKI_HELP@@@/r ${krokiHelpFile}" \
      -e "/@@@KROKI_HELP@@@/d"
  exit 0
}

optionVersionCallback() {
  ensureKrokiInstalled
  echo -e "${__HELP_TITLE_COLOR}This command(${SCRIPT_NAME}) version: ${__RESET_COLOR}{{ .RootData.binData.commands.default.version }}"
  local krokiVersion
  krokiVersion=$("${KROKI_DIR:-${PERSISTENT_TMPDIR}/kroki}/kroki" version 2>&1 | head -n1)
  echo -e "${__HELP_TITLE_COLOR}kroki version: ${__RESET_COLOR}${krokiVersion}"
  exit 0
}
