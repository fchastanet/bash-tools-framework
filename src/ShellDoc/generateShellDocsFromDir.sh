#!/usr/bin/env bash

# @description generate doc + index
# @arg $1 fromDir:String
# @arg $2 fromDirRelative:String
# @arg $3 docDir:String
# @arg $4 indexFile:String
# @arg $5 repositoryUrl:String base url for src file (eg:https://github.com/fchastanet/bash-tools-framework)
# @arg $6 excludeDirectoriesPattern:String grep exclude pattern. Eg: '/testsData|/_.*'
# @arg $7 excludeFilesPattern:String grep exclude pattern. Eg: '(/_\.sh|/ZZZ\.sh|/__all\.sh)$'
ShellDoc::generateShellDocsFromDir() {
  local fromDir="$1"
  local fromDirRelative="$2"
  local docDir="$3"
  local indexFile="$4"
  local repositoryUrl="${5:-}"
  local excludeDirectoriesPattern="${6:-}"
  local excludeFilesPattern="${7:-}"

  # exclude dir pattern
  local -a grepExclude
  if [[ -z "${excludeDirectoriesPattern}" ]]; then
    grepExclude=(cat)
  else
    grepExclude=(grep -E -v "${excludeDirectoriesPattern}")
  fi

  # generate one .md per directory
  local relativeDir
  local targetDocFile
  local targetDocFileRelative

  while IFS= read -r relativeDir; do
    relativeDir="${relativeDir#./}"
    targetDocFile="${docDir}/${relativeDir}.md"
    targetDocFileRelative="$(realpath --canonicalize-missing --relative-to "${indexFile%/*}" "${targetDocFile}")"

    local targetDocFileDir="${targetDocFile%/*}"
    if [[ ! -d "${targetDocFileDir}" ]]; then
      mkdir -p "${targetDocFileDir}" || true
    fi
    if ShellDoc::generateShellDocDir \
      "${fromDir}/${relativeDir}" \
      "${fromDirRelative}/${relativeDir}" \
      "${targetDocFile}" \
      "${repositoryUrl}" \
      "${excludeFilesPattern}" && [[ -n "$(tail -n +6 "${targetDocFile}")" ]]; then
      ShellDoc::appendDocToIndex "${indexFile}" "${targetDocFileRelative}" "${relativeDir}"
    else
      rm -f "${targetDocFile}" || true
      Log::displaySkipped "${fromDir}/${relativeDir} does not contain any documentation"
    fi
  done < <(cd "${fromDir}" && find . -type d -name '[^.]*' | "${grepExclude[@]}" | LC_ALL=C sort)
}
