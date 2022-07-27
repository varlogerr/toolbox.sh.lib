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

  SHLIB_CHANNEL1_COUNT=$(( SHLIB_CHANNEL1_COUNT + ${msgs_count} ))

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

# Print to channel2.
# FLAGS:
#   -q, --quiet   suppress stdout
#   --            endopts
# RC:
#   0 - messages printed to the channel
#   1 - no messages printed to the channel
# USAGE:
# ```sh
# shlib_channel2_print [-q|--quiet] [--] [MSG...]
# ```
shlib_channel2_print() {
  declare -a msgs
  local quiet=false

  shlib_channel2_flush > /dev/null

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

  SHLIB_CHANNEL2_COUNT=$(( SHLIB_CHANNEL2_COUNT + ${msgs_count} ))

  export SHLIB_CHANNEL2
  SHLIB_CHANNEL2="$(printf -- '%s\n' "${msgs[@]}"; echo x)"
  SHLIB_CHANNEL2="${SHLIB_CHANNEL2%$'\n'x}"

  ${quiet} || printf -- '%s\n' "${SHLIB_CHANNEL2}" >&2
  return 0
}

# Check channel2 state.
# RC:
#   0 - channel2 is empty
#   1 - channel2 is not empty
# USAGE:
# ```sh
# shlib_channel2_is_empty \
#   && echo "Empty" || echo "Not empty"
# ```
shlib_channel2_is_empty() {
  [[ -n "${SHLIB_CHANNEL2+x}" ]] && return 1
  return 0
}

# Flush channel2 to stdout
# RC:
#   0 - channel2 is empty
#   1 - channel2 is not empty
# USAGE:
# ```sh
# shlib_channel2_is_empty
# [[ ${?} ]] && echo "Empty" || echo "Not empty"
# ```
shlib_channel2_flush() {
  shlib_channel2_is_empty && return 1

  printf -- '%s\n' "${SHLIB_CHANNEL2}"
  unset SHLIB_CHANNEL2
  return 0
}

# Get count of messages passed through channel2
# USAGE:
# ```sh
# [[ shlib_channel2_count -gt 0 ]] \
#   && echo "Messages" || echo "No messages"
# ```
shlib_channel2_count() {
  printf -- '%d\n' "${SHLIB_CHANNEL2_COUNT}"
}
