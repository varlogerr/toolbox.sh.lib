__main_source() {
  unset __main_source

  local curdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

  . "${curdir}/lib/conffile.sh"
  . "${curdir}/lib/file.sh"
  . "${curdir}/lib/shlib.sh"
  . "${curdir}/lib/txt.sh"

} && __main_source
