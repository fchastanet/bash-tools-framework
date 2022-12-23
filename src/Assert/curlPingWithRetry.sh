#!/usr/bin/env bash

# @param {String} url $1 the url to contact using curl
# @param {String} title $2 the title to pass to Retry::parameterized method
# @paramDefault {String} title $2 "Try to contact ${title} ..."
# @param {int} maxRetries $3 max retries
# @paramDefault {int} maxRetries $3 default Value: 40
# @param {int} delayBetweenTries $4 delay between attempt in seconds
# @paramDefault {String} delayBetweenTries $4 default Value: 5 seconds
Assert::curlPingWithRetry() {
  local url="$1"
  local title="${2:-"Try to contact ${url} ..."}"
  local maxRetries="${3:-40}"
  local delayBetweenTries="${4:-5}"

  Retry::parameterized \
    "${maxRetries}" \
    "${delayBetweenTries}" \
    "${title}" \
    curl \
    --silent -o /dev/null --fail -L \
    --connect-timeout 5 --max-time 10 "${url}"
}
