#!/bin/bash
# Update date and lastmod frontmatter fields in markdown files
# Usage:
#   ./update-lastmod.sh --init    # Migration mode: update all git-tracked files in content/
#   ./update-lastmod.sh --commit  # Commit mode: update staged content/*.md files (for pre-commit)

# Configuration
readonly CONTENT_DIR="content"
readonly TIMEZONE="Europe/Paris"
readonly DEFAULT_TIME="08:00:00"
readonly DATE_FORMAT="%Y-%m-%dT%H:%M:%S%:z"

# Get current date in the required format
getCurrentDate() {
  TZ="${TIMEZONE}" date +"${DATE_FORMAT}"
}

# Get today's date (YYYY-MM-DD only)
getTodayDate() {
  TZ="${TIMEZONE}" date +"%Y-%m-%d"
}

# Extract date portion from ISO8601 timestamp
# Args: $1 = timestamp (e.g., "2026-03-29T15:30:05+02:00")
getDatePortion() {
  local timestamp="$1"
  # Extract YYYY-MM-DD portion
  echo "${timestamp}" | sed 's/T.*//; s/["'\'']*//g'
}

# Get git creation date for a file
# Args: $1 = file path
getGitCreationDate() {
  local file="$1"
  local timestamp

  # Get the first commit date for this file
  timestamp=$(git log --follow --format="%aI" --reverse -- "${file}" | head -1)

  if [[ -z "${timestamp}" ]]; then
    # File not in git yet, use current date with default time
    getCurrentDate
    return
  fi

  # Convert to our format with default time if no time component
  local dateOnly
  dateOnly=$(date -d "${timestamp}" +"%Y-%m-%d" 2>/dev/null || echo "")

  if [[ -z "${dateOnly}" ]]; then
    getCurrentDate
    return
  fi

  # Format with default time and timezone
  TZ="${TIMEZONE}" date -d "${dateOnly} ${DEFAULT_TIME}" +"${DATE_FORMAT}"
}

# Get git last modification date for a file
# Args: $1 = file path
getGitModificationDate() {
  local file="$1"
  local timestamp

  # Get the last commit date for this file
  timestamp=$(git log --follow --format="%aI" -1 -- "${file}" | head -1)

  if [[ -z "${timestamp}" ]]; then
    # File not in git yet, use current date with default time
    getCurrentDate
    return
  fi

  # Convert to our format with default time if no time component
  local dateOnly
  dateOnly=$(date -d "${timestamp}" +"%Y-%m-%d" 2>/dev/null || echo "")

  if [[ -z "${dateOnly}" ]]; then
    getCurrentDate
    return
  fi

  # Format with default time and timezone
  TZ="${TIMEZONE}" date -d "${dateOnly} ${DEFAULT_TIME}" +"${DATE_FORMAT}"
}

# Extract frontmatter from markdown file
# Args: $1 = file path
extractFrontmatter() {
  local file="$1"

  # Extract content between first two ---
  awk '/^---$/ {if (++count == 2) exit} count == 1 && NR > 1' "${file}"
}

# Get the line number where frontmatter ends
# Args: $1 = file path
getFrontmatterEndLine() {
  local file="$1"

  # Find the line number of the second ---
  awk '/^---$/ {count++; if (count == 2) {print NR; exit}}' "${file}"
}

# Check if frontmatter has a field
# Args: $1 = frontmatter content, $2 = field name
hasFrontmatterField() {
  local frontmatter="$1"
  local field="$2"

  echo "${frontmatter}" | grep -q "^${field}:"
}

# Get frontmatter field value
# Args: $1 = frontmatter content, $2 = field name
getFrontmatterField() {
  local frontmatter="$1"
  local field="$2"

  echo "${frontmatter}" | grep "^${field}:" | sed "s/^${field}: *//; s/['\"]//g" | head -1
}

