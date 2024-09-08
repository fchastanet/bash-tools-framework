#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionBashFrameworkConfig="${FRAMEWORK_ROOT_DIR}/.framework-config"

optionHelpCallback() {
  installRequirementsCommandHelp
  exit 0
}
