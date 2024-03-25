#!/usr/bin/env bash

# @description add the line ip hostname at the end of /etc/hosts only if hostname does not exists yet in this file
# if wsl do the same in ${BASE_MNT_C}/Windows/System32/drivers/etc/hosts
# @warning files are backup before being updated
# @arg $1 hostName:String
# @arg $2 ip:String optional, default value: 127.0.0.1
# @env BASE_MNT_C String
# @stderr diagnostics information is displayed
# @env SUDO String allows to use custom sudo prefix command
# @require Git::requireGitCommand
# @require Linux::requireSudoCommand
# @feature Retry::default
Dns::addHost() {
  local hostName="$1"
  local ip="${2:-127.0.0.1}"
  local -a cmd

  if ! grep -q -E "[[:space:]]${hostName}([[:space:]]|$)" /etc/hosts; then
    SUDO=${SUDO:-} Backup::file /etc/hosts
    printf '%s\t%s\n' "${ip}" "${hostName}" | ${SUDO:-} tee -a /etc/hosts
    Log::displaySuccess "Host ${hostName} added to /etc/hosts"
  fi
  if Assert::wsl; then
    [[ -f "${BASE_MNT_C}/Windows/System32/drivers/etc/hosts" ]] || return 1
    if ! dos2unix <"${BASE_MNT_C}/Windows/System32/drivers/etc/hosts" | grep -q -E "[[:space:]]${hostName}([[:space:]]|$)"; then
      SUDO=${SUDO:-} Backup::file "${BASE_MNT_C}/Windows/System32/drivers/etc/hosts"
      cmd=(
        -ExecutionPolicy Bypass
        -NoProfile
        -Command Add-Content -Path "c:/Windows/System32/drivers/etc/hosts"
        -Value "'${ip} ${hostName}'"
      )
      ${POWERSHELL_BIN:-powershell.exe} -Command "Start-Process powershell \"${cmd[*]}\" -Verb RunAs"
      Log::displaySuccess "Host ${hostName} added to ${BASE_MNT_C}/Windows/System32/drivers/etc/hosts"
    fi
  fi
}
