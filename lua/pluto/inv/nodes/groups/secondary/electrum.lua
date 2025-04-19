--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local GROUP = pluto.nodes.groups.get("electrum_enchant", 1)

GROUP.Type = "secondary"

GROUP.Guaranteed = {
	"electrum_enchant",
    "electrum_spawns",
    "electrum_share",
}

GROUP.SmallNodes = {
    damagetradefr = 1,
    distancetraderc = 1,
    fireratetradedmg = 1,
    magtradereload = 1,
    recoiltradedis = 1,
    reloadingtrademag = 1,
}
