#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/dockerLint
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

DEFAULT_ARGS=(-f checkstyle)
MIN_HADOLINT_VERSION="2.12.0"
HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} hadolint wrapper
- installs new hadolint version(>${MIN_HADOLINT_VERSION}) automatically
- lint this project files using default files filter
- use the default options '${DEFAULT_ARGS[*]}' if no parameter specified

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <hadolint options>
EOF
)"
Args::defaultHelpNoExit "${HELP}" "$@" || true

# check if command in PATH is already the minimal version needed
if ! Version::checkMinimal "hadolint" "--version" "${MIN_HADOLINT_VERSION}" >/dev/null 2>&1; then
  Github::upgradeRelease \
    "${VENDOR_BIN_DIR}/hadolint" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
fi

if (($# == 0)); then
  set -- "${DEFAULT_ARGS[@]}"
fi
while IFS='' read -r file; do
  hadolint "$@" "${file}"
  echo
done < <(git ls-files --exclude-standard | grep -E '/Dockerfile.*' || true)
