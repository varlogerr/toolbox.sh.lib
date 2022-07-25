# Check if PATH is file, symlik to file or named pipe
# readabe be you. Usage:
# ```
# file_is_readable PATH && { echo "yes"; } || { echo "no"; }
# ```
file_is_readable() {
  local path="${1}"
  [[ (-L "${path}" && ! -p "${path}") ]] \
    && path="$(realpath -- "${path}")"

  [[ (-f "${path}" || -p "${path}") ]] \
    && [[ -r "${path}" ]]
}

file_cut() {
  local file

  [[ ${#} -gt 1 ]] && {
    echo "[${FUNCNAME[0]}] Multiple files are not allowed" >&2
    return 1
  }

  [[ -n "${1+x}" ]] && file="${1}"
  [[ -z "${file+x}" ]] && {
    # Function reading from stdin
    # https://unix.stackexchange.com/questions/154485/how-do-i-capture-stdin-to-a-variable-without-stripping-any-trailing-newlines
    RETVAL="$(cat --; echo x)"
    RETVAL="${RETVAL%$'\n'x}"
    return
  }

  file_is_readable "${file}" || {
    echo "[${FUNCNAME[0]}] File must exist and to be readable by current user: ${file}" >&2
    return 1
  }
  RETVAL="$(cat -- "${file}")"
}
