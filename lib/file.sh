# Check PATH is file, symlik to file or named pipe
# readabe by you or return falsy return code. Usage:
# ```
# # -f, --listfile  provide a file with a list of files
# #     (one per line, empty lines ignored). the LISTFILE
# #     path is not checked for being readable! if it
# #     doesn't exist or unreadable, the error is ignored
# # --out   print valid paths to out channel
# # --err   print invalid paths to err channel
# # -q, --quiet   suppress stdout and stderr
# shlib_file_readable [-f|--listfile LISTFILE...] \
#   [--out] [--err] [-q|--quiet] PATH...
#
# # --  endopts, i.e. flags after it will be treated
# #     as paths
# shlib_file_readable -- [FLAG...] PATH...
#
# # read LISTFILE from stdin
# cat LISTFILE_FILE... | shlib_file_readable [FLAG...]
# ```
shlib_file_readable() {
  local paths=()
  local out=false
  local err=false
  local quiet=false
  local aux

  shlib_flush1 > /dev/null
  shlib_flush2 2> /dev/null

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
          paths+=("${aux[@]}")
        }
        ;;
      --out         ) out=true ;;
      --err         ) err=true ;;
      -q|--quiet    ) quiet=true ;;
      --            ) endopts=true ;;
      *             ) paths+=("${1}") ;;
    esac

    shift
  done

  [[ ${#paths[@]} -lt 1 ]] && {
    aux="$(grep -xvE '\s*' 2> /dev/null)"
    [[ -n "${aux}" ]] && {
      mapfile -t aux <<< "${aux}"
      paths+=("${aux[@]}")
    }
  }

  local rc=0
  local files_out
  local files_err
  local path
  for path in "${paths[@]}"; do
    if [[ (-f "${path}" || -p "${path}") ]] \
      && [[ -r "${path}" ]] \
    ; then
      if ${out}; then
        files_out+="${files_out+$'\n'}${path}"
      fi
      continue
    fi

    rc=1
    if ${err}; then
      files_err+="${files_err+$'\n'}${path}"
    fi
  done

  [[ -n "${files_err+x}" ]] && shlib_print2 "${files_err}" "${quiet}"
  [[ -n "${files_out+x}" ]] && shlib_print1 "${files_out}" "${quiet}"
  return ${rc}
}

# Cat file. If a file is not readable file, symlik to
# file or named pipe by defaultit will be silently
# skipped, but the return code will be negative. Usage:
# ```
# # no output and return code 0 with no FILE provided.
# # =====
# # -f, --listfile  provide a file with a list of files
# #     (one per line, empty lines ignored). the LISTFILE
# #     path is not checked for being readable! if it
# #     doesn't exist or unreadable, the error is ignored
# # --err   print invalid files to err channel
# # -q, --quiet   suppress stderr
# shlib_file_cat [-f|--listfile LISTFILE...] [--err] \
#   [-q|--quiet] [FILE...]
#
# # --  endopts, i.e. flags after it will be treated
# #     as files
# shlib_file_cat -- [FLAG...] [PATH...]
#
# # read LISTFILE from stdin
# cat LISTFILE_FILE... | shlib_file_cat [FLAG...]
# ```
shlib_file_cat() {
  local files=()
  declare -a readable_flags=()
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
          files+=("${aux[@]}")
        }
        ;;
      --err         ) readable_flags+=(--err) ;;
      -q|--quiet    ) readable_flags+=(--quiet) ;;
      --            ) endopts=true ;;
      *             ) files+=("${1}") ;;
    esac

    shift
  done

  [[ ${#files[@]} -lt 1 ]] && {
    aux="$(grep -xvE '\s*' 2> /dev/null)"
    [[ -n "${aux}" ]] && {
      mapfile -t aux <<< "${aux}"
      files+=("${aux[@]}")
    }
  }

  local rc=0
  local res
  [[ ${#files[@]} -lt 1 ]] && {
    # Function reading from stdin
    # https://unix.stackexchange.com/questions/154485/how-do-i-capture-stdin-to-a-variable-without-stripping-any-trailing-newlines
    res="$(cat --; echo x)"
  } || {
    shlib_file_readable "${readable_flags[@]}" --out "${files[@]}" > /dev/null
    rc=${?}

    res="$(cat -- "$(shlib_flush1)"; echo x)"
  }

  shlib_print1 "${res%$'\n'x}"
  return ${rc}
}
