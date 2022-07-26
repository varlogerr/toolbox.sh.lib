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
  declare -A path_err=(
    [file]="${FILES_DIR}/${GLOBAL_RANDVAL}.txt"
    [lnk]="${FILES_DIR}/${GLOBAL_RANDVAL}.lnk"
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

  out_act="$("${cmd}" "${path_err[file]}" 2>&1)"
  assert_readable "${RC_ERR}" "${?}" "" "${out_act}" \
    "Fail on not existing file (stderr)"

  "${cmd}" "${path_err[file]}"
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

  out_act="$("${cmd}" <(echo))"
  assert_readable "${RC_OK}" "${?}" "" "${out_act}" \
    "Susseed on named pipe (stdout)"

  "${cmd}" <(echo)
  assert_readable "${RC_OK}" "${?}" "" "$(shlib_read1)" \
    "Susseed on named pipe (SHLIB_OUT)"

  out_exp="${path[file]}"$'\n'"${path[lnk]}"
  {
    out_act="$("${cmd}" --out "${path[file]}" "${path[lnk]}")"
    assert_readable "${RC_OK}" "${?}" "${out_exp}" "${out_act}" \
      "Output to stdout"

    "${cmd}" --out "${path[file]}" "${path[lnk]}" > /dev/null
    assert_readable "${RC_OK}" "${?}" "${out_exp}" "$(shlib_read1)" \
      "Output to SHLIB_OUT"
  }

  out_exp="${path_err[lnk]}"$'\n'"${path_err[file]}"
  {
    out_act="$("${cmd}" "${path_err[lnk]}" "${path_err[file]}" \
      --err 2>&1 1> /dev/null)"
    assert_readable "${RC_ERR}" "${?}" "${out_exp}" "${out_act}" \
      "Output to stderr"

    "${cmd}" "${path_err[lnk]}" "${path_err[file]}" \
      --err > /dev/null 2>&1
    assert_readable "${RC_ERR}" "${?}" "${out_exp}" "$(shlib_read2)" \
      "Output to SHLIB_ERR"
  }

  out_act="$(cd "${FILES_DIR}"; "${cmd}" --out --err)"
  assert_readable "${RC_OK}" "${?}" "" "${out_act}" \
    "Consider flag named file to be a flag"

  out_exp="--out"$'\n'"--err"
  out_act="$(cd "${FILES_DIR}"; "${cmd}" --out -- --out --err)"
  assert_readable "${RC_OK}" "${?}" "${out_exp}" "${out_act}" \
    "Consider flag named file to be a file after endopts"
} && __readable
