#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/buildBinFiles
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.buildBinFiles.tpl)"

buildBinFilesCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

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

run() {
  beforeBuild="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
  computeMd5File "${beforeBuild}"

  cat "${beforeBuild}"

  "${FRAMEWORK_ROOT_DIR}/build.sh"

  # allows to add ignore missing option to md5sum when using pre-commit
  declare -a args=()
  # shellcheck disable=SC2154
  if [[ "${optionIgnoreMissing}" = "1" ]]; then
    args+=(--ignore-missing)
  fi
  # exit with code != 0 if at least one bin file has changed
  if ! md5sum -c "${args[@]}" "${beforeBuild}"; then
    echo >&2 "some bin files need to be committed"
    exit 1
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
