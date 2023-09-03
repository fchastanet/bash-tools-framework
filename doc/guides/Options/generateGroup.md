## Index

* [Options::generateGroup](#optionsgenerategroup)

### Options::generateGroup

Generates a function that allows to manipulate a group of options.
function generated allows group options using `--group` option when
using `Options::generateOption`

#### Output on stdout

By default the name of the random generated function name
is displayed as output of this function.
By providing the option `--function-name`, the output of this
function will be the generated function itself with the chosen name.

#### Syntax

```text
Usage:  Options::generateGroup [OPTIONS]

OPTIONS:
  --title <String|Function>
  [--help <String|Function>]
  [--function-name <String>]
```

#### Example

```bash
declare optionGroup="$(
  Options::generateGroup \
    --title "Command global options" \
    --help "The Console component adds some predefined options to all commands:"
)"
Options::sourceFunction "${optionGroup}"
"${optionGroup}" help
```

#### Options

* **--title \<String|Function\>**

  (mandatory) provides group title

* **--help \<String|Function\>**

  (optional) provides command description help

* **--function-name \<String\>**

  (optional) the name of the function that will be generated

#### Exit codes

* **1**: if error during option parsing
* **1**: if bash-tpl error during template rendering
* **2**: if file generation error (only if functionName argument empty)

#### Output on stderr

* diagnostics information is displayed

#### See also

* [generateCommand function](#/doc/guides/Options/generateCommand)
* [generateOption function](#/doc/guides/Options/generateOption)
* [group function](#/doc/guides/Options/functionGroup)
