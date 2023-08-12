#!/usr/bin/env bash

# @arg $1 url:String the url to contact using curl
# @arg $2 title:String the title to pass to Retry::parameterized method
# default: "Try to contact ${title} ..."
# @arg $3 maxRetries:int max retries
# default: 40
# @arg $4 delayBetweenTries:int delay between attempt in seconds
# default: 5 seconds
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