# Increment version number
# Args: $1 = version string (e.g., "1.2" or "1.2.3")
incrementVersion() {
  local version="$1"

  # Extract the last number and increment it
  if [[ "${version}" =~ ^([0-9]+)\.([0-9]+)(\.([0-9]+))?$ ]]; then
    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[4]}"

    if [[ -n "${patch}" ]]; then
      # Has patch version, increment it
      echo "${major}.${minor}.$((patch + 1))"
    else
      # Only major.minor, increment minor
      echo "${major}.$((minor + 1))"
    fi
  else
    # Invalid format, return as is
    echo "${version}"
  fi
}

# Update frontmatter in a markdown file
# Args: $1 = file path, $2 = frontmatter content
updateFrontmatter() {
  local file="$1"
  local newFrontmatter="$2"
  local endLine

  endLine=$(getFrontmatterEndLine "${file}")

  if [[ -z "${endLine}" ]]; then
    Log::displayError "✗ No frontmatter found in ${file}"
    return 1
  fi

  # Create temp file with new frontmatter and remaining content
  {
    echo "---"
    echo "${newFrontmatter}"
    echo "---"
    tail -n +"$((endLine + 1))" "${file}"
  } >"${file}.tmp"

  mv "${file}.tmp" "${file}"
}

# Process a file in migration mode (migrate old fields to new ones)
# Args: $1 = file path
processMigrationMode() {
  local file="$1"
  local frontmatter
  local newFrontmatter
  local dateValue=""
  local lastmodValue=""
  local modified=0

  Log::displayInfo "Processing migration: ${file}"

  # Extract current frontmatter
  frontmatter=$(extractFrontmatter "${file}")

  if [[ -z "${frontmatter}" ]]; then
    Log::displayWarning "  ⊘ No frontmatter found, skipping"
    return 0
  fi

  # Remove old field names first
  newFrontmatter=$(echo "${frontmatter}" | grep -v "^creationDate:" | grep -v "^lastUpdated:")

  # Handle date field
  if ! hasFrontmatterField "${frontmatter}" "date"; then
    if hasFrontmatterField "${frontmatter}" "creationDate"; then
      # Migrate from creationDate
      dateValue=$(getFrontmatterField "${frontmatter}" "creationDate")

      # Convert date to proper format with time if needed
      if [[ ! "${dateValue}" =~ T ]]; then
        # Add default time and timezone
        dateValue=$(TZ="${TIMEZONE}" date -d "${dateValue} ${DEFAULT_TIME}" +"${DATE_FORMAT}")
      fi

      Log::displayInfo "  ✓ Migrating creationDate to date: ${dateValue}"
      modified=1
    else
      # Get from git
      dateValue=$(getGitCreationDate "${file}")
      Log::displayInfo "  ✓ Creating date from git: ${dateValue}"
      modified=1
    fi
  fi

  # Handle lastmod field
  if ! hasFrontmatterField "${frontmatter}" "lastmod"; then
    if hasFrontmatterField "${frontmatter}" "lastUpdated"; then
      # Migrate from lastUpdated
      lastmodValue=$(getFrontmatterField "${frontmatter}" "lastUpdated")

      # Convert date to proper format with time if needed
      if [[ ! "${lastmodValue}" =~ T ]]; then
        # Add default time and timezone
        lastmodValue=$(TZ="${TIMEZONE}" date -d "${lastmodValue} ${DEFAULT_TIME}" +"${DATE_FORMAT}")
      fi

      Log::displaySuccess "  ✓ Migrating lastUpdated to lastmod: ${lastmodValue}"
      modified=1
    else
      # Get from git
      lastmodValue=$(getGitModificationDate "${file}")
      Log::displaySuccess "  ✓ Creating lastmod from git: ${lastmodValue}"
      modified=1
    fi
  fi

  # Handle version field
  if ! hasFrontmatterField "${newFrontmatter}" "version"; then
    Log::displaySuccess "  ✓ Adding version: 1.0"
    modified=1
  fi

  # Add date, lastmod, and version at the end of frontmatter
  if [[ "${modified}" = "1" ]]; then
    # Append date if we have a value
    if [[ -n "${dateValue}" ]]; then
      newFrontmatter=$(printf "%s\ndate: '%s'" "${newFrontmatter}" "${dateValue}")
    fi

    # Append lastmod if we have a value
    if [[ -n "${lastmodValue}" ]]; then
      newFrontmatter=$(printf "%s\nlastmod: '%s'" "${newFrontmatter}" "${lastmodValue}")
    fi

    # Append version if it doesn't exist
    if ! hasFrontmatterField "${newFrontmatter}" "version"; then
      newFrontmatter=$(printf "%s\nversion: '1.0'" "${newFrontmatter}")
    fi
  fi

  # Update file if modified
  if [[ "${modified}" = "1" ]]; then
    updateFrontmatter "${file}" "${newFrontmatter}"
    Log::displaySuccess "  ✅ Updated ${file}"
  else
    Log::displayWarning "  ⊘ No changes needed"
  fi
}

