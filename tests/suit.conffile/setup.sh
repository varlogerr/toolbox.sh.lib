local CONFDIR="${SUIT_MOCKDIR}/conffiles"

assert_rmcomment() {
  assert_result "${@:1:4}" "(rmcomment) ${5}"
}
