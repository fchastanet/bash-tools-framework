%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --variable-type StringArray \
    --help "provide the directory where to find the functions source code. (Prefer using .framework-config file)" \
    --max -1 \
    --alt "--src-dir" \
    --alt "-s" \
    --callback optionSrcDirsCallback \
    --variable-name "optionSrcDirs" \
    --function-name optionSrcDirsFunction
)
options+=(
  optionSrcDirsFunction
)
%

# default option values
declare -a optionSrcDirs=()

optionSrcDirsCallback() {
  if [[ ! -d "$1" ]]; then
    Log::fatal "Command ${SCRIPT_NAME} - Directory '$1' does not exists"
  fi
  FRAMEWORK_SRC_DIRS+=("$(realpath --physical "$1")")
}
