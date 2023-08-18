Compiler::Embed::extractFileFromBase64 "${targetFile}" "${base64}" "${fileMode}"

declare -gx embed_file_${asName}="${targetFile}"
