## Index

* [Options::generateArg](#optionsgeneratearg)

### Options::generateArg

Generates a function that allows to manipulate an argument.

#### Output on stdout

By default the name of the random generated function name
is displayed as output of this function.
By providing the option `--function-name`, the output of this
function will be the generated function itself with the chosen name.

#### Syntax

```text
Usage:  Options::generateArg [OPTIONS]

Options::generateArg [OPTIONS]

OPTIONS:
  [--variable-name | --var <argVariableName>]
  [--help <String|Function>]
  [--name <argName>]
  [--min <count>] [--max <count>]
  [--authorized-values <StringList>]
  [--regexp <String>]
  [--callback <String>]
  [--function-name <String>]
```

#### Example

```bash
declare positionalArg1="$(
  Options::generateArg \
  --variable-name "fileToCompile" \
  --min 1 \
  --name "File to compile" \
  --help "provides the file to compile."
)"
Options::sourceFunction "${positionalArg1}"
"${positionalArg1}" parse "$@"
```

#### Callback

the callback will be called with the following arguments:

* if type String Array, list of arguments collected so far
* else the Boolean or String argument collected
* a `--` separator.
* the rest of arguments not parsed yet

#### Options

* **--variable-name** | **--var \<varName\>**

  (optional) provides the variable name that will be used to store the parsed arguments.

* **--help \<help\>**

  (optional) provides argument help description (Default: Empty string)

* **--name**

  (optional) provides the argument name that will be used to display the help. (Default: variable name)

* **--min \<int\>**

  (optional) Indicates the minimum number of args that will be parsed. (Default: 1)

* **--max \<int\>**

  (optional) Indicates the maximum number of args that will be parsed. (Default: 1)

* **--authorized-values  \<String\>**

  (optional) list of authorized values separated by |

* **--regexp \<String\>**

  (optional) regexp to use to validate the option value

* **--callback \<String\>**

  (optional) the name of the callback called if the arg is parsed successfully. The argument value will be passed as parameter (several parameters if type StringArray).

* **--function-name \<String\>**

  (optional) the name of the function that will be generated

#### Exit codes

* **1**: if error during argument parsing
* **3**: if error during template rendering

#### Output on stderr

* diagnostics information is displayed

#### See also

* [generateCommand function](#/doc/guides/Options/generateCommand)
* [arg function](#/doc/guides/Options/functionArg)
