# Options namespace

- [1. What is it ?](#1-what-is-it-)
- [2. How it works ?](#2-how-it-works-)
  - [2.1. generation functions](#21-generation-functions)
  - [2.2. generated functions](#22-generated-functions)
- [3. Full example](#3-full-example)
- [4. generate options parser](#4-generate-options-parser)

## 1. What is it ?

- manage command options
  - generate help for --env-file, --verbose, ...
  - inspired by docker --help globals options
    - @require Log::requireVerboseArgHelp append help to an array
- option
  - Options::generate

## 2. How it works ?

Using templating feature, you have the ability to create a kind of object.

```bash
declare optionVerbose=<% Options::generateOption \
  --form commandForm \
  --variable-name "verbose" \
  --alt "-v" \
  --alt "--verbose" \
  --variable-type "Boolean" \
  --default-value "0" \
  --off-value "0" \ # default
  --on-value "1" \ # default
  --help "display more information about processed files" \
  --validator "validatorHandler"\
  --handler "handler" \
  --post-process-handler "postProcessHandler"
%>
```

This will have 2 effects during compilation:

- Creating a function to help you manipulating the option
- optionVerbose variable will point to that function

### 2.1. generation functions

This paragraph describes the function allowing to generate the code during
compilation.

- [Options::generateCommand](Options/generateCommand.md)
- [Options::generateOption](Options/generateOption.md)
- [Options::generateArg](Options/generateArg.md)

### 2.2. generated functions

The 3 generate functions above will generate respectively the 3 functions below:

- [Options::functionCommand](Options/functionCommand.md)
- [Options::functionOption](Options/functionOption.md)
- [Options::functionArg](Options/functionArg.md)

These functions allow to manipulate respectively:

- Command
- Option
- Argument

## 3. Full example

```bash
declare optionVerbose=<% Options::generateOption \
  --variable-name "verbose" \
  --alt "--verbose" \
  --alt "-v" \
  --variable-type "Boolean" \
  --help "displays more information about processed files"
%>
declare optionSrcDirs=<% Options::generateOption \
  --variable-name "srcDirs" \
  --alt "-s" \
  --alt "--src-dir" \
  --help-item-name "srcDir" \
  --variable-type "StringArray" \
  --help "provides the directory where to find the functions source code."
%>
declare commandForm=<% Options::generateCommand \
  --help "Command help" \
  --author "author is me" \
  --command-name "myCommand" \
  --license "MIT License" \
  optionVerbose \
  optionSrcDirs
%>

```

_Using `commandForm help` would generate the following help:_

```text
Description: Command help

Usage: myCommand [OPTIONS]
Usage: myCommand [-h|--help] prints this help and exits
Usage: myCommand [--verbose|-v] [--src-dir|-s <srcDir>]

  --help, -h
        prints this help and exits

  --verbose, -v
        displays more information about processed files

  --src-dir|-s <srcDir>
        provides the directory where to find the
        functions source code.

Author:
author is me

License:
MIT License
```

## 4. generate options parser

```bash
Options::parse \
  "variableName" "optionSpec" "help" "validatorHandler" "handler" "postProcessHandler"

Options::parse \
  --variable-name "verbose" \
  --alt "-v" \
  --alt "--verbose" \
  --variable-type "Boolean" \
  --default-value "0" \
  --off-value "0" \ # default
  --on-value "1" \ # default
  --help "help" \
  --validator "validatorHandler"\
  --handler "handler" \
  --post-process-handler "postProcessHandler"

# postProcessHandler could be the Env::requireRemoveVerboseArg
# handlers are facultative to allow manual processing of several options
# --log-level=<string> | --log-level <string> | -l <string>
# validatorHandler could assert level is correct
Options::parse \
  --variable-name "logLevel" \
  --alt "--log-level" \
  --alt "-l" \
  --variable-type "String" \
  --default-value "info" \
  --authorized-values "debug|info|warn|error" \
  --help "help" \
  --validator "validatorHandler" \
  --pre-process-handler "preProcessHandler"
  --handler "handler" \
  --post-process-handler "postProcessHandler"

# --src-dir=<string> | -s <string>
# validatorHandler could assert path is valid
# preProcessHandler could remove duplicates
# postProcessHandler could remove the argument from arg list (default postProcessHandler ?)
Options::parse \
  --variable-name "srcDirs" \
  --alt "-s" \
  --alt "--src-dir" \
  --variable-type "String[]" \
  --mandatory \ # default is required
  --help "help" \
  --validator "validatorHandler" \
  --pre-process-handler "preProcessHandler"
  --handler "handler" \
  --post-process-handler "postProcessHandler"
```

Could generate this code

```bash
# boolean option parse
local ${argValue}=${defaultValue:-}
local arg
for arg in "${BASH_FRAMEWORK_ARGV[@]}"; do
  case "${arg}" in
    "$(${options[@]} | join ' | ')")
      ${argValue}=${on-value:-1}
      ;;
    *)
      # ignore
      ;;
  esac
done
export ${argValue}
```
