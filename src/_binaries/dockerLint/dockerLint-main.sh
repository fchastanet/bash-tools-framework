#!/usr/bin/env bash

Linux::requireJqCommand

# check if command in PATH is already the minimal version needed
if ! Version::checkMinimal "hadolint" "--version" "<% ${MIN_HADOLINT_VERSION} %>" >/dev/null 2>&1; then
  Github::upgradeRelease \
    "${FRAMEWORK_VENDOR_BIN_DIR}/hadolint" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
fi
# shellcheck disable=SC2046
if ((${#BASH_FRAMEWORK_ARGV_ONLY_ARG[@]} == 0)); then
  mapfile -t BASH_FRAMEWORK_ARGV_ONLY_ARG < <(
    git ls-files --exclude-standard | grep -E '/Dockerfile.*'
  )
fi
if ((BASH_FRAMEWORK_ARGS_VERBOSE >= __VERBOSE_LEVEL_DEBUG)); then
  set -x
fi
"${FRAMEWORK_VENDOR_BIN_DIR}/hadolint" \
  "${BASH_FRAMEWORK_ARGV_FILTERED[@]}" \
  "${BASH_FRAMEWORK_ARGV_ONLY_ARG[@]}"
set +x &>/dev/null
