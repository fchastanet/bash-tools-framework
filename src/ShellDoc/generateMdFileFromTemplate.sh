#!/usr/bin/env bash

# generate markdown file from template by replacing
# @@@command_help@@@ by the help of the command
# eg: @@@test_help@@@ will be replaced by the output
# of the command `test --help` in the directory provided
# @param {String} $1 templateFile the file to use as template
# @param {String} $2 targetFile the target file
# @param {String} $3 fromDir the directory from which commands will be searched
# @param {int} $4 tokenNotFoundCount passed by reference, will return
#    the number of tokens @@@command_help@@@ not found in the template file
# @param {String} excludeFilesPattern $5 grep exclude pattern
#   eg: '^(bash-tpl)$'
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
      ) || Log::displayError "$(realpath "${fromDir}/${relativeFile}" --relative-to="${ROOT_DIR}") --help error caught"
    else
      ((++tokenNotFoundCount))
      Log::displayWarning "token ${token} not found in ${targetFile}"
    fi
    ((nbTokensGenerated++)) || true
  done < <(cd "${fromDir}" && find . -type f -executable | "${grepExclude[@]}")
  endTime=$(date +%s.%3N)
  Log::displayInfo "${nbTokensGenerated} commands' help replaced in $(echo "scale=3; ${endTime} - ${startTime}" | bc)seconds"
}
