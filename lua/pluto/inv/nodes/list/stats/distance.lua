--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "distance"

NODE.Name = "Distance Increase"
NODE.Experience = 1900

function NODE:GetDescription(node)
	return string.format("Distance before Falloff is increased by %.2f%%", 2.5 + node.node_val1 * 2.5)
end

function NODE:ModifyWeapon(node, wep)
	wep.Pluto.DamageDropoffRange = wep.Pluto.DamageDropoffRange + (2.5 + node.node_val1 * 2.5) / 100
end
