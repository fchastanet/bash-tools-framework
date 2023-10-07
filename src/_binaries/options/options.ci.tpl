%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "activate continuous integration mode (tmp folder not shared with host)" \
    --alt "--ci" \
    --callback updateOptionContinuousIntegrationMode \
    --variable-name "optionContinuousIntegrationMode" \
    --function-name optionContinuousIntegrationModeFunction
)
options+=(
  optionContinuousIntegrationModeFunction
)
%
declare optionContinuousIntegrationMode=0

# shellcheck disable=SC2317 # if function is overridden
updateOptionContinuousIntegrationMode() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1")
}
