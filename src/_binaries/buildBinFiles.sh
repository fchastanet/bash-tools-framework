#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/buildBinFiles
# IMPLEMENT Compiler::Implement::MainInterface

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"
FRAMEWORK_ROOT_DIR="$(cd "${CURRENT_DIR}/.." && pwd -P)"
FRAMEWORK_SRC_DIR="${FRAMEWORK_ROOT_DIR}/src"
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_load.tpl"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} build files using build.sh
and check if bin file has been updated, if yes return exit code > 0

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--ignore-missing]

    --ignore-missing  do not exit with error for missing files
                      useful when committing because were not existing before

INTERNAL TOOL

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"

main() {
  Args::defaultHelp "${HELP}" "$@"

  declare beforeBuild
  computeMd5File() {
    local md5File="$1"
    local currentFile
    while IFS= read -r file; do
      currentFile="$(FRAMEWORK_ROOT_DIR=${FRAMEWORK_ROOT_DIR} envsubst <<<"${file}")"
      md5sum "${currentFile}" >>"${md5File}" 2>&1 || true
    done < <(
      grep -R "^# BIN_FILE" "${FRAMEWORK_SRC_DIR}/_binaries" |
        (grep -v -E '/testsData/' || true) |
        sed -E 's#^.*IN_FILE=(.*)$#\1#'
    )
  }

  beforeBuild="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
  computeMd5File "${beforeBuild}"

  cat "${beforeBuild}"

  "${FRAMEWORK_ROOT_DIR}/build.sh"

  # allows to add ignore missing option to md5sum when using pre-commit
  declare -a args=("${@}")
  # exit with code != 0 if at least one bin file has changed
  if ! md5sum -c "${args[@]}" "${beforeBuild}"; then
    echo >&2 "some bin files need to be committed"
    exit 1
  fi
}

main "$@"
