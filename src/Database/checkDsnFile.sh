#!/usr/bin/env bash

# @description check if dsn file has all the mandatory variables set
# Mandatory variables are: HOSTNAME, USER, PASSWORD, PORT
#
# @arg $1 dsnFileName:String dsn absolute filename
# @set HOSTNAME loaded from dsn file
# @set PORT loaded from dsn file
# @set USER loaded from dsn file
# @set PASSWORD loaded from dsn file
# @exitcode 0 on valid file
# @exitcode 1 if one of the properties of the conf file is invalid or if file not found
# @stderr log output if error found in conf file
Database::checkDsnFile() {
  local dsnFileName="$1"
  if [[ ! -f "${dsnFileName}" ]]; then
    Log::displayError "dsn file ${dsnFileName} not found"
    return 1
  fi

  (
    unset HOSTNAME PORT PASSWORD USER
    # shellcheck source=/src/Database/testsData/dsn_valid.env
    source "${dsnFileName}"
    if [[ -z ${HOSTNAME+x} ]]; then
      Log::displayError "dsn file ${dsnFileName} : HOSTNAME not provided"
      return 1
    fi
    if [[ -z "${HOSTNAME}" ]]; then
      Log::displayWarning "dsn file ${dsnFileName} : HOSTNAME value not provided"
    fi
    if [[ "${HOSTNAME}" = "localhost" ]]; then
      Log::displayWarning "dsn file ${dsnFileName} : check that HOSTNAME should not be 127.0.0.1 instead of localhost"
    fi
    if [[ -z "${PORT+x}" ]]; then
      Log::displayError "dsn file ${dsnFileName} : PORT not provided"
      return 1
    fi
    if ! [[ ${PORT} =~ ^[0-9]+$ ]]; then
      Log::displayError "dsn file ${dsnFileName} : PORT invalid"
      return 1
    fi
    if [[ -z "${USER+x}" ]]; then
      Log::displayError "dsn file ${dsnFileName} : USER not provided"
      return 1
    fi
    if [[ -z "${PASSWORD+x}" ]]; then
      Log::displayError "dsn file ${dsnFileName} : PASSWORD not provided"
      return 1
    fi
  )
}
