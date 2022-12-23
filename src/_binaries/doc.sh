#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/doc
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

export FRAMEWORK_DIR="${ROOT_DIR}"

.INCLUDE "${TEMPLATE_DIR}/_includes/executedAsUser.sh"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} generate jekyll documentation
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME}

.INCLUDE "${TEMPLATE_DIR}/_includes/author.tpl"
EOF
)"
Args::defaultHelp "${HELP}" "$@"

# clean folder before generate
rm -f "${ROOT_DIR}/jekyll/Index.md" || true
rm -Rf "${ROOT_DIR}/jekyll/bashDoc" || true

ShellDoc::generateShellDocsFromDir \
  "${SRC_DIR}" \
  "${ROOT_DIR}/jekyll/bashDoc" \
  "${ROOT_DIR}/jekyll/Index.md" \
  '(/_\.sh|/ZZZ\.sh|_includes/.*\.sh|/__all\.sh)$'

cp "${ROOT_DIR}/README.md" "${ROOT_DIR}/jekyll"
cp "${ROOT_DIR}/Framework.tmpl.md" "${ROOT_DIR}/jekyll/Framework.md"
# inject index file into Framework.md
sed -E -i "/## Framework library full Index/ r ${ROOT_DIR}/jekyll/Index.md" "${ROOT_DIR}/jekyll/Framework.md"
rm -f "${ROOT_DIR}/jekyll/Index.md"
