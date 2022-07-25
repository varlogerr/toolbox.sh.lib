__rmcomment() {
  unset __rmcomment

  assert_rmcomment() {
    assert_result "${@:1:4}" "(rmcomment) ${5}"
  }

  local cmd=conffile_rmcomment
  local exp_res
  local act_res
  local RC_OK=0
  local RC_ERR=1
  declare -A file=(
    [hash]="${CONFDIR}/hash-file.conf"
    [semi]="${CONFDIR}/semi-file.conf"
  )

  ${cmd} "${file[hash]}" "${file[semi]}" 2> /dev/null
  assert_rmcomment "${RC_ERR}" "${?}" "" "" \
    "Fail with multiple files input"

  ${cmd} "" 2> /dev/null
  assert_rmcomment "${RC_ERR}" "${?}" "${exp_res}" "${act_res}" \
    "Fail with unreadable file"

  exp_res="$(cat ${CONFDIR}/file-uncommented.conf)"
  for f in "${file[@]}"; do
    act_res="$(${cmd} "${f}")"
    assert_rmcomment "${RC_OK}" "${?}" "${exp_res}" "${act_res}" \
      "Uncomment file (file): $(basename -- "${f}")"
    act_res="$(cat "${f}" | ${cmd})"
    assert_rmcomment "${RC_OK}" "${?}" "${exp_res}" "${act_res}" \
      "Uncomment file (stdin): $(basename -- "${f}")"
  done

  unset assert_rmcomment
} && __rmcomment