# Check if file has actual content changes (not just metadata)
# Args: $1 = file path
# Returns: 0 if file has changes, 1 if no changes
hasActualChanges() {
  local file="$1"

  # Check if file is tracked by git
  if ! git ls-files --error-unmatch "${file}" >/dev/null 2>&1; then
    # New file, not tracked yet - consider it as changed
    return 0
  fi

  # Get the diff excluding frontmatter date/lastmod/version lines
  local diff
  diff=$(git diff HEAD -- "${file}" 2>/dev/null | grep -E "^[+-]" | grep -vE "^[+-](date|lastmod|version):" || true)

  if [[ -n "${diff}" ]]; then
    # Has actual content changes
    return 0
  else
    # No actual changes (only metadata might have changed)
    return 1
  fi
}

# Process a file in commit mode (set current date if fields missing)
# Args: $1 = file path
processCommitMode() {
  local file="$1"
  local frontmatter
  local newFrontmatter
  local currentDate
  local modified=0

  Log::displayInfo "Processing commit: ${file}"

  # Only process .md files in content directory
  if [[ ! "${file}" =~ ^content/.*\.md$ ]]; then
    Log::displayWarning "  ⊘ Not a content markdown file, skipping"
    return 0
  fi

  # Check if file exists
  if [[ ! -f "${file}" ]]; then
    Log::displayWarning "  ⊘ File not found, skipping"
    return 0
  fi

  # Extract current frontmatter
  frontmatter=$(extractFrontmatter "${file}")

  if [[ -z "${frontmatter}" ]]; then
    Log::displayWarning "  ⊘ No frontmatter found, skipping"
    return 0
  fi

  currentDate="$(getCurrentDate)"
  local todayDate
  todayDate="$(getTodayDate)"

  # Check 1: Skip if file has no actual content changes (for pre-commit run -a)
  # Check 2: Skip if lastmod already has today's date (for multiple commits same day)
  local skipUpdate=0
  local skipReason=""

  if ! hasActualChanges "${file}"; then
    skipUpdate=1
    skipReason="No content changes detected"
  elif hasFrontmatterField "${frontmatter}" "lastmod"; then
    local existingLastmod
    existingLastmod=$(getFrontmatterField "${frontmatter}" "lastmod")
    local existingDate
    existingDate=$(getDatePortion "${existingLastmod}")

    if [[ "${existingDate}" = "${todayDate}" ]]; then
      skipUpdate=1
      skipReason="Already updated today"
    fi
  fi

  if [[ "${skipUpdate}" = "1" ]]; then
    Log::displayWarning "  ⊘ ${skipReason}, skipping lastmod and version"
  fi

  # Remove date, lastmod, and version fields from frontmatter (we'll add them at the end)
  newFrontmatter=$(echo "${frontmatter}" | grep -v "^date:" | grep -v "^lastmod:" | grep -v "^version:")
  # Determine date value
  local dateValue
  if hasFrontmatterField "${frontmatter}" "date"; then
    dateValue=$(getFrontmatterField "${frontmatter}" "date")
  else
    dateValue="${currentDate}"
    Log::displaySuccess "  ✓ Adding date: ${currentDate}"
    modified=1
  fi

  # Update lastmod only if not already updated today
  local lastmodValue
  if [[ "${skipUpdate}" = "1" ]]; then
    # Keep existing lastmod
    lastmodValue=$(getFrontmatterField "${frontmatter}" "lastmod")
  else
    # Update to current date
    lastmodValue="${currentDate}"
    Log::displaySuccess "  ✓ Updating lastmod: ${currentDate}"
    modified=1
  fi

  # Handle version increment
  local versionValue
  if [[ "${skipUpdate}" = "1" ]]; then
    # Keep existing version
    if hasFrontmatterField "${frontmatter}" "version"; then
      versionValue=$(getFrontmatterField "${frontmatter}" "version")
    else
      versionValue="1.0"
    fi
  elif hasFrontmatterField "${frontmatter}" "version"; then
    local oldVersion
    oldVersion=$(getFrontmatterField "${frontmatter}" "version")
    versionValue=$(incrementVersion "${oldVersion}")
    Log::displaySuccess "  ✓ Incrementing version: ${oldVersion} → ${versionValue}"
    modified=1
  else
    versionValue="1.0"
    Log::displaySuccess "  ✓ Adding version: ${versionValue}"
    modified=1
  fi

  # Add date, lastmod, and version at the end of frontmatter
  newFrontmatter=$(printf "%s\ndate: '%s'\nlastmod: '%s'\nversion: '%s'" "${newFrontmatter}" "${dateValue}" "${lastmodValue}" "${versionValue}")

  # Update file if modified
  if [[ "${modified}" = "1" ]]; then
    updateFrontmatter "${file}" "${newFrontmatter}"
    Log::displaySuccess "  ✅ Updated ${file}"
  else
    Log::displayWarning "  ⊘ No changes needed"
  fi
}

