__channel() {
  unset __channel

  local out_exp
  local out_act

  {
    out_act="$(shlib_channel1_print)"
    assert_result "1" "$?" "" "${out_act}" \
      "channel1_print: RC 1 and blank stdout on no messages"

    shlib_channel1_print
    assert_result "1" "$?" "" "${SHLIB_CHANNEL1}" \
      "channel1_print: RC 1 and blank SHLIB_CHANNEL1 on no messages"

    out_act="$(shlib_channel2_print 2>&1 1>/dev/null)"
    assert_result "1" "$?" "" "${out_act}" \
      "channel2_print: RC 1 and blank stderr on no messages"

    shlib_channel2_print
    assert_result "1" "$?" "" "${SHLIB_CHANNEL2}" \
      "channel2_print: RC 1 and blank SHLIB_CHANNEL2 on no messages"
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
} && __channel
