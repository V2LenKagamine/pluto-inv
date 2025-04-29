--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Toxicity"
MOD.Tags = {
	"damage", "poison", "dot"
}

MOD.Color = Color(211, 3, 211)

function MOD:IsNegative(roll)
	return false
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Poison; Poison does low damage, but prevents any healing."

MOD.Tiers = {
	{ 25, 35 },
	{ 15, 25 },
	{ 5, 15 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep:ScaleRollType("damage", rolls[1], true)
end

function MOD:OnDamage(wep, rolls, vic, dmginfo, state)
	if (IsValid(vic) and vic:IsPlayer() and dmginfo:GetDamage() > 0) then
		state.poisonstacks = math.ceil(wep:ScaleRollType("damage", rolls[1]) / 100 * dmginfo:GetDamage())
	end
end

function MOD:PostDamage(wep, rolls, vic, dmginfo, state)
	if (state.poisonstacks) then
		dmginfo:SetDamage(dmginfo:GetDamage() - state.poisonstacks)
		self:DoStuff(target,dmginfo:GetAttacker() , state.poisonstacks)
	end
end

pluto.statuses = pluto.statuses or {}
pluto.statuses.poison = pluto.statuses.poison or {}
function MOD:DoStuff(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "Pluto_Poison") then
            status = ent
            break
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "Pluto_Poison"
        status.Data = {
            Dealer = atk,
            OnThink = pluto.statuses.poison.DoThink,
            TicksLeft = stacks,
            ThinkDelay = 0.375,
            Hook_Noheal = {
                "PlutoHealthGain",
                pluto.statuses.poison.NoHeal,
            },
        }
        status:Spawn()
    else
        status.Data.TicksLeft = status.Data.TicksLeft + stacks
    end
end

function pluto.statuses.poison.DoThink(ent)
    if(not ent) then return end
    local vic = ent:GetParent()

    local todeal = 0.4

    local dinfo = DamageInfo()
    if(IsValid(ent.Data.Dealer)) then
        dinfo:SetAttacker(ent.Data.Dealer)
    else
        dinfo:SetAttacker(game.GetWorld())
    end
    dinfo:SetDamageType(DMG_DIRECT + DMG_BULLET)
    dinfo:SetDamagePosition(vic:GetPos())
    dinfo:SetDamage(todeal)
    vic:TakeDamageInfo(dinfo)
end

function pluto.statuses.poison.NoHeal(healer,amnt)
    for _,ent in pairs(healer:GetChildren()) do
        if(ent.PrintName == "Pluto_Poison") then 
            return false 
        end
    end
end

return MOD