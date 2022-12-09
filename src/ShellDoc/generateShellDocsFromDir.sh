#!/usr/bin/env bash

# generate doc + index
# @param {String} $1 fromDir
# @param {String} $2 docDir
# @param {String} $3 indexFile
ShellDoc::generateShellDocsFromDir() {
  local fromDir="$1"
  local docDir="$2"
  local indexFile="$3"

  while IFS= read -r relativeFile; do
    relativeFile="${relativeFile#./}"
    local basenameNoExtension="${relativeFile%.*}"
    local targetDocFile="${docDir}/${basenameNoExtension}.md"
    local targetDocDir

    # create target doc dir
    targetDocDir="$(dirname "${targetDocFile}")"
    mkdir -p "${targetDocDir}" || {
      Log::displayError "unable to create target doc directory ${targetDocDir}"
      return 1
    }

    # generate markdown file from shell file
    Log::displayInfo "generate markdown doc for ${relativeFile} in ${targetDocFile}"

    if ShellDoc::generateShellDocFile "${fromDir}" "${relativeFile}" "${targetDocFile}"; then
      ShellDoc::appendDocToIndex "${indexFile}" "${relativeFile}" "${basenameNoExtension}"
    fi
  done < <(cd "${fromDir}" && find . -name "*.sh" | sort)
}
