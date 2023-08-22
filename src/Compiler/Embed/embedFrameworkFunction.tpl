# @require Compiler::Embed::requireEmbedBinDir

declare -gx embed_function_<% ${asName} %>="<% ${targetFile} %>"
declare -gx encoded_binary_file_<% ${asName} %>="<% ${binFileBase64} %>"

Compiler::Embed::extractFileFromBase64 \
  "${embed_function_<% ${asName} %>}" \
  "${encoded_binary_file_<% ${asName} %>}"
