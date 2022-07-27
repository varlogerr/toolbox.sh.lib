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
  }

  for f in -q --quiet; do
    out_act="$(shlib_channel1_print "test" -q)"
    assert_result "0" "$?" "" "${out_act}" \
      "channel1_print: RC 0 and blank stdout on ${f} flag"

    out_exp="test"
    shlib_channel1_print "test" -q
    assert_result "0" "$?" "${out_exp}" "${SHLIB_CHANNEL1}" \
      "channel1_print: RC 0 and SHLIB_CHANNEL1 contains message on ${f} flag"
  done
} && __channel
