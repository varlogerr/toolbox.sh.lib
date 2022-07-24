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
