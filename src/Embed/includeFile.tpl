Embed::extractFile_${asName}() {
  if [[ ! -f "${targetFile}" ]]; then
    mkdir -p "$(dirname "${targetFile}")"
    base64 -d >"${targetFile}" <<<"${md5}"
    chmod "${fileMode}" "${targetFile}"
  fi
}

Embed::extractFile_${asName}

declare -gx embed_file_${asName}="${targetFile}"
