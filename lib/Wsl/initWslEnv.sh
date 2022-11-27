#!/usr/bin/env bash

Wsl::initEnv() {
  if Assert::wsl; then
    # Here we are parsing WINDOW_PATH env variable
    # for each path we remove potential control character
    # that could break PATH variable
    # using "${dir}" we ensure path with spaces will be
    # correctly handled
    # shellcheck disable=SC2207,SC2116
    IFS=':' windowsDirs=($(echo "${WINDOW_PATH}"))
    for dir in "${windowsDirs[@]}"; do
      dir="$(echo "${dir}" | tr -d '[:cntrl:]')"
      export PATH="${dir}":${PATH}
    done

    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
      if [[ -e "/run/WSL/${i}_interop" ]]; then
        export WSL_INTEROP=/run/WSL/${i}_interop
      fi
    done
    WSL_DISTRO_NAME="$(Wsl::cachedWslpath -m / | sed -r 's#.*\$/([^/]+)/$#\1#')"
    export WSL_DISTRO_NAME
  fi
}
