#!/usr/bin/env bash

# try to ping the dns
# @param $1 is the dns hostname
# @return 1 on error
Dns::checkHostname() {
  local host="$1"
  if [[ -z "${host}" ]]; then
    return 1
  fi

  # check if host is reachable
  local returnCode=0
  Functions::captureOutputAndExitCode "ping -c 1 ${host}" "try to reach host ${host}"
  returnCode=$?

  if [[ "${returnCode}" = "0" ]]; then
    # get ip from ping
    # under windows: Pinging willywonka.host.lan [127.0.0.1] with 32 bytes of data
    # under linux: PING willywonka.host.lan (127.0.1.1) 56(84) bytes of data.
    local ip
    ip=$(echo "${COMMAND_OUTPUT}" | grep -i ping | grep -Eo '[0-9.]{4,}' | head -1)

    # now we have to check if ip is bound to local ip address
    if [[ ${ip} != 127.0.* ]]; then
      # resolve to a non local address
      # check if ip resolve to our ips
      message="check if ip(${ip}) associated to host(${host}) is listed in your network configuration"
      if Assert::windows; then
        Functions::captureOutputAndExitCode "ipconfig | grep ${ip} | cat" "${message}"
        returnCode=$?
      else
        Functions::captureOutputAndExitCode "ifconfig | grep ${ip} | cat" "${message}"
        returnCode=$?
      fi
      if [[ "${returnCode}" != "0" ]]; then
        returnCode=2
      elif [[ -z "${COMMAND_OUTPUT}" ]]; then
        returnCode=3
      fi
    fi
  fi

  return "${returnCode}"
}
