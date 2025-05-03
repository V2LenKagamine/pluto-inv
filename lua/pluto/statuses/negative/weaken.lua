STAT.Name = "weaken"
STAT.IsNegative = true
STAT.NoCleanse = true

function STAT:AddStatus(target, atk, stacks)
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
            Hook_Dmg = {
                "EntityTakeDamage",
                pluto.statushooks.HookDamage,
            },
            DontExpire = true,
        }
        status:Spawn()
    else
        status.Data.Stax = (status.Data.Stax or 0) + stacks
    end
end

function pluto.statushooks.HookDamage(ent,dinfo)
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