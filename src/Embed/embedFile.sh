#!/usr/bin/env bash

# allow to embed selected directory providing the given dirAlias
# @arg $1 dir:string
# @arg $2 dirAlias:string
# @env _COMPILE_ROOT_DIR
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
Embed::embedFile() {
  local file="$1"
  local fileAlias="$2"
  local fileMd5sum

  fileMd5sum="$(md5sum "${file}" | awk '{print $1}')"
  (
    base64="$(base64 -w 0 "${file}")" \
    asName="${fileAlias}" \
    fileMode="$(stat -c "%a %n" "${file}" | awk '{print $1}')" \
    targetFile="\${PERSISTENT_TMPDIR:-/tmp}/${fileMd5sum}/${fileAlias}" \
      envsubst <"${_COMPILE_ROOT_DIR}/src/Embed/embedFile.tpl"
  )
}
