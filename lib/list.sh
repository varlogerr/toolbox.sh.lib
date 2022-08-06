#
# ALIASES
#
${aliased} && {
  args2list() { shlib_list_from_args "${@}"; }
  list2arr() { shlib_arr_from_list "${@}"; }
}

shlib_list_from_args() {
  local -a _lfa_items
  local _lfa_rc=${SHLIB_OK}

  local -a _lfa_retvarnames
  local -a _lfa_prefixes
  local -a _lfa_offsets
  local -a _lfa_endopts=false
  local -a _lfa_key
  while :; do
    [[ -n "${1+x}" ]] || break
    ${_lfa_endopts} && _lfa_key="*" || _lfa_key="${1}"

    case "${_lfa_key}" in
      --          ) _lfa_endopts=true ;;
      -r|--retvar ) shift; _lfa_retvarnames+=("${1}") ;;
      -p|--prefix ) shift; _lfa_prefixes+=("${1}") ;;
      --offset    ) shift; _lfa_offsets+=("${1}") ;;
      *           ) _lfa_items+=("${1}") ;;
    esac

    shift
  done
  _lfa_prefixes+=('* ')

  [[ "${#_lfa_retvarnames[@]}" -gt 1 ]] && {
    echo "${FUNCNAME[0]}: multiple RETVAR is not allowed" >&2
    _lfa_rc=$(shlib_excode_add ${_lfa_rc} ${SHLIB_ERRSYS})
  }
  [[ "${#_lfa_prefixes[@]}" -gt 2 ]] && {
    echo "${FUNCNAME[0]}: multiple PREFIX is not allowed" >&2
    _lfa_rc=$(shlib_excode_add ${_lfa_rc} ${SHLIB_ERRSYS})
  }
  [[ "${#_lfa_offsets[@]}" -gt 1 ]] && {
    echo "${FUNCNAME[0]}: multiple OFFSET is not allowed" >&2
    _lfa_rc=$(shlib_excode_add ${_lfa_rc} ${SHLIB_ERRSYS})
  }

  local _lfa_retvar
  [[ "${#_lfa_retvarnames[@]}" -gt 0 ]] && {
    local -n _lfa_retvar="${_lfa_retvarnames[0]}" \
      2>/dev/null || {
        echo "${FUNCNAME[0]}: Invalid RETVAR name: ${_lfa_retvarnames[0]}" >&2
        _lfa_rc=$(shlib_excode_add ${_lfa_rc} ${SHLIB_ERRSYS})
      }
  }
  local _lfa_offset_len
  [[ "${#_lfa_offsets[@]}" -gt 0 ]] && {
    _lfa_offset_len="${_lfa_offsets[0]}"
    test "${_lfa_offset_len}" -ge 0 \
      2>/dev/null || {
        echo "${FUNCNAME[0]}: OFFSET must be a >= 0 number: ${_lfa_offset_len}" >&2
        _lfa_rc=$(shlib_excode_add ${_lfa_rc} ${SHLIB_ERRSYS})
      }
  }

  shlib_excode_contains ${_lfa_rc} ${SHLIB_ERRSYS} && return ${_lfa_rc}

  # no items to process
  [[ "${#_lfa_items[@]}" -lt 1 ]] && return ${SHLIB_OK}

  local _lfa_prefix="${_lfa_prefixes[0]}"
  local _lfa_offset_len="${_lfa_offsets[0]-${#_lfa_prefix}}"
  [[ ${_lfa_offset_len} -gt 0 ]] \
    && _lfa_offset=$(printf -- ' %0.s' $(seq 1 ${_lfa_offset_len}))

  local _lfa_ix
  for _lfa_ix in "${!_lfa_items[@]}"; do
    _lfa_items[$_lfa_ix]="$(sed -e '2,$s/^/'"${_lfa_offset}"'/' \
                            <<< "${_lfa_items[$_lfa_ix]}")"
  done

  _lfa_prefix="$(sed -e 's/\\/\\\\/g' -e 's/%/%%/g' \
                  <<< "${_lfa_prefix}")"

  _lfa_retvar="$(printf -- "${_lfa_prefix}"'%s\n' "${_lfa_items[@]}")"
  printf '%s\n' "${_lfa_retvar}"
}

# Convert list from LISTFILE to array ARRVAR
#
# USAGE:
# ```sh
# shlib_arr_from_list [-p|--prefix PREFIX] \
#   [-] [--] ARRVAR LISTFILE...
# ```
#
# OPTIONS:
# -p, --prefix  list item prefix, defaults to '* '
# --            endopts
#
# RC:
# 0 - operation successful
# 1 - input error from stderr
#
# DEMO:
# ```sh
# declare lst="* 1"$'\n'"* 2"
# declare -a arr
# shlib_arr_from_list arr <(printf '%s\n' "${lst}")
# shlib_arr_from_list arr <<< "${lst}"
# ```
shlib_arr_from_list() {
  local prefix='* '

  local pos=()
  local endopts=false
  local key
  while :; do
    [[ -n "${1+x}" ]] || break
    ${endopts} && key='*' || key="${1}"

    case "${key}" in
      -p|--prefix ) shift; prefix="${1}" ;;
      --          ) endopts=true ;;
      *           ) pos+=("${1}") ;;
    esac

    shift
  done

  local -n __arr_from_list="${pos[0]}" || return ${?}
  local list="$(cat -- "${pos[@]:1}"; echo x)"
  # if list == x, it's empty
  [[ "${list}" == x ]] && return

  local cur_ix=-1
  declare -a msgbag_arr
  mapfile -t msgbag_arr <<< "${list%$'\n'x}"
  for l in "${msgbag_arr[@]}"; do
    # detect new entry and cut 2 first characters
    [[ "${l}" == "${prefix}"* ]] && (( cur_ix++ ))
    [[ ${cur_ix} -eq -1 ]] && continue
    __arr_from_list[$cur_ix]+="${__arr_from_list[$cur_ix]+$'\n'}${l:${#prefix}}"
  done
}
