#!/usr/bin/env bash

# @description try to ping the dns
# @arg $1 host:String is the dns hostname
# @exitcode 1 if host arg empty
# @exitcode 2 if ping host failed
# @exitcode 3 if ip is not bound to local ip address
# @exitcode 4 if ifconfig result is empty
Dns::checkHostname() {
  local host="$1"
  if [[ -z "${host}" ]]; then
    return 1
  fi

  # check if host is reachable
  local -a pingCmd=(ping -c 1 "${host}")
  if Assert::windows; then
    pingCmd=(ping -n 1 "${host}")
  fi

  if ! Command::captureOutputAndExitCode "${pingCmd[*]}" "try to reach host ${host}"; then
    return 2
  fi

  # get ip from ping
  # under windows: Pinging willywonka.host.lan [127.0.0.1] with 32 bytes of data
  # under linux: PING willywonka.host.lan (127.0.1.1) 56(84) bytes of data.
  local ip
  ip=$(echo "${COMMAND_OUTPUT}" | grep -i ping | grep -Eo '[0-9.]{4,}' | head -1)

  # now we have to check if ip is bound to local ip address
  if [[ ${ip} != 127.0.* ]]; then
    # resolve to a non local address
    # check if ip resolve to our ips
    local message="check if ip(${ip}) associated to host(${host}) is listed in your network configuration"
    local -a ipconfigCmd=(ifconfig)
    if Assert::windows; then
      ipconfigCmd=(ipconfig)
    fi

    if ! Command::captureOutputAndExitCode "${ipconfigCmd[*]} | grep ${ip} | cat" "${message}"; then
      return 3
    fi
    if [[ -z "${COMMAND_OUTPUT}" ]]; then
      return 4
    fi
  fi

  return 0
}
