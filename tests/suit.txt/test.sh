local exp_res
local act_res
local input

input="   Hello "
exp_res="Hello "
act_res="$(txt_ltrim <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_ltrim trims left spaces (stdin input)"
act_res="$(txt_ltrim <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_ltrim trims left spaces (file input)"

input=" Hello   "
exp_res=" Hello"
act_res="$(txt_rtrim <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rtrim trims right spaces (stdin input)"
act_res="$(txt_rtrim <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rtrim trims right spaces (file input)"

input=" Hello   "
exp_res="Hello"
act_res="$(txt_trim <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_trim trims left and right spaces (stdin input)"
act_res="$(txt_trim <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_trim trims left and right spaces (file input)"

input="Hello"$'\n'$'\n'"world"
exp_res="Hello"$'\n'"world"
act_res="$(txt_rmblank <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rmblank removes blank lines (stdin input)"
act_res="$(txt_rmblank <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rmblank removes blank lines (file input)"

input="Hello"$'\n'"# world"
exp_res="Hello"
act_res="$(txt_rmcomment <<< "${input}")"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rmcomment removes comment lines (stdin input)"
act_res="$(txt_rmcomment <(echo "${input}"))"
assert_result 0 0 "${exp_res}" "${act_res}" \
  "txt_rmcomment removes comment lines (file input)"
