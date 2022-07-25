# Remove comment lines (; and #) from CONFFILE.
# Usage:
# ```
# conffile_rmcomment CONFFILE
# cat CONFFILE | conffile_rmcomment
# ```
conffile_rmcomment() {
  unset FUNCRET

  [[ -z "${1+x}" ]] && {
    file_cut > /dev/null || return ${rc}
  } || {
    file_cut "${@}" > /dev/null || return ${rc}
  }

  FUNCRET="$(grep -v -E '^\s*[#;].*$' <<< "${FUNCRET}")"
  printf -- '%s\n' "${FUNCRET}"
}
