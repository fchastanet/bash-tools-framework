%
readonly vendors="alpine|ubuntu"
readonly bashVersions="4.4|5.0|5.1|5.2"
readonly defaultVendor="ubuntu"
readonly defaultBashVersion="5.1"
readonly defaultBashBaseImage="ubuntu:20.04"

# shellcheck source=/dev/null
source <(
Options::generateOption \
  --variable-type String \
  --variable-name "optionVendor" \
  --alt --vendor \
  --help "vendor image to use: ${vendors} (Default: ${defaultVendor})" \
  --authorized-values "alpine|ubuntu" \
  --callback updateOptionVendorCallback \
  --function-name optionVendorFunction

Options::generateOption \
  --variable-type String \
  --variable-name "optionBashVersion" \
  --alt --bash-version \
  --help "version of bash to use: ${bashVersions} (Default: ${defaultBashVersion})" \
  --authorized-values "${bashVersions}" \
  --callback updateOptionBashVersionCallback \
  --function-name optionBashVersionFunction

Options::generateOption \
  --variable-type String \
  --variable-name "optionBashBaseImage" \
  --alt --bash-base-image \
  --help "bash bash image to use (eg: ubuntu:20.04, amd64/bash:4.4-alpine3.18) (Default: ${defaultBashBaseImage})" \
  --callback updateOptionBashBaseImageCallback \
  --function-name optionBashBaseImageFunction

Options::generateOption \
  --variable-type String \
  --variable-name "optionBranchName" \
  --alt --branch-name \
  --help "branch name being built, will help to create docker image tag name" \
  --callback updateOptionBranchNameCallback \
  --function-name optionBranchNameFunction
)
options+=(
  optionVendorFunction
  optionBashVersionFunction
  optionBashBaseImageFunction
  optionBranchNameFunction
)
%

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

declare optionVendor="<% ${defaultVendor} %>"
declare optionBashVersion="<% ${defaultBashVersion} %>"
declare optionBashBaseImage="<% ${defaultBashBaseImage} %>"
