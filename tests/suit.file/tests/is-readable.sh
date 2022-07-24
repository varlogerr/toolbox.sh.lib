__is_readable() {
  unset __is_readable

  assert_is_readable() {
    assert_result "${@:1:2}" "" "" "is_readable: ${3}"
  }

  local RC_OK=0
  local RC_ERR=1
  local file_path="${FILES_DIR}/file.txt"
  local lnk_path="${FILES_DIR}/file-lnk.txt"
  local perm_unread="0000"
  local perm_bak="$(stat -c '%a' "${file_path}")"
  local input

  file_is_readable "${FILES_DIR}/${GLOBAL_RANDVAL}.txt"
  assert_is_readable "${RC_ERR}" "${?}" \
    "Fail on not existing file"

  file_is_readable "${FILES_DIR}"
  assert_is_readable "${RC_ERR}" "${?}" \
    "Fail on directory"

  {
    chmod "${perm_unread}" "${file_path}"

    file_is_readable "${file_path}"
    assert_is_readable "${RC_ERR}" "${?}" \
      "Fail on unreadable file"

    file_is_readable "${lnk_path}"
    assert_is_readable "${RC_ERR}" "${?}" \
      "Fail on symlink to unreadable file"

    chmod "0${perm_bak}" "${file_path}"
  }

  file_is_readable "${file_path}"
  assert_is_readable "${RC_OK}" "${?}" \
    "Susseed on readable file"

  file_is_readable "${lnk_path}"
  assert_is_readable "${RC_OK}" "${?}" \
    "Susseed on symlink to readable file"

  file_is_readable <(echo "${GLOBAL_RANDVAL}")
  assert_is_readable "${RC_OK}" "${?}" \
    "Susseed on named pipe"

  unset assert_is_readable
} && __is_readable
