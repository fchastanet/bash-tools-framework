#!/usr/bin/env bash

# generate markdown file from template by replacing
# @@@command_help@@@ by the help of the command
# eg: @@@test_help@@@ will be replaced by the output
# of the command `test --help` in the directory provided
#
# @arg $1 templateFile:String the file to use as template
# @arg $2 targetFile:String the target file
# @arg $3 fromDir:String the directory from which commands will be searched
# @arg $4 tokenNotFoundCount:int passed by reference, number of tokens @@@command_help@@@ not found in the template file
# @arg $5 excludeFilesPattern:String grep exclude pattern (eg: '^(bash-tpl)$')
ShellDoc::generateMdFileFromTemplate() {
  local templateFile="$1"
  local targetFile="$2"
  local fromDir="$3"
  local -n tokenNotFoundCount=$4
  local excludeFilesPattern="${5:-}"

  local -a grepExclude
  local startTime endTime

  if [[ -z "${excludeFilesPattern}" ]]; then
    grepExclude=(cat)
  else
    grepExclude=(grep -E -v "${excludeFilesPattern}")
  fi

  cp "${templateFile}" "${targetFile}"

  startTime=$(date +%s.%3N)
  ((nbTokensGenerated = 0)) || true
  while IFS= read -r relativeFile; do
    local token="${relativeFile#./}"
    token="${token////_}"
    if grep -q "@@@${token}_help@@@" "${targetFile}"; then
      Log::displayInfo "generate help for ${token}"
      ( #
        (cd "${fromDir}" && "${relativeFile}" --help) |
          File::replaceTokenByInput "@@@${token}_help@@@" "${targetFile}"
      ) || Log::displayError "$(realpath "${fromDir}/${relativeFile}" --relative-to="${FRAMEWORK_ROOT_DIR}") --help error caught"
    else
      ((++tokenNotFoundCount))
      Log::displayWarning "token ${token} not found in ${targetFile}"
    fi
    ((nbTokensGenerated++)) || true
  done < <(cd "${fromDir}" && find . -type f -executable | "${grepExclude[@]}")
  endTime=$(date +%s.%3N)
  Log::displayInfo "${nbTokensGenerated} commands' help replaced in $(echo "scale=3; ${endTime} - ${startTime}" | bc)seconds"
}
