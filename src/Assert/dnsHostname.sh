#!/usr/bin/env bash

# check if param is valid dns hostname
# @arg $1 hostName:String the dns hostname
# @exitcode 1 on error
Assert::dnsHostname() {
  [[ "$1" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]]
}
