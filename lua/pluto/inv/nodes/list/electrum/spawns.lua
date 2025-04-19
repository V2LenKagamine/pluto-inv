--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "electrum_spawns"

NODE.Name = "Electrum: Coined"
NODE.Experience = 5400

function NODE:GetDescription(node)
	return string.format("%.2f%% more currency from this weapon.", 7.5 + node.node_val1 * 10)
end

function NODE:ModifyWeapon(node, wep)
	timer.Simple(0, function()
		if (not IsValid(wep)) then
			return
		end
		if (not wep.ElectrumEnchant) then
			return
		end

		local old = wep.UpdateSpawnPoints
		function wep:UpdateSpawnPoints(state)
			if (old) then
				old(self, state)
			end

			state.Points = state.Points * (1 + (7.5 + node.node_val1 * 7.5) / 100)
		end
	end)
end