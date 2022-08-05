${aliased} && {
  excode_is_valid() { shlib_excode_is_valid "${@}"; }
  excode_is_ok() { shlib_excode_is_ok "${@}"; }
  excode_add() { shlib_excode_add "${@}"; }
  excode_contains() { shlib_excode_contains "${@}"; }
}

# https://tldp.org/LDP/abs/html/ops.html

export SHLIB_OK=0
export SHLIB_KO=1
export SHLIB_ERRSYS=2

shlib_excode_is_valid() {
  local code
  [[ -n "${1+x}" ]] && code="${1}" || {
    echo "${FUNCNAME[0]}: CODE is required" >&2
    return ${SHLIB_ERRSYS}
  }
  shift

  [[ ${#} -gt 0 ]] && {
    echo "${FUNCNAME[0]}: multiple CODE is not allowed" >&2
    return ${SHLIB_ERRSYS}
  }
  test "${code}" -ge 0 2>/dev/null \
    && test "${code}" -le 255 2>/dev/null || return ${SHLIB_KO}

  return ${SHLIB_OK}
}

shlib_excode_is_ok() {
  local code="${?}"
  [[ -n "${1+x}" ]] && { code="${1}"; shift; }

  [[ ${#} -gt 0 ]] && {
    echo "${FUNCNAME[0]}: multiple CODE is not allowed" >&2
    return ${SHLIB_ERRSYS}
  }
  shlib_excode_is_valid "${code}" || {
    echo "${FUNCNAME[0]}: invalid CODE: ${code}" >&2
    return ${SHLIB_ERRSYS}
  }

  [[ ${code} -eq ${SHLIB_OK} ]] \
    && return ${SHLIB_OK} || return ${SHLIB_KO}
}

shlib_excode_add() {
  local _ea_new="${?}"

  local -a _ea_retvarnames
  local -a _ea_positional
  while :; do
    [[ -n "${1+x}" ]] || break

    case "${1}" in
      -r|--retvar ) shift; _ea_retvarnames+=("${1}") ;;
      *           ) _ea_positional+=("${1}")
    esac

    shift
  done

  _ea_positional+=("${_ea_new}")

  [[ ${#_ea_retvarnames[@]} -gt 1 ]] && {
    echo "${FUNCNAME[0]}: multiple RETVAR is not allowed" >&2
    return ${SHLIB_ERRSYS}
  }
  [[ ${#_ea_positional[@]} -lt 2 ]] && {
    echo "${FUNCNAME[0]}: CODE is required" >&2
    return ${SHLIB_ERRSYS}
  }
  [[ ${#_ea_positional[@]} -gt 3 ]] && {
    echo "${FUNCNAME[0]}: multiple NEW_CODE is not allowed" >&2
    return ${SHLIB_ERRSYS}
  }

  local _ea_retvarname
  local _ea_code="${_ea_positional[0]}"
  _ea_new="${_ea_positional[1]}"
  [[ "${#_ea_retvarnames[@]}" -gt 0 ]] && {
    local -n _ea_retvarname="${_ea_retvarnames[0]}" 2>/dev/null \
      || {
        echo "${FUNCNAME[0]}: invalid RETVAR name: ${_ea_retvarnames[0]}" >&2
        return ${SHLIB_ERRSYS}
      }
  }

  shlib_excode_is_valid "${_ea_code}" || {
    echo "${FUNCNAME[0]}: invalid CODE value: ${_ea_code}" >&2
    return ${SHLIB_ERRSYS}
  }
  shlib_excode_is_valid "${_ea_new}" || {
    echo "${FUNCNAME[0]}: invalid NEW_CODE value: ${_ea_new}" >&2
    return ${SHLIB_ERRSYS}
  }

  _ea_retvarname="$(( _ea_code | "${_ea_new}" ))"
  printf '%d\n' "${_ea_retvarname}"
  return ${SHLIB_OK}
}

shlib_excode_contains() {
  local check_code="${?}"

  [[ ${#} -lt 1 ]] && {
    echo "${FUNCNAME[0]}: CODE is required" >&2
    return ${SHLIB_ERRSYS}
  }

  local code="${1}"
  shift
  [[ -n "${1+x}" ]] && {
    check_code="${1}"
    shift
  }

  [[ ${#} -gt 0 ]] && {
    echo "${FUNCNAME[0]}: multiple CHECK_CODE is not allowed" >&2
    return ${SHLIB_ERRSYS}
  }
  shlib_excode_is_valid "${code}" || {
    echo "${FUNCNAME[0]}: invalid CODE value: ${code}" >&2
    return ${SHLIB_ERRSYS}
  }
  shlib_excode_is_valid "${check_code}" || {
    echo "${FUNCNAME[0]}: invalid CHECK_CODE value: ${check_code}" >&2
    return ${SHLIB_ERRSYS}
  }

  [[ $(( code | ${check_code} )) -eq ${code} ]] \
    && return ${SHLIB_OK} || return ${SHLIB_KO}
}
