# Options namespace

- [1. What is it ?](#1-what-is-it-)
- [2. How it works ?](#2-how-it-works-)
  - [2.1. generation functions](#21-generation-functions)
  - [2.2. generated functions](#22-generated-functions)
- [3. Two generation modes available](#3-two-generation-modes-available)
  - [3.1. Legacy - external random function generation](#31-legacy---external-random-function-generation)
  - [3.2. Recommended Way - script generation](#32-recommended-way---script-generation)
- [Best practices](#best-practices)
  - [scope function/variable names](#scope-functionvariable-names)
- [4. Examples](#4-examples)
  - [4.1. Test examples](#41-test-examples)
  - [4.2. Real examples](#42-real-examples)
  - [4.3. Full example](#43-full-example)

## 1. What is it ?

Options::generateCommand allows to generate a function that will help you to:

- manage command options and arguments
  - options --bash-framework-config, --verbose, ...
  - arguments
- check option/argument presence
- execute callbacks on certain option/argument
- validate option/argument and reports error
- allows to generate command argument inspired by docker command (like
  `docker --help`)
- allows to group some options (like `docker --help` globals options)
- automatically generates help

Options::generateCommand uses these functions:

- Options::generateGroup - function to help you to group options under the same
  category
- Options::generateArg - function that can parse or display help related to one
  argument
- Options::generateOption - function that can parse or display help related to
  one option

## 2. How it works ?

Using templating feature, you have the ability to create a kind of object.

```bash
source <(
 Options::generateGroup \
  --title "GLOBAL OPTIONS:" \
  --function-name groupGlobalOptionsFunction || exit 1

 Options::generateOption \
  --help "verbose mode" \
  --variable-name "verboseOption" \
  --group groupGlobalOptionsFunction \
  --alt "--verbose" --alt "-v" \
  --function-name optionVerboseFunction || exit 2
)
declare -a options=(
 optionVerboseFunction
 --command-name awkLint
 --unknown-argument-callback unknownArgumentCallback
 --function-name awkLintCommand
)

# shellcheck source=/dev/null
source <(Options::generateCommand "${options[@]}") || exit 3

awkLintCommand parse "$@"
```

This will have 2 effects during compilation:

- Creating a function to help you manipulating the option
- optionVerboseFunction variable will point to that function

### 2.1. generation functions

This paragraph describes the function allowing to generate the code during
compilation.

- [Options::generateGroup](Options/generateGroup.md)
- [Options::generateOption](Options/generateOption.md)
- [Options::generateArg](Options/generateArg.md)
- [Options::generateCommand](Options/generateCommand.md)

### 2.2. generated functions

The 4 generate functions above will generate respectively the 4 functions below:

- [Options::functionGroup](Options/functionGroup.md)
- [Options::functionOption](Options/functionOption.md)
- [Options::functionArg](Options/functionArg.md)
- [Options::functionCommand](Options/functionCommand.md)

These functions allow to manipulate respectively:

- Group
- Option
- Argument
- Command

## 3. Two generation modes available

`Options::generate*` function generates code, 2 modes are available:

- Legacy: external random function generation
- Recommended Way: script generation

Only `Options::generateCommand` generated function needs to be included in the
resulting compiled file as other `Options::generate*` function are used as
helpers to generate that function.

### 3.1. Legacy - external random function generation

If the option `--function-name` is not provided to the `Options::generate*`
function, then the generate function will create a script file in a special src
directory available to the compiler with a function name randomly generated.

This mode has several drawbacks, it's why recommended way has been created
afterwards:

- As the function name is randomly generated, compiled files change everytime
  they are compiled.
- to allow generateCommand to work, we have to source the functions generated
  during template evaluation. It is still the case with new mode but with a
  cleaner way.
- for each option/arg/group created a variable has to be declared
- the final code is not easy to read

Let's see an example of integration:

```bash
local optionGroup="$(Options::generateGroup \
 --title "Command global options" \
 --help "The Console component adds some predefined options to all commands:")"
Options::sourceFunction "${optionGroup}"

local optionHelp="$(Options::generateOption \
 --variable-type Boolean --help "help" \
 --group "${optionGroup}" \
 --variable-name "help" --alt "--help" --alt "-h" --callback helpCallback)"
Options::sourceFunction "${optionHelp}"

local optionVerbose
optionVerbose="$(Options::generateOption --help "verbose mode" \
 --group "${optionGroup}" \
 --variable-name "verbose" \
 --alt "--verbose" --alt "-v")"
Options::sourceFunction "${optionVerbose}"

local destFiles
destFiles="$(Options::generateArg --variable-name "destFiles" --max 3 --callback destFilesCallback)"
Options::sourceFunction "${destFiles}"

Options::generateCommand --help "super command" \
 ${optionVerbose} \
 ${optionHelp} \
 ${destFiles}
```

The last `Options::generateCommand` will echo the function name automatically
generated, allowing the compiler to load the corresponding source file and
injecting the function in the compiled file.

### 3.2. Recommended Way - script generation

The recommended way make things a little bit easier. A new option
`--function-name` has been added to all `Options::generate*` functions allowing
to specify the function name that will be generated. Instead of outputting the
generated function name, the `Options::generate*` function will directly output
the generated function itself. Allowing to use `source <(...)` syntax, see
example below.

Note that as functions have custom names, it makes the generateCommand even
easier to write.

```bash
# shellcheck source=/dev/null
source <(
 Options::generateGroup \
  --title "GLOBAL OPTIONS:" \
  --function-name groupGlobalOptions

 Options::generateOption \
  --help "help" \
  --group groupGlobalOptions \
  --variable-name "help" \
  --alt "--help" \
  --alt "-h" \
  --callback helpCallback \
  --function-name optionHelp

 Options::generateOption \
  --help "verbose mode" \
  --group groupGlobalOptions \
  --variable-name "verbose" \
  --alt "--verbose" --alt "-v" \
  --function-name optionVerbose

 Options::generateArg \
  --variable-name "destFiles" \
  --max 3 \
  --callback destFilesCallback \
  --function-name argDestFiles
)

Options::generateCommand --help "super command" \
 optionVerbose \
 optionHelp \
 destFiles
```

## Best practices

### scope function/variable names

In order to avoid function names conflicts, it is highly recommended to scope
the variable names (`--variable-name`) and function names used as
callbacks(`--callback`, `--group`, ...) or `--function-name`.

Eg: instead of ~~--function-name srcDirs~~ Use `--function-name optionSrcDirs`

You even have the ability to use bashFramework function naming convention
allowing the callback function to be automatically imported.

## 4. Examples

### 4.1. Test examples

several examples are available in tests folder

- [generateCommand.case6.sh args/options mix](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateCommand.case6.sh)
  - [corresponding help](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateCommand.case6.expected.help)
- [generateCommand.case7.sh subcommand](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateCommand.case7.sh)
  - [corresponding help](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateCommand.case7.expected.help)

### 4.2. Real examples

Binaries of this framework are using this feature:

- [awkLint](https://github.com/fchastanet/bash-tools-framework/blob/master/src/_binaries/awkLint.sh)
  that uses:
  - [options.base.tpl](https://github.com/fchastanet/bash-tools-framework/blob/master/src/_binaries/options/options.base.tpl)
  - [command.awkLint.tpl](https://github.com/fchastanet/bash-tools-framework/blob/master/src/_binaries/options/command.awkLint.tpl)

Here the help generated:

```text
Description: lint awk files

Lint all files with .awk extension in current git folder.
Result in checkstyle format.

USAGE: awkLint [OPTIONS]
USAGE: awkLint [--help|-h] [--version] [--quiet|-q] [--no-color]
  [--log-level <String>] [--display-level <String>] [--verbose|-v]

GLOBAL OPTIONS:
  --help, -h (optional) (at most 1 times)
    help
  --version (optional) (at most 1 times)
    Print version information and quit
  --quiet, -q (optional) (at most 1 times)
    quiet mode
  --no-color (optional) (at most 1 times)
    Produce monochrome output.
  --log-level <String> (optional) (at most 1 times)
    Set log level
  --display-level <String> (optional) (at most 1 times)
    set display level
  --verbose, -v (optional) (at most 1 times)
    verbose mode

VERSION: 1.0

AUTHOR:
[François Chastanet](https://github.com/fchastanet)

SOURCE FILE:
https://github.com/fchastanet/bash-tools-framework/tree/master/src/_binaries/awkLint.sh

LICENSE:
MIT License

Copyright (c) 2022 François Chastanet
```

### 4.3. Full example

in you bash-tpl template add these lines:

```bash
%
source <(
 Options::generateOption \
  --help "help" \
  --group groupGlobalOptions \
  --variable-name "help" \
  --alt "--help" \
  --alt "-h" \
  --callback helpCallback \
  --function-name optionHelp

 Options::generateOption \
  --help "verbose mode" \
  --group groupGlobalOptions \
  --variable-name "verbose" \
  --alt "--verbose" --alt "-v" \
  --function-name optionVerbose

 Options::generateOption \
  --variable-name "srcDirs" \
  --alt "-s" \
  --alt "--src-dir" \
  --min 1 \
  --max 3 \
  --help-item-name "srcDir" \
  --variable-type "StringArray" \
  --help "provides the directory where to find the functions source code." \
  --function-name "optionSrcDirs"
)
Options::generateCommand \
 --help "Command help" \
 --author "author is me" \
 --command-name "myCommand" \
 --license "MIT License" \
 --function-name myCommand \
 optionVerbose \
 optionSrcDirs

%

myCommand parse "${BASH_FRAMEWORK_ARGV[@]}"
```

_Using `myCommand --help` will generate the following help:_

```text
Description: Command help

Usage: myCommand [OPTIONS]
Usage: myCommand [-h|--help] prints this help and exits
Usage: myCommand [--verbose|-v] [--src-dir|-s <srcDir>]

  --help, -h (optional) (at most 1 times)
    prints this help and exits

  --verbose, -v (optional) (at most 1 times)
    displays more information about processed files

  --src-dir|-s <srcDir> (mandatory) (at most 3 times)
    provides the directory where to find the
    functions source code.

Author:
author is me

License:
MIT License
```
