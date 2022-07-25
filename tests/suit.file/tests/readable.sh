__is_readable() {
  unset __is_readable

  assert_is_readable() {
    assert_result "${@:1:2}" "" "" "readable: ${3}"
  }

  local cmd=file_readable
  local RC_OK=0
  local RC_ERR=1
  declare -A path=(
    [file]="${FILES_DIR}/file.txt"
    [lnk]="${FILES_DIR}/file-lnk.txt"
  )
  local perm_unread="0000"
  local perm_bak="$(stat -c '%a' "${path[file]}")"
  local input

  ${cmd} "${FILES_DIR}/${GLOBAL_RANDVAL}.txt"
  assert_is_readable "${RC_ERR}" "${?}" \
    "Fail on not existing file"

  ${cmd} "${FILES_DIR}"
  assert_is_readable "${RC_ERR}" "${?}" \
    "Fail on directory"

  chmod "${perm_unread}" "${path[file]}"
  for f in "${path[@]}"; do
    ${cmd} "${f}"
    assert_is_readable "${RC_ERR}" "${?}" \
      "Fail on unreadable file: $(basename -- "${f}")"
  done
  chmod "0${perm_bak}" "${path[file]}"

  for f in "${path[@]}"; do
    ${cmd} "${f}"
    assert_is_readable "${RC_OK}" "${?}" \
      "Susseed on readable file: $(basename -- "${f}")"
  done

  ${cmd} <(echo "${GLOBAL_RANDVAL}")
  assert_is_readable "${RC_OK}" "${?}" \
    "Susseed on named pipe"

  unset assert_is_readable
} && __is_readable
