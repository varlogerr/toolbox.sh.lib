#
# ALIASES
#
${aliased} && {
  conf_strip() { shlib_conf_strip "${@}"; }
  conf_parse() { shlib_conf_parse "${@}"; }
  conf_check_format() { shlib_conf_check_format "${@}"; }
}

# Strip down conffile to only section, meta and
# kye-value lines. Silently ignore unreadable files.
#
# USAGE:
# ```sh
# shlib_conf_strip [-f|--listfile LISTFILE...] \
#   [-p|--prefix COMMENT_REFIX] [--] [-] [FILE...] [<<< TEXT]
# ```
#
# OPTIONS:
# -f, --listfile  provide a file with a list of files
#     (one per line, empty lines ignored).
# -p, --prefix  comment line prefix char, defaults to '#;'
# --  endopts
# -   substituted by text comming from stdin
shlib_conf_strip() {
  declare prefix='#;'
  declare -a tail=()

  local endopts=false
  local key
  while :; do
    [[ -n "${1}" ]] || break
    ${endopts} && key='*' || key="${1}"
    case "${key}" in
      -p|--prefix ) shift; prefix="${1}" ;;
      --          ) endopts=true; tail+=("${1}") ;;
      *           ) tail+=("${1}") ;;
    esac
    shift
  done

  prefix="$(shlib_sed_escape_key "${prefix}")"

  local meta_rex='@meta\[([a-zA-Z]+([-_\.a-zA-Z0-9]+[a-zA-Z0-9])?)\]\s*=\s*(.*)'
  # strip blank lines | strip non-meta comments \
  # | unspace '=' | unspace meta comments
  shlib_txt_trim "${tail[@]}" | shlib_txt_rmblank \
  | grep -E '^\s*(['"${prefix}"']\s*'"${meta_rex}"'|[^'"${prefix}"']+)$' \
  | sed -E 's/^([^'"${prefix}"'\[][^ =]+)\s*=\s*/\1=/' \
  | sed -E 's/^(['"${prefix}"'])\s*'"${meta_rex}"'/\1@meta[\2]=\4/'
}

# Strip down conffile to only section, meta and
# kye-value lines. Silently ignore unreadable files.
# Prints to stdout key-value and optionally preserves
# the result to CONFVAR
#
# USAGE:
# ```sh
# shlib_conf_parse [-f|--listfile LISTFILE...] \
#   [-p|--prefix COMMENT_REFIX] [--var CONFVAR] \
#   [--] [-] [FILE...] [<<< TEXT]
# ```
#
# OPTIONS:
# -f, --listfile  provide a file with a list of files
#     (one per line, empty lines ignored).
# -p, --prefix    comment line prefix char, defaults to '#;'
# --var           put result to CONFVAR
# --              endopts
# -               substituted by text comming from stdin
#
# DEMO:
# ```sh
# # preserve result to CONFIG map and suppress output
# declare -A CONFIG
# shlib_conf_parse file.conf --var CONFIG > /dev/null
# ```
shlib_conf_parse() {
  declare -a tail=()
  declare prefix='#;'
  declare varname
  local -A __config_pars

  local endopts=false
  local key
  while :; do
    [[ -n "${1}" ]] || break
    ${endopts} && key='*' || key="${1}"
    case "${key}" in
      --var       ) shift; unset __config_pars; local -n __config_pars="${1}" ;;
      -p|--prefix ) prefix="${2}"; shift; tail+=("${1}" "${prefix}") ;;
      --          ) endopts=true; tail+=("${1}") ;;
      *           ) tail+=("${1}") ;;
    esac
    shift
  done

  local content="$(shlib_conf_strip "${tail[@]}")"
  content="$(__shlib_conf_desect sections "${content}" "${prefix}")"

  local content_arr
  local key
  local val
  mapfile -t content_arr <<< "${content}"
  for i in "${content_arr[@]}"; do
    key="${i%%=*}"; val="${i#*=}"
    __config_pars[$key]="${val}"
  done

  printf -- '%s\n' "${content}"
}

shlib_conf_check_format() {
  :
}

__shlib_conf_desect() {
  local -n __sections="${1}"
  local content="${2}"
  local prefix="${3}"
  prefix="$(shlib_sed_escape_key "${prefix}")"

  local -A sections
  local section=""
  local metas=()
  local name_rex='\[([a-zA-Z]+([-_\.a-zA-Z0-9]+[a-zA-Z0-9])?)\]'
  local meta_rex="[${prefix}]"'@meta\[([a-zA-Z]+([-_\.a-zA-Z0-9]+[a-zA-Z0-9])?)\]=(.*)'
  local key_prefix
  while read -r l; do
    grep -Exq "${name_rex}" <<< "${l}" && {
      section="$(sed -Ee 's/^'"${name_rex}"'$/\1/' <<< "${l}")"
      continue
    }

    grep -Exq "${meta_rex}" <<< "${l}" && {
      metas+=("$(sed -Ee 's/^'"${meta_rex}"'$/\1=\3/' <<< "${l}")")
      continue
    }

    key_prefix="${section}@"

    [[ ${#metas[@]} -gt 0 ]] \
      && printf -- "${key_prefix}${l%%=*}@"'%s\n' "${metas[@]}"

    printf -- "${key_prefix}"'%s\n' "${l}"

    # printf -- "${section}"${l%*=}'.%s\n' "${l}"
    # [[ ${#metas[@]} -gt 0 ]] && printf -- "${section}"'.%s\n' "${metas[@]}"
    metas=()
  done <<< "${content}"
}
