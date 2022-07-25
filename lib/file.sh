# Check if PATH is file, symlik to file or named pipe
# readabe be you. Usage:
# ```
# file_readable PATH && { echo "yes"; } || { echo "no"; }
# ```
file_readable() {
  local path
  [[ -n "${1+x}" ]] && path="${1}"

  [[ (-L "${path}" && ! -p "${path}") ]] \
    && path="$(realpath -- "${path}")"

  [[ (-f "${path}" || -p "${path}") ]] \
    && [[ -r "${path}" ]]
}

# Read from file or stdin.
# If file doesn't exist or not readable or
# multiple files provided, error is triggered.
#
# Data is returned via global FNCRET variable
# Usage:
# ```
# file_cut FILE
# cat FILE | file_cut
# ```
file_cut() {
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
    _shlib_print_res "${res%$'\n'x}"
    return
  }

  file_readable "${file}" || {
    _shlib_print_err "File must exist and to be readable by current user: ${file}"
    return 1
  }

  _shlib_print_res "$(cat -- "${file}")"
}
