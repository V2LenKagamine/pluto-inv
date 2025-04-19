--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "unrelenting"

NODE.Name = "Unrelenting"
NODE.Experience = 7000
NODE.Description = "Gain 10% magazine size. Lose 20% reload speed. Regain full magazine on kill."

function NODE:ModifyWeapon(node, wep)
	wep.Primary.ClipSize_Original = wep.Primary.ClipSize_Original or wep.Primary.ClipSize
	wep.Primary.DefaultClip_Original = wep.Primary.DefaultClip_Original or wep.Primary.DefaultClip

	wep.Pluto.ClipSize = (wep.Pluto.ClipSize or 1) + 0.10
	local round = wep.Pluto.ClipSize > 1 and math.ceil or math.floor
	wep.Primary.ClipSize = round(wep.Primary.ClipSize_Original * wep.Pluto.ClipSize)
	wep.Primary.DefaultClip = round(wep.Primary.DefaultClip_Original * wep.Pluto.ClipSize)

	wep.Pluto.ReloadAnimationSpeed = wep.Pluto.ReloadAnimationSpeed - 0.2
    local id = "pandora_unrelenting_" .. wep:GetPlutoID()
	hook.Add("PlayerDeath", id, function(self, vic, inf, atk)
		if (atk ~= inf:GetOwner() or inf ~= inf) then
			return
		end
        inf:SetClip1(inf:GetMaxClip1())
	end)
end
