# Remove comment lines (; and #) from CONFFILE.
# Usage:
# ```
# conffile_rmcomment CONFFILE
# cat CONFFILE | conffile_rmcomment
# ```
conffile_rmcomment() {
  [[ -z "${1+x}" ]] && {
    file_cut > /dev/null || return ${rc}
  } || {
    file_cut "${@}" > /dev/null || return ${rc}
  }

  _print_res "$(grep -v -E '^\s*[#;].*$' <<< "${FUNCRES}")"
}
