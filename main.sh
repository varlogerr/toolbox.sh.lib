__main_source() {
  unset __main_source

  export SHLIB_CHANNEL1_COUNT=0

  local curdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

  . "${curdir}/lib/channel.sh"
  . "${curdir}/lib/conffile.sh"
  . "${curdir}/lib/file.sh"
  . "${curdir}/lib/txt.sh"

} && __main_source
