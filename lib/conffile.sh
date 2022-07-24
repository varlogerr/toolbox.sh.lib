# Remove comment lines (; and #) from CONFFILE.
# Usage:
# ```
# conffile_rmcomment CONFFILE
# cat CONFFILE | conffile_rmcomment
# ```
conffile_rmcomment() {
  local file
  local txt

  [[ ${#} -gt 1 ]] && {
    echo "[${FUNCNAME[0]}] Multiple files are not allowed" >&2
    return 1
  }

  [[ -n "${1+x}" ]] && file="${1}"

  [[ -n "${file+x}" ]] && {
    file_is_readable "${file}" || {
      echo "[${FUNCNAME[0]}] File must exist and to be readable by current user: ${file}" >&2
      return 1
    }
    txt="$(cat -- "${file}")"
  } || {
    txt="$(cat --; echo x)"
    txt="${txt%$'\n'x}"
  }

  grep -v -E '^\s*[#;].*$' <<< "${txt}"
}
