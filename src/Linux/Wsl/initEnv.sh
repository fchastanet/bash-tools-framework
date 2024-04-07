#!/usr/bin/env bash

# @description initialize some important variables for scripts to run correctly
# when wsl installation is run under wsl is in progress
# @warning initialization skipped if script not run under wsl
# @noargs
# @set PATH String populated with WINDOW_PATH paths
# @set WSL_INTEROP String with current used process
# @set WSL_DISTRO_NAME String initialized using wslpath -m /
# @env WSL_INIT int 0 to disable wsl env initialization
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::initEnv() {
  if [[ "${WSL_INIT:-1}" = "0" ]]; then
    return 0
  fi
  if ! Assert::wsl; then
    return 0
  fi
  # Here we are parsing WINDOW_PATH env variable
  # for each path we remove potential control character
  # that could break PATH variable
  # using "${dir}" we ensure path with spaces will be
  # correctly handled
  local dir windowsDirs
  WINDOWS_PATH="$(wslvar PATH)"
  # shellcheck disable=SC2207,SC2116
  IFS=';' windowsDirs=($(echo "${WINDOWS_PATH}"))
  for dir in "${windowsDirs[@]}"; do
    dir="$(echo "${dir}" | tr -d '[:cntrl:]')"
    Env::pathPrepend "${dir}"
  done
  export PATH

  local p
  while IFS="" read -r p || [[ -n "${p}" ]]; do
    if [[ -e "/run/WSL/${p}_interop" ]]; then
      export WSL_INTEROP=/run/WSL/${p}_interop
      break
    fi
  done < <(
    pstree --numeric-sort --show-pids --show-parents $$ |
      head -1 |
      grep -o -E '[0-9]+' |
      tac
  )
  Linux::Wsl::cachedWslpath2 WSL_DISTRO_NAME -m /
  # eg: //wsl.localhost/UbuntuTest/
  WSL_DISTRO_NAME="${WSL_DISTRO_NAME%*/}"  # remove last slash
  WSL_DISTRO_NAME="${WSL_DISTRO_NAME##*/}" # keep last part after slash
  export WSL_DISTRO_NAME
}
