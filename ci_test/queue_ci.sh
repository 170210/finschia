#!/bin/sh

FROM_ACCOUNT="alice"
TOKEN_NAME="ST1"            
ERROR_FLAG="failed"

STORE_RES=$(fnsad tx wasm store contracts/queue.wasm --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia --gas 1500000 -b block -o json -y)
CODE_ID=`echo $STORE_RES | jq '.logs[] | select(.msg_index == 0) | .events[] | select(.type == "store_code") | .attributes[] | select(.key == "code_id") | .value | tonumber'`
# initialize smart contract
init_msg=`jq -nc '{}'`      
INSTANTIATE_RES=`fnsad tx wasm instantiate $CODE_ID $init_msg --label $TOKEN_NAME  --admin $(fnsad keys show $FROM_ACCOUNT -a --keyring-backend test) --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -o json -y`
CONTRACT_ADDRESS=`echo $INSTANTIATE_RES | jq '.logs[] | select(.msg_index == 0) | .events[] | select(.type == "instantiate") | .attributes[] | select(.key == "_contract_address") | .value' | sed 's/"//g'`

# enqueue in order
# now: {100, 200, 300}
for value in 100 200 300; do
    enqueue_msg=`jq -nc --arg value $value '{enqueue:{value:($value | tonumber)}}'`
    RUN_INFO=$(fnsad tx wasm execute $CONTRACT_ADDRESS $enqueue_msg --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -y)
    if grep -q "$ERROR_FLAG" <<< "$RUN_INFO"; then
        echo "error"
    fi
done

# the result should be 3
count_msg=`jq -nc '{coun:{}}'`
RUN_INFO=fnsad query wasm contract-state smart $CONTRACT_ADDRESS $count_msg
if grep -q "$ERROR_FLAG" <<< "$RUN_INFO"; then
    echo "error"
fi


# dequeue
# now: {200, 300}
dequeue_msg=`jq -nc '{dequeu:{}}'`      
RUN_INFO=fnsad tx wasm execute $CONTRACT_ADDRESS $dequeue_msg --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -y
if grep -q "$ERROR_FLAG" <<< "$RUN_INFO"; then
    echo "error"
fi

# the result should be 500
sum_msg=`jq -nc '{sum:{}}'`
RUN_INFO=fnsad query wasm contract-state smart $CONTRACT_ADDRESS $sum_msg

# the result should be 
# counters:
# - - 200
#   - 300
# - - 300
#   - 0
reducer_msg=`jq -nc '{reducer:{}}'`
RUN_INFO=fnsad query wasm contract-state smart $CONTRACT_ADDRESS $reducer_msg

# the result should be
# early:
# - 1
# - 2
# empty: []
# late: []
list_msg=`jq -nc '{list:{}}'`
RUN_INFO=fnsad query wasm contract-state smart $CONTRACT_ADDRESS $list_msg
