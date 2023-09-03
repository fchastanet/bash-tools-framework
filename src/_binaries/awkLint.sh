#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/awkLint
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options.awkLint.tpl)"

awkLintCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

awkLintScript="$(
  cat <<'EOF'
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_binaries/awkLint.awk"
EOF
)"

run() {
  # <?xml version='1.0' encoding='UTF-8'?>
  # <checkstyle version='4.3'>
  # <file name='./tests/bash&#45;framework/ManualTest.sh' >
  # <error line='9' column='8' severity='warning' message='Can&#39;t follow non&#45;constant source. Use a directive to specify location.' source='ShellCheck.SC1090' />
  # <error line='17' column='5' severity='warning' message='Use &#39;cd ... &#124;&#124; exit&#39; or &#39;cd ... &#124;&#124; return&#39; in case cd fails.' source='ShellCheck.SC2164' />
  # <error line='27' column='5' severity='warning' message='Use &#39;cd ... &#124;&#124; exit&#39; or &#39;cd ... &#124;&#124; return&#39; in case cd fails.' source='ShellCheck.SC2164' />
  # </file>
  # </checkstyle>
  echo "<?xml version='1.0' encoding='UTF-8'?>"
  echo "<checkstyle>"
  while IFS='' read -r file; do
    echo "<file name='${file}'>"
    awk --source "BEGIN { exit(0) } END { exit(0) }" --lint=no-ext -f "${file}" 2>&1 </dev/null |
      awk --source "${awkLintScript}" - || true
    echo "</file>"
  done < <(git ls-files --exclude-standard | grep -E '\.(awk)$' || true)
  echo "</checkstyle>"
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
