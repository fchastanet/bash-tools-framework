%
declare versionNumber="1.0"
declare commandFunctionName="frameworkLintCommand"
declare help="This framework linter"
# shellcheck disable=SC2016
declare longDescription='''
Lint files of the current repository
- check if all Namespace::functions are existing in the framework
- check that function defined in a .sh is correctly named
- check each function has a bats file associated
- shdoc
  - check that shdoc valid annotations are used
  - check that @require function matches naming convention and exists
  - check that at least @description is provided
'''
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.format.tpl)"

%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --variable-type "String" \
    --help "Specify expected warning count (default: 0)" \
    --alt "--expected-warnings-count" \
    --callback optionExpectedWarningsCountCallback \
    --variable-name optionExpectedWarningsCount \
    --function-name optionExpectedWarningsCountFunction
)

options+=(
  optionExpectedWarningsCountFunction
)

Options::generateCommand "${options[@]}"
%

declare -i optionExpectedWarningsCount=0

optionExpectedWarningsCountCallback() {
  if [[ ! "$2" =~ ^[0-9]+$ ]] || (( $2 < 0 )); then
    Log::fatal "Command ${SCRIPT_NAME} - Expected warnings count value should be a number greater or equal to 0"
  fi
}
