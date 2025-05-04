STAT.Name = "immune"
STAT.IsNegative = false
STAT.NoCleanse = true

function STAT:AddStatus(target, atk, stacks, time)
    if(not isentity(target)) then return end
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
end

function pluto.statushooks.HookImmune(ent,target)
    if(target ~= ent:GetParent()) then return end
    if(ent.IsNegative and not ent.NoCleanse) then return false end
end


return STAT