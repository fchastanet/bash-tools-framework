#!/usr/bin/env bash

BASH_FRAMEWORK_TOMDOC_INSTALLED="${ROOT_DIR}/vendor/.tomdocInstalled"
BASH_FRAMEWORK_TOMDOC_CHECK_TIMEOUT=86400 # 1 day

ShellDoc::installRequirementsIfNeeded() {
  if [[ "$(
    Cache::getFileContentIfNotExpired \
      "${BASH_FRAMEWORK_TOMDOC_INSTALLED}" \
      "${BASH_FRAMEWORK_TOMDOC_CHECK_TIMEOUT}"
  )" != "1" ]]; then

    (Log::displayInfo "Check if tomdoc.sh is up to date")
    if Git::shallowClone \
      "https://github.com/fchastanet/tomdoc.sh.git" \
      "${VENDOR_DIR:-${ROOT_DIR}/vendor}/fchastanet.tomdoc.sh" \
      "master" \
      "FORCE_DELETION"; then
      echo "1" >"${BASH_FRAMEWORK_TOMDOC_INSTALLED}"
    else
      Log::fatal "unable to install tomdoc.sh library"
    fi
  fi
}
