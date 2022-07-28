local exp_res
local act_res
local input

input="   Hello "
exp_res="Hello "
act_res="$(ltrim <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "ltrim trims left spaces (stdin input)"
act_res="$(ltrim <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "ltrim trims left spaces (file input)"

input=" Hello   "
exp_res=" Hello"
act_res="$(rtrim <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "rtrim trims right spaces (stdin input)"
act_res="$(rtrim <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "rtrim trims right spaces (file input)"

input=" Hello   "
exp_res="Hello"
act_res="$(trim <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "trim trims left and right spaces (stdin input)"
act_res="$(trim <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "trim trims left and right spaces (file input)"

input="Hello"$'\n'$'\n'"world"
exp_res="Hello"$'\n'"world"
act_res="$(rmblank <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "rmblank removes blank lines (stdin input)"
act_res="$(rmblank <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "rmblank removes blank lines (file input)"

input="Hello"$'\n'"# world"
exp_res="Hello"
act_res="$(txt_rmcomment <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rmcomment removes comment lines (stdin input)"
act_res="$(txt_rmcomment <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rmcomment removes comment lines (file input)"
