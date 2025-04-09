#!/usr/bin/env bash

# @description intermediate callback that is used by Github::upgradeRelease
# or Github::installRelease
# if installCallback is not set, it allows to:
#   - copy the downloaded file to the right target file
#   - and set the execution bit
# else
#   installCallback is called with newSoftware, targetFile, version arguments
# fi
# @warning do not use this function as callback for Github::upgradeRelease or Github::installRelease, as it would result to an infinite loop
# @arg $1 newSoftware:String the downloaded software file
# @arg $2 targetFile:String where we want to copy the file
# @arg $3 version:String the version that has been downloaded
# @arg $4 installCallback:Function (optional) the callback to call with 3 first arguments
# @env SUDO String allows to use custom sudo prefix command
# @exitcode * on failure
# @see Github::upgradeRelease
# @see Github::installRelease
# @internal
Github::defaultInstall() {
  local newSoftware="$1"
  local targetFile="$2"
  local version="$3"
  local installCallback=$4
  # shellcheck disable=SC2086
  if ! ${SUDO:-} test -d "${targetFile%/*}"; then
    ${SUDO:-} mkdir -p "${targetFile%/*}"
  fi
  if [[ "$(type -t "${installCallback}")" = "function" ]]; then
    ${installCallback} "${newSoftware}" "${targetFile}" "${version}"
  else
    ${SUDO:-} mv "${newSoftware}" "${targetFile}" || {
      Log::displayError "Failed to move ${newSoftware} to ${targetFile}"
      return 1
    }
    ${SUDO:-} chmod +x "${targetFile}" || {
      Log::displayError "Failed to set execution bit on ${targetFile}"
      return 1
    }
    hash -r
    ${SUDO:-} rm -f "${newSoftware}" || true
    if [[ -z "${CURRENT_VERSION}" ]]; then
      Log::displaySuccess "Version ${version} installed in ${targetFile}"
    else
      Log::displaySuccess "Version ${CURRENT_VERSION} upgraded to ${version} in ${targetFile}"
    fi
  fi
}
