#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/dockerLint

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"
FRAMEWORK_ROOT_DIR="$(cd "${CURRENT_DIR}/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_load.tpl"

DEFAULT_ARGS=(-f checkstyle)
MIN_HADOLINT_VERSION="2.12.0"
HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} hadolint wrapper
- installs new hadolint version(>${MIN_HADOLINT_VERSION}) automatically
- lint this project files using default files filter
- use the default options '${DEFAULT_ARGS[*]}' if no parameter specified

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <hadolint options>

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
Args::defaultHelpNoExit "${HELP}" "$@" || true

# check if command in PATH is already the minimal version needed
if ! Version::checkMinimal "hadolint" "--version" "${MIN_HADOLINT_VERSION}" >/dev/null 2>&1; then
  Github::upgradeRelease \
    "${FRAMEWORK_VENDOR_BIN_DIR}/hadolint" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
fi

if (($# == 0)); then
  set -- "${DEFAULT_ARGS[@]}"
fi

# shellcheck disable=SC2046
"${FRAMEWORK_VENDOR_BIN_DIR}/hadolint" "$@" $(git ls-files --exclude-standard | grep -E '/Dockerfile.*')
