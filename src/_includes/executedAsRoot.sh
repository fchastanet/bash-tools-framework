#!/bin/bash

if [[ "$(id -u)" = "0" ]]; then
  Log::fatal "this script should be executed as normal user"
fi
