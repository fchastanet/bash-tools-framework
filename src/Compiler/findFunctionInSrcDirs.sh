#!/usr/bin/env bash

# convert function name to path replacing :: by /
convertFunctionNameToPath() {
  local functionName="$1"
  echo "$(sed -E 's#::#/#g' <<<"${functionName}").sh"
}

# return the path of the function found in srcDirs
# @arg $1 functionName:String function name (eg: Functions::myFunction)
# @arg $@ srcDirs:String[] rest of args list of src directories in
# which the function will be searched
# @exitcode 1 if function not found, 0 if found
# @stdout the filepath of the function
Compiler::findFunctionInSrcDirs() {
  local functionName="$1"
  shift || true
  local -a srcDirs=("$@")
  local fileNameToImport

  fileNameToImport="$(convertFunctionNameToPath "${functionName}")"

  # search through srcDirs the file to import
  for srcDir in "${srcDirs[@]}"; do
    fileToImport="${srcDir}/${fileNameToImport}"
    if [[ -f "${fileToImport}" ]]; then
      # we found it
      echo "${fileToImport}"
      return 0
    fi
  done

  return 1
}
