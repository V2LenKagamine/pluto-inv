--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local GROUP = pluto.nodes.groups.get("reserves", 1)

GROUP.Type = "primary"

GROUP.Guaranteed = {
	"mythic_reserves"
}

GROUP.SmallNodes = {
	mag = 4,
	firerate = {
		Shares = 2,
		Max = 1,
	},
	distance = 2,
    distancetraderc = 1
}
