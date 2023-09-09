%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --variable-type String \
    --help "define output format of this command (default: plain)" \
    --alt "--format" \
    --authorized-values "plain|checkstyle" \
    --callback updateArgListFormatCallback \
    --variable-name "optionFormat" \
    --function-name optionFormatFunction
)
options+=(
  optionFormatFunction
)
%

# default option values
declare optionFormat="plain"

# shellcheck disable=SC2317 # if function is overridden
updateArgListFormatCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$@")
}
