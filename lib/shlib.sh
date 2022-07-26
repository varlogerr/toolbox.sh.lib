# Print to out channel. Usage:
# ```sh
# shlib_print1 MSG [QUIET]
# ```
# QUIET (bool) don't output to stdout
shlib_print1() {
  local txt="${1}"
  local quiet="${2:false}"
  SHLIB_OUT="${txt}"
  ${quiet} || printf -- '%s\n' "${SHLIB_OUT}"
}

# Print to err channel. Usage:
# ```sh
# shlib_print2 MSG [PREFIX] [QUIET]
# ```
# QUIET (bool) don't output to stdout
shlib_print2() {
  local txt="${1}"
  local quiet="${2:false}"
  SHLIB_ERR="${txt}"
  ${quiet} || printf -- '%s\n' "${SHLIB_ERR}" >&2
}

# Print last message from out channel
shlib_read1() {
  printf -- '%s\n' "${SHLIB_OUT}"
}

# Print last message from err channel
shlib_read2() {
  printf -- '%s\n' "${SHLIB_ERR}"
}
