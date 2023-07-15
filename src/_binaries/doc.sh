#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/doc
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"
DOC_DIR="${ROOT_DIR}/pages"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} generate markdown documentation
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME}

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
Args::defaultHelp "${HELP}" "$@"

if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
  "${BIN_DIR}/runBuildContainer" "/bash/bin/doc" "$@"
  exit $?
fi

export FRAMEWORK_DIR="${ROOT_DIR}"

#-----------------------------
# doc generation
#-----------------------------

Log::displayInfo 'generate Commands.md'
((TOKEN_NOT_FOUND_COUNT = 0)) || true
ShellDoc::generateMdFileFromTemplate \
  "${ROOT_DIR}/Commands.tmpl.md" \
  "${DOC_DIR}/Commands.md" \
  "${BIN_DIR}" \
  TOKEN_NOT_FOUND_COUNT \
  '(bash-tpl|meta|simpleBinary)$'

# clean folder before generate
rm -f "${DOC_DIR}/Index.md" || true
rm -Rf "${DOC_DIR}/bashDoc" || true

ShellDoc::generateShellDocsFromDir \
  "${SRC_DIR}" \
  "${DOC_DIR}/bashDoc" \
  "${DOC_DIR}/FrameworkIndex.md" \
  '(/_\.sh|/ZZZ\.sh|_includes/.*\.sh|_binaries/.*\.sh|/__all\.sh)$'

cp "${ROOT_DIR}/README.md" "${DOC_DIR}"
sed -i -E \
  -e '/<!-- remove -->/,/<!-- endRemove -->/d' \
  -e 's#https://fchastanet.github.io/bash-tools-framework/#/#' \
  -e 's#^> \*\*_TIP:_\*\* (.*)$#> [!TIP|label:\1]#' \
  "${DOC_DIR}/README.md"

cp "${ROOT_DIR}/BestPractices.md" "${DOC_DIR}"
cp "${ROOT_DIR}/Framework.tmpl.md" "${DOC_DIR}/Framework.md"
cp "${ROOT_DIR}/FrameworkFullDoc.tmpl.md" "${DOC_DIR}/FrameworkFullDoc.md"

Log::displayInfo 'generate FrameworkFullDoc.md'
(
  cd "${ROOT_DIR}/pages/bashDoc" || exit 1
  currentDir=""
  echo ""
  while IFS= read -r file; do
    dir="$(dirname "${file}")"
    if [[ "${currentDir}" != "${dir}" ]]; then
      echo
      echo "## ${dir#./}"
      currentDir="${dir}"
    fi
    # shellcheck disable=SC2016
    # print removing 2 first titles
    sed -E \
      -e 's/^(##?) [^#]+$//g' \
      -e 's/^### Function (.+)$/### \1/g' \
      "${file}"
  done < <(
    # find ensuring that files are ordered
    find . -type f -printf '%h\0%d\0%p\n' |
      sort -t '\0' -n |
      awk -F '\0' '{print $3}'
  )
) >>"${DOC_DIR}/FrameworkFullDoc.md"

if ((TOKEN_NOT_FOUND_COUNT > 0)); then
  exit 1
fi
