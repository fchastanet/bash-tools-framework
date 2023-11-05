%
declare versionNumber="1.0"
declare commandFunctionName="plantumlCommand"
declare help="Generates plantuml diagrams from puml files."
# shellcheck disable=SC2016
declare longDescription="""
Generates plantuml diagrams from puml files in formats provided
"""
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
  optionFormatsFunction
  optionOutputDirFunction
  argPlantumlFilesFunction
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"
declare optionOutputDir="<% ${optionDefaultOutputDir} %>"

plantumlCallback() {
  if ((${#optionFormats[@]} == 0)); then
    optionFormats=("<% ${optionFormatDefault} %>")
  fi
}

plantUmlOutputDirCallback() {
  if [[ ! -d "$2" ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - unknown directory '$2'"
    return 1
  fi
}

plantUmlFileCallback() {
  if [[ ! -f "$1" ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - unknown file '$1'"
    return 1
  fi
}
