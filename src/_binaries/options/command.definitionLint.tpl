%
declare generateFormatOption=1
declare versionNumber="1.0"
declare commandFunctionName="definitionLintCommand"
declare help="Lint files of the given directory."
declare longDescription="""
for each definition file:
- check that all mandatory methods are existing
  installScripts_<fileName>_helpDescription
  installScripts_<fileName>_helpVariables
  installScripts_<fileName>_listVariables
  installScripts_<fileName>_defaultVariables
  installScripts_<fileName>_checkVariables
  installScripts_<fileName>_fortunes
  installScripts_<fileName>_dependencies
  installScripts_<fileName>_breakOnConfigFailure
  installScripts_<fileName>_breakOnTestFailure
  installScripts_<fileName>_install
  installScripts_<fileName>_configure
  installScripts_<fileName>_test
- check if other definitions files functions are defined by currently
  linted definition file it would mean that another file has defined
  the same methods
- check if each dependency exists

INTERNAL
"""

%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.format.tpl)"
%
# shellcheck source=/dev/null
source <(
Options::generateArg \
  --variable-name "argFolder" \
  --name "folder" \
  --help "the folder to recursively lint" \
  --function-name argFolderFunction
)
options+=(
  argFolderFunction
)
Options::generateCommand "${options[@]}"
%
