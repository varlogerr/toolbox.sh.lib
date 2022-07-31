${aliased} && {
  sed_escape_rex() { shlib_sed_escape_rex "${@}"; }
  sed_escape_replace() { shlib_sed_escape_replace "${@}"; }
}

# https://stackoverflow.com/a/2705678

shlib_sed_escape_rex() {
  local -A opts

  __shlib_sed_escape_parse_opts opts "${@}" || return ${?}

  local rex="${opts[pos]}"
  local __retvar_escape_rex
  [[ -n "${opts[retvar]+x}" ]] && {
    local -n __retvar_escape_rex="${opts[retvar]}" \
      2>/dev/null || return "${SHLIB_ERRSYS}"
  }

  __retvar_escape_rex="$(sed -e 's/[]\/$*.^[]/\\&/g' <<< "${rex}")"
  printf '%s\n' "${__retvar_escape_rex}"
  return "${SHLIB_OK}"
}

shlib_sed_escape_replace() {
  local -A opts

  __shlib_sed_escape_parse_opts opts "${@}" || return ${?}

  local replace="${opts[pos]}"
  local __retvar_escape_replace
  [[ -n "${opts[retvar]+x}" ]] && {
    local -n __retvar_escape_replace="${opts[retvar]}" \
      2>/dev/null || return "${SHLIB_ERRSYS}"
  }

  __retvar_escape_replace="$(sed -e 's/[\/&]/\\&/g' <<< "${replace}")"
  printf '%s\n' "${__retvar_escape_replace}"
  return "${SHLIB_OK}"
}

__shlib_sed_escape_parse_opts() {
  local -n __opts="${1}"
  shift
  local -a retvar=()
  local -a pos=()

  local endopts=false
  local key
  while :; do
    [[ -n ${1+x} ]] || break
    ${endopts} && key='*' || key="${1}"

    case "${key}" in
      --          ) endopts=true ;;
      -r|--retvar ) shift; retvar+=("${1}") ;;
      *           ) pos+=("${1}") ;;
    esac

    shift
  done

  [[ ${#pos[@]} -ne 1 ]] && return "${SHLIB_ERRSYS}"
  [[ ${#retvar[@]} -gt 1 ]] && return "${SHLIB_ERRSYS}"

  __opts[pos]="${pos[0]}"
  [[ ${#retvar[@]} -gt 0 ]] && __opts[retvar]="${retvar[0]}"

  return "${SHLIB_OK}"
}
