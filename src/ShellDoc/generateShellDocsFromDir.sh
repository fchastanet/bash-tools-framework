#!/usr/bin/env bash

# generate doc + index
# @param {String} $1 fromDir
# @param {String} $2 docDir
# @param {String} $3 indexFile
# @param {String} excludeFilesPattern $4 grep exclude pattern
#   eg: '(/_\.sh|/ZZZ\.sh|_includes/.*\.sh|/__all\.sh)$'
ShellDoc::generateShellDocsFromDir() {
  local fromDir="$1"
  local docDir="$2"
  local indexFile="$3"
  local excludeFilesPattern="${4:-}"
  local -a grepExclude
  local startTime endTime

  if [[ -z "${excludeFilesPattern}" ]]; then
    grepExclude=(cat)
  else
    grepExclude=(grep -E -v "${excludeFilesPattern}")
  fi

  startTime=$(date +%s.%3N)
  ((nbFilesGenerated = 0)) || true
  while IFS= read -r relativeFile; do
    relativeFile="${relativeFile#./}"
    local basenameNoExtension="${relativeFile%.*}"
    local targetDocFile="${docDir}/${basenameNoExtension}.md"
    local targetDocDir
    local targetDocFileRelative
    targetDocFileRelative="$(realpath --canonicalize-missing --relative-to "$(dirname "${indexFile}")" "${targetDocFile}")"

    # create target doc dir
    targetDocDir="$(dirname "${targetDocFile}")"
    mkdir -p "${targetDocDir}" || {
      Log::displayError "unable to create target doc directory ${targetDocDir}"
      return 1
    }

    # generate markdown file from shell file
    Log::displayInfo "generate markdown doc for ${relativeFile} in ${targetDocFile}"

    if ShellDoc::generateShellDocFile "${fromDir}" "${relativeFile}" "${targetDocFile}"; then
      ShellDoc::appendDocToIndex "${indexFile}" "${targetDocFileRelative}" "${basenameNoExtension}"
    fi
    ((nbFilesGenerated++)) || true
  done < <(cd "${fromDir}" && find . -name "*.sh" | "${grepExclude[@]}" | sort)
  endTime=$(date +%s.%3N)
  Log::displayInfo "${nbFilesGenerated} files generated in $(echo "scale=3; ${endTime} - ${startTime}" | bc)seconds"
}
