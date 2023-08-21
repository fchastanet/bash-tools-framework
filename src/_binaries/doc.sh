#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/doc
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

DOC_DIR="${FRAMEWORK_ROOT_DIR}/pages"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} generate markdown documentation
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME}

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
Args::defaultHelp "${HELP}" "$@"

ShellDoc::installRequirementsIfNeeded

if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
  if [[ "${ARGS_VERBOSE}" = "1" ]]; then
    set -- "$@" --verbose
  fi
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
  '(bash-tpl|var|simpleBinary|shdoc|installFacadeExample)$'

# clean folder before generate
rm -f "${DOC_DIR}/Index.md" || true
rm -Rf "${DOC_DIR}/bashDoc" || true
rm -Rf "${DOC_DIR}/FrameworkIndex.md" || true

ShellDoc::generateShellDocsFromDir \
  "${FRAMEWORK_SRC_DIR}" \
  "src" \
  "${DOC_DIR}/bashDoc" \
  "${DOC_DIR}/FrameworkIndex.md" \
  "<% ${REPOSITORY_URL} %>" \
  '/testsData|/_.*' \
  '(/__all\.sh)$'

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
cp "${FRAMEWORK_ROOT_DIR}/FrameworkDoc.md" "${DOC_DIR}"
cp "${FRAMEWORK_ROOT_DIR}/src/Docker/DockerUsage.md" "${DOC_DIR}/DockerUsage.md"

Log::displayInfo 'generate FrameworkFullDoc.md'
cp "${FRAMEWORK_ROOT_DIR}/FrameworkFullDoc.tmpl.md" "${DOC_DIR}/FrameworkFullDoc.md"
(
  echo
  find "${DOC_DIR}/bashDoc" -type f -name '*.md' -print0 | LC_ALL=C sort -z | xargs -0 cat
) >>"${DOC_DIR}/FrameworkFullDoc.md"

ShellDoc::fixMarkdownToc "${DOC_DIR}/FrameworkFullDoc.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/BestPractices.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/CompileCommand.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/FrameworkDoc.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/README.md"
ShellDoc::fixMarkdownToc "${DOC_DIR}/Commands.md"

if ((TOKEN_NOT_FOUND_COUNT > 0)); then
  exit 1
fi
