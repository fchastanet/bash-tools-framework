#!/usr/bin/env bash

BASH_FRAMEWORK_SHDOC_INSTALLED="${FRAMEWORK_ROOT_DIR}/vendor/.shDocInstalled"
BASH_FRAMEWORK_SHDOC_CHECK_TIMEOUT=86400 # 1 day

ShellDoc::installRequirementsIfNeeded() {
  if [[ "$(
    Cache::getFileContentIfNotExpired \
      "${BASH_FRAMEWORK_SHDOC_INSTALLED}" \
      "${BASH_FRAMEWORK_SHDOC_CHECK_TIMEOUT}"
  )" != "1" ]]; then
    Log::displayInfo "Check if shdoc is up to date"
    if GIT_CLONE_OPTIONS="--recursive" Git::cloneOrPullIfNoChanges \
      "${FRAMEWORK_VENDOR_DIR:-${FRAMEWORK_ROOT_DIR}/vendor}/shdoc" \
      "git@github.com:fchastanet/shdoc.git"; then
      echo "1" >"${BASH_FRAMEWORK_SHDOC_INSTALLED}"
    else
      Log::fatal "unable to install shdoc library"
    fi
  fi
}
