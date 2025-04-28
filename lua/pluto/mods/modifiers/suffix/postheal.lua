--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Rejuvenation"
MOD.Color = Color(3, 211, 201)
MOD.Tags = {
	"healing",
}

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	if (index == 1) then
		return string.format("%i", roll)
	else
		return string.format("%.01f", roll)
	end
end

MOD.Description = "After a righteous kill, heal %s of your health over %s seconds"

MOD.Tiers = {
	{ 13, 20, 3, 7.5 },
	{  8, 13, 3, 7.5 },
	{  5,  8, 3, 7.5 },
}

function MOD:OnKill(wep, rolls, atk, vic)
	if (ttt.GetCurrentRoundEvent() ~= "") then
		return
	end

	if (atk:GetRoleTeam() ~= vic:GetRoleTeam()) then
		self:DoStuff(atk,rolls[1],rolls[2])
	end
end

pluto.statuses = pluto.statuses or {}
pluto.statuses.heal = pluto.statuses.heal or {}
function MOD:DoStuff(target, healper, time)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "Pluto_Heal") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "Pluto_Heal"
        status.Data = {
            Dealer = target,
            OnThink = pluto.statuses.heal.DoThink,
            TicksLeft = time,
            ThinkDelay = 1,
            HealPer = (healper/time)
        }
        status:Spawn()
    else
        status.Data.TicksLeft = status.Data.TicksLeft + time
    end
end

function pluto.statuses.heal.DoThink(ent)
    local p = ent:GetParent()
	if (not IsValid(p) or not p:IsPlayer() or not p:Alive()) then
		ent:Remove()
		return
	end

	local heal = ent.Data.HealPer
	
	if (p:Health() >= p:GetMaxHealth() or hook.Run("PlutoHealthGain", p, heal)) then
		return
	end

	p:SetHealth(math.min(p:GetMaxHealth(), p:Health() + heal))
end
return MOD