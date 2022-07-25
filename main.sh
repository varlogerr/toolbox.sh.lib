__main_source() {
  unset __main_source

  local curdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  export __SHLIB_NOPATH=/dev/null/foo/bar

  . "${curdir}/lib/conffile.sh"
  . "${curdir}/lib/file.sh"
  . "${curdir}/lib/print.sh"
  . "${curdir}/lib/txt.sh"

} && __main_source
