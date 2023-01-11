#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/shellcheckLint
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

if [[ -z "${DEFAULT_ARGS+unset}" ]]; then
  DEFAULT_ARGS=(--source-path=SCRIPTDIR --check-sourced -x -f checkstyle)
fi
MIN_SHELLCHECK_VERSION="0.9.0"
HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} shellcheck wrapper
- installs new shellcheck version(>${MIN_SHELLCHECK_VERSION}) automatically
- lint this project files using default files filter
- use the default options '${DEFAULT_ARGS[*]}' if no parameter specified

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <shellcheck options>

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"

EOF
)"
Args::defaultHelpNoExit "${HELP}" "$@" || true

# check if command in PATH is already the minimal version needed
if ! Version::checkMinimal "shellcheck" "--version" "${MIN_SHELLCHECK_VERSION}" >/dev/null 2>&1; then
  install() {
    local file="$1"
    local targetFile="$2"
    local version="$3"
    local tempDir
    tempDir="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-framework-shellcheck-$$-XXXXXX)"
    (
      cd "${tempDir}" || exit 1
      tar -xJvf "${file}"
      mv "shellcheck-v${version}/shellcheck" "${targetFile}"
      chmod +x "${targetFile}"
    )
  }
  Github::upgradeRelease \
    "${VENDOR_BIN_DIR}/shellcheck" \
    "https://github.com/koalaman/shellcheck/releases/download/v@latestVersion@/shellcheck-v@latestVersion@.linux.x86_64.tar.xz" \
    "--version" \
    Version::getCommandVersionFromPlainText \
    install
fi

if (($# == 0)); then
  set -- "${DEFAULT_ARGS[@]}"
fi

(
  # shellcheck disable=SC2046
  LC_ALL=C.UTF-8 shellcheck "$@" \
    $(git ls-files --exclude-standard | grep -E '\.(sh|bats)$' || true)
)
