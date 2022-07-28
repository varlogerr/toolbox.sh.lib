${aliased} && {
  sed_key() { shlib_sed_escape_key "${@}"; }
  sed_replace() { shlib_sed_escape_replace "${@}"; }
}

# https://stackoverflow.com/a/2705678

shlib_sed_escape_key() {
  sed -e 's/[]\/$*.^[]/\\&/g' <<< "${1}"
}

shlib_sed_escape_replace() {
  sed -e 's/[\/&]/\\&/g' <<< "${1}"
}
