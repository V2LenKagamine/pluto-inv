--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "recoiltradedis"

NODE.Name = "Recoil From Distance"
NODE.Experience = 3000

function NODE:GetDescription(node)
	return string.format("Recoil is %.2f%% easier to control, but Falloff happens %.2f%% closer.", 3 + node.node_val1 * 9,2.5 + node.node_val1 * 2.5)
end

function NODE:ModifyWeapon(node, wep)
	wep.Pluto.ViewPunchAngles = wep.Pluto.ViewPunchAngles - (3 + node.node_val1 * 9) / 100
    wep.Pluto.DamageDropoffRange = wep.Pluto.DamageDropoffRange - (2.5 + node.node_val1 * 2.5) / 100
end
