#!/usr/bin/env bash

# Fix
# - The authenticity of host 'www.host.net (140.82.121.4)' can't be established
# - And Offending key for IP
Ssh::fixAuthenticityOfHostCantBeEstablished() {
  ssh-keygen -R "$1" # remove host before adding it to prevent duplication
  ssh-keyscan "$1" >>"${HOME}/.ssh/known_hosts" || true
}
