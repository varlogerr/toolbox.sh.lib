# Remove comment lines (; and #) from CONFFILE.
# Usage:
# ```
# conffile_rmcomment CONFFILE
# cat CONFFILE | conffile_rmcomment
# ```
conffile_rmcomment() {
  file_cut "${@}" > /dev/null || return ${rc}

  _shlib_print_res "$(grep -v -E '^\s*[#;].*$' <<< "${FUNCRES}")"
}
