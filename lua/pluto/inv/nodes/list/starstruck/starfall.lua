--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local NODE = pluto.nodes.get "starstruck_starfall"

NODE.Name = "Starstruck: Star Blessing"
NODE.Experience = 7500

function NODE:GetDescription(node)
	return string.format("%.2f%% chance on Rightfull Kill to give both players some stardust.", (25 + (node.node_val1 * 50)))
end

function NODE:ModifyWeapon(node, wep)
    if(not SERVER)then return end

	timer.Simple(0, function()
		if (not IsValid(wep)) then
			return
		end
		if (not wep.StarEnchant) then
			return
		end
        local id = "starstruck_stars" .. wep:GetPlutoID()
		hook.Add("PlayerDeath",id,function(self,vic,inf,killer)
            --if (math.random() >= .25 + (node.node_val1 / 2)) then return end
            if (pluto.rounds.getcurrent()) then return end
	        if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then return end
	        if (not IsValid(vic) or killer ~= self:GetOwner()) then return end
            if (vic:GetRoleTeam() == killer:GetRoleTeam()) then return end
            local amnt math.floor(math.Rand(3,6))
            for i = 1,amnt do
                pluto.currency.spawnfor(vic.Player,pluto.currency.byname.stardust)
                pluto.currency.spawnfor(killer.Player,pluto.currency.byname.stardust)
                print("Bingo!")
            end
        end)
	end)
end