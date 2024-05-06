#!/usr/bin/env bash

# @description Retry a command 5 times with a delay of 15 seconds between each attempt
# @arg $@ command:String[] the command to run
# @exitcode 0 on success
# @exitcode 1 if max retries count reached
# @env RETRY_MAX_RETRY int max retries
# @env RETRY_DELAY_BETWEEN_RETRIES int delay between attempts
Retry::default() {
  Retry::parameterized "${RETRY_MAX_RETRY:-5}" "${RETRY_DELAY_BETWEEN_RETRIES:-15}" "" "$@"
}
