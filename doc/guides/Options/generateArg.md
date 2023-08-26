# Arg generation

```bash
declare positionalArg1=<% Options::generateArg \
  --variable-name "fixedArg1" \
  --arg-name "fixedArg1" \
  --arg-index 1 \
  --optional \
  --help "positional parameter 1"
%>
```

**Description**

Generates a function that allows to manipulate an argument.

**Syntax**

```text
Usage:  Options::generateArg [OPTIONS] [TYPE_OPTIONS]

Options::generateArg
  --variable-name | --var <argVariableName>
  [--help <String|Function>]
  [--name <argName>]
  [--min <count>] [--max <count>]
  [--authorized-values <StringList>]
  [--regexp <String>]
```

**Mandatory Options:**

`--variable-name [ --var <String|Function>`

> provides the variable name that will be used to store the parsed argument.

**Optional Options:**

`--help <String|Function>`

> provides argument help description Default: Empty string

`--name <String|Function>`

> provides the argument name that will be used to display the help. Default:
> variable name

`--min <int>`

> Indicates the minimum number of args that will be parsed. Default: 1 If set to
> 0, it means the argument is optional.

`--max <int>`

> Indicates the maximum number of args that will be parsed. Provide -1 for
> infinite number of arguments. Default: 1

`--min <count-min>, --max <count-max>`

> If count-max = count-min <= 1, the variable will be a simple type. If
> count-max > count-min, the variable will be an array. If count-max <
> count-min, an error is generated.

`--authorized-values <StringList>` _(optional)_

> Indicates the possible value list separated by `|` character.
>
> Default: no check.
>
> Eg.: --authorized-values "debug|info|warn|error"

`--regexp <String>` _(optional)_

> regexp to use to validate the argument value.
