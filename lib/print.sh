_shlib_print_err() {
  local txt="${1}"
  FUNCERR="${txt}"
  printf -- '%s\n' "${FUNCERR}" >&2
}

_shlib_print_res() {
  local txt="${1}"
  FUNCRES="${txt}"
  printf -- '%s\n' "${FUNCRES}"
}
