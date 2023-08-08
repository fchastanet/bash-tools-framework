{
  line=$0
  if (match(line, /^(\s*- \[([0-9]+\.)+ [^]]+\]\(#)([^)]+)\)/, arr)) {
    print arr[1] "_" rewrite(arr[3]) ")"
  } else {
    print line
  }
}
function rewrite(str)
{
    gsub(/-(-)+/, "-", str)
    return str
}
