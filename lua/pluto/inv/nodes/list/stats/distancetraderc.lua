--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "distancetraderc"

NODE.Name = "Distance From Recoil"
NODE.Experience = 3800

function NODE:GetDescription(node)
	return string.format("Distance before Falloff is increased by %.2f%%, but the weapon kicks %.2f%% harder.", 5 + node.node_val1 * 5,3 + node.node_val1 * 9)
end

function NODE:ModifyWeapon(node, wep)
	wep.Pluto.DamageDropoffRange = wep.Pluto.DamageDropoffRange + (5 + node.node_val1 * 5) / 100
    wep.Pluto.ViewPunchAngles = wep.Pluto.ViewPunchAngles + (3 + node.node_val1 * 9) / 100
end
