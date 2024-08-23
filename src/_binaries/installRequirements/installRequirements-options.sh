#!/usr/bin/env bash

# shellcheck disable=SC2034
declare copyrightBeginYear="2024"
# shellcheck disable=SC2034
declare versionNumber="1.0"

declare optionBashFrameworkConfig="${FRAMEWORK_ROOT_DIR}/.framework-config"

optionHelpCallback() {
  installRequirementsCommandHelp
  exit 0
}
