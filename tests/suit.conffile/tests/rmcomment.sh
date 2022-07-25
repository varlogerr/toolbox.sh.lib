__rmcomment() {
  unset __rmcomment

  local cmd=conffile_rmcomment
  local exp_res
  local act_res
  local RC_OK=0
  local RC_ERR=1
  declare -A file=(
    [hash]="${CONFDIR}/file-hash.conf"
    [semi]="${CONFDIR}/file-semi.conf"
  )
  local file_cut_bak="$(local -f file_cut)"

  {
    file_cut() { return 1; }

    ${cmd} "" 2> /dev/null
    assert_rmcomment "${RC_ERR}" "${?}" "" "${FUNCRES+x}" \
      "Fail on file_cut fail (file)"

    ${cmd} <<< "" 2> /dev/null
    assert_rmcomment "${RC_ERR}" "${?}" "" "${FUNCRES+x}" \
      "Fail on file_cut fail (stdin)"

    eval "${file_cut_bak}"
  }

  exp_res="$(cat ${CONFDIR}/file-uncommented.conf)"
  for f in "${file[@]}"; do
    ${cmd} "${f}" > /dev/null
    assert_rmcomment "${RC_OK}" "${?}" "${exp_res}" "${FUNCRES}" \
      "Uncomment file (file): $(basename -- "${f}")"

    ${cmd} <<< "$(cat "${f}")" > /dev/null
    assert_rmcomment "${RC_OK}" "${?}" "${exp_res}" "${FUNCRES}" \
      "Uncomment file (stdin): $(basename -- "${f}")"
  done

  unset assert_rmcomment
} && __rmcomment
