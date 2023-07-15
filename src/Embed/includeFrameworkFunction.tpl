Embed::extractFunction_${asName}() {
  if [[ ! -f "${targetFile}" ]]; then
    mkdir -p "$(dirname "${targetFile}")"
    base64 -d >"${targetFile}" <<<"${md5}"
    chmod +x "${targetFile}"
  fi
}

Embed::extractFunction_${asName}
Env::pathPrepend "$(dirname "${targetFile}")"

declare -gx embed_function_${asName}="${targetFile}"
