
local exp_res
local act_res
local input

shlib_channel1_is_empty && echo "Empty" || echo "Not empty"

echo '======'
shlib_channel1_print "HELLO" "WORLD" "hello world" "Hello
World" ""

echo '======'
shlib_channel1_is_empty && echo "Empty" || echo "Not empty"

echo '======'
shlib_channel1_flush

echo '======'
shlib_channel1_is_empty && echo "Empty" || echo "Not empty"
