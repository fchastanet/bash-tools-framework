## Index

* [Options::generateCommand](#optionsgeneratecommand)

### Options::generateCommand

[![2 Warning(s)](https://img.shields.io/badge/Warnings-2-yellow.svg)](#)

Generates a function that allows to manipulate a command
constituted with options, group and arguments.

#### Output on stdout

By default the name of the random generated function name
is displayed as output of this function.
By providing the option `--function-name`, the output of this
function will be the generated function itself with the chosen name.

#### Syntax

```text
Usage:  Options::generateCommand [OPTIONS]
[optionsVariablesReferences] [argVariablesReferences]

USAGE: Options::generateCommand [OPTIONS] [ARGS]

OPTIONS:
  [--help|--short-description <String|Function>]
  [--long-description <String|Function>]
  [--command-name <String|Function>]
  [--version <String|Function>]
  [--author <String|Function>]
  [--License <String|Function>]
  [--copyright <String|Function>]
  [--help-template <String>]
  [--unknown-option-callback]
  [--unknown-argument-callback]

ARGS: list of option/arg functions
```

#### Example

```bash
declare commandForm="$(Options::generateCommand \
  --help "Command help" \
  --version "version 1.0" \
  --author "author is me" \
  --command-name "myCommand" \
  --license "MIT License" \
  --copyright "Copyright" \
  --help-template "path/to/template.tpl"
)"
Options::sourceFunction "${commandForm}"
"${commandForm}" parse "$@"
```

#### --callback option
you can set several callbacks
callback is called without any parameter.

#### --unknown-option-callback/--unknown-argument-callback option
You can set several callbacks.
Callback is called with the option/argument that is invalid.
An invalid option is a string that begin with `-`
and that does not match any option configured.
An invalid argument is an argument that does not
match any configured argument.

#### --every-option-callback/--every-argument-callback option
You can set several callbacks.
Callback is called on every option/argument
returning 1 from the callback allows to ignore the default behavior
eg: default behavior for options is to display invalid option
note: it doesn't prevent to call other callbacks

#### Options

* **--help** | **--summary** | **--short-description \<String|Function\>**

  (optional) provides command short description help

* **--long-description \<String|Function\>**

  (optional) provides command long description help

* **--command-name \<String|Function\>**

  (optional) provides the command name. (Default: name of current command file without path)

* **--version \<String|Function\>**

  (optional) provides version section help. Section not generated if not provided.

* **--author \<String|Function\>**

  (optional) provides author section help. Section not generated if not provided.

* **--license \<String|Function\>**

  (optional) provides License section. Section not generated if not provided.

* **--source-file \<String|Function\>**

  (optional) provides Source file section. Section not generated if not provided.

* **--copyright \<String|Function\>**

  (optional) provides copyright section. Section not generated if not provided.

* **--help-template \<String|Function\>**

  (optional) if you want to override the default template used to generate the help

* **--function-name \<String\>**

  the name of the function that will be generated

* **--unknown-option-callback \<Function\>**

  (0 or more) the callback called when an option is unknown (Default: options parser display error message if option provided does not match any specified options).

* **--unknown-argument-callback \<Function\>**

  (0 or more) the callback called when an argument is unknown (Default: parser does not report any error).

* **--every-option-callback \<Function\>**

  (0 or more) the callback called for every option.

* **--every-argument-callback \<Function\>**

  (0 or more) the callback called for every argument.

* **--callback \<Function\>**

  (0 or more) the callback called when all options and arguments have been parsed.

#### Arguments

* **...** (args:StringArray): (mandatory, at least one) list of options/arguments functions, allowing to link the options/arguments with this command

#### Exit codes

* **1**: if error during option/argument parsing
* **2**: if error during option/argument type parsing
* **3**: if error during template rendering

#### Output on stderr

* diagnostics information is displayed

#### Warnings

* arguments function list has to be provided in correct order
* argument/option variable names have to be unique. Best practice is to scope the variable name to avoid variable name conflicts.

#### See also

* [generateOption function](#/doc/guides/Options/generateOption)
* [generateArg function](#/doc/guides/Options/generateArg)
* [generateGroup function](#/doc/guides/Options/generateGroup)
* [command function](#/doc/guides/Options/functionCommand)
