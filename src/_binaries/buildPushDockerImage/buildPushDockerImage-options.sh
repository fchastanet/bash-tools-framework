#!/usr/bin/env bash

# shellcheck disable=SC2034
declare versionNumber="1.0"
declare copyrightBeginYear="2023"

optionHelpCallback() {
  buildPushDockerImageCommandHelp
  exit 0
}

# shellcheck disable=SC2317 # if function is overridden
updateOptionVendorCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1" "$2")
}

# shellcheck disable=SC2317 # if function is overridden
updateOptionBashVersionCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1" "$2")
}

# shellcheck disable=SC2317 # if function is overridden
updateOptionBashBaseImageCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1" "$2")
}

# shellcheck disable=SC2317 # if function is overridden
updateOptionBranchNameCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1" "$2")
}
