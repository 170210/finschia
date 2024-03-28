#!/bin/bash 

rm -fr $HOME/.finschia
FNSAD="./build/origin/fnsad" ./init_single.sh
cat <<< $(jq '.app_state.gov.voting_params.voting_period = "20s"' $HOME/.finschia/config/genesis.json) > $HOME/.finschia/config/genesis.json

./build/origin/fnsad start
