STAT.Name = "fire"
STAT.IsNegative = true
 
function STAT:AddStatus(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "fire") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "fire"
        status.Data = {
            Dealer = atk,
            TicksLeft = stacks,
            ThinkDelay = 0.2,
        }
        status:Spawn()
    else
        status.Data.TicksLeft = (status.Data.TicksLeft or 0) + stacks
    end
end


function STAT:DoThink(status)
    if(not status) then return end
    local vic = status:GetParent()
    local visFire = status.VFireP
    if(vic and not IsValid(visFire)) then
        visFire = CreateVFire(vic,vic:GetPos(),vector_origin,100,status.Data.Dealer)
        visFire.vFireDamageData = {dmgMul = 0, dmgType = DMG_BURN}
        visFire:Spawn()
        status.VFireP = visFire
    end

    local stax = status.Data.TicksLeft
    local todeal = 1.05
    if(stax >= 12) then
        todeal = 1.175
        status.Data.TicksLeft = status.Data.TicksLeft + 0.25
    elseif(stax < 12 and stax >= 6) then
        todeal = 1.1
        status.Data.TicksLeft = status.Data.TicksLeft + 0.05
    end

    local dinfo = DamageInfo()
    if(IsValid(status.Data.Dealer)) then
        dinfo:SetAttacker(status.Data.Dealer)
    else
        dinfo:SetAttacker(game.GetWorld())
    end
    dinfo:SetDamageType(DMG_DIRECT + DMG_BURN)
    dinfo:SetInflictor(status)
    dinfo:SetDamagePosition(vic:GetPos())
    dinfo:SetDamage(todeal)
    vic:TakeDamageInfo(dinfo)
end

function STAT:OnExpire(status)
    local visfire = status.VFireP
    if(IsValid(visfire)) then
        status:GetParent():Extinguish()
    end
end

return STAT