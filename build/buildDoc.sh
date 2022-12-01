#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM src/build/buildDoc.sh
# DO NOT EDIT IT
#####################################

ROOT_DIR="/home/wsl/projects/bash-tools2"
# shellcheck disable=SC2034
LIB_DIR="${ROOT_DIR}/lib"
# shellcheck disable=SC2034

# shellcheck disable=SC2034
((failures = 0)) || true

shopt -s expand_aliases
set -o pipefail
set -o errexit
# a log is generated when a command fails
set -o errtrace
# use nullglob so that (file*.php) will return an empty array if no file matches the wildcard
shopt -s nullglob
export TERM=xterm-256color

#avoid interactive install
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# FUNCTIONS

if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
  "${ROOT_DIR}/.build/runBuildContainer.sh" "/bash/build/doc.sh" "$@"
  exit $?
fi

INDEX_FILE="/tmp/Index.md"

generateShDoc() {
  local file="$1"
  local currentDir="$2"
  local indexFile="$3"
  local relativeFile="${file#"${currentDir}/"}"
  local basename="${file##*/}"
  local basenameNoExtension="${basename%.*}"

  cd "${currentDir}" || exit 1
  echo "generate markdown doc for ${relativeFile} in doc/${basenameNoExtension}.md"

  local doc
  doc="$("./vendor/fchastanet.tomdoc.sh/tomdoc.sh" "${relativeFile}")"
  if [[ -n "${doc}" ]]; then
    echo "${doc}" >"${currentDir}/doc/${basenameNoExtension}.md"

    # add reference to index file
    echo "* [${relativeFile}](doc/${basenameNoExtension}.md)" >>"${indexFile}"
  else
    # empty doc
    rm -f "${currentDir}/doc/${basenameNoExtension}.md" || true
  fi
}
export -f generateShDoc

escapeColorCodes() {
  cat - | sed $'s/\e\\[[0-9;:]*[a-zA-Z]//g'
}

generateReadme() {
  TMP_DIR="$(mktemp -d "/tmp/bash-tools.XXXXXXXX")"
  trap 'rm -rf "${TMP_DIR}"' ERR EXIT

  replaceTokenByFileContent() {
    local TOKEN="$1"
    "${CURRENT_DIR}/bin/${TOKEN}" --help | escapeColorCodes >"${TMP_DIR}/${TOKEN}_help"
    (
      cd "${TMP_DIR}" || exit 1
      sed -i -e "/@@@${TOKEN}_help@@@/r ${TOKEN}_help" -e "/@@@${TOKEN}_help@@@/d" "${CURRENT_DIR}/README.md"
    )
  }

  cp "${CURRENT_DIR}/tests/tools/data/mysql2puml.puml" "${TMP_DIR}/mysql2puml_plantuml_diagram"
  cp "${CURRENT_DIR}/README.tmpl.md" "${CURRENT_DIR}/README.md"

  replaceTokenByFileContent "gitRenameBranch"
  replaceTokenByFileContent "dbQueryAllDatabases"
  replaceTokenByFileContent "dbScriptAllDatabases"
  replaceTokenByFileContent "dbImport"
  replaceTokenByFileContent "dbImportProfile"
  replaceTokenByFileContent "gitIsAncestorOf"
  replaceTokenByFileContent "gitIsBranch"
  replaceTokenByFileContent "mysql2puml"
  replaceTokenByFileContent "cli"
  sed -i -e "/@@@mysql2puml_plantuml_diagram@@@/r ${CURRENT_DIR}/tests/tools/data/mysql2puml.puml" -e "/@@@mysql2puml_plantuml_diagram@@@/d" "${CURRENT_DIR}/README.md"
  sed -i -e "/@@@bash_doc_index@@@/r ${INDEX_FILE}" -e "/@@@bash_doc_index@@@/d" "${CURRENT_DIR}/README.md"
}

#-----------------------------
# configure environment
#-----------------------------
mkdir -p ~/.bash-tools
cp -R conf/. ~/.bash-tools
sed -i \
  -e "s@^BASH_TOOLS_FOLDER=.*@BASH_TOOLS_FOLDER=$(pwd)@g" \
  -e "s@^S3_BASE_URL=.*@S3_BASE_URL=s3://example.com/exports/@g" \
  ~/.bash-tools/.env
# fake docker command
touch /tmp/docker
chmod 755 /tmp/docker
export PATH=/tmp:${PATH}

#-----------------------------
# doc generation
#-----------------------------
# generate doc + index
echo "generate bash-framework index"
mkdir -p "${CURRENT_DIR}/doc"
while IFS= read -r file; do
  generateShDoc "${file}" "${CURRENT_DIR}" "${INDEX_FILE}"
done < <(find "${CURRENT_DIR}/bash-framework" -name "*.sh" | sort)

# generate readme
echo "generate README.md"
generateReadme

# cleaning
rm -f "${INDEX_FILE}"
