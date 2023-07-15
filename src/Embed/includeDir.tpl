Embed::extractDir_${asName}() {
  if [[ ! -d "${targetDir}" ]]; then
    mkdir -p "${targetDir}"
    (
      cd "${targetDir}" || exit 1
      tar -xzf <(base64 -d <<<"${md5}")
    ) || return 1
  fi
}

Embed::extractDir_${asName}

declare -gx embed_dir_${asName}="${targetDir}"
