STAT.Name = "immune"
STAT.IsNegative = false
STAT.NoCleanse = true

function STAT:AddStatus(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "immune") then
            status = ent
            break 
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "immune"
        status.Data = {
            Dealer = atk,
            Stax = stacks,
            Hook_Immune = {
                "PlutoTryAddStatus",
                pluto.statushooks.HookImmune,
            },
            DontExpire = true,
        }
        status:Spawn()
    else
        status.Data.Stax = (status.Data.Stax or 0) + stacks
    end
end

function pluto.statushooks.HookImmune(ent,target)
    if(target ~= ent:GetParent()) then return end
    if(ent.IsNegative and not ent.NoCleanse) then return false end
end


return STAT