__file_cat() {
  unset __file_cat

  shlib_file_cat <(echo '1
2
3

')
} && __file_cat
