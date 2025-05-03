STAT.Name = "heal_flat"
STAT.IsNegative = false 

function STAT:AddStatus(target, _, healper, time)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "heal_flat") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "heal_flat"
        status.Data = {
            Dealer = target,
            TicksLeft = time,
            ThinkDelay = 1,
            HealPer = (healper/time)
        }
        status:Spawn()
    else
        status.Data.TicksLeft = (status.Data.TicksLeft or 0) + time
        status.Data.HealPer = ((status.Data.HealPer or 0) + (healper/time)) / 2
    end
end

function STAT:DoThink(status)
    local p = status:GetParent()
	if (not IsValid(p) or not p:IsPlayer() or not p:Alive()) then
		status:Remove()
		return
	end

	local heal = status.Data.HealPer
	
	if (p:Health() >= p:GetMaxHealth() or hook.Run("PlutoHealthGain", p, heal)) then
		return
	end

	p:SetHealth(math.min(p:GetMaxHealth(), p:Health() + heal))
end

return STAT