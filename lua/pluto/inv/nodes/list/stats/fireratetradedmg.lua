--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "fireratetradedmg"

NODE.Name = "Firerate From Damage"
NODE.Experience = 5000

function NODE:GetDescription(node)
	return string.format("Firerate is increased by %.2f%%, but lose %.2f%% Damage.", 1 + node.node_val1 * 2,node.node_val1 * 2)
end

function NODE:ModifyWeapon(node, wep)
	wep.Pluto.Delay = wep.Pluto.Delay + (1 + node.node_val1 * 2) / 100
    wep.Pluto.Damage = wep.Pluto.Damage + wep:ScaleRollType("damage", (node.node_val1 * 2) / 100, true)
end
