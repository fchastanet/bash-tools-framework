declare -gx embed_function_<%% echo ${asName} %>="<%% echo ${targetFile} %>"
declare -gx encoded_binary_file_<%% echo ${asName} %>="<%% echo ${binFileBase64} %>"

Compiler::Embed::extractFileFromBase64 \
  "${embed_function_<%% echo ${asName} %>}" \
  "${encoded_binary_file_<%% echo ${asName} %>}"
