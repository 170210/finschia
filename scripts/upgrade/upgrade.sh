#!/bin/bash 

./build/origin/fnsad tx gov submit-proposal software-upgrade v4-Unknown --title "test" --description "test" --from jack --upgrade-height 20 --deposit 10000000stake --chain-id=finschia --keyring-backend=test --gas-prices 1000stake --gas 10000000 --gas-adjustment 1.5 -b block -y

sleep 5

./build/origin/fnsad tx gov vote 1 yes --from jack --chain-id=finschia --keyring-backend=test -b block -y
