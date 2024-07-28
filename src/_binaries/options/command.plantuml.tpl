%
declare versionNumber="1.0"
declare commandFunctionName="plantumlCommand"
declare help="Generates plantuml diagrams from puml files."
# shellcheck disable=SC2016
declare longDescription='''
Generates plantuml diagrams from puml files in formats provided

${__HELP_TITLE_COLOR}PLANTUML HELP${__RESET_COLOR}

@@@PLANTUML_HELP@@@
'''
declare optionFormatAuthorizedValues="svg|png"
declare optionFormatDefault="svg"
declare optionDefaultOutputDir="doc/images"
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%

# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --variable-type StringArray \
    --help "define output format of this command(available: ${optionFormatAuthorizedValues}) (default: ${optionFormatDefault:-plain})" \
    --alt "--format" \
    --alt "-f" \
    --authorized-values "${optionFormatAuthorizedValues}" \
    --variable-name "optionFormats" \
    --function-name optionFormatsFunction

  Options::generateOption \
    --variable-type String \
    --help "define PLANTUML_LIMIT_SIZE" \
    --alt "--limit-size" \
    --alt "-l" \
    --callback optionLimitSizeCallback \
    --variable-name "optionLimitSize" \
    --function-name optionLimitSizeFunction

  Options::generateOption \
    --variable-type Boolean \
    --help "to write image file in same directory as source file and with the same base name(except extension)" \
    --alt "--same-dir" \
    --variable-name "sameDirectoryOption" \
    --function-name sameDirectoryOptionFunction

  plantUmlOutputDirCallback() { :; }
  Options::generateOption \
    --variable-type String \
    --help "define output directory of this command (default: ${optionDefaultOutputDir})" \
    --alt "--output-dir" \
    --alt "-o" \
    --callback plantUmlOutputDirCallback \
    --variable-name "optionOutputDir" \
    --function-name optionOutputDirFunction

  plantUmlFileCallback() { :; }
  Options::generateArg \
    --variable-name "argPlantumlFiles" \
    --min 0 \
    --max -1 \
    --name "plantUmlFile" \
    --callback plantUmlFileCallback \
    --help "plantuml files (if not provided, deduce files from git repository with .puml extension)" \
    --function-name argPlantumlFilesFunction
)
options+=(
  --callback plantumlCallback
  --unknown-option-callback unknownOption
  optionFormatsFunction
  optionLimitSizeFunction
  optionOutputDirFunction
  argPlantumlFilesFunction
  sameDirectoryOptionFunction
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"
declare optionOutputDir="<% ${optionDefaultOutputDir} %>"
declare -a plantumlOptions=()

# shellcheck disable=SC2317 # if function is overridden
unknownOption() {
  plantumlOptions+=("$1")
}

# shellcheck disable=SC2317 # if function is overridden
plantUmlFileCallback() {
  if [[ ! -f "$1" ]]; then
    plantumlOptions+=("$1")
  fi
}

optionHelpCallback() {
  local plantumlHelpFile
  plantumlHelpFile="$(Framework::createTempFile "hadolintHelp")"
  if command -v docker &>/dev/null; then
    docker pull plantuml/plantuml >/dev/null
      docker run --rm plantuml/plantuml -help >"${plantumlHelpFile}"
  else
    echo "docker was not available while generating this documentation" >"${plantumlHelpFile}"
  fi
  <% ${commandFunctionName} %> help |
    sed -E \
      -e "/@@@PLANTUML_HELP@@@/r ${plantumlHelpFile}" \
      -e "/@@@PLANTUML_HELP@@@/d"
  exit 0
}

# shellcheck disable=SC2317 # if function is overridden
plantumlCallback() {
  if ((${#optionFormats[@]} == 0)); then
    optionFormats=("<% ${optionFormatDefault} %>")
  fi
}

# shellcheck disable=SC2317 # if function is overridden
optionLimitSizeCallback() {
  if [[ -n "${optionLimitSize}" && ! "${optionLimitSize}" =~ ^[0-9]+$ ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - invalid limit size value '$2'"
    return 1
  fi
}

# shellcheck disable=SC2317 # if function is overridden
plantUmlOutputDirCallback() {
  if [[ ! -d "$2" ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - unknown directory '$2'"
    return 1
  fi
}
