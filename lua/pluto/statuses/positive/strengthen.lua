STAT.Name = "strengthen"
STAT.IsNegative = false

function STAT:AddStatus(target, atk, stacks, seconds)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "strengthen") then
            status = ent
            break 
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "strengthen"
        status.Data = {
            Dealer = atk,
            Stax = stacks,
            TicksLeft = seconds,
            ThinkDelay = 1,
            Hook_Dmg = {
                "EntityTakeDamage",
                pluto.statushooks.HookStrDamage,
            },
        }
        status:Spawn()
    else
        status.Data.Stax = (status.Data.Stax or 0) + stacks
        status.Data.TicksLeft = (status.Data.TicksLeft or 0) + seconds
    end
end

function STAT:OnExpire(status)
    if(status.Data.Stax >= 2) then
        pluto.statuses.byname["weaken"]:AddStatus(status:GetParent(),status:GetParent(),math.floor((status.Data.Stax or 1) / 2))
    end
end

function pluto.statushooks.HookStrDamage(ent,dinfo)
    for _,child in pairs(dinfo:GetAttacker():GetChildren()) do
        if(child:GetClass() ~= "pluto_status") then continue end
        if(child.PrintName == "strengthen") then
            local dmg = dinfo:GetDamage() * (1 + (0.05 * (child.Data.Stax or 0)))
            dinfo:SetDamage(dmg)
            break --Can only have 1 status of a type so.
        end
    end
end


return STAT