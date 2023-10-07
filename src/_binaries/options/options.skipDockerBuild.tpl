%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "skip docker image build if option provided" \
    --alt "--skip-docker-build" \
    --callback updateOptionSkipDockerBuildCallback \
    --variable-name "optionSkipDockerBuild" \
    --function-name optionSkipDockerBuildFunction
)
options+=(
  optionSkipDockerBuildFunction
)
%

declare optionSkipDockerBuild=0

# shellcheck disable=SC2317 # if function is overridden
updateOptionSkipDockerBuildCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1")
}
