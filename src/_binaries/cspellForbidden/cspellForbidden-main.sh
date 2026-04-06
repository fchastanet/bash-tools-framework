#!/usr/bin/env bash

# ensure .cspell/forbidden.txt exists
if [[ ! -f ".cspell/forbidden.txt" ]]; then
  mkdir -p .cspell
  Log::fatal "The file .cspell/forbidden.txt does not exist. Please create it or link it and add the forbidden words, one per line with !word."
fi

# ensure .cspell/forbidden.txt is used by cspell
# Determine which config file to use (prefer yaml over json)
cspellConfigFile="cspell.yaml"
if [[ ! -f "cspell.yaml" && ! -f "cspell.yml" ]]; then
  Log::fatal "Only cspell.yaml or cspell.yml configuration files are supported. Please create one of these files."
elif [[ -f "cspell.yml" ]]; then
  cspellConfigFile="cspell.yml"
fi

EXPECTED_FORBIDDEN_DICT_ENTRY=$(
  cat <<EOF
dictionaryDefinitions:
  - name: forbidden
    addWords: false
    path: .cspell/forbidden.txt
EOF
)

confError() {
  Log::displayError "The forbidden dictionary is not properly defined in the dictionaryDefinitions section of ${cspellConfigFile}."
  if [[ -n "$1" ]]; then
    Log::displayError "$1"
  fi
  Log::displayInfo "Please add the following entry in ${cspellConfigFile}:"
  echo -e "${EXPECTED_FORBIDDEN_DICT_ENTRY}\n"
  exit 1
}

# check if expected forbidden dictionary entry exists in the dictionaryDefinitions section
if ! yq -e '.dictionaryDefinitions[]? | select(.name == "forbidden")' "${cspellConfigFile}" >/dev/null; then
  confError
fi
if ! yq -e '.dictionaryDefinitions[]? | select(.name == "forbidden") | .addWords == false' "${cspellConfigFile}" >/dev/null; then
  confError "The 'addWords' property for the forbidden dictionary must be set to false."
fi
if ! yq -e '.dictionaryDefinitions[]? | select(.name == "forbidden") | .path == ".cspell/forbidden.txt"' "${cspellConfigFile}" >/dev/null; then
  confError "The 'path' property for the forbidden dictionary must be set to .cspell/forbidden.txt."
fi

# check if forbidden dictionary is listed in the dictionaries
if ! yq '.dictionaries[]?' "${cspellConfigFile}" | grep -q "^forbidden$"; then
  Log::displayError "The forbidden dictionary is not listed in the dictionaries section of ${cspellConfigFile}."
  Log::displayInfo "Please add 'forbidden' to the list of dictionaries in ${cspellConfigFile}."
  exit 1
fi

# check that all words from .cspell/forbidden.txt are beginning with "!" (except for empty lines and comments)
if grep -E '^[^#!]' .cspell/forbidden.txt >/dev/null; then
  Log::fatal "All words in .cspell/forbidden.txt must start with '!' (except for empty lines and comments). Please update the file accordingly."
fi

# ensure all the .txt files in .cspell directory are sorted and unique (case-sensitive)
for file in .cspell/*.txt; do
  if [[ -f "$file" && "$file" != ".cspell/forbidden.txt" ]]; then
    declare tmpFile="${TMPDIR}/tmp.$$.txt"
    Log::displayInfo "Sorting and uniquing the file $file"
    LC_COLLATE=C sort --ignore-case "$file" | uniq >"$tmpFile" || {
      Log::fatal "Failed to sort and unique the file $file"
    }
    mv "$tmpFile" "$file"
  fi
done

# run cspell on git tracked files
# shellcheck disable=SC2154
(
  git ls-files
  git ls-tree --full-tree -r --name-only HEAD
) | sort | uniq |
  npx cspell --quiet --no-must-find-files --file-list stdin "${cspellOptions[@]}"
