--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "Igniting"
MOD.Tags = {
	"damage", "fire", "dot"
}

MOD.Color = Color(211, 111, 3)

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f%%", roll)
end

MOD.Description = "%s of Damage dealt is converted to Flame; Missed shots may ignite terrain."

MOD.Tiers = {
	{ 25, 35 },
	{ 15, 25 },
	{ 5, 15 },
}

function MOD:ModifyWeapon(wep, rolls)
	wep:ScaleRollType("damage", rolls[1], true)
end

function MOD:OnShoot(wep, rolls, trce, dmg, state)
    if(CLIENT) then return end
    if(trce.Entity) then
        if(trce.Entity:IsWorld()) then
            if(math.Rand(0,100) < wep:ScaleRollType("damage",rolls[1])) then
                CreateVFire(trce.Entity,trce.HitPos,trce.Normal,50)
            end
        end
    end
end

function MOD:OnDamage(wep, rolls, target, dmg, state)
	if (not IsValid(target) or not isentity(target)) then return end
    if(target:IsPlayer() and dmg:GetDamage() > 0) then
		state.firestacks = (wep:ScaleRollType("damage", rolls[1])/100) * dmg:GetDamage()
		self:DoStuff(target,dmg:GetAttacker(),state.firestacks)
	end
end

function MOD:PostDamage(wep, rolls, target, dmg, state)
    if(not state) then return end
	if (state.firestacks) then
		dmg:SetDamage(dmg:GetDamage() - state.firestacks)
	end
end
pluto.statuses = pluto.statuses or {}
pluto.statuses.fire = pluto.statuses.fire or {}
function MOD:DoStuff(target, atk, stacks)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "Pluto_Fire") then
            status = ent
            break 
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "Pluto_Fire"
        status.Data = {
            Dealer = atk,
            OnThink = pluto.statuses.fire.DoThink,
            TicksLeft = 1,
            ThinkDelay = 0.2,
        }
        status:Spawn()
    end
    status.Data.TicksLeft = (status.Data.TicksLeft or 0) + stacks
end


function pluto.statuses.fire.DoThink(ent)
    local vic = ent:GetParent()
    local visFire
    if(not IsValid(visFire)) then
        visFire = CreateVFire(vic,vector_origin,vector_origin,1)
        visFire.vFireDamageData = {dmgMul = 0, dmgType = DMG_BURN}
        visFire:Spawn()
    end

    local stax = ent.Data.TicksLeft
    local todeal = 0.1
    if(stax >= 9) then
        todeal = 0.4
        ent.Data.TicksLeft = Data.TicksLeft + 0.5
    elseif(stax < 9 and stax >= 3) then
        todeal = .2
        ent.Data.TicksLeft = Data.TicksLeft + 0.25
    end

    local dinfo = DamageInfo()
    if(IsValid(ent.Data.Dealer)) then
        dinfo:SetAttacker(ent.Data.Dealer)
    else
        dinfo:SetAttacker(game.GetWorld())
    end
    dinfo:SetDamageType(DMG_DIRECT + DMG_BURN)
    dinfo:SetDamagePosition(vic:GetPos())
    dinfo:SetDamage(todeal)
    vic:TakeDamageInfo(dinfo)
end

return MOD