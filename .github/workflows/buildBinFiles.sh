#!/usr/bin/env bash
ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/../.." && pwd -P)
SRC_DIR="$(cd "${ROOT_DIR}/src" && pwd -P)"
FRAMEWORK_DIR="${ROOT_DIR}"
export FRAMEWORK_DIR

# shellcheck source=src/_includes/_header.sh
source "${SRC_DIR}/_includes/_header.sh"

declare beforeBuild
computeMd5File() {
  local md5File="$1"
  while IFS= read -r file; do
    md5sum "${file}" >>"${md5File}" 2>&1 || true
  done < <(grep -R "# BIN_FILE" "${SRC_DIR}" | sed -E 's#^.*IN_FILE=(.*)$#\1#' | envsubst)
}

beforeBuild="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
computeMd5File "${beforeBuild}"

cat "${beforeBuild}"

"${ROOT_DIR}/build.sh"

# exit with code != 0 if at least one bin file has changed
if ! md5sum -c "${beforeBuild}"; then
  echo >&2 "some bin files need to be committed"
  exit 1
fi
