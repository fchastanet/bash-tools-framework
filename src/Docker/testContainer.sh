#!/usr/bin/env bash

# Test if a container launched by docker-compose is reachable
# docker-compose will be up and shutdown at the end of the process if success or not
# @param {String} dir $1 the directory that contains the docker-compose.yml file
# @param {String} containerName $2 name of the container that is tested
# @param {String} title $3 a title that allows to discriminate the log lines
# @param {String|Function} testCallbackOrUrl $4 a function callback that will be
#   called to check the container or an url to curl, in this case the following
#   parameters will be used to retry the url a certain amount of times.
# @param {int} maxRetries $1 max retries
# @paramDefault {int} maxRetries $5 default Value: 40
# @param {int} delayBetweenTries $6 delay between attempt in seconds
# @paramDefault {String} delayBetweenTries $6 default Value: 5 seconds
# @return 1 if directory does not exists
# @return 2 on container test failure
# @return 3 on <docker-compose up> failure
Docker::testContainer() {
  local directory="$1"
  local containerName="$2"
  local title="$3"
  local testCallBackOrUrl=$4
  local maxRetries="${5:-40}"
  local delayBetweenTries="${6:-5}"

  if [[ ! -d "${directory}" ]]; then
    Log::displayError "Directory ${directory} does not exist"
    return 1
  fi
  (
    # shellcheck disable=SC2317  # Don't warn about unreachable commands
    cleanOnExit() {
      Log::displayInfo "Shuting down ${title} ..."
      (
        cd "${directory}" || exit 1
        docker-compose down
      )
    }
    trap cleanOnExit EXIT INT ABRT TERM

    cd "${directory}" || return 1
    Log::displayInfo "Launching ${title} ..."
    docker-compose up -d || return 3

    (
      if [[ "$(type -t "${testCallBackOrUrl}")" = "function" ]]; then
        "${testCallBackOrUrl}"
      else
        Retry::parameterized "${maxRetries}" "${delayBetweenTries}" \
          "Try to contact ${title} ..." curl \
          --silent -o /dev/null --fail -L \
          --connect-timeout 5 --max-time 10 "${testCallBackOrUrl}"
      fi
    ) || {
      docker-compose logs "${containerName}"
      Log::displayError "${title} initialization has failed, check above logs"
      return 2
    }
    Log::displaySuccess "${title} tested successfully"
  )
}
