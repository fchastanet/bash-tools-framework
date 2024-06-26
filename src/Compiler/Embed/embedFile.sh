#!/usr/bin/env bash

# @description allows to embed selected file providing the given dirAlias
# @arg $1 file:string
# @arg $2 fileAlias:string
# @stdout the generated bin file extractor
#   this bin file extractor actually calls a function that will
#   extract the real binFile(base64 encoded)
# @env _COMPILE_ROOT_DIR
# @env PERSISTENT_TMPDIR to avoid file to be deleted by traps
# @see Compiler::Embed::embed
Compiler::Embed::embedFile() {
  local file="$1"
  local fileAlias="$2"
  local fileMd5sum

  fileMd5sum="$(md5sum "${file}" | Filters::firstField)"
  (
    base64="$(base64 -w 0 "${file}")" \
    asName="${fileAlias}" \
    fileMode="$(stat -c "%a" "${file}")" \
    targetFile="\${PERSISTENT_TMPDIR:-/tmp}/${fileMd5sum}/${fileAlias}" \
      envsubst <"${_COMPILE_ROOT_DIR}/src/Compiler/Embed/embedFile.tpl"
  )
}
