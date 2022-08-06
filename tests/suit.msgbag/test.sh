local RC_OK=0
local RC_ERR=1
local res_exp
local res_act

__msgbag_add_get() {
  unset __msgbag_add_get

  local cmd=msgbag_add
  assert_msg_add() { assert_result "${@:1:4}" "\`${!cmd}\` ${5}"; }

  msgbag_add vvv 1 2 3
  echo "${vvv}"
} && __msgbag_add_get

# __msgbag_test() {
#   unset __msgbag_test

#   declare str
#   declare -a arr
#   declare -A map
#   declare -a reciever

#   for var in str arr map[msgs]; do
#     msgbag_add "${var}"

#     assert_result "${RC_ERR}" "$?" "x" "${!var:-x}" \
#       "Fail adding message with empty input (${var})"

#     res_exp=0
#     res_act="$(msgbag_len "${var}")"
#     assert_result "${RC_OK}" "$?" "${res_exp}" "${res_act}" \
#       "Calculate 0 length message bag lengh (${var})"

#     msgbag_is_empty "${var}"
#     assert_result "${RC_OK}" "$?" "" "" \
#       "Check empty for 0 lenght message bag (${var})"

#     msgbag_get "${var}" reciever
#     assert_result "${RC_ERR}" "$?" "" "$(printf '%s\n' "${reciever[@]}")" \
#       "Fail get multiline messages on 0 length message bag (${var})"

#     res_act="$(msgbag_printix "${var}" 1)"
#     assert_result "${RC_ERR}" "$?" "" "${res_act}" \
#       "Fail pringing 1st item from message bag (${var})"

#     msgbag_printix "${var}" reciever
#     assert_result "${RC_ERR}" "$?" "" "$(printf '%s\n' "${reciever[@]}")" \
#       "Fail flushing message bag on 0 length message bag (${var})"
#   done

#   for var in str arr map[msgs]; do
#     msgbag_add "${var}" "one" "two"$'\n'"three"

#     assert_result "${RC_OK}" "$?" "" "" \
#       "Succeed adding multiple messages (${var})"

#     res_exp=2
#     res_act="$(msgbag_len "${var}")"
#     assert_result "${RC_OK}" "$?" "${res_exp}" "${res_act}" \
#       "Calculate message bag lengh (${var})"

#     msgbag_is_empty "${var}"
#     assert_result "${RC_ERR}" "$?" "" "" \
#       "Check empty (${var})"

#     res_exp="+ one"$'\n'"+ two"$'\n'"three"
#     reciever=()
#     msgbag_get "${var}" reciever
#     assert_result "${RC_OK}" "$?" "${res_exp}" "$(printf '+ %s\n' "${reciever[@]}")" \
#       "Get multiline messages (${var})"

#     res_exp="one"
#     res_act="$(msgbag_printix "${var}" 1)"
#     assert_result "${RC_OK}" "$?" "${res_exp}" "${res_act}" \
#       "Print 1st item from message bag (${var})"

#     res_exp="+ one"$'\n'"+ two"$'\n'"three"
#     reciever=()
#     msgbag_flush "${var}" reciever
#     assert_result "${RC_OK}" "$?" "${res_exp}" "$(printf '+ %s\n' "${reciever[@]}")" \
#       "Flush message bag (${var})"

#     reciever=()
#     msgbag_get "${var}" reciever
#     assert_result "${RC_ERR}" "$?" "" "$(printf '%s\n' "${reciever[@]}")" \
#       "Messaage bag is empty after flush (${var})"
#   done
# } && __msgbag_test

# __msgbag_test() {
#   unset __msgbag_test

#   declare -a input1=(one two)
#   declare -a input2=(three four)
#   declare -a input_total=("${input1[@]}" "${input2[@]}")

#   declare str
#   declare -a arr
#   declare -A map
#   declare -a reciever

