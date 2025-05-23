--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local GROUP = pluto.nodes.groups.get("gold_enchant", 1)

GROUP.Type = "secondary"

GROUP.Guaranteed = {
	"gold_enchant",
    "gold_transform",
    "gold_spawns",
}

GROUP.SmallNodes = {
    firerate = 1,
    mag = 1,
    reloading = 1,
    damage = 1,
    distance = 1,
    recoil = 1,
}
