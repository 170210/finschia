#!/bin/bash

FROM_ACCOUNT='alice'
TOKEN_NAME='ST1'

executeCheck(){
    if [[ $1 == *"failed"* ]]; then
        echo $2
        echo $1
        exit 1
    fi    
}

queryCheck(){
    echo $1
    echo $2
    if [[ $1 != $2 ]]; then
        echo "expected result is :$2"
        echo "but query result is:$1"
#        exit 1
    fi    
}

STORE_RES=$(fnsad tx wasm store contracts/queue.wasm --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia --gas 1500000 -b block -o json -y)
CODE_ID=`echo $STORE_RES | jq '.logs[] | select(.msg_index == 0) | .events[] | select(.type == "store_code") | .attributes[] | select(.key == "code_id") | .value | tonumber'`
# initialize smart contract
init_msg=`jq -nc '{}'`      
INSTANTIATE_RES=`fnsad tx wasm instantiate $CODE_ID $init_msg --label $TOKEN_NAME  --admin $(fnsad keys show $FROM_ACCOUNT -a --keyring-backend test) --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -o json -y`
CONTRACT_ADDRESS=`echo $INSTANTIATE_RES | jq '.logs[] | select(.msg_index == 0) | .events[] | select(.type == "instantiate") | .attributes[] | select(.key == "_contract_address") | .value' | sed 's/"//g'`

# check enqueue
# now: {100, 200, 300}
for value in 100 200 300; do
    enqueue_msg=`jq -nc --arg value $value '{enqueue:{value:($value | tonumber)}}'`
    run_info=$(fnsad tx wasm execute $CONTRACT_ADDRESS $enqueue_msg --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -y)
    executeCheck $run_info "enqueue_error"
done

# check count
expected_result='data: count: 3'
count_msg=`jq -nc '{count:{}}'`
query_result=$(fnsad query wasm contract-state smart $CONTRACT_ADDRESS $count_msg)
executeCheck $query_result "query_error"
queryCheck $query_result $expected_result

# check dequeue
# now: {200, 300}
dequeue_msg=`jq -nc '{dequeue:{}}'`      
run_info=$(fnsad tx wasm execute $CONTRACT_ADDRESS $dequeue_msg --from $FROM_ACCOUNT --keyring-backend test --chain-id finschia -b block -y)
executeCheck $run_info "enqueue_error"

# check sum
expected_result='data: sum: 500'
sum_msg=`jq -nc '{sum:{}}'`
query_result=$(fnsad query wasm contract-state smart $CONTRACT_ADDRESS $sum_msg)
executeCheck $query_result "query_error"
queryCheck $query_result $expected_result

# check reducer
expected_result='data: counters: - - 200 - 300 - - 300 - 0'
reducer_msg=`jq -nc '{reducer:{}}'`
query_result=$(fnsad query wasm contract-state smart $CONTRACT_ADDRESS $reducer_msg)
executeCheck $query_result "query_error"
queryCheck $query_result $expected_result

# check list
expected_result='data: early: - 1 - 2 empty: [] late: []'
list_msg=`jq -nc '{list:{}}'`
query_result=$(fnsad query wasm contract-state smart $CONTRACT_ADDRESS $list_msg)
executeCheck $query_result "query_error"
queryCheck $query_result $expected_result

# check open_iterators
openIterators_msg=`jq -nc '{open_iterators:{count:3}}'`
query_result=$(fnsad query wasm contract-state smart $CONTRACT_ADDRESS $openIterators_msg)
executeCheck $query_result "query_error"
echo $query_result