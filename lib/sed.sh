${aliased} && {
  sed_escape_rex() { shlib_sed_escape_rex "${@}"; }
  sed_escape_replace() { shlib_sed_escape_replace "${@}"; }
}

# https://stackoverflow.com/a/2705678

shlib_sed_escape_rex() {
  local -A _er_opts

  __shlib_sed_escape_parse_opts _er_opts "${@}" || return ${?}

  local _er_rex="${_er_opts[pos]}"
  local _er_retvarname
  [[ -n "${_er_opts[retvar]+x}" ]] && {
    local -n _er_retvarname="${_er_opts[retvar]}" \
      2>/dev/null || return "${SHLIB_ERRSYS}"
  }

  _er_retvarname="$(sed -e 's/[]\/$*.^[]/\\&/g' <<< "${_er_rex}")"
  printf '%s\n' "${_er_retvarname}"
  return "${SHLIB_OK}"
}

shlib_sed_escape_replace() {
  local -A _er_opts

  __shlib_sed_escape_parse_opts _er_opts "${@}" || return ${?}

  local _er_replace="${_er_opts[pos]}"
  local _er_retvarname
  [[ -n "${_er_opts[retvar]+x}" ]] && {
    local -n _er_retvarname="${_er_opts[retvar]}" \
      2>/dev/null || return "${SHLIB_ERRSYS}"
  }

  _er_retvarname="$(sed -e 's/[\/&]/\\&/g' <<< "${_er_replace}")"
  printf '%s\n' "${_er_retvarname}"
  return "${SHLIB_OK}"
}

__shlib_sed_escape_parse_opts() {
  local -n _epo_opts="${1}"
  shift
  local -a _epo_retvarnames=()
  local -a _epo_positional=()

  local _epo_endopts=false
  local _epo_key
  while :; do
    [[ -n ${1+x} ]] || break
    ${_epo_endopts} && _epo_key='*' || _epo_key="${1}"

    case "${_epo_key}" in
      --          ) _epo_endopts=true ;;
      -r|--retvar ) shift; _epo_retvarnames+=("${1}") ;;
      *           ) _epo_positional+=("${1}") ;;
    esac

    shift
  done

  [[ ${#_epo_positional[@]} -ne 1 ]] && return "${SHLIB_ERRSYS}"
  [[ ${#_epo_retvarnames[@]} -gt 1 ]] && return "${SHLIB_ERRSYS}"

  _epo_opts[pos]="${_epo_positional[0]}"
  [[ ${#_epo_retvarnames[@]} -gt 0 ]] && _epo_opts[retvar]="${_epo_retvarnames[0]}"

  return "${SHLIB_OK}"
}
