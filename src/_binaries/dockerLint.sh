#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/dockerLint
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options.dockerLint.tpl)"

dockerLintCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

run() {
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
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
