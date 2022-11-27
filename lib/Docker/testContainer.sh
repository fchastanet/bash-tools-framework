#!/usr/bin/env bash

Docker::testContainer() {
  local dir="$1"
  local host="$2"
  local containerName="$3"
  local title="$4"
  local testCallBackOrUrl="$5"

  Assert::dirExists "${dir}" || ((++failures))
  NetFunctions::assertHost "${host}" || ((++failures))

  (
    cleanOnExit() {
      Log::displayInfo "Shuting down ${title} ..."
      (
        cd "${dir}" || exit 1
        docker-compose down
      )
    }
    trap cleanOnExit EXIT INT ABRT TERM

    cd "${dir}" || exit 1
    Log::displayInfo "Launching ${title} ..."
    docker-compose up -d

    (
      if [[ "$(type -t "${testCallBackOrUrl}")" = "function" ]]; then
        "${testCallBackOrUrl}"
      else
        Functions::retryParameterized 40 5 "Try to contact ${title} ..." curl \
          --silent -o /dev/null --fail -L \
          --connect-timeout 5 --max-time 10 "${testCallBackOrUrl}"
      fi
    ) || {
      docker-compose logs "${containerName}"
      Log::displayError "${title} initialization has failed, check above logs"
      exit 1
    }
    Log::displaySuccess "${title} tested successfully"
  )
}
