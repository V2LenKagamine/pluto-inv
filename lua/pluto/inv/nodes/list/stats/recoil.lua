--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "recoil"

NODE.Name = "Recoil Management"
NODE.Experience = 1500

function NODE:GetDescription(node)
	return string.format("Recoil is %.2f%% easier to control", 3 + node.node_val1 * 9)
end

function NODE:ModifyWeapon(node, wep)
	wep.Pluto.ViewPunchAngles = wep.Pluto.ViewPunchAngles - (3 + node.node_val1 * 9) / 100
end
