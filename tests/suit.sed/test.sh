local res_act
local res_exp

__test_escape_rex() {
  unset __test_escape_rex

  local cmd=sed_escape_rex

  res_exp=''
  res_act="$(${cmd})"
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} fails with SHLIB_ERRSYS and empty stdout on no REX"

  res_exp=''
  unset retvar; declare retvar
  for f in -r --retvar; do
    ${cmd} "${f}" retvar >/dev/null
    assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar+x}" \
      "${cmd} fails with SHLIB_ERRSYS and no RETVAR on no REX: ${f}"
  done

  res_exp='\[\]\\\/\$\*\.\^'
  res_act="$(${cmd} '[]\/$*.^')"
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} escapes to stdout"

  res_exp='\[\]\\\/\$\*\.\^'
  unset retvar; declare retvar
  for f in -r --retvar; do
    ${cmd} "${f}" retvar '[]\/$*.^' >/dev/null
    assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}" \
      "${cmd} escapes to RETVAR: ${f}"
  done

  res_exp=''
  res_act="$(${cmd} '')"
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} succeeds with empty stdout on empty REX"

  res_exp='x'
  unset retvar; declare retvar
  ${cmd} -r retvar '' >/dev/null
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}${retvar+x}" \
    "${cmd} succeeds with empty RETVAR on empty REX"

  res_exp=''
  res_act="$(${cmd} '-r')"
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} fails with SHLIB_ERRSYS and empty stdout on flag-like REX"

  res_exp='-r'
  res_act="$(${cmd} -- '-r')"
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} escapes to stdout on flag-like REX after \`--\`"

  res_exp='-r'
  unset retvar; declare retvar
  ${cmd} -r retvar -- '-r' >/dev/null
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}" \
    "${cmd} escapes to RETVAR on flag-like REX after \`--\`"

  res_exp=''
  res_act="$(${cmd} '' '')"
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} fails with SHLIB_ERRSYS and empty stdout on multiple REX"

  unset retvar; declare retvar
  res_exp=''
  ${cmd} -r retvar '' ''
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar+x}" \
    "${cmd} fails with SHLIB_ERRSYS and no RETVAR on multiple REX"
} && __test_escape_rex

__test_escape_replace() {
  unset __test_escape_replace

  local cmd=sed_escape_replace

  res_exp=''
  res_act="$(${cmd})"
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} fails with SHLIB_ERRSYS and empty stdout on no REPLACE"

  res_exp=''
  unset retvar; declare retvar
  for f in -r --retvar; do
    ${cmd} "${f}" retvar >/dev/null
    assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar+x}" \
      "${cmd} fails with SHLIB_ERRSYS and no RETVAR on no REPLACE: ${f}"
  done

  res_exp='\\\/\&'
  res_act="$(${cmd} '\/&')"
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} escapes to stdout"

  res_exp='\\\/\&'
  unset retvar; declare retvar
  for f in -r --retvar; do
    ${cmd} "${f}" retvar '\/&' >/dev/null
    assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}" \
      "${cmd} escapes to retvar: ${f}"
  done

  res_exp=''
  res_act="$(${cmd} '')"
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} succeeds with empty stdout on empty REPLACE"

  res_exp='x'
  unset retvar; declare retvar
  ${cmd} -r retvar '' >/dev/null
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}${retvar+x}" \
    "${cmd} succeeds with empty RETVAR on empty REPLACE"

  res_exp=''
  res_act="$(${cmd} '-r')"
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} fails with SHLIB_ERRSYS and empty stdout on flag-like REPLACE"

  res_exp='-r'
  res_act="$(${cmd} -- '-r')"
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} escapes to stdout on flag-like REPLACE after \`--\`"

  res_exp='-r'
  unset retvar; declare retvar
  ${cmd} -r retvar -- '-r' >/dev/null
  assert_result "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}" \
    "${cmd} escapes to RETVAR on flag-like REPLACE after \`--\`"

  res_exp=''
  res_act="$(${cmd} '' '')"
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "${cmd} fails with SHLIB_ERRSYS and empty stdout on multiple REPLACE"

  unset retvar; declare retvar
  res_exp=''
  ${cmd} -r retvar '' ''
  assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar+x}" \
    "${cmd} fails with SHLIB_ERRSYS and no RETVAR on multiple REPLACE"
} && __test_escape_replace

__test_escape_common() {
  unset __test_escape_common

  local cmds=(sed_escape_rex sed_escape_replace)

  local cmd
  for cmd in "${cmds[@]}"; do
    res_exp=''
    res_act="$(${cmd} -r '-retvar' '')"
    assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
      "${cmd} fails with SHLIB_ERRSYS and empty stdout on invalid RETVAR name"

    unset retvar1; declare retvar1
    unset retvar2; declare retvar2
    res_exp=''
    res_act="$(${cmd} -r retvar1 -r retvar2 '')"
    assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
      "${cmd} fails with SHLIB_ERRSYS and empty stdout on multiple RETVAR"

    unset retvar1; declare retvar1
    unset retvar2; declare retvar2
    res_exp=''
    ${cmd} -r retvar1 -r retvar2 ''
    assert_result "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar1+x}${retvar2+x}" \
      "${cmd} fails with SHLIB_ERRSYS and no RETVAR on multiple RETVAR"
  done
} && __test_escape_common
