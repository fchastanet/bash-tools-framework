#!/usr/bin/env bash

# allow to embed selected directory providing the given dirAlias
# @param {string} dir $1
# @param {string} dirAlias $2
# @env _COMPILE_ROOT_DIR
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
Embed::includeDir() {
  local dir="$1"
  local dirAlias="$2"

  (
    md5="$(
      cd "${dir}" || exit 1
      tar -cz -O . | base64 -w 0
    )" \
    asName="${dirAlias}" \
    targetDir="\${TMPDIR:-/tmp}/${dirAlias}" \
      envsubst <"${_COMPILE_ROOT_DIR}/src/Embed/includeDir.tpl"
  )
}
