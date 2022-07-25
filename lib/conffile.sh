# Remove comment lines (; and #) from CONFFILE.
# Usage:
# ```
# conffile_rmcomment CONFFILE
# cat CONFFILE | conffile_rmcomment
# ```
conffile_rmcomment() {
  [[ -z "${1+x}" ]] && {
    file_cut || return ${rc}
  } || {
    file_cut "${@}" || return ${rc}
  }

  grep -v -E '^\s*[#;].*$' <<< "${RETVAL}"
}