# Main function
main() {
  # Parse arguments
  if [[ $# -eq 0 ]]; then
    Log::displayError "Error: Mode required. Use --init or --commit"
    Log::displayInfo "Usage:"
    Log::displayInfo "  $0 --init    # Migration mode: process all git-tracked content/*.md files"
    Log::displayInfo "  $0 --commit  # Commit mode:    process staged content/*.md files"
    exit 1
  fi

  # shellcheck disable=SC2154
  if [[ "${optionInit}" = "1" ]]; then
    # Migration mode: process all git-tracked .md files in content/
    Log::displayInfo "Running in migration mode: updating git-tracked files in ${CONTENT_DIR}/"

    local fileCount=0
    local files=()

    # Get git-tracked files in content/ directory
    while IFS= read -r file; do
      if [[ "${file}" =~ ^${CONTENT_DIR}/.*\.md$ ]]; then
        files+=("${file}")
      fi
    done < <(git ls-files "${CONTENT_DIR}/**/*.md" 2>/dev/null)

    if [[ ${#files[@]} -eq 0 ]]; then
      Log::displayWarning "⊘ No git-tracked markdown files found in ${CONTENT_DIR}/"
      exit 0
    fi

    for file in "${files[@]}"; do
      processMigrationMode "${file}"
      fileCount=$((fileCount + 1))
    done

    Log::displayInfo "✅ Migration complete: processed ${fileCount} files"
  fi

  # shellcheck disable=SC2154
  if [[ "${optionCommit}" = "1" ]]; then
    # Commit mode: process staged content/*.md files
    Log::displayInfo "Running in commit mode: updating staged files in ${CONTENT_DIR}/"

    local fileCount=0
    local files=()

    # Get staged files in content/ directory
    while IFS= read -r file; do
      if [[ -n "${file}" && "${file}" =~ ^${CONTENT_DIR}/.*\.md$ ]]; then
        files+=("${file}")
      fi
    done < <(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep "^${CONTENT_DIR}/.*\.md$")

    if [[ ${#files[@]} -eq 0 ]]; then
      Log::displayWarning "⊘ No staged markdown files found in ${CONTENT_DIR}/"
      exit 0
    fi

    for file in "${files[@]}"; do
      processCommitMode "${file}"
      fileCount=$((fileCount + 1))
    done

    Log::displayInfo "✅ Commit mode complete: processed ${fileCount} files"
  fi
}

# Run main function
main "$@"
