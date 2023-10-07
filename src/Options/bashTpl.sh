#!/usr/bin/env bash

# @description use bash-tpl to render a template
# allows also to catch eventual errors from bash-tpl
# to fail if errors found
# @arg $1 tplFile:String the template to render
# @exitcode 1 if error found during rendering
# @stdout the file rendered
# @stderr diagnostics information is displayed
Options::bashTpl() {
  local tplFile="$1"
  (
    # make srcDirs array available for dynamicSrcFile and dynamicSrcDir
    trap 'rm -f "${bashTplLogFile}" || true' INT EXIT HUP QUIT ABRT TERM
    local bashTplLogFile
    bashTplLogFile="$(Framework::createTempFile "bashTplLogFile")"
    # shellcheck source=/dev/null
    source <("${_COMPILE_ROOT_DIR}/bin/bash-tpl" "${tplFile}" 2>"${bashTplLogFile}")
    wait $!
    if [[ -s "${bashTplLogFile}" ]]; then
      Log::displayError "bash-tpl found some errors"
      cat >&2 "${bashTplLogFile}"
      exit 1
    fi
  )
}
