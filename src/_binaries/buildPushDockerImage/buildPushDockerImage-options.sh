#!/usr/bin/env bash

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
