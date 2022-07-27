# Print to channel1.
# FLAGS:
#   -q, --quiet   suppress stdout
#   --            endopts
# RC:
#   0 - messages printed to the channel
#   1 - no messages printed to the channel
# USAGE:
# ```sh
# shlib_channel1_print [-q|--quiet] [--] [MSG...]
# ```
shlib_channel1_print() {
  declare -a msgs
  local quiet=false

  shlib_channel1_flush > /dev/null

  local endopts=false
  local key
  while :; do
    [[ -n "${1+x}" ]] || break
    # if endopts, all the params are positional
    ${endopts} && key='*' || key="${1}"

    case "${key}" in
      -q|--quiet  ) quiet=true ;;
      --          ) endopts=true ;;
      *           ) msgs+=("${1}") ;;
    esac

    shift
  done

  local msgs_count=${#msgs[@]}
  [[ ${msgs_count} -gt 0 ]] || return 1

  (( SHLIB_CHANNEL1_COUNT++ ))

  export SHLIB_CHANNEL1
  SHLIB_CHANNEL1="$(printf -- '%s\n' "${msgs[@]}"; echo x)"
  SHLIB_CHANNEL1="${SHLIB_CHANNEL1%$'\n'x}"

  ${quiet} || printf -- '%s\n' "${SHLIB_CHANNEL1}"
  return 0
}

# Check channel1 state.
# RC:
#   0 - channel1 is empty
#   1 - channel1 is not empty
# USAGE:
# ```sh
# shlib_channel1_is_empty \
#   && echo "Empty" || echo "Not empty"
# ```
shlib_channel1_is_empty() {
  [[ -n "${SHLIB_CHANNEL1+x}" ]] && return 1
  return 0
}

# Flush channel1 to stdout
# RC:
#   0 - channel1 is empty
#   1 - channel1 is not empty
# USAGE:
# ```sh
# shlib_channel1_is_empty
# [[ ${?} ]] && echo "Empty" || echo "Not empty"
# ```
shlib_channel1_flush() {
  shlib_channel1_is_empty && return 1

  printf -- '%s\n' "${SHLIB_CHANNEL1}"
  unset SHLIB_CHANNEL1
  return 0
}


# # Check channel1 state. Usage:
# # ```sh
# # shlib_channel1_is_empty \
# #   && echo "Empty" || echo "Not empty"
# # ```
# shlib_channel1_is_empty() {
#   [[ -n "${SHLIB_CHANNEL1+x}" ]] && return 1
#   return 0
# }

# # Get chennel1 object count. Usage:
# # ```sh
# # shlib_channel1_is_empty \
# #   && echo "Empty" || echo "Not empty"
# # ```
# shlib_channel1_len() {
#   grep -c -- '^\*' <<< "${SHLIB_CHANNEL1}"
# }

# shlib_channel1_to_arr() {
#   shlib_channel1_is_empty && return 1

#   declare -n arr="${1}"

#   local line
#   declare -a aux
#   local ctr=-1

#   mapfile -t aux <<< "${SHLIB_CHANNEL1}"
#   for line in "${aux[@]}"; do
#     [[ "${line}" == '* '* ]] && {
#       (( ctr++ ))
#       arr[$ctr]="${line:2}"
#       continue
#     }

#     arr[$ctr]+=$'\n'"${line:2}"
#   done

#   return 0
# }

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
