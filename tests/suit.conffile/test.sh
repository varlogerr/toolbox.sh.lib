. "${SUITDIR}/tests/rmcomment.sh"

txt="
one
two
"

echo =====
file_cat <<< "${txt}"
echo =====
file_cat <(echo "${txt}")
