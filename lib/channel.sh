# Add to channel1. Appends by default
# Flags:
# --prepend   add before current channel msgs
# --          endopts, following it arguments
#     will be processed as positional
# Return codes:
# 0 - messages added
# 1 - no messages added
# Usage:
# ```sh
# # add message via argument
# shlib_channel1_add [--prepend] [--] MSG...
# # no messages added
# shlib_channel1_add [--prepend] [--] \
#   || echo "Not added"
# ```
shlib_channel1_add() {
  local msgs
  local prepend=false

  local endopts=false
  local key
  while :; do
    [[ -n "${1+x}" ]] || break
    key="${1}"
    # if endopts, all the params are positional
    ${endopts} && key='*'

    case "${key}" in
      --prepend ) prepend=true ;;
      --        ) endopts=true ;;
      *         ) msgs+="${msgs+$'\n'}$(
          sed -e 's/^/  /' -e '1 s/^ /*/' <<< "${1}"
        )" ;;
    esac

    shift
  done

  [[ -n "${msgs}" ]] || return 1

  [[ -n "${SHLIB_CHANNEL1+x}" ]] || {
    export SHLIB_CHANNEL1
  }

  ${prepend} && {
    SHLIB_CHANNEL1="${msgs}${SHLIB_CHANNEL1+$'\n'}${SHLIB_CHANNEL1}"
  } || {
    SHLIB_CHANNEL1+="${SHLIB_CHANNEL1+$'\n'}${msgs}"
  }

  return 1
}

# Check channel1 state. Usage:
# ```sh
# shlib_channel1_is_empty \
#   && echo "Empty" || echo "Not empty"
# ```
shlib_channel1_is_empty() {
  [[ -n "${SHLIB_CHANNEL1+x}" ]] && return 1
  return 0
}

# Get chennel1 object count. Usage:
# ```sh
# shlib_channel1_is_empty \
#   && echo "Empty" || echo "Not empty"
# ```
shlib_channel1_is_empty() {
  [[ -n "${SHLIB_CHANNEL1+x}" ]] && return 1
  return 0
}

# # Flush out channel1 to stdout. Usage:
# # ```sh
# # shlib_channel1_flush \
# #   && echo "Flushed" || echo "Was empty"
# # ```
# shlib_channel1_flush() {
#   shlib_channel1_is_empty && return 1

#   printf -- '%s\n' "${SHLIB_CHANNEL1}"
#   unset SHLIB_CHANNEL1
#   return 0
# }

# # Print to out channel. Usage:
# # ```sh
# # shlib_print1 MSG [QUIET]
# # ```
# # QUIET (bool) don't output to stdout
# shlib_channel1_print() {

# }

# # Print to out channel. Usage:
# # ```sh
# # shlib_print1 MSG [QUIET]
# # ```
# # QUIET (bool) don't output to stdout
# shlib_channel1_print() {

# }

# # Print to out channel. Usage:
# # ```sh
# # shlib_print1 MSG [QUIET]
# # ```
# # QUIET (bool) don't output to stdout
# shlib_print1() {
#   local txt="${1}"
#   local quiet="${2:-false}"
#   SHLIB_OUT="${txt}"
#   ${quiet} || printf -- '%s\n' "${SHLIB_OUT}"
# }

# # Print to err channel. Usage:
# # ```sh
# # shlib_print2 MSG [PREFIX] [QUIET]
# # ```
# # QUIET (bool) don't output to stderr
# shlib_print2() {
#   local txt="${1}"
#   local quiet="${2:-false}"
#   SHLIB_ERR="${txt}"
#   ${quiet} || printf -- '%s\n' "${SHLIB_ERR}" >&2
# }

# # Flush out channel to stdout
# shlib_flush1() {
#   printf -- '%s\n' "${SHLIB_OUT}"
#   SHLIB_OUT=""
# }

# # Flush err channel to stderr
# shlib_flush2() {
#   printf -- '%s\n' "${SHLIB_ERR}" >&2
#   SHLIB_ERR=""
# }
