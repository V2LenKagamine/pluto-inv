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
        DontExpire = true,
        IsImmunity = true,
    }
    status:Spawn()
end

return STAT