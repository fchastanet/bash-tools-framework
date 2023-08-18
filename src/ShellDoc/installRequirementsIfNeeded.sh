#!/usr/bin/env bash

BASH_FRAMEWORK_SHDOC_INSTALLED="${FRAMEWORK_ROOT_DIR}/vendor/.shDocInstalled"
BASH_FRAMEWORK_SHDOC_CHECK_TIMEOUT=86400 # 1 day

# @description install requirements to execute shdoc
# @warning cloning is skipped if vendor/.shDocInstalled file exists
# @warning a new check is done everyday
# @warning repository is not updated if a change is detected
# @env BASH_FRAMEWORK_SHDOC_CHECK_TIMEOUT int default value 86400 (86400 seconds = 1 day)
# @set BASH_FRAMEWORK_SHDOC_INSTALLED String the file created when git clone succeeded
# @see https://github.com/fchastanet/shdoc
# @stderr diagnostics information is displayed
# @feature Git::cloneOrPullIfNoChanges
ShellDoc::installRequirementsIfNeeded() {
  if [[ "$(
    Cache::getFileContentIfNotExpired \
      "${BASH_FRAMEWORK_SHDOC_INSTALLED}" \
      "${BASH_FRAMEWORK_SHDOC_CHECK_TIMEOUT}"
  )" != "1" ]]; then
    Log::displayInfo "Check if shdoc is up to date"
    if GIT_CLONE_OPTIONS="--recursive" Git::cloneOrPullIfNoChanges \
      "${FRAMEWORK_VENDOR_DIR:-${FRAMEWORK_ROOT_DIR}/vendor}/shdoc" \
      "https://github.com/fchastanet/shdoc.git"; then
      echo "1" >"${BASH_FRAMEWORK_SHDOC_INSTALLED}"
    else
      Log::fatal "unable to install shdoc library"
    fi
  fi
}
