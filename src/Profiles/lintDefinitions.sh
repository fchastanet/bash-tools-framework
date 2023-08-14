#!/usr/bin/env bash

# ensure all methods called dynamically are imported
# import Log::displayError
# import Log::displaySkipped
# import Log::displayWarning

# formatter plain
ProfilesLintDefinitionsHeader_plain() {
  true
}
ProfilesLintDefinitionsFileStart_plain() {
  true
}
ProfilesLintDefinitionsFileMsg_plain() {
  local file="$1"
  local severity="$2"
  local msg="$3"
  # to avoid frameworkLint to detect "Log :: display" as a missing definition
  local separator="::"
  "Log${separator}display${severity^}" "File ${file} - ${msg}"
}
ProfilesLintDefinitionsFileEnd_plain() {
  true
}
ProfilesLintDefinitionsFooter_plain() {
  local errorCount="$1"
  if [[ "${errorCount}" = "0" ]]; then
    Log::displaySuccess "No lint error found !"
  else
    Log::displayError "${errorCount} errors has been found"
  fi
}

# formatter checkstyle
ProfilesLintDefinitionsHeader_checkstyle() {
  echo "<?xml version='1.0' encoding='UTF-8'?>"
  echo "<checkstyle>"
}
ProfilesLintDefinitionsFileStart_checkstyle() {
  local file="$1"
  echo "<file name='${file}'>"
}
ProfilesLintDefinitionsFileMsg_checkstyle() {
  local file="$1"
  local severity="$2"
  local msg="$3"
  echo "<error severity='${severity}' message='$(echo "${msg}" | sed -E "s/'/\&quot;/g")'/>"
}
ProfilesLintDefinitionsFileEnd_checkstyle() {
  local file="$1"
  echo "</file>"
}
ProfilesLintDefinitionsFooter_checkstyle() {
  echo "</checkstyle>"
}

# @description  linter that allows to check if a list of
# methods is defined in each sh file of given scriptsDir
# @arg $1 scriptsDir:String the directory to check
# @arg $2 format:String can be plain or checkstyle
# @arg $@ args:String[]
# @exitcode 1 if errorCount > 0
# @stderr diagnostics information is displayed
Profiles::lintDefinitions() {
  local scriptsDir="$1"
  local format="$2"
  local -a mandatoryMethods=(
    helpDescription
    helpVariables
    listVariables
    defaultVariables
    checkVariables
    fortunes
    dependencies
    breakOnConfigFailure
    breakOnTestFailure
    install
    configure
    "test"
  )
  local errorCount
  ((errorCount = 0)) || true
  "ProfilesLintDefinitionsHeader_${format}"

  while IFS= read -r relativeScriptFile; do
    ProfilesLintDefinitionFile "${scriptsDir}" "${relativeScriptFile}" "${format}" ||
      ((errorCount += $?))
  done < <(ProfilesListDefinitionsFiles "${scriptsDir}")

  "ProfilesLintDefinitionsFooter_${format}" "${errorCount}"

  ((errorCount == 0))
}

ProfilesListDefinitionsFiles() {
  local scriptsDir="$1"
  find "${scriptsDir}" -type f -name '*.sh' | sed -E "s#^${scriptsDir}/##" | sort
}

ProfilesGetScriptNameFromRelativeScriptFile() {
  local relativeScriptFile="$1"
  local scriptName
  scriptName="$(basename "${relativeScriptFile}")"
  echo "${scriptName%.sh}"
}

ProfilesLintDefinitionFile() {
  local scriptsDir="$1"
  local relativeScriptFile="$2"
  local format="$3"
  local scriptName fullMethodName relativeScriptFile errorCount
  local errorCount
  ((errorCount = 0)) || true

  scriptName="$(ProfilesGetScriptNameFromRelativeScriptFile "${relativeScriptFile}")"

  "ProfilesLintDefinitionsFileStart_${format}" "${relativeScriptFile}"

  # load each script and check methods validity
  ( #
    ((errors = 0)) || true
    # remove all the methods defined
    # shellcheck disable=SC2046
    declare -a functions
    readarray -t functions < <(
      declare -f -F | grep -E '^declare -f installScripts_' | cut -f 3 -d' '
    )
    if ((${#functions[@]} > 0)); then
      unset -f "${functions[@]}" || true
    fi

    # shellcheck source=src/Profiles/testsData/allDepsRecursive/installScripts/Install1.sh
    source "${scriptsDir}/${relativeScriptFile}"

    # check if other definitions files functions are defined by this definition file
    # it would mean that another file has defined the same methods
    local relativeOtherScriptFile
    while IFS= read -r relativeOtherScriptFile; do
      if [[ "${relativeOtherScriptFile}" = "${relativeScriptFile}" ]]; then
        continue
      fi
      local otherScriptName
      otherScriptName="$(ProfilesGetScriptNameFromRelativeScriptFile "${relativeOtherScriptFile}")"
      local otherScriptMethods
      otherScriptMethods="$(declare -f -F | grep -E "^declare -f installScripts_${otherScriptName}_" | sed -E 's/declare -f //g')"
      if [[ -n "${otherScriptMethods}" ]]; then
        "ProfilesLintDefinitionsFileMsg_${format}" "${relativeScriptFile}" "error" \
          "Methods ${otherScriptMethods} should be defined in ${otherScriptName}.sh file"
        ((++errors))
      fi
    done < <(ProfilesListDefinitionsFiles "${scriptsDir}")

    # check that all mandatory methods exists
    for method in "${mandatoryMethods[@]}"; do
      fullMethodName="installScripts_${scriptName}_${method}"
      if ! declare -f -F "${fullMethodName}" &>/dev/null; then
        "ProfilesLintDefinitionsFileMsg_${format}" "${relativeScriptFile}" "error" \
          "Method ${fullMethodName} does not exist, check that following methods exists (${mandatoryMethods[*]})"
        ((++errors))
        # stop at first method missing
        break
      fi
      # check if each dependency exists
      if [[ "${method}" = "dependencies" ]]; then
        while IFS= read -r dep; do
          if [[ ! -f "${scriptsDir}/${dep}.sh" ]]; then
            "ProfilesLintDefinitionsFileMsg_${format}" "${relativeScriptFile}" "error" \
              "unknown dependency '${dep}' specified in '${fullMethodName}'"
            ((++errors))
          fi
        done < <("${fullMethodName}")
      fi
    done

    return "${errors}"
  ) || ((errorCount += $?))

  "ProfilesLintDefinitionsFileEnd_${format}" "${relativeScriptFile}"

  return "${errorCount}"
}
