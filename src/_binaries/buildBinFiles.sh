#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/buildBinFiles
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

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
Args::defaultHelp "${HELP}" "$@"

declare beforeBuild
computeMd5File() {
  local md5File="$1"
  while IFS= read -r file; do
    md5sum "${file}" >>"${md5File}" 2>&1 || true
  done < <(
    grep -R "^# BIN_FILE" "${SRC_DIR}/_binaries" |
      (grep -v -E '/testsData/' || true) |
      sed -E 's#^.*IN_FILE=(.*)$#\1#' |
      envsubst
  )
}

beforeBuild="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
computeMd5File "${beforeBuild}"

cat "${beforeBuild}"

"${ROOT_DIR}/build.sh"

# allows to add ignore missing option to md5sum when using pre-commit
declare -a args=("${@}")
# exit with code != 0 if at least one bin file has changed
if ! md5sum -c "${args[@]}" "${beforeBuild}"; then
  echo >&2 "some bin files need to be committed"
  exit 1
fi
