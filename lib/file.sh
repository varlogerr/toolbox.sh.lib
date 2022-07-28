#
# ALIASES
#
${aliased} && {
  freadable() { shlib_file_readable "${@}"; }
  fread() { shlib_file_cat "${@}"; }
}

# Function reading from stdin
# https://unix.stackexchange.com/questions/154485/how-do-i-capture-stdin-to-a-variable-without-stripping-any-trailing-newlines

# Check input files are files, file symlinks of named pipe
# readable by you
#
# USAGE:
# ```sh
# shlib_file_readable [-f|--listfile LISTFILE...] \
#   [-p|--paths PATHSVARNAME] [-e|--errbag ERRBAGVARNAME] \
#   [-s|--std] [--] PATH...
# ```
#
# OPTIONS:
# -f, --listfile  provide a file with a list of files
#     (one per line, empty lines ignored). the LISTFILE
#     path is not checked for being readable! if it
#     doesn't exist or unreadable, the error is ignored
# -p, --paths   valid paths variable name (instance of
#     msgbag)
# -e, --errbag  invalid paths variable name (instance of
#     msgbag)
# -s, --std     output to stdout and stderr
# --  endopts
shlib_file_readable() {
  declare -a in_paths=()
  local varname_paths
  local varname_errbag
  local listfile
  local std=false

  local endopts=false
  local key
  local aux
  while :; do
    [[ -n "${1+x}" ]] || break
    # if endopts, all the params are positional
    ${endopts} && key='*' || key="${1}"

    case "${key}" in
      -f|--listfile )
        shift
        aux="$(grep -xvE -- '\s*' "${1}" 2> /dev/null)"
        [[ -n "${aux}" ]] && {
          mapfile -t aux <<< "${aux}"
          in_paths+=("${aux[@]}")
        }
        ;;
      -p|--paths    ) shift; varname_paths="${1}" ;;
      -e|--errbag   ) shift; varname_errbag="${1}" ;;
      -s|--std      ) std=true ;;
      --            ) endopts=true ;;
      *             ) in_paths+=("${1}") ;;
    esac

    shift
  done

  local rc=0
  local path
  for path in "${in_paths[@]}"; do
    if [[ (-f "${path}" || -p "${path}") ]] \
      && [[ -r "${path}" ]] \
    ; then
      ${std} && printf -- '%s\n' "${path}"
      [[ -n "${varname_paths+x}" ]] \
        && shlib_msgbag_add "${varname_paths}" "${path}"

      continue
    fi

    rc=1

    ${std} && printf -- '%s\n' "${path}" >&2
    [[ -n "${varname_errbag+x}" ]] \
      && shlib_msgbag_add "${varname_errbag}" "${path}"
  done

  return ${rc}
}

# Cat file. Silently ignore unreadable files.
#
# USAGE:
# ```sh
# shlib_file_cat [-f|--listfile LISTFILE...] \
#   [--] [-] [FILE...] [<<< TEXT]
# ```
#
# OPTIONS:
# -f, --listfile  provide a file with a list of files
#     (one per line, empty lines ignored).
# --  endopts
# -   substituted by text comming from stdin
shlib_file_cat() {
  declare -a cat_args=()

  local aux
  local endopts=false
  local key
  while :; do
    [[ -n "${1+x}" ]] || break
    key="${1}"
    # if endopts, all the params are positional
    ${endopts} && key='*'

    case "${key}" in
      -f|--listfile )
        shift
        aux="$(grep -xvE -- '\s*' "${1}" 2> /dev/null)"
        [[ -n "${aux}" ]] && {
          mapfile -t aux <<< "${aux}"
          cat_args+=("${aux[@]}")
        }
        ;;
      --            ) endopts=true ;;
      *             ) cat_args+=("${1}") ;;
    esac

    shift
  done

  local res="$(cat -- "${cat_args[@]}" 2> /dev/null; echo x)"
  [[ "${res}" == x ]] && return

  printf '%s\n' "${res%$'\n'x}"
}
