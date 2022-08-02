local res_act
local res_exp

__test_from_args() {
  unset __test_from_args

  local cmd=args2list

  assert_from_args() {
    assert_result "${@:1:4}" "\`args2list\` ${5}"
  }

  res_exp=""
  res_act="$(${cmd})"
  assert_from_args "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "succeeds with SHLIB_OK and empty result on empty input"

  unset retvar; declare retvar
  res_exp="x"
  ${cmd} -r retvar
  assert_from_args "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar-x}" \
    "succeeds with SHLIB_OK and no RETVAR on empty input"
} && __test_from_args
