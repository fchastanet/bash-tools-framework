#!/usr/bin/env bash

# Internal: check if dsn file has all the mandatory variables set
# Mandatory variables are: HOSTNAME, USER, PASSWORD, PORT
#
# **Arguments**:
# * $1 - dsn absolute filename
#
# Returns 0 on valid file, 1 otherwise with log output
Database::checkDsnFile() {
  local DSN_FILENAME="$1"
  if [[ ! -f "${DSN_FILENAME}" ]]; then
    Log::displayError "dsn file ${DSN_FILENAME} not found"
    return 1
  fi

  (
    unset HOSTNAME PORT PASSWORD USER
    # shellcheck source=/tests/data/dsn_valid.env
    source "${DSN_FILENAME}"
    if [[ -z ${HOSTNAME+x} ]]; then
      Log::displayError "dsn file ${DSN_FILENAME} : HOSTNAME not provided"
      return 1
    fi
    if [[ -z "${HOSTNAME}" ]]; then
      Log::displayWarning "dsn file ${DSN_FILENAME} : HOSTNAME value not provided"
    fi
    if [[ "${HOSTNAME}" = "localhost" ]]; then
      Log::displayWarning "dsn file ${DSN_FILENAME} : check that HOSTNAME should not be 127.0.0.1 instead of localhost"
    fi
    if [[ -z "${PORT+x}" ]]; then
      Log::displayError "dsn file ${DSN_FILENAME} : PORT not provided"
      return 1
    fi
    if ! [[ ${PORT} =~ ^[0-9]+$ ]]; then
      Log::displayError "dsn file ${DSN_FILENAME} : PORT invalid"
      return 1
    fi
    if [[ -z "${USER+x}" ]]; then
      Log::displayError "dsn file ${DSN_FILENAME} : USER not provided"
      return 1
    fi
    if [[ -z "${PASSWORD+x}" ]]; then
      Log::displayError "dsn file ${DSN_FILENAME} : PASSWORD not provided"
      return 1
    fi
  )
}
