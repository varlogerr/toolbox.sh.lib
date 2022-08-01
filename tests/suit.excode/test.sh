local res_act
local res_exp

__test_is_valid() {
  unset __test_is_valid

  local cmd=excode_is_valid

  assert_is_valid() {
    assert_result "${1}" "${2}" "" "" "\`is_valid\` ${3}"
  }

  ${cmd}
  assert_is_valid "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on no CODE"

  ${cmd} ${SHLIB_OK}
  assert_is_valid "${SHLIB_OK}" "${?}" \
    "succeeds on min available CODE"

  ${cmd} 255
  assert_is_valid "${SHLIB_OK}" "${?}" \
    "succeeds on max available CODE"

  ${cmd} -1
  assert_is_valid "${SHLIB_KO}" "${?}" \
    "fails with SHLIB_KO on negative CODE"

  ${cmd} 256
  assert_is_valid "${SHLIB_KO}" "${?}" \
    "fails with SHLIB_KO on out of range CODE"

  ${cmd} yara
  assert_is_valid "${SHLIB_KO}" "${?}" \
    "fails with SHLIB_KO on invalid CODE"

  ${cmd} ${SHLIB_OK} ${SHLIB_OK}
  assert_is_valid "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on multiple CODE"

  unset assert_is_valid
} && __test_is_valid

__test_is_ok() {
  unset __test_is_ok

  local cmd=excode_is_ok

  assert_is_ok() {
    assert_result "${1}" "${2}" "" "" "\`is_ok\` ${3}"
  }

  __tmp() { unset __tmp; return ${SHLIB_OK}; }; __tmp
  ${cmd}
  assert_is_ok "${SHLIB_OK}" "${?}" \
    "succeeds with SHLIB_OK on OK last exit code"

  __tmp() { unset __tmp; return ${SHLIB_KO}; }; __tmp
  ${cmd}
  assert_is_ok "${SHLIB_KO}" "${?}" \
    "succeeds with SHLIB_KO on KO last exit code"

  ${cmd} ${SHLIB_OK}
  assert_is_ok "${SHLIB_OK}" "${?}" \
    "succeeds with SHLIB_OK on OK CODE"

  ${cmd} ${SHLIB_KO}
  assert_is_ok "${SHLIB_KO}" "${?}" \
    "succeeds with SHLIB_KO on KO CODE"

  ${cmd} yara
  assert_is_ok "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on invalid CODE"

  ${cmd} ${SHLIB_KO} ${SHLIB_KO}
  assert_is_ok "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on multiple CODE"

  unset assert_is_ok
} && __test_is_ok

__test_add() {
  unset __test_add

  local cmd=excode_add
  local retvar

  assert_add() { assert_result "${@:1:4}" "\`add\` ${5}"; }

  res_exp=""
  res_act="$(${cmd})"
  assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and empty stdout on no CODE"

  res_exp=""
  res_act="$(${cmd} inval)"
  assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and empty stdout on invalid CODE"

  res_exp="x"
  unset retvar; declare retvar
  for f in -r --retvar; do
    ${cmd} ${f} retvar
    assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar-x}" \
      "fails with SHLIB_ERRSYS and no RETVAR on no CODE: ${f}"

    ${cmd} inval ${f} retvar
    assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar-x}" \
      "fails with SHLIB_ERRSYS and no RETVAR on invalid CODE: ${f}"
  done

  res_exp=3
  __tmp() { unset __tmp; return 1; }; __tmp
  res_act="$(${cmd} 2)"
  assert_add "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "sums CODE with last exit code to stdout"

  res_exp=3
  for f in -r --retvar; do
    __tmp() { unset __tmp; return 1; }; __tmp
    ${cmd} 2 ${f} retvar >/dev/null
    assert_add "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}" \
      "sums CODE with last exit code to RETVAR: ${f}"
  done

  res_exp=''
  for f in -r --retvar; do
    __tmp() { unset __tmp; return 1; }; __tmp
    ${cmd} 2 ${f} -inval >/dev/null
    assert_add "${SHLIB_ERRSYS}" "${?}" "" "" \
      "fails with SHLIB_ERRSYS on invalid RETVAR name: ${f}"
  done

  res_exp=""
  res_act="$(${cmd} 4 inval)"
  assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and empty stdout on invalid NEW_CODE"

  unset retvar; declare retvar
  res_exp="x"
  ${cmd} 4 inval -r retvar
  assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar-x}" \
    "fails with SHLIB_ERRSYS and no RETVAR on invalid NEW_CODE"

  res_exp=5
  res_act="$(${cmd} 4 1)"
  assert_add "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "sums CODE with NEW_CODE to stdout"

  res_exp=5
  ${cmd} 4 1 -r retvar >/dev/null
  assert_add "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}" \
    "sums CODE with NEW_CODE to RETVAR"

  res_exp=""
  res_act="$(${cmd} 4 1 1)"
  assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and empty stdout on multiple NEW_CODE"

  unset retvar; declare retvar
  res_exp=x
  ${cmd} 4 1 1 -r retvar >/dev/null
  assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar-x}" \
    "fails with SHLIB_ERRSYS and no RETVAR on multiple NEW_CODE"

  unset retvar; declare retvar
  res_exp=x
  ${cmd} 4 1 -r retvar -r retvar >/dev/null
  assert_add "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${retvar-x}" \
    "fails with SHLIB_ERRSYS and no RETVAR on multiple RETVAR"

  unset assert_add
} && __test_add

__test_contains() {
  unset __test_contains

  local cmd=excode_contains

  assert_contains() {
    assert_result "${1}" "${2}" "" "" "\`contains\` ${3}"
  }

  ${cmd}
  assert_contains "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on no CODE"

  ${cmd} 6 2
  assert_contains "${SHLIB_OK}" "${?}" \
    "succeeds with SHLIB_OK on CODE contains CHECK_CODE"

  ${cmd} 6 3
  assert_contains "${SHLIB_KO}" "${?}" \
    "succeeds with SHLIB_KO on CODE doesn't contain CHECK_CODE"

  __tmp() { unset __tmp; return ${SHLIB_OK}; }; __tmp
  ${cmd} 3
  assert_contains "${SHLIB_OK}" "${?}" \
    "succeeds with SHLIB_OK on CODE contains last exit code"

  __tmp() { unset __tmp; return ${SHLIB_KO}; }; __tmp
  ${cmd} 6
  assert_contains "${SHLIB_KO}" "${?}" \
    "succeeds with SHLIB_KO on CODE doesn't contain last exit code"

  ${cmd} yara 0
  assert_contains "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on invalid CODE"

  ${cmd} 0 yara
  assert_contains "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on invalid CHECK_CODE"

  ${cmd} 0 0 0
  assert_contains "${SHLIB_ERRSYS}" "${?}" \
    "fails with SHLIB_ERRSYS on multiple CHECK_CODE"

  unset assert_contains
} && __test_contains