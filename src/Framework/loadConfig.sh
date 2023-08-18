#!/usr/bin/env bash

# @description load .framework-config
# @arg $1 loadedConfigFile:&String (passed by reference) the finally loaded configuration file path
# @arg $@ srcDirs:String[] the src directories in which .framework-config file will be searched
# @stdout the config file path loaded if any
# @exitcode 0 if .framework-config file has been found in srcDirs provided
# @exitcode 1 if .framework-config file not found
# @see Conf::loadNearestFile
Framework::loadConfig() {
  # shellcheck disable=SC2034
  local -n loadConfig_loadedConfigFile=$1
  shift || true
  Conf::loadNearestFile ".framework-config" loadConfig_loadedConfigFile "$@"
}
