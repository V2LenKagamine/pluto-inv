STAT.Name = "poison"
STAT.IsNegative = true 


function STAT:AddStatus(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "poison") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "poison"
        status.Data = {
            Dealer = atk,
            TicksLeft = stacks,
            ThinkDelay = 0.5,
            Hook_Noheal = {
                "PlutoHealthGain",
                pluto.statushooks.NoHeal,
            },
        }
        status:Spawn()
    else
        status.Data.TicksLeft = (status.Data.TicksLeft or 0) + stacks
    end
end

function STAT:DoThink(status)
    if(not status) then return end
    local vic = status:GetParent()

    local todeal = 1.025

    local dinfo = DamageInfo()
    if(IsValid(status.Data.Dealer)) then
        dinfo:SetAttacker(status.Data.Dealer)
    else
        dinfo:SetAttacker(game.GetWorld())
    end
    dinfo:SetDamageType(DMG_DIRECT + DMG_BULLET)
    dinfo:SetInflictor(status)
    dinfo:SetDamagePosition(vic:GetPos())
    dinfo:SetDamage(todeal)
    vic:TakeDamageInfo(dinfo)
end

function pluto.statushooks.NoHeal(healer,amnt)
    for _,ent in pairs(healer:GetChildren()) do
        if(ent.PrintName == "poison") then 
            return false 
        end
    end
end

return STAT