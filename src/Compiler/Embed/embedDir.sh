#!/usr/bin/env bash

# @description allow to embed selected directory providing the given dirAlias
# @arg $1 dir:string
# @arg $2 dirAlias:string
# @stdout the generated bin file extractor
#   this bin file extractor actually calls a function that will
#   extract the real binFile(base64 encoded)
# @env _COMPILE_ROOT_DIR
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
# @require Linux::requireTarCommand
# @see Compiler::Embed::embed
Compiler::Embed::embedDir() {
  local dir="$1"
  local dirAlias="$2"

  (
    base64="$(
      cd "${dir}" || exit 1
      tar --sort=name \
        --mtime="@0" \
        --owner=0 --group=0 --numeric-owner \
        --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime,delete=mtime \
        --no-same-owner \
        -cz -O . | base64 -w 0
    )" \
    asName="${dirAlias}" \
    targetDir="\${TMPDIR:-/tmp}/${dirAlias}" \
      envsubst <"${_COMPILE_ROOT_DIR}/src/Compiler/Embed/embedDir.tpl"
  )
}
