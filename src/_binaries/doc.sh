#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/doc

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"
FRAMEWORK_ROOT_DIR="$(cd "${CURRENT_DIR}/.." && pwd -P)"
DOC_DIR="${FRAMEWORK_ROOT_DIR}/pages"
.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_load.tpl"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} generate markdown documentation
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME}

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
Args::defaultHelp "${HELP}" "$@"

if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
  "${COMMAND_BIN_DIR}/runBuildContainer" "/bash/bin/doc" "$@"
  exit $?
fi

export FRAMEWORK_ROOT_DIR

#-----------------------------
# doc generation
#-----------------------------

Log::displayInfo 'generate Commands.md'
((TOKEN_NOT_FOUND_COUNT = 0)) || true
ShellDoc::generateMdFileFromTemplate \
  "${FRAMEWORK_ROOT_DIR}/Commands.tmpl.md" \
  "${DOC_DIR}/Commands.md" \
  "${COMMAND_BIN_DIR}" \
  TOKEN_NOT_FOUND_COUNT \
  '(bash-tpl|var|simpleBinary)$'

# clean folder before generate
rm -f "${DOC_DIR}/Index.md" || true
rm -Rf "${DOC_DIR}/bashDoc" || true

ShellDoc::generateShellDocsFromDir \
  "${FRAMEWORK_SRC_DIR}" \
  "${DOC_DIR}/bashDoc" \
  "${DOC_DIR}/FrameworkIndex.md" \
  '(/_\.sh|/ZZZ\.sh|_includes/.*\.sh|_binaries/.*\.sh|/__all\.sh)$'

cp "${FRAMEWORK_ROOT_DIR}/README.md" "${DOC_DIR}"
sed -i -E \
  -e '/<!-- remove -->/,/<!-- endRemove -->/d' \
  -e 's#https://fchastanet.github.io/bash-tools-framework/#/#' \
  -e 's#^> \*\*_TIP:_\*\* (.*)$#> [!TIP|label:\1]#' \
  "${DOC_DIR}/README.md"

mkdir -p "${DOC_DIR}/images" || true
cp -R "${FRAMEWORK_ROOT_DIR}/images/"* "${DOC_DIR}/images"
cp "${FRAMEWORK_ROOT_DIR}/BestPractices.md" "${DOC_DIR}"
cp "${FRAMEWORK_ROOT_DIR}/CompileCommand.md" "${DOC_DIR}"
cp "${FRAMEWORK_ROOT_DIR}/FrameworkFullDoc.tmpl.md" "${DOC_DIR}/FrameworkFullDoc.md"

Log::displayInfo 'generate FrameworkFullDoc.md'
(
  cd "${FRAMEWORK_ROOT_DIR}/pages/bashDoc" || exit 1
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

ShellDoc::fixMarkdownToc "${DOC_DIR}/FrameworkFullDoc.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/BestPractices.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/CompileCommand.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/README.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/Commands.md"

if ((TOKEN_NOT_FOUND_COUNT > 0)); then
  exit 1
fi