#   res_exp="$(printf -- '%s\n' "${input_total[@]}")"
#   for var in str arr map[msgs]; do
#     reciever=()

#     msgbag_add "${var}" "${input1[@]}"
#     msgbag_add "${var}" "${input2[@]}"
#     msgbag_get "${var}" reciever

#     assert_result "${RC_OK}" "${?}" "${res_exp}" "$(printf -- '%s\n' "${reciever[@]}")" \
#       "Succeed multiple add operations ($var)"
#   done
# } && __msgbag_test

# __msgbag_test() {
#   unset __msgbag_test

#   declare -a input=(one two)

#   declare str
#   declare -a arr
#   declare -A map
#   declare -a reciever

#   for var in str arr map[msgs]; do
#     reciever=()

#     msgbag_add "${var}" "${input[@]}"

#     res_exp="$(printf -- '%s\n' "${input[@]}")"
#     msgbag_get "${var}" reciever
#     msgbag_get "${var}" reciever
#     assert_result "${RC_OK}" "${?}" "${res_exp}" "$(printf -- '%s\n' "${reciever[@]}")" \
#       "Get override RECIPIENT ($var)"

#     res_exp="$(printf -- '%s\n' "${input[@]}"$'\n'"${input[@]}")"
#     for f in -a --append; do
#       reciever=()
#       msgbag_get "${var}" reciever ${f}
#       msgbag_get "${var}" reciever ${f}
#       assert_result "${RC_OK}" "${?}" "${res_exp}" "$(printf -- '%s\n' "${reciever[@]}")" \
#         "Get append to RECIPIENT ($var): ${f}"
#     done
#   done
# } && __msgbag_test

# __msgbag_test() {
#   unset __msgbag_test

#   declare -a input=(one two)

#   declare str
#   declare -a arr
#   declare -A map
#   declare -a reciever

#   for var in str arr map[msgs]; do
#     reciever=()
#     msgbag_add "${var}" "${input[@]}"

#     res_exp="$(printf -- '%s\n' "${input[@]}")"
#     msgbag_get "${var}" reciever
#     msgbag_flush "${var}" reciever
#     assert_result "${RC_OK}" "${?}" "${res_exp}" "$(printf -- '%s\n' "${reciever[@]}")" \
#       "Flush override RECIPIENT ($var)"

#     res_exp="$(printf -- '%s\n' "${input[@]}"$'\n'"${input[@]}")"
#     for f in -a --append; do
#       msgbag_add "${var}" "${input[@]}"

#       reciever=()
#       msgbag_get "${var}" reciever ${f}
#       msgbag_flush "${var}" reciever ${f}
#       assert_result "${RC_OK}" "${?}" "${res_exp}" "$(printf -- '%s\n' "${reciever[@]}")" \
#         "Flush append to RECIPIENT ($var): ${f}"
#     done
#   done
# } && __msgbag_test

# __msgbag_test() {
#   unset __msgbag_test

#   declare -a input=(one two)

#   declare str
#   declare -a arr
#   declare -A map

#   for var in str arr map[msgs]; do
#     res_act="$(msgbag2list "${var}")"
#     assert_result "${RC_ERR}" "${?}" "" "${res_act}" \
#       "Fail output list with no input ($var)"

#     msgbag_add "${var}" "${input[@]}"

#     res_exp="$(printf -- '* %s\n' "${input[@]}")"
#     res_act="$(msgbag2list "${var}")"
#     assert_result "${RC_OK}" "${?}" "${res_exp}" "${res_act}" \
#       "Output list ($var)"

#     res_exp="$(printf -- '+ %s\n' "${input[@]}")"
#     for f in -p --prefix; do
#       res_act="$(msgbag2list "${var}" ${f} '+ ')"
#       assert_result "${RC_OK}" "${?}" "${res_exp}" "${res_act}" \
#         "Output list ($var): ${f} '+ '"
#     done
#   done
# } && __msgbag_test
