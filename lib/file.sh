# Check PATH is file, symlik to file or named pipe
# readabe by you or return falsy return code. Usage:
# ```
# # if no PATH is provided return code will be 0.
# # ======
# # --out   print valid paths to out channel
# # --err   print invalid paths to err channel
# # -q, --quiet   suppress stdout and stderr
# file_readable [--out] [--err] [-q|--quiet] [PATH...]
#
# # --  endopts, i.e. flags after it will be treated
# #     as paths
# file_readable -- [FLAG...] [PATH...]
# ```
file_readable() {
  local paths=()
  local out=false
  local err=false
  local quiet=false

  local endopts=false
  local key
  while :; do
    [[ -n "${1+x}" ]] || break
    key="${1}"
    ${endopts} && key='*'

    case "${key}" in
      -q|--quiet  ) quiet=true ;;
      --out       ) out=true ;;
      --err       ) err=true ;;
      --          ) endopts=true ;;
      *           ) paths+=("${1}") ;;
    esac

    shift
  done

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

  [[ -n "${files_out+x}" ]] && shlib_print1 "${files_out}" "${quiet}"
  [[ -n "${files_err+x}" ]] && shlib_print2 "${files_err}" "${quiet}"
  return ${rc}
}

# Cat file or from stdin to out channel. If a file is
# not readable file, symlik to file or named pipe by
# defaultit will be silently skipped, but the return
# code will be negative. Usage:
# ```
# # no output and return code 0 with no FILE provided.
# # =====
# # -f, --listfile  provide a file with a list of files
# #     (one per line, empty lines ignored)
# # --err   print invalid files to err channel
# # -q, --quiet   suppress stderr
# file_cat [-f|--listfile LISTFILE...] [--err] \
#   [-q|--quiet] [FILE...]
#
# # --  endopts, i.e. flags after it will be treated
# #     as files
# file_cat -- [FLAG...] [PATH...]
#
# # LISTFILE from stdin
# cat LISTFILE... | file_cat [FLAGS...]
# ```
file_cat() {
  local file="${1-${__SHLIB_NOPATH}}"
  local res

  [[ ${#} -gt 1 ]] && {
    _shlib_print_err "Multiple files are not supported"
    return 1
  }

  [[ "${file}" == "${__SHLIB_NOPATH}" ]] && {
    # Function reading from stdin
    # https://unix.stackexchange.com/questions/154485/how-do-i-capture-stdin-to-a-variable-without-stripping-any-trailing-newlines
    res="$(cat --; echo x)"
  } || {
    file_readable "${file}" || {
      _shlib_print_err "File must exist and to be readable by current user: ${file}"
      return 1
    }

    res="$(cat -- "${file}"; echo x)"
  }

  # _shlib_print_res "${res%$'\n'x}"
  echo "${res}" | head -n -1
}
