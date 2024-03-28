package v050

import (
	storetypes "cosmossdk.io/store/types"
	circuittypes "cosmossdk.io/x/circuit/types"
	nfttypes "cosmossdk.io/x/nft"
	"github.com/Finschia/finschia/v3/app/upgrades"
	consensustypes "github.com/cosmos/cosmos-sdk/x/consensus/types"
	crisistypes "github.com/cosmos/cosmos-sdk/x/crisis/types"
	grouptypes "github.com/cosmos/cosmos-sdk/x/group"
	icacontrollertypes "github.com/cosmos/ibc-go/v8/modules/apps/27-interchain-accounts/controller/types"
	ibcfeetypes "github.com/cosmos/ibc-go/v8/modules/apps/29-fee/types"
)

// UpgradeName defines the on-chain upgrade name
const UpgradeName = "v4-Unknown"

var Upgrade = upgrades.Upgrade{
	UpgradeName:          UpgradeName,
	CreateUpgradeHandler: CreateUpgradeHandler,
	StoreUpgrades: storetypes.StoreUpgrades{
		Added: []string{
			circuittypes.ModuleName,
			consensustypes.ModuleName,
			crisistypes.ModuleName,
			ibcfeetypes.ModuleName,
			grouptypes.ModuleName,
			icacontrollertypes.SubModuleName,
			nfttypes.ModuleName,
		},
		Deleted: []string{},
	},
}
