--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local GROUP = pluto.nodes.groups.get("puttsman", 2)

GROUP.Type = "primary"

GROUP.Guaranteed = {
    "recoil"
}

GROUP.SmallNodes = {
	damage = {
		Shares = 1,
		Max = 1,
	},
	distance = {
        Shares = 2,
        Max = 2,
    },
	mag = 1,
    firerate = 1,
	recoil = {
        Shares = 2,
        Max = 2,
    },
}
