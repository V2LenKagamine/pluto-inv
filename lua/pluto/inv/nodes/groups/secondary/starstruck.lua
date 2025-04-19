--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local GROUP = pluto.nodes.groups.get("starstruck_enchant", 1)

GROUP.Type = "secondary"

GROUP.Guaranteed = {
	"starstruck_enchant",
    "starstruck_spawns",
    "starstruck_starfall",
}

GROUP.SmallNodes = {
    distancetraderc = 1,
    magtradereload = 1,
    fireratetradedmg = 1,
    distance = 1,
    mag = 1,
    firerate = 1,
}
