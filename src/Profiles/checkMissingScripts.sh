#!/usr/bin/env bash

Profiles::checkMissingScripts() {
  local -a missingInstallScripts=()
  local -a missingConfigureScripts=()
  local -a missingTestScripts=()
  local -a missingDependencies=()

  while IFS= read -r line; do
    if [[ ! -f "${SCRIPTS_DIR}/${line}/install" ]]; then
      missingInstallScripts+=("${line}/install")
    fi

    if [[ ! -f "${SCRIPTS_DIR}/${line}/configure" ]]; then
      missingConfigureScripts+=("${line}/configure")
    fi

    if [[ ! -f "${SCRIPTS_DIR}/${line}/test" ]]; then
      missingTestScripts+=("${line}/test")
    fi

    while IFS= read -r dep; do
      if [[ ! -d "${SCRIPTS_DIR}/${dep}" ]]; then
        missingDependencies+=("unknown dependency '${dep}' in ${line}/dependencies")
      fi
    done < <(deps "${line}")

  done < <(cd "${SCRIPTS_DIR}/" && find . -maxdepth 1 -type d | sed -e 's#^./##g' | grep -v '^.$')

  if [[ ${#missingInstallScripts[@]} != 0 ]]; then
    Log::displayError "missing install script in '${SCRIPTS_DIR}/'"
    (printf >&2 '%s\n' "${missingInstallScripts[@]}")
  fi
  if [[ ${#missingConfigureScripts[@]} != 0 ]]; then
    Log::displayError "missing configure script in '${SCRIPTS_DIR}/'"
    (printf >&2 '%s\n' "${missingConfigureScripts[@]}")
  fi
  if [[ ${#missingTestScripts[@]} != 0 ]]; then
    Log::displayError "missing test script in '${SCRIPTS_DIR}/'"
    (printf >&2 '%s\n' "${missingTestScripts[@]}")
  fi
  if [[ ${#missingDependencies[@]} != 0 ]]; then
    Log::displayError "missing dependencies folder in '${SCRIPTS_DIR}/'"
    (printf >&2 '%s\n' "${missingDependencies[@]}")
  fi
  if [[ ${#missingInstallScripts[@]} != 0 || ${#missingConfigureScripts[@]} != 0 || ${#missingTestScripts[@]} != 0 || ${#missingDependencies[@]} != 0 ]]; then
    Log::displayError "at least one script(install, config or test) or dependency is missing"
    return 1
  fi

  return 0
}
