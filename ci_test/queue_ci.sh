#!/bin/sh

FROM_ACCOUNT=alice
TOKEN_NAME=ST1            
            
STORE_RES=$(fnsad tx wasm store contracts/queue.wasm --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia --gas 1500000 -b block -o json -y)
echo $STORE_RES
CODE_ID=`echo $STORE_RES | jq '.logs[] | select(.msg_index == 0) | .events[] | select(.type == "store_code") | .attributes[] | select(.key == "code_id") | .value | tonumber'`

# 
init_msg=`jq -nc '{}'`      
INSTANTIATE_RES=`fnsad tx wasm instantiate $CODE_ID $init_msg --label $TOKEN_NAME  --admin $(fnsad keys show $FROM_ACCOUNT -a --keyring-backend test) --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -o json -y`
CONTRACT_ADDRESS=`echo $INSTANTIATE_RES | jq '.logs[] | select(.msg_index == 0) | .events[] | select(.type == "instantiate") | .attributes[] | select(.key == "_contract_address") | .value' | sed 's/"//g'`
echo $CONTRACT_ADDRESS

for value in 100 200 300; do
    enqueue_msg=`jq -nc --arg value $value '{enqueue:{value:($value | tonumber)}}'`
    fnsad tx wasm execute $CONTRACT_ADDRESS $enqueue_msg --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -y
done

count_msg=`jq -nc '{count:{}}'`
fnsad query wasm contract-state smart $CONTRACT_ADDRESS $query_msg

dequeue_msg=`jq -nc '{}'`      
fnsad tx wasm execute $CONTRACT_ADDRESS $dequeue_msg --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -y

sum_msg=`jq -nc '{sum:{}}'`
fnsad query wasm contract-state smart $CONTRACT_ADDRESS $query_msg

reducer_msg=`jq -nc '{reducer:{}}'`
fnsad query wasm contract-state smart $CONTRACT_ADDRESS $query_msg

list_msg=`jq -nc '{list:{}}'`
fnsad query wasm contract-state smart $CONTRACT_ADDRESS $query_msg
