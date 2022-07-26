__readable() {
  unset __readable

  local -f assert_readable

  assert_readable() {
    assert_result "${@:1:4}" "readable: ${5}"
  }

  local cmd=file_readable
  local RC_OK=0
  local RC_ERR=1
  declare -A path=(
    [file]="${FILES_DIR}/file.txt"
    [lnk]="${FILES_DIR}/file.lnk"
  )
  local perm_unread="0000"
  local perm_bak="0$(stat -c '%a' "${path[file]}")"
  local out_act
  local out_exp
  local out_act


  out_act="$("${cmd}")"
  assert_readable "${RC_OK}" "${?}" "" "${out_act}" \
    "Success on no input (stdout)"

  "${cmd}"
  assert_readable "${RC_OK}" "${?}" "" "$(shlib_read1)" \
    "Success on no input (SHLIB_OUT)"

  out_act="$("${cmd}" "${FILES_DIR}/${GLOBAL_RANDVAL}.txt" 2>&1)"
  assert_readable "${RC_ERR}" "${?}" "" "${out_act}" \
    "Fail on not existing file (stderr)"

  "${cmd}" "${FILES_DIR}/${GLOBAL_RANDVAL}.txt"
  assert_readable "${RC_ERR}" "${?}" "" "$(shlib_read2)" \
    "Fail on not existing file (SHLIB_ERR)"

  out_act="$("${cmd}" "${FILES_DIR}" 2>&1)"
  assert_readable "${RC_ERR}" "${?}" "" "${out_act}" \
    "Fail on directory (stderr)"

  "${cmd}" "${FILES_DIR}"
  assert_readable "${RC_ERR}" "${?}" "" "$(shlib_read2)" \
    "Fail on directory (SHLIB_ERR)"

  {
    chmod "${perm_unread}" "${path[file]}"

    for f in "${path[@]}"; do
      out_act="$("${cmd}" "${f}" 2>&1)"
      assert_readable "${RC_ERR}" "${?}" "" "${out_act}" \
        "Fail on unreadable file (stderr): $(basename -- "${f}")"

      "${cmd}" "${f}"
      assert_readable "${RC_ERR}" "${?}" "" "$(shlib_read2)" \
        "Fail on unreadable file (SHLIB_ERR): $(basename -- "${f}")"
    done

    chmod "${perm_bak}" "${path[file]}"
  }

  for f in "${path[@]}"; do
    out_act="$(${cmd} "${f}")"
    assert_readable "${RC_OK}" "${?}" "" "${out_act}" \
      "Susseed on readable file (stdout): $(basename -- "${f}")"

    "${cmd}" "${f}"
    assert_readable "${RC_OK}" "${?}" "" "$(shlib_read1)" \
      "Susseed on readable file (SHLIB_OUT): $(basename -- "${f}")"
  done

  out_act="$("${cmd}" <(echo "${GLOBAL_RANDVAL}"))"
  assert_readable "${RC_OK}" "${?}" "" "${out_act}" \
    "Susseed on named pipe (stdout)"

  "${cmd}" <(echo "${GLOBAL_RANDVAL}")
  assert_readable "${RC_OK}" "${?}" "" "$(shlib_read1)" \
    "Susseed on named pipe (SHLIB_OUT)"
} && __readable
