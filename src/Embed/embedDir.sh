#!/usr/bin/env bash

# allow to embed selected directory providing the given dirAlias
# @arg $1 dir:string
# @arg $2 dirAlias:string
# @env _COMPILE_ROOT_DIR
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
Embed::embedDir() {
  local dir="$1"
  local dirAlias="$2"

  (
    base64="$(
      cd "${dir}" || exit 1
      tar -cz -O . | base64 -w 0
    )" \
    asName="${dirAlias}" \
    targetDir="\${TMPDIR:-/tmp}/${dirAlias}" \
      envsubst <"${_COMPILE_ROOT_DIR}/src/Embed/embedDir.tpl"
  )
}
