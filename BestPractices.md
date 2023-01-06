# Best practices and recipes

- local or declare multiple local a z
- shift each arg to avoid not shifting at all
- declare all variables as local in functions to avoid making them global
- export readonly does not work, first readonly then export
- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html> but set -o
  nounset is not usable because empty array are considered unset
- `${PARAMETER:-WORD}` `${PARAMETER-WORD}` If the parameter PARAMETER is unset
  (never was defined) or null (empty), this one expands to WORD, otherwise it
  expands to the value of PARAMETER, as if it just was ${PARAMETER}. If you omit
  the : (colon), like shown in the second form, the default value is only used
  when the parameter was unset, not when it was empty.
- always use `sed -E`
- `cat << 'EOF'` avoid to interpolate variables
- ensure we don't have any globals, all variables should be passed to the
  functions
- avoid using grep -P as it is not supported on alpine, prefer using -E
- to construct complex command line, prefer to use an array
  - `declare -a cmd=(git push origin :${branch})`
  - then you can display the result using echo `"${cmd[*]}"`
  - you can execute the command using `"${cmd[@]}"`
- to check if an environment variable is set

```bash
if [[ -z ${varName+xxx} ]]; then
  # varName is not set
fi
```
