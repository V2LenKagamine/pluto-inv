--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "demon_poss"

NODE.Name = "Demonic Possession"
NODE.Description = "This gun is possessed by a demon. 40% of your life force is taken. You cannot heal. This gun cannot be dropped."
NODE.Experience = 0

function NODE:ModifyWeapon(node, wep)
	if (wep.DemonicPossession) then
		return
	end

	wep.AllowDrop = false
	if (SERVER) then
		local owner = wep:GetOwner()
		owner:SetHealth(owner:Health() * 0.6)
		owner:SetMaxHealth(owner:GetMaxHealth() * 0.6)
	end

	wep.DemonicPossession = true

	hook.Add("PlutoHealthGain", wep, function(self, p)
		if (self:GetOwner() == p) then
			return true
		end
	end)

	if (CLIENT and LocalPlayer() == wep:GetOwner()) then
		chat.AddText(Color(255, 20, 50, 200), "yes... your soul will do nicely...")
	end
end
