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
  }

  res_exp='- one'$'\n''- two'
  input=(one two)
  {
    for f in -p --prefix; do
      res_act="$("${cmd}" -p '- ' "${input[@]}")"
      assert_from_args "${SHLIB_OK}" "${rc}" "${res_exp}" "${res_act}" \
        "PREFIX is changed: ${f}"
    done
  }

  res_exp='* one'$'\n''* two'$'\n''    three'
  input=(one "two"$'\n'"three")
  res_act="$("${cmd}" --offset 4 "${input[@]}")"
  assert_from_args "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "OFFSET is changed"

  res_exp='* -r'$'\n''* 4'
  input=(-r 4)
  res_act="$("${cmd}" -- "${input[@]}")"
  assert_from_args "${SHLIB_OK}" "${?}" "${res_exp}" "${res_act}" \
    "option-like param processed as ITEM after endopts"

  res_exp="shlib_list_from_args: multiple RETVAR is not allowed"
  declare ret1 ret2
  res_act="$("${cmd}" -r ret1 -r ret2 2>&1)"
  assert_from_args "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and error message on multiple RETVAR"

  res_exp="shlib_list_from_args: multiple PREFIX is not allowed"
  res_act="$("${cmd}" -p '- ' -p '- ' 2>&1)"
  assert_from_args "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and error message on multiple PREFIX"

  res_exp="shlib_list_from_args: multiple OFFSET is not allowed"
  res_act="$("${cmd}" --offset 4 --offset 4 2>&1)"
  assert_from_args "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and error message on multiple OFFSET"

  res_exp="shlib_list_from_args: Invalid RETVAR name: -retvar"
  res_act="$(${cmd} -r -retvar 2>&1)"
  assert_from_args "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and error message on invalid RETVAR"

  res_exp="shlib_list_from_args: OFFSET must be a >= 0 number: -1"
  res_act="$(${cmd} --offset -1 2>&1)"
  assert_from_args "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and error message on negative OFFSET"

  res_exp="shlib_list_from_args: OFFSET must be a >= 0 number: inval"
  res_act="$(${cmd} --offset inval 2>&1)"
  assert_from_args "${SHLIB_ERRSYS}" "${?}" "${res_exp}" "${res_act}" \
    "fails with SHLIB_ERRSYS and error message on invalid OFFSET"

  unset assert_from_args
} && __test_from_args
