STAT.Name = "bleed"
STAT.IsNegative = true 

function STAT:AddStatus(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "bleed") then
            status = ent
            break 
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "bleed"
        status.Data = {
            Dealer = atk,
            TicksLeft = stacks,
            ThinkDelay = .325,
        }
        status:Spawn()
    else
        status.Data.TicksLeft = (status.Data.TicksLeft or 0) + stacks
    end
end
function STAT:DoThink(status)

    local vic = status:GetParent()

    local stax = status.Data.TicksLeft
    local todeal
    if(stax >= 7.5) then
        todeal = 2.3
        status.Data.TicksLeft = status.Data.TicksLeft - 1
    else
        todeal = 1.15
    end
    if(vic:GetVelocity():LengthSqr() > vic:GetSlowWalkSpeed()^2 or vic:IsNextBot()) then
        todeal = todeal * 1.25
    end

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

return STAT