STAT.Name = "shock"
STAT.IsNegative = true 


function STAT:AddStatus(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "shock") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "shock"
        status.Data = {
            Dealer = atk,
            TicksLeft = 6,
            ThinkDelay = 0.5,
            Stax = stacks,
        }
        status:Spawn()
    else
        status.Data.Stax = (status.Data.Stax or 0) + stacks
        status.Data.TicksLeft = 6
    end
end

function STAT:DoThink(status)
    if(not status) then return end

    if (status.Data.Stax >= 20) then
        status:OnExpire(true)
    end
end

function STAT:OnExpire(status,forced)
    if(not status) then return end
    local vic = status:GetParent()

    local todeal = status.Data.Stax * 1.1
    if(forced) then
        todeal = status.Data.Stax * 1.2
    end
    status.Data.Stax = 0
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
    if(dinfo:GetDamage() > 0) then
        vic:TakeDamageInfo(dinfo)
    end
end
