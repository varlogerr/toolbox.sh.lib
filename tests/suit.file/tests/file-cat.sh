__file_cat() {
  unset __file_cat

  local -f assert_file_cat

  assert_file_cat() {
    assert_result "${@:1:4}" "file_cat: ${5}"
  }

  local -r cmd=shlib_file_cat
  local -r RC_OK=0
  local -r RC_ERR=1
  declare -rA path=(
    [file]="${FILES_DIR}/file.txt"
    [lnk]="${FILES_DIR}/file.lnk"
  )
  declare -rA path_err=(
    [file]="${FILES_DIR}/${GLOB_RANDVAL}.txt"
    [lnk]="${FILES_DIR}/${GLOB_RANDVAL}.lnk"
  )
  local out_act
  local out_exp


} && __file_cat
