#!/usr/bin/env bash

# @description generate shell doc file from given directory
#
# @arg $1 dir:String
# @arg $2 relativeDir:String
# @arg $3 targetDocFile:String the markdown file generated using shdoc
# @arg $4 repositoryUrl:String base url for src file (eg:https://github.com/fchastanet/bash-tools-framework)
# @arg $5 excludeFilesPattern:String grep exclude pattern. Eg: '(/_\.sh|/ZZZ\.sh|/__all\.sh)$'
# @exitcode 0 if file has been generated
# @exitcode 1 if file is empty or error
ShellDoc::generateShellDocDir() {
  local dir="$1"
  local relativeDir="$2"
  local targetDocFile="$3"
  local repositoryUrl="${4:-}"
  local excludeFilesPattern="${5:-}"
  local namespaceFile
  local relativeFile

  local -a grepExclude
  if [[ -z "${excludeFilesPattern}" ]]; then
    grepExclude=(cat)
  else
    grepExclude=(grep -E -v "${excludeFilesPattern}")
  fi

  namespaceFile="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-shdoc-namespace-XXXXXX)"
  Log::displayInfo "Generating ${targetDocFile} based on ${namespaceFile}"

  (
    local firstFile=1
    # generate one big sh file with all sh files of the directory
    echo '#!/usr/bin/env bash' >"${namespaceFile}"
    echo "# @name ${relativeDir}" >>"${namespaceFile}"
    while IFS= read -r relativeFile; do
      relativeFile="${relativeFile#./}"
      (
        if [[ "${firstFile}" = "1" && "${relativeFile}" != "_.sh" ]]; then
          (
            echo "# @description Directory ${relativeDir}"
            echo
          ) >>"${namespaceFile}"
        fi

        echo "# @section ${relativeDir}/${relativeFile}"
        if [[ -n "${repositoryUrl}" ]]; then
          echo "# @description [file source ${relativeDir}/${relativeFile}](${repositoryUrl}/tree/master/${relativeDir}/${relativeFile})"
        else
          echo "# @description file source ${relativeDir}/${relativeFile}"
        fi
        # remove shebang/unwanted strings
        sed -E \
          -e '1d' \
          -e '/^[ \t]*# cspell:/d' \
          -e '/^[ \t]*# jscpd:/d' \
          -e '/^[ \t]*# shellcheck /d' \
          "${dir}/${relativeFile}"
      ) >>"${namespaceFile}"
      firstFile=0
    done < <(cd "${dir}" && find . -maxdepth 1 -name "*.sh" | "${grepExclude[@]}" | LC_ALL=C sort)

    local doc
    doc="$(ShellDoc::generateShellDoc "${namespaceFile}")"
    if (("$(grep -c . <<<"${doc}")" > 1)); then
      # remove index that is auto managed by docsify
      # increment title level by one (#)
      sed -E \
        -e '/^## Index/,/## /d' \
        -e 's/^(##*) (.*)$/#\1 \2/' \
        <<<"${doc}" >"${targetDocFile}"
      return 0
    else
      return 1
    fi
  )
}
