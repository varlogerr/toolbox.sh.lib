# Check PATH is file, symlik to file or named pipe
# readabe by you. Usage:
# ```
# # just check all the files without any output
# file_readable PATH... && { echo "yes"; } || { echo "no"; }
#
# # same as previous, just print valid files to out channel
# file_readable --out PATH...
#
# # same as previous, but print invalid files to err channel
# file_readable --err PATH...
#
# # quiet, don't output to stderr / stdout
# file_readable [-q|--quiet] --out --err PATH...
#
# # with endopts (`--`) flags will be treated as a files
# file_readable -- --err PATH...
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

# Read from file or stdin.
# If file doesn't exist or not readable or
# multiple files provided, error is triggered.
#
# Data is returned via global FNCRET variable
# Usage:
# ```
# file_cat FILE
# cat FILE | file_cat
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
