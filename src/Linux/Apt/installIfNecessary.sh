#!/usr/bin/env bash

# @description apt-get install if package is not installed yet
# @arg $@ packages:String[] list of packages to install
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
# @env SKIP_APT_GET_UPDATE
# @stdout diagnostics logs
Linux::Apt::installIfNecessary() {
  local -a packages=("$@")
  local package
  local -i installNeeded=0
  for package in "${packages[@]}"; do
    if [[ "${package}" =~ ^[-]{1,2} ]]; then
      continue
    fi
    if ! Linux::Apt::isPackageInstalled "${package}"; then
      Log::displayInfo "Package ${package} is not installed"
      installNeeded=1
    fi
  done
  if ((installNeeded == 1)); then
    if [[ "${SKIP_APT_GET_UPDATE:-0}" = "0" ]]; then
      Linux::Apt::update
    fi
    Linux::Apt::install "${packages[@]}"
    for package in "${packages[@]}"; do
      if [[ "${package}" =~ ^-- ]]; then
        continue
      fi
      if ! Linux::Apt::isPackageInstalled "${package}"; then
        Log::displayWarning "Package ${package} does not appear to have been installed, check if you could have chosen the wrong package name (Eg: python3.9-distutils instead of python3-distutils)"
      fi
    done
  else
    Log::displayInfo "Apt install avoided as packages are already installed : ${packages[*]}"
  fi
}
