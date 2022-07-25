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
  local file_cut_bak="$(local -f file_cut)"

  {
    file_cut() { return 1; }
    ${cmd} "" 2> /dev/null
    assert_rmcomment "${RC_ERR}" "${?}" "" "" \
      "Fail on file_cut fail (file)"

    ${cmd} <<< "" 2> /dev/null
    assert_rmcomment "${RC_ERR}" "${?}" "${exp_res}" "${act_res}" \
      "Fail on file_cut fail (stdin)"
    eval "${file_cut_bak}"
  }

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
