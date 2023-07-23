declare -gx embed_function_<%% echo ${asName} %>="<%% echo ${targetFile} %>"
declare -gx encoded_binary_file_<%% echo ${asName} %>="<%% echo ${binFileMd5} %>"

Embed::extractFileFromMd5 \
  "${embed_function_<%% echo ${asName} %>}" \
  "${encoded_binary_file_<%% echo ${asName} %>}"
