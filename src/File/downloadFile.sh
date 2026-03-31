#!/usr/bin/env bash

# @description Download a file from a URL using curl or wget
# @arg $1 url:String the URL to download from
# @arg $2 targetFile:String the local file path where to save the downloaded file
# @exitcode 0 if download successful
# @exitcode 1 if download failed
# @exitcode 2 if neither curl nor wget is available
# @stdout download progress messages
# @stderr error messages
File::downloadFile() {
  local url="$1"
  local targetFile="$2"

  if [[ -z "${url}" ]]; then
    Log::displayError "URL is required"
    return 1
  fi

  if [[ -z "${targetFile}" ]]; then
    Log::displayError "Target file path is required"
    return 1
  fi

  # Try curl first
  if command -v curl &>/dev/null; then
    curl -fsSL -o "${targetFile}" "${url}"
  # Fall back to wget
  elif command -v wget &>/dev/null; then
    wget -q -O "${targetFile}" "${url}"
  else
    Log::displayError "Neither curl nor wget available to download file"
    return 2
  fi
}
