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
Options::generateCommand "${options[@]}"
%
