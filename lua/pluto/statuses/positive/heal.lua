STAT.Name = "heal"
STAT.IsNegative = false 

function STAT:AddStatus(target, _, healper, time)
    if(not isentity(target)) then return end
    status = ents.Create("pluto_status")
    status:SetParent(target)
    status.PrintName = "heal"
    status.Data = {
        Dealer = target,
        TicksLeft = time,
        ThinkDelay = 1,
        HealPer = (healper/time)
    }
    status:Spawn()
end

function STAT:DoThink(status)
    local p = status:GetParent()
	if (not IsValid(p) or not p:IsPlayer() or not p:Alive()) then
		status:Remove()
		return
	end

	local heal = status.Data.HealPer
	local maxHP = p:GetMaxHealth()

    heal = (heal * maxHP) * (1 / maxHP)

	if (p:Health() >= maxHP or hook.Run("PlutoHealthGain", p, heal)) then
		return
	end
    
	p:SetHealth(math.min(maxHP, p:Health() + heal))
end

return STAT