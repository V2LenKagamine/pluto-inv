--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local GROUP = pluto.nodes.groups.get("damager", 2)

GROUP.Type = "primary"

GROUP.Guaranteed = {
    "damagetradefr",
}

GROUP.SmallNodes = {
	damage = {
		Shares = 3,
		Max = 2,
	},
	firerate = 2,
    mag = {
        Shares = 1,
        Max = 1,
    },
}
