# Remove comment lines (; and #) from CONFFILE.
# Usage:
# ```
# conffile_rmcomment CONFFILE
# cat CONFFILE | conffile_rmcomment
# ```
conffile_rmcomment() {
  unset RETVAL

  [[ -z "${1+x}" ]] && {
    file_cut > /dev/null || return ${rc}
  } || {
    file_cut "${@}" > /dev/null || return ${rc}
  }

  RETVAL="$(grep -v -E '^\s*[#;].*$' <<< "${RETVAL}")"
  printf -- '%s\n' "${RETVAL}"
}
