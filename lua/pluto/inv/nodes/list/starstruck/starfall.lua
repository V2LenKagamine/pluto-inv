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
        local id = "starstruck_stars_" .. wep:GetPlutoID()
		hook.Add("DoPlayerDeath",id,function(self,vic,klr,dmginfo)
            if (math.random() >= .25 + (node.node_val1 / 2)) then return end
            if (pluto.rounds.getcurrent()) then return end
	        if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then return end
            if (IsValid(vic)) then return end --bots.
            if (vic:GetRoleTeam() == klr:GetRoleTeam()) then return end
            local amnt math.floor(math.Rand(1,4))
            for i = 1,amnt do
                pluto.currency.spawnfor(vic,"stardust")
                pluto.currency.spawnfor(klr,"stardust")
            end
        end)
	end)
end