package v050

import (
	"context"

	upgradetypes "cosmossdk.io/x/upgrade/types"

	"github.com/cosmos/cosmos-sdk/types/module"

	"github.com/Finschia/finschia/v3/app/upgrades"
)

func CreateUpgradeHandler(
	mm *module.Manager,
	configurator module.Configurator,
	ak *upgrades.AppKeepers,
) upgradetypes.UpgradeHandler {
	// sdk 47 to sdk 50
	return func(ctx context.Context, plan upgradetypes.Plan, fromVM module.VersionMap) (module.VersionMap, error) {
		// var logger log.Logger
		// logger.Info("Starting module migrations...")
		vm, err := mm.RunMigrations(ctx, configurator, fromVM)
		if err != nil {
			return vm, err
		}

		vm["auth"] = 1
		vm["bank"] = 1
		vm["collection"] = 2
		vm["distribution"] = 1
		vm["foundation"] = 2
		vm["gov"] = 1
		vm["slashing"] = 1
		vm["staking"] = 1
		vm["token"] = 1

		// logger.Info("Upgrade complete")
		return vm, err
	}
}
