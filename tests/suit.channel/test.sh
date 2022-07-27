__channel() {
  unset __channel

  local out_exp
  local out_act
  local input

  {
    out_act="$(shlib_channel1_print)"
    assert_result "1" "$?" "" "${out_act}" \
      "channel1_print: RC 1 and blank stdout on no messages"

    out_act="$(shlib_channel2_print 2>&1 1>/dev/null)"
    assert_result "1" "$?" "" "${out_act}" \
      "channel2_print: RC 1 and blank stderr on no messages"

    shlib_channel1_print
    assert_result "1" "$?" "" "${SHLIB_CHANNEL1}" \
      "channel1_print: RC 1 and blank SHLIB_CHANNEL1 on no messages"

    shlib_channel2_print
    assert_result "1" "$?" "" "${SHLIB_CHANNEL2}" \
      "channel2_print: RC 1 and blank SHLIB_CHANNEL2 on no messages"
  }

  {
    out_exp="one"$'\n'"two"
    input=("one" "two")

    out_act="$(shlib_channel1_print "${input[@]}")"
    assert_result "0" "$?" "${out_exp}" "${out_act}" \
      "channel1_print: Print multi messages to stdout"

    out_act="$(shlib_channel2_print "${input[@]}" 2>&1 1>/dev/null)"
    assert_result "0" "$?" "${out_exp}" "${out_act}" \
      "channel2_print: Print multi messages to stderr"

    shlib_channel1_print "${input[@]}" >/dev/null
    assert_result "0" "$?" "${out_exp}" "${SHLIB_CHANNEL1}" \
      "channel1_print: SHLIB_CHANNEL1 contains multi messages"

    shlib_channel2_print "${input[@]}" 2>/dev/null
    assert_result "0" "$?" "${out_exp}" "${SHLIB_CHANNEL2}" \
      "channel2_print: SHLIB_CHANNEL2 contains multi messages"
  }

  for f in -q --quiet; do
    out_act="$(shlib_channel1_print "test" -q)"
    assert_result "0" "$?" "" "${out_act}" \
      "channel1_print: Blank stdout on ${f} flag"

    out_act="$(shlib_channel2_print "test" -q 2>&1 1>/dev/null)"
    assert_result "0" "$?" "" "${out_act}" \
      "channel2_print: Blank stdout on ${f} flag"

    out_exp="test"

    shlib_channel1_print "test" -q
    assert_result "0" "$?" "${out_exp}" "${SHLIB_CHANNEL1}" \
      "channel1_print: SHLIB_CHANNEL1 contains message on ${f} flag"

    shlib_channel2_print "test" -q
    assert_result "0" "$?" "${out_exp}" "${SHLIB_CHANNEL2}" \
      "channel2_print: SHLIB_CHANNEL2 contains message on ${f} flag"
  done

  {
    out_exp="-q"$'\n'"--query"$'\n'"--"
    input=("-q" "--query" "--")

    out_act="$(shlib_channel1_print -- "${input[@]}")"
    assert_result "0" "$?" "${out_exp}" "${out_act}" \
      "channel1_print: Print flags to stdout as messages after --"

    out_act="$(shlib_channel2_print -- "${input[@]}" 2>&1 1>/dev/null)"
    assert_result "0" "$?" "${out_exp}" "${out_act}" \
      "channel2_print: Print flags to stderr as messages after --"
  }
} && __channel
