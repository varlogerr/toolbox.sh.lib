local res_act
local res_exp
local input

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

  ${cmd} -r -retvar
  assert_from_args "${SHLIB_ERRSYS}" "${?}" "" "" \
    "fails with SHLIB_ERRSYS on invalid RETVAR"

  res_exp="* "
  {
    res_act="$(${cmd} "")"
    assert_from_args "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
      "empty single item list to stdout on empty string input"

    unset retvar; declare retvar
    ${cmd} -r retvar "" >/dev/null
    assert_from_args "${SHLIB_OK}" "${?}" "${res_exp}" "${retvar}" \
      "empty single item list to RETVAR on empty string input"
  }

  res_exp="* one"$'\n'"* two"$'\n'"  "
  input=("one" "two"$'\n')
  unset retvars; declare -A retvars
  unset rcs; declare -A rcs
  {
    res_act="$(${cmd} "${input[@]}")"
    assert_from_args "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
      "multi items with with single line to stdout"

    for f in -r --retvar; do
      ${cmd} "${input[@]}" ${f} retvars[$f] >/dev/null
      rcs[$f]=$?
      assert_from_args "${SHLIB_OK}" "${rcs[$f]}" "${res_exp}" "${retvars[$f]}" \
        "multi items with with single line to RETVAR: ${f}"
    done

    assert_from_args "${rcs[-r]}" "${rcs[--retvar]}" "${retvars[-r]}" "${retvars[--retvar]}" \
      "-r and --retvar flags provide same result"
  }

  unset assert_from_args
} && __test_from_args
