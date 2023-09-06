## Index

* [Options::generateOption](#optionsgenerateoption)

### Options::generateOption

Generates a function that allows to manipulate an option.

#### Output on stdout

By default the name of the random generated function name
is displayed as output of this function.
By providing the option `--function-name`, the output of this
function will be the generated function itself with the chosen name.

#### Syntax

```text
Usage:  Options::generateOption [OPTIONS] [TYPE_OPTIONS]

Options::generateOption[OPTIONS]

OPTIONS:
  --alt <optionName>
  --variable-name | --var <optionVariableName>
  [--variable-type <String|Function>]
  [--mandatory]
  [--help <String|Function>]
  [--group <Function>]
  [--callback <Function>]
  [--function-name <String>]

TYPE_OPTIONS: see Boolean/String/StringArray option documentation
```

#### Example

```bash
declare myOption="$(
  Options::generateOption \
    --variable-name "srcDirs" \
    --alt "-s" \
    --alt "--src-dir" \
    --variable-type "StringArray" \
    --required \
    --help "provides the directory where to find the functions source code."
)"
Options::sourceFunction "${myOption}"
"${myOption}" parse "$@"
```

#### Callback

the callback will be called with the following arguments:

* if type String Array, list of arguments collected so far
* else the Boolean or String argument collected
* a `--` separator.
* the rest of arguments not parsed yet

#### Options

* **--alt \<optionName\>**

  (mandatory at least one) option name possibility, the string allowing to discriminate the option.

* **--variable-name** | **--var \<varName\>**

  (mandatory) provides the variable name that will be used to store the parsed options.

* **--variable-type \<Boolean|String|StringArray\>**

  (optional) option type (default: Boolean)

* **--mandatory**

  (optional) as its name indicates, by default an option is optional. But using `--mandatory` you can make the option mandatory. An error will be generated if the option is not found during parsing arguments.

* **--help \<help\>**

  (optional) provides option help description (Default: Empty string)

* **--group \<Function\>**

  (optional) the group to which the option will be attached. Grouped option will be displayed under that group. (Default: no group)

* **--callback \<Function\>**

  (0 or several times) the callback called if the option is parsed successfully. The option value will be passed as parameter (several parameters if type StringArray).

* **--function-name \<String\>**

  (optional) the name of the function that will be generated

* --* (optional) Others options are passed to specific option handler depending on variable type

#### Exit codes

* **1**: if error during option parsing
* **2**: if error during option type parsing
* **3**: if error during template rendering

#### Output on stderr

* diagnostics information is displayed

#### See also

* [generateCommand function](#/doc/guides/Options/generateCommand)
* [option function](#/doc/guides/Options/functionOption)
