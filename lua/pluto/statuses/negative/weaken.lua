STAT.Name = "weaken"
STAT.IsNegative = true
STAT.NoCleanse = true

function STAT:AddStatus(target, atk, stacks, time)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "weaken") then
            status = ent
            break 
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "weaken"
        status.Data = {
            Dealer = atk,
            Stax = stacks,
            ThinkDelay = 1,
            Hook_Dmg = {
                "EntityTakeDamage",
                pluto.statushooks.HookDamage,
            },
            DontExpire = true,
        }
        if(time) then
            status.TicksLeft = time
            status.DontExpire = false
        end
        status:Spawn()
    else
        status.Data.Stax = stacks > status.Data.Stax and stacks or status.Data.Stax
        if(not status.Data.DontExpire) then
            status.Data.TicksLeft = (status.Data.TicksLeft or 0) + (time or 0)
        end
    end
end

function pluto.statushooks.HookDamage(ent,dinfo)
    if (not dinfo:GetAttacker()) then return end
    for _,child in pairs(dinfo:GetAttacker():GetChildren()) do
        if(child:GetClass() ~= "pluto_status") then continue end
        if(child.PrintName == "weaken") then
            local dmg = dinfo:GetDamage() * (1 - (0.05 * (child.Data.Stax or 0)))
            dinfo:SetDamage(dmg)
            break --Can only have 1 status of a type so.
        end
    end
end


return STAT