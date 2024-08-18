BEGIN {
  file=""
  lineNumber=0
  lineIdx=0
  previousLineNumber=0
  message=""
  column=0
  severity="warning"
  errorNumber=0
}
{
  line=$0

  # awk: bin/mysql2puml.awk:181:     if (length(currentLine) < 2 || match(currentLine, "^--") > 0) {
  # awk: bin/mysql2puml.awk:181:     ^ syntax error
  # awk: warning: function uml_parse_line called but never defined

  if (match(line, /^awk: ([^:]+):([^:]+): ([ ]*)(.+)$/, arr)) {
      file=arr[1]
      oldLineNumber=lineNumber
      lineNumber=arr[2]
      if ( \
        oldLineNumber != lineNumber \
        && !(oldLineNumber ",message" in lineDetails) \
      ) {
        # special case where lineNumber is presented only once
        # eg: awk: bin/mysql2puml.awk:14: BEGIN blocks must have an action part
        lineDetails[oldLineNumber ",severity"] = "error"
        lineDetails[oldLineNumber ",message"] = lineDetails[oldLineNumber ",source"]
        delete lineDetails[oldLineNumber ",source"]
      }

      if (oldLineNumber == lineNumber) {
        lineDetails[lineNumber ",message"] = arr[4]
        lineDetails[lineNumber ",columnNumber"] = length(arr[3]) + 1
        lineDetails[lineNumber ",severity"] = (index(arr[4], "error") == 0)?"warning":"error"
      } else if (match(arr[4], /^warning:/)) {
        lineDetails[lineNumber ",message"] = arr[4]
        lineDetails[lineNumber ",columnNumber"] = -1
        lineDetails[lineNumber ",severity"] = "warning"
        lines[lineIdx++]=lineNumber
      } else {
        lineDetails[lineNumber ",source"]=arr[4]
        lines[lineIdx++]=lineNumber
      }
  } else if (match(line, /^awk: (warning:) (.+)$/, arr)) {
    errorNumber--
    lines[lineIdx++]=errorNumber
    lineDetails[errorNumber ",message"] = arr[2]
    lineDetails[errorNumber ",columnNumber"] = 0
    lineDetails[errorNumber ",lineNumber"] = 0
    lineDetails[errorNumber ",severity"] = (index(arr[2], "warning") == 0)?"error":"warning"
  } else {
    errorNumber--
    lines[lineIdx++]=errorNumber
    lineDetails[errorNumber ",message"] = line
    lineDetails[errorNumber ",columnNumber"] = 0
    lineDetails[errorNumber ",lineNumber"] = 0
    lineDetails[errorNumber ",severity"] = (index(line, "warning") == 0)?"error":"warning"
  }
}

END {
  for (lineIdx in lines) {
    lineNumber = lines[lineIdx]
    message=""
    if (lineNumber ",source" in lineDetails) {
      message = message lineDetails[lineNumber ",source"];
      message = message " "
    }
    message = message lineDetails[lineNumber ",message"]

    printf("<error line=\"%s\" column=\"%s\" severity=\"%s\" message=\"%s\" />\n",  \
      lineNumber, \
      lineDetails[lineNumber ",columnNumber"], \
      lineDetails[lineNumber ",severity"], \
      escapeXmlAttribute(message) \
    )
  }
}

# quote function for attribute values
#  escape every character, which can
#  cause problems in attribute value
#  strings; we have no information,
#  whether attribute values were
#  enclosed in single or double quotes
function escapeXmlAttribute(str)
{
    gsub(/&/, "\\&amp;", str)
    gsub(/</, "\\&lt;", str)
    gsub(/"/, "\\&quot;", str)
    gsub(/'/, "\\&apos;", str)
    return str
}
