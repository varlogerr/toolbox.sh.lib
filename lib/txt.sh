#
# ALIASES
#
${aliased} && {
  ltrim() { shlib_txt_ltrim "${@}"; }
  rtrim() { shlib_txt_rtrim "${@}"; }
  trim() { shlib_txt_trim "${@}"; }
  rmblank() { shlib_txt_rmblank "${@}"; }
  txt_ltrim() { shlib_txt_ltrim "${@}"; }
  txt_rtrim() { shlib_txt_rtrim "${@}"; }
  txt_trim() { shlib_txt_trim "${@}"; }
  txt_rmblank() { shlib_txt_rmblank "${@}"; }
}

# Left trim all lines in the text.
# Silently ignore unreadable files
#
# USAGE:
# ```
# shlib_txt_ltrim [-f|--listfile LISTFILE...] \
#   [--] [-] [FILE...] [<<< TEXT]
# ```
shlib_txt_ltrim() {
  shlib_file_cat "${@}" | sed -E 's/^\s+//'
}

# Right trim all lines in the text.
# Silently ignore unreadable files
#
# USAGE:
# ```
# shlib_txt_rtrim [-f|--listfile LISTFILE...] \
#   [--] [-] [FILE...] [<<< TEXT]
# ```
shlib_txt_rtrim() {
  shlib_file_cat "${@}" | sed -E 's/\s+$//'
}

# Trim all lines in the text.
# Silently ignore unreadable files
#
# USAGE:
# ```
# shlib_txt_trim [-f|--listfile LISTFILE...] \
#   [--] [-] [FILE...] [<<< TEXT]
# ```
shlib_txt_trim() {
  shlib_txt_ltrim "${@}" | shlib_txt_rtrim
}

# rm blank and spaces only lines in the text.
# Silently ignore unreadable files
#
# USAGE:
# ```
# shlib_txt_rmblank [-f|--listfile LISTFILE...] \
#   [--] [-] [FILE...] [<<< TEXT]
# ```
shlib_txt_rmblank() {
  shlib_file_cat "${@}" | grep -v -E '^\s*$'
}

# TODO mv to conffile module
# rm comment lines from the text. usage:
#
# USAGE:
# ```
# txt_rmcomment [-f|--listfile LISTFILE...] \
#   [--] [-] [FILE...] [<<< TEXT]
# ```
txt_rmcomment() {
  echo "txt_rmcomment deprecated" >&2
  shlib_file_cat "${@}" | grep -v -E '^\s*#.*$'
}
