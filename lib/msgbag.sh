#
# ALIASES
#
${aliased} && {
  msgbag_add() { shlib_msgbag_add "${@}"; }
  msgbag_len() { shlib_msgbag_len "${@}"; }
  msgbag_is_empty() { shlib_msgbag_is_empty "${@}"; }
  msgbag_get() { shlib_msgbag_get "${@}"; }
  msgbag_printix() { shlib_msgbag_printix "${@}"; }
  msgbag_flush() { shlib_msgbag_flush "${@}"; }
  msgbag2list() { shlib_msgbag_to_list "${@}"; }
  list2msgbag() { shlib_msgbag_from_list "${@}"; }
}

shlib_msgbag_add() {
  local _ma_rc=${SHLIB_OK}
  local _ma_bagref
  [[ -n "${1+x}" ]] && {
    local -n _ma_bagref="${1}" 2>/dev/null || {
      echo "${FUNCNAME[0]}: invalid BAGREF value: ${1}" >&2
      _ma_rc="$(shlib_excode_add ${_ma_rc} ${SHLIB_ERRSYS})"
    }
    shift
  } || {
    echo "${FUNCNAME[0]}: BAGREF is required" >&2
    _ma_rc="$(shlib_excode_add ${_ma_rc} ${SHLIB_ERRSYS})"
  }

  if [[ ${#} -lt 1 ]] \
    || $(shlib_excode_contains ${_ma_rc} ${SHLIB_ERRSYS}) \
  ; then return ${_ma_rc}; fi

  [[ "$(declare -p "${!_ma_bagref}" 2> /dev/null)" =~ ^'declare -'[a-zA-Z]*'a' ]] && {
    _ma_bagref+=("${@:1}")
    return 0
  }

  declare _ma_appendix="$(shlib_list_from_args "${@}")"
  _ma_bagref+="${_ma_bagref:+$'\n'}${_ma_appendix}" 2>/dev/null || {
    echo "${FUNCNAME[0]}: can't write to BAGREF" >&2
    return ${SHLIB_ERRSYS}
  }

  return ${_ma_rc}
}

shlib_msgbag_get() {
  local _mg_rc=${SHLIB_OK}
  local _mg_bagref
  local _mg_retref

  [[ -z "${1+x}" ]] && {
    echo "${FUNCNAME[0]}: BAGREF is required" >&2
    _mg_rc="$(shlib_excode_add ${_mg_rc} ${SHLIB_ERRSYS})"
  } || {
    local -n _mg_bagref="${1}" 2>/dev/null || {
      echo "${FUNCNAME[0]}: invalid BAGREF value: ${1}" >&2
      _mg_rc="$(shlib_excode_add ${_mg_rc} ${SHLIB_ERRSYS})"
    }
    shift
  }

  [[ -z "${1+x}" ]] && {
    echo "${FUNCNAME[0]}: RETREF is required" >&2
    _mg_rc="$(shlib_excode_add ${_mg_rc} ${SHLIB_ERRSYS})"
  } || {
    local -n _mg_retref="${1}" 2>/dev/null || {
      echo "${FUNCNAME[0]}: invalid RETREF value: ${1}" >&2
      _mg_rc="$(shlib_excode_add ${_mg_rc} ${SHLIB_ERRSYS})"
    }
    shift
  }

  [[ ${#} -gt 0 ]] && {
    echo "${FUNCNAME[0]}: multiple RETREF is not allowed" >&2
    _mg_rc="$(shlib_excode_add ${_mg_rc} ${SHLIB_ERRSYS})"
  }
}

# # Get count of messages in the BOXNAME message bag
# #
# # USAGE:
# # ```sh
# # shlib_msgbag_len BOXNAME
# # printf 'Lenth is %d' $(shlib_msgbag_len BOXNAME)
# # ```
# #
# # RC:
# # 0 - operation successful
# # 1 - or input error from stderr
# #
# # DEMO:
# # ```sh
# # # outputs 2
# # declare msgs_str
# # shlib_msgbag_add msgs_str "hello" "world"
# # shlib_msgbag_len msgs_str
# # ```
# shlib_msgbag_len() {
#   local -n __msgbag_len="${1}" || return $?

#   [[ "$(declare -p "${!__msgbag_len}" 2> /dev/null)" =~ ^'declare -'[a-zA-Z]*'a' ]] && {
#     echo ${#__msgbag_len[@]}
#     return 0
#   }

#   grep -c '^\*' <<< "${__msgbag_len}"
#   return 0
# }

# # Check if BOXNAME message bag is empty
# #
# # USAGE:
# # ```sh
# # shlib_msgbag_add BOXNAME MSG...
# # shlib_msgbag_is_empty BOXNAME; echo $?
# # ```
# #
# # RC:
# # 0 - operation successful
# # 1 - message bag not is empty
# #     or input error from stderr
# #
# # DEMO:
# # ```sh
# # # outputs "Not empty"
# # declare msgs_str
# # shlib_msgbag_add msgs_str "hello" "world"
# # shlib_msgbag_is_empty msgs_str \
# #   && echo "Empty" || echo "Not empty"
# # ```
# shlib_msgbag_is_empty() {
#   local -n __msgbag_empty="${1}" || return $?

#   [[ $(shlib_msgbag_len __msgbag_empty) -gt 0 ]] && return 1
#   return 0
# }

# # Populate RECIPIENT array with BOXNAME message bag values
# #
# # USAGE:
# # ```sh
# # shlib_msgbag_add BOXNAME MSG...
# # shlib_msgbag_get BOXNAME RECIPIENT [-a|--append]
# # ```
# #
# # OPTIONS:
# # -a, --append  append the result to RECIPIENT,
# #               othervise override
# #
# # RC:
# # 0 - operation successful
# # 1 - no messages in the message box
# #     or input error from stderr
# #
# # DEMO:
# # ```sh
# # # outputs "hello"$'\n'"world"
# # declare msgs_str
# # declare -a msgs_rec
# # shlib_msgbag_add msgs_str "hello" "world"
# # shlib_msgbag_get msgs_str msgs_rec
# # printf -- '%s\n' "${msgs_rec[@]}"
# # ```
# shlib_msgbag_get() {
#   local append=false

#   local pos=()
#   while :; do
#     [[ -n "${1+x}" ]] || break

#     case "${1}" in
#       -a|--append ) append=true ;;
#       *           ) pos+=("${1}") ;;
#     esac

#     shift
#   done

#   declare -n __msgbag_get="${pos[0]}" || return $?
#   declare -n __recip_get="${pos[1]}" || return $?

#   [[ "$(shlib_msgbag_len "${!__msgbag_get}")" -gt 0 ]] || return 1

#   declare -a aux
#   [[ "$(declare -p "${!__msgbag_get}" 2> /dev/null)" =~ ^'declare -'[a-zA-Z]*'a' ]] && {
#     aux=("${__msgbag_get[@]}")
#   } || {
#     shlib_arr_from_list aux <<< "${__msgbag_get}"
#   }

#   ${append} \
#     && __recip_get+=("${aux[@]}") \
#     || __recip_get=("${aux[@]}")

#   return 0
# }

# # Print message from BOXNAME message bag by index,
# # where indexing starts with 1
# #
# # USAGE:
# # ```sh
# # shlib_msgbag_printix BOXNAME INDEX
# # ```
# #
# # RC:
# # 0 - operation successful
# # 1 - no message under the required index
# #     or input error from stderr
# #
# # DEMO:
# # ```sh
# # # outputs "hello"$'\n'"world"
# # declare msgs_str
# # shlib_msgbag_add msgs_str "hello" "world"
# # for i in $(seq 1 $(shlib_msgbag_len msgs_str)); do
# #   printf -- '%s\n' "$(shlib_msgbag_printix msgs_str ${i})"
# # done
# # ```
# shlib_msgbag_printix() {
#   local -n __msgbag_printix="${1}" || return $?
#   local ix="${2}"
#   shift
#   shift
#   declare -a recipient

#   shlib_msgbag_get __msgbag_printix recipient || return $?
#   (( ix-- ))
#   [[ -n "${recipient[$ix]+x}" ]] || return 1
#   printf -- '%s\n' "${recipient[$ix]}"
#   return 0
# }

# # Populate RECIPIENT array with BOXNAME message bag values
# # and reset BOXNAME. BOXNAME impact by type:
# # * array - BOXNAME becomes empty array
# # * assoc array - the key gets unset
# # * normal var - the var gets unset
# #
# # USAGE:
# # ```sh
# # shlib_msgbag_add BOXNAME MSG...
# # shlib_msgbag_flush BOXNAME RECIPIENT [-a|--append]
# # ```
# #
# # OPTIONS:
# # -a, --append  append the result to RECIPIENT,
# #               othervise override
# #
# # RC:
# # 0 - operation successful
# # 1 - no messages in the message box
# #     or input error from stderr
# #
# # DEMO:
# # ```sh
# # # outputs "hello"$'\n'"world"
# # declare msgs_str
# # declare -a msgs_rec
# # shlib_msgbag_add msgs_str "hello" "world"
# # shlib_msgbag_flush msgs_str msgs_rec
# # printf -- '%s\n' "${msgs_rec[@]}"
# # ```
# shlib_msgbag_flush() {
#   declare -a get_flags=()

#   local pos=()
#   while :; do
#     [[ -n "${1+x}" ]] || break

#     case "${1}" in
#       -*  ) get_flags+=("${1}") ;;
#       *   ) pos+=("${1}") ;;
#     esac

#     shift
#   done

#   declare -n __msgbag_flush="${pos[0]}" || return $?
#   declare -n __recip_flush="${pos[1]}" || return $?

#   shlib_msgbag_get "${!__msgbag_flush}" "${!__recip_flush}" \
#     "${get_flags[@]}" || return $?

#   [[ "$(declare -p "${!__msgbag_flush}" 2> /dev/null)" =~ ^'declare -'[a-zA-Z]*'a' ]] && {
#     __msgbag_flush=()
#     return 0
#   }

#   unset __msgbag_flush
#   return 0
# }

# # Read BOXNAME variable and output list
# #
# # USAGE:
# # ```sh
# # shlib_msgbag_to_list BOXNAME [-p|--prefix PREFIX]
# # ```
# #
# # OPTIONS:
# # -p, --prefix  list item prefix, defaults to '* '
# #
# # RC:
# # 0 - operation successful
# # 1 - no messages in the message box
# #     or input error from stderr
# #
# # DEMO:
# # ```sh
# # # outputs "* hello"$'\n'"* world"
# # declare msgs_str
# # shlib_msgbag_add msgs_str "hello" "world"
# # shlib_msgbag_to_list msgs_str
# # ```
# shlib_msgbag_to_list() {
#   declare -a arr2list_opts

#   local -a pos=()
#   while :; do
#     [[ -n "${1+x}" ]] || break

#     case "${1}" in
#       -p|--prefix ) arr2list_opts+=("${@:1:2}"); shift ;;
#       *           ) pos+=("${1}") ;;
#     esac

#     shift
#   done

#   local -n __msgbag_to_list="${pos[0]}" || return $?
#   local -a recip
#   shlib_msgbag_get __msgbag_to_list recip || return $?
#   shlib_arr_to_list recip "${arr2list_opts[@]}"
# }
