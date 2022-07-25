# Check if PATH is file, symlik to file or named pipe
# readabe be you. Usage:
# ```
# file_is_readable PATH && { echo "yes"; } || { echo "no"; }
# ```
file_is_readable() {
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
  unset FUNCRET
  local file

  [[ ${#} -gt 1 ]] && {
    echo "Multiple files are not allowed" >&2
    return 1
  }

  [[ -z "${1+x}" ]] && {
    # Function reading from stdin
    # https://unix.stackexchange.com/questions/154485/how-do-i-capture-stdin-to-a-variable-without-stripping-any-trailing-newlines
    FUNCRET="$(cat --; echo x)"
    FUNCRET="${FUNCRET%$'\n'x}"
  } || {
    file="${1}"
    file_is_readable "${file}" || {
      echo "File must exist and to be readable by current user: ${file}" >&2
      return 1
    }
    FUNCRET="$(cat -- "${file}")"
  }

  printf -- '%s\n' "${FUNCRET}"
}
