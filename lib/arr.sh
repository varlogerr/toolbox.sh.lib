#
# ALIASES
#
${aliased} && {
  arr2list() { shlib_arr_to_list "${@}"; }
  list2arr() { shlib_arr_from_list "${@}"; }
}

# Read ARRVAR variable and output list
#
# USAGE:
# ```sh
# shlib_arr_to_list [-p|--prefix PREFIX] ARRVAR
# ```
#
# OPTIONS:
# -p, --prefix  list item prefix, defaults to '* '
#
# RC:
# 0 - operation successful
# 1 - input error from stderr
#
# DEMO:
# ```sh
# # output:
# # * 1
# # * 2
# #   3
# declare -a arr=(1 2$'\n'3)
# shlib_arr_to_list arr
#
# # output:
# # - 1
# # - 2
# declare -a arr=(1 2)
# shlib_arr_to_list arr -p '- '
# ```
shlib_arr_to_list() {
  local prefix='* '
  local offset

  local pos=()
  while :; do
    [[ -n "${1+x}" ]] || break

    case "${1}" in
      -p|--prefix ) shift; prefix="${1}" ;;
      *           ) pos+=("${1}") ;;
    esac

    shift
  done

  declare -n __arr_to_list="${pos[0]}" || return ${?}
  offset="$(printf -- ' %0.s' $(seq 1 ${#prefix}))"

  # https://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
  prefix="$(sed -e 's/[\/&]/\\&/g' <<< "${prefix}")"

  for i in "${__arr_to_list[@]}"; do
    sed -e '2,$s/^/'"${offset}"'/' -e '1 s/^/'"${prefix}"'/' <<< "${i}"
  done
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
