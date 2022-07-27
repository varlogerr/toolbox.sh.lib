
local exp_res
local act_res
local input

shlib_channel1_is_empty && echo "Empty" || echo "Not empty"

shlib_channel1_add "out1" "out2
nexline" "out3"

shlib_channel1_is_empty && echo "Empty" || echo "Not empty"
