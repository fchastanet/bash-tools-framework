#!/usr/bin/env bash

# @param {string[]} $@ the src directories in which .framework-config file will be searched
# @output the config file path loaded if any
# @return 0 if .framework-config file has beend found in srcDirs provided
Framework::loadConfig() {
  Conf::loadNearestFile ".framework-config" "$@"
}
