local CONFDIR="${SUIT_MOCKDIR}/conffiles"

local -f assert_rmcomment
assert_rmcomment() {
  assert_result "${@:1:4}" "(rmcomment) ${5}"
}
