--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "reloadingtrademag"

NODE.Name = "Reloading From Magazine"
NODE.Experience = 2750

function NODE:GetDescription(node)
	return string.format("Reloading is %.2f%% faster, but lose %.2f%% magazine size.", 1 + node.node_val1 * 4,2 + node.node_val1 * 4)
end

function NODE:ModifyWeapon(node, wep)
	wep.Pluto.ReloadAnimationSpeed = wep.Pluto.ReloadAnimationSpeed + (1 + node.node_val1 * 4) / 100

    wep.Primary.ClipSize_Original = wep.Primary.ClipSize_Original or wep.Primary.ClipSize
	wep.Primary.DefaultClip_Original = wep.Primary.DefaultClip_Original or wep.Primary.DefaultClip

	wep.Pluto.ClipSize = (wep.Pluto.ClipSize or 1) - (4 + node.node_val1 * 8) / 100
	local round = wep.Pluto.ClipSize > 1 and math.ceil or math.floor
	wep.Primary.ClipSize = round(wep.Primary.ClipSize_Original * wep.Pluto.ClipSize)
	wep.Primary.DefaultClip = round(wep.Primary.DefaultClip_Original * wep.Pluto.ClipSize)
end
