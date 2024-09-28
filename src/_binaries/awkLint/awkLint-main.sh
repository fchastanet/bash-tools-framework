#!/usr/bin/env bash
# @embed "${FRAMEWORK_ROOT_DIR}/src/_binaries/awkLint/awkLint.awk" AS awkLintScript

# <?xml version='1.0' encoding='UTF-8'?>
# <checkstyle version='4.3'>
# <file name='./tests/bash&#45;framework/ManualTest.sh' >
# <error line='9' column='8' severity='warning' message='Can&#39;t follow non&#45;constant source. Use a directive to specify location.' source='ShellCheck.SC1090' />
# <error line='17' column='5' severity='warning' message='Use &#39;cd ... &#124;&#124; exit&#39; or &#39;cd ... &#124;&#124; return&#39; in case cd fails.' source='ShellCheck.SC2164' />
# <error line='27' column='5' severity='warning' message='Use &#39;cd ... &#124;&#124; exit&#39; or &#39;cd ... &#124;&#124; return&#39; in case cd fails.' source='ShellCheck.SC2164' />
# </file>
# </checkstyle>
declare exitCode="0"
echo "<?xml version='1.0' encoding='UTF-8'?>"
echo "<checkstyle>"
tempFile="$(Framework::createTempFile)"
while IFS='' read -r file; do
  # shellcheck disable=SC2154
  if [[ ! -f "${file}" ]]; then
    Log::displayWarning "File ${file} has been deleted from git."
  else
    echo "<file name='${file}'>"
    awk --source "BEGIN { exit(0) } END { exit(0) }" --lint=no-ext \
      -f "${file}" >"${tempFile}" 2>&1 </dev/null || exitCode="1"
    awk -f "${embed_file_awkLintScript}" - <"${tempFile}"
    echo "</file>"
  fi
done < <(
  git ls-files --exclude-standard |
    grep -E '\.(awk)$' || true
)
echo "</checkstyle>"
exit "${exitCode}"
