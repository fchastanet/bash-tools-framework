#!/usr/bin/env bash

# @description initialize some important variables for scripts to run correctly
# when wsl installation is run under wsl is in progress
# @warning initialization skipped if script not run under wsl
# @noargs
# @env WINDOW_PATH String use this env var to populate PATH with WINDOWS_PATH values
# @set PATH String populated with WINDOW_PATH paths
# @set WSL_INTEROP String with current used process
# @set WSL_DISTRO_NAME String initialized using wslpath -m /
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::initEnv() {
  if Assert::wsl; then
    # Here we are parsing WINDOW_PATH env variable
    # for each path we remove potential control character
    # that could break PATH variable
    # using "${dir}" we ensure path with spaces will be
    # correctly handled
    local dir, windowsDirs
    # shellcheck disable=SC2207,SC2116
    IFS=':' windowsDirs=($(echo "${WINDOW_PATH}"))
    for dir in "${windowsDirs[@]}"; do
      dir="$(echo "${dir}" | tr -d '[:cntrl:]')"
      Env::pathPrepend "${dir}"
    done
    export PATH

    local i
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
      if [[ -e "/run/WSL/${i}_interop" ]]; then
        export WSL_INTEROP=/run/WSL/${i}_interop
      fi
    done
    WSL_DISTRO_NAME="$(Linux::Wsl::cachedWslpath -m / | sed -E 's#.*\$/([^/]+)/$#\1#')"
    export WSL_DISTRO_NAME
  fi
}
