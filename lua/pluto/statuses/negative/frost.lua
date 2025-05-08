STAT.Name = "frost"
STAT.IsNegative = true 

function STAT:AddStatus(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "frost") then
            status = ent
            break
        end
    end
    local comptime = CurTime() + ((target:Ping() or 0) * 4 / 1000)
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "frost"
        status.Data = {
            Dealer = atk,
            TicksLeft = stacks,
            ThinkDelay = 0.45,
            Hook_Speed = {
                "TTTUpdatePlayerSpeed",
                pluto.statushooks.HookSpeed,
            },
        }
        status:Spawn()
        target:SetFrostStarted(comptime)
    else
        status.Data.TicksLeft = (status.Data.TicksLeft or 0) + stacks
    end
    local frostLvl = 1 + math.floor(status.Data.TicksLeft / 6)
    target:SetFrostUntil(comptime + (status.Data.TicksLeft * (status.Data.ThinkDelay or 0)))
    target:SetFrostLvl(frostLvl)
end

function STAT:DoThink(status)
    if(not status) then return end
    local vic = status:GetParent()

    local stax = status.Data.TicksLeft
    local todeal = 1.05
    local frostLvl = 1 + math.floor(stax / 6)

    todeal = todeal * frostLvl
    vic:SetFrostLvl(frostLvl)
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

local frost_scalar = 
{
    [1] = 0.125,
    [2] = 0.2,
    [3] = 0.325,
    [4] = 0.4,
    [5] = 0.475,
    [6] = 0.6,
    [7] = 0.75,
}


hook.Add("TTTGetHiddenPlayerVariables", "pluto_frost", function(vars)
    table.insert(vars, {
        Name = "FrostUntil",
        Type = "Float",
        Default = -math.huge,
        Enums = {}
    })
    table.insert(vars, {
        Name = "FrostStarted",
        Type = "Float",
        Default = -math.huge,
        Enums = {}
    })
    table.insert(vars, {
        Name = "FrostLvl",
        Type = "Float",
        Default = -math.huge,
        Enums = {}
    })
end)

function pluto.statushooks.HookSpeed(plr,data)
    if(not plr) then return end
    if(not plr:IsPlayer()) then return end
    local sloweduntil = plr:GetFrostUntil()

	if (sloweduntil > CurTime() and plr:GetFrostStarted() < CurTime()) then
		data.FinalMultiplier = data.FinalMultiplier * (1 - (frost_scalar[plr:GetFrostLvl()] or 0))
	end
end

return STAT
