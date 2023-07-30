#!/usr/bin/env bash

# allow to embed selected directory providing the given dirAlias
# @param {string} dir $1
# @param {string} dirAlias $2
# @env _COMPILE_ROOT_DIR
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
Embed::embedFile() {
  local file="$1"
  local fileAlias="$2"

  (
    md5="$(base64 -w 0 "${file}")" \
    asName="${fileAlias}" \
    fileMode="$(stat -c "%a %n" "${file}" | awk '{print $1}')" \
    targetFile="\${PERSISTENT_TMPDIR:-/tmp}/bin/${fileAlias}" \
      envsubst <"${_COMPILE_ROOT_DIR}/src/Embed/embedFile.tpl"
  )
}
