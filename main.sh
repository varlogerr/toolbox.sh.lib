__shlib_main() {
  unset __shlib_main

  local aliased=false
  [[ " ${@} " == *" aliased "* ]] && aliased=true

  local curdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  local libdir="${curdir}/lib"
  local libs="$(find "${libdir}" -type f -maxdepth 1 -name '*.sh')"
  declare -a libs_arr
  mapfile -t libs_arr <<< "${libs}"

  for f in "${libs_arr[@]}"; do
    . "${f}"
  done
} && __shlib_main "${@}"
