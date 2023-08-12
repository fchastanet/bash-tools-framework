#!/usr/bin/env bash

# Test if a container launched by docker-compose is reachable
# docker-compose will be up and shutdown at the end of the process if success or not
# @arg $1 dir:String the directory that contains the docker-compose.yml file
# @arg $2 containerName:String name of the container that is tested
# @arg $3 title:String a title that allows to discriminate the log lines
# @arg $4 testCallback:Function a function callback that will be called to check the container
# @exitcode 1 if directory does not exists
# @exitcode 2 on container test failure
# @exitcode 3 on <docker-compose up> failure
# @exitcode 4 if testCallBack is not a function
Docker::testContainer() {
  local directory="$1"
  local containerName="$2"
  local title="$3"
  local testCallBack=$4

  if [[ ! -d "${directory}" ]]; then
    Log::displayError "Directory ${directory} does not exist"
    return 1
  fi
  if [[ "$(type -t "${testCallBack}")" != "function" ]]; then
    Log::displayError "testCallBack parameter should be a function"
    return 4
  fi
  (
    # shellcheck disable=SC2317  # Don't warn about unreachable commands
    cleanOnExit() {
      Log::displayInfo "Shuting down ${title} ..."
      docker-compose down
    }
    trap cleanOnExit EXIT INT ABRT TERM

    cd "${directory}" || return 1
    Log::displayInfo "Launching ${title} ..."
    docker-compose up -d || return 3

    if ! "${testCallBack}"; then
      docker-compose logs "${containerName}"
      Log::displayError "${title} initialization has failed, check above logs"
      return 2
    fi
    Log::displaySuccess "${title} tested successfully"
  )
}
