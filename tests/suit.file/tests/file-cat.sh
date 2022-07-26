__file_cat() {
  unset __file_cat

  local -f assert_file_cat

  assert_file_cat() {
    assert_result "${@:1:4}" "file_cat: ${5}"
  }

  local cmd=shlib_file_cat


} && __file_cat
