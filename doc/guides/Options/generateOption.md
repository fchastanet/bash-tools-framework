# Option generation

```bash
declare optionVerbose=<% Options::generateOption \
  --help "displays more information about processed files" \
  --variable-name "verbose" \
  --alt "--verbose" \
  --alt "-v" \
  --mandatory \
  --variable-type "Boolean" \
%>
```

**Description**

Generates a function that allows to manipulate an option.

**Syntax**

```text
Usage:  Options::generateOption [OPTIONS] [TYPE_OPTIONS]

Options::generateOption
  --help <String|Function>
  --variable-name <optionVariableName>
  --alt <option>
  [--mandatory]
  [--group <Function>]
  [--variable-type <String|Function>]
  [TYPE_OPTIONS]
```

**Mandatory Options:**

`--help <String|Function>`

> provides option description help.

`--variable-name <String|Function>`

> provides the variable name that will be used to store the parsed options.

`--alt <String>` _(at least one)_

> provides the string allowing too discriminate the option.
>
> You must provide at least one `--alt` option.

**Options:**

`--mandatory` _(optional)_

> as its name indicates, by default an option is optional. But using
> `--mandatory` you can make the option mandatory. An error will be generated if
> the option is not found during parsing arguments.

`--group <Function>` _(optional)_

> associate the option to a group. grouped option will be displayed under that
> group. Default: no group

`--variable-type <String>` _(optional)_

> the type of option to generate. Supported types are:
>
> - **Boolean** : indicates an option that will evaluate to 1 if the option is
>   present
> - **String** : indicates an option that should be followed by a string

**Specific `Boolean` options**

These options are specific to `Boolean` options

`--off-value <Number>` _(optional)_

> Applicable to `Boolean` option type only. Indicates the default off value of
> the variable.
>
> Default: 0

`--on-value <Number>` _(optional)_

> Applicable to `Boolean` option type only. Indicates the default on value of
> the variable.
>
> Default: 1

**Specific `String` options**

These options are specific to `String` options

`--default-value <String|Function>` _(optional)_

> Applicable to `String` option type only. Indicates the default value of the
> variable
>
> Default: "" (empty string)

**Specific `String` or `StringArray` options**

These options are specific to `String` or `StringArray` options

`--authorized-values <StringList>` _(optional)_

> Applicable to `String` or `StringArray` option type only. Indicates the
> possible value list separated by | character
>
> Default: no check.
>
> Eg.: --authorized-values "debug|info|warn|error"

**Specific `StringArray` options**

These options are specific to `StringArray` options

`--min <Number>` _(optional)_

> Applicable to `StringArray` option type only. Indicates the minimum number of
> options to provide.
>
> - Defaults to 0 or 1 if mandatory.

`--max <Number>` _(optional)_

> Applicable to `StringArray` option type only. Indicates the maximum number of
> options to provide.
>
> - Default "" means no limit

**Exit status:**

_Exit code 1_

> If function provided does not match any existing function in compiler srcDirs,
> the command fails with exit code 1. Bash framework Function naming convention
> are the only function supported in arguments.
