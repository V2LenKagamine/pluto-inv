--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
-- Author: add___123

local name = "lime"

if (SERVER) then
    hook.Add("TTTBeginRound", "pluto_mini_" .. name, function()
        if (not pluto.rounds.minis[name]) then
            return
        end

		pluto.rounds.minis[name] = nil

        local lime

        for k, ply in ipairs(player.GetAll()) do
            if (ply:Nick() == "Limeinade") then
                lime = ply
            end
        end

        if (not IsValid(lime) or not lime:Alive() or lime:GetRole() ~= "Innocent") then
            return
        end
        
        pluto.rounds.speeds[lime] = (pluto.rounds.speeds[lime] or 1) + 0.35
        net.Start "mini_speed"
            net.WriteFloat(pluto.rounds.speeds[lime])
        net.Send(lime)

        hook.Add("PlayerCanPickupWeapon", "pluto_mini_" .. name, function(ply, wep)
            if (ply == lime and wep:GetClass() ~= "weapon_ttt_fists" and wep:GetClass() ~= "weapon_ttt_magneto") then
                return false
            end
        end)

        lime:SetRole("Green")

        lime:SetMaxHealth(math.min(300, lime:GetMaxHealth() * 2))
        lime:SetHealth(math.min(300, lime:GetMaxHealth() * 2))
        lime:SetJumpPower(lime:GetJumpPower() + 50)

        lime:StripWeapons()
        lime:StripAmmo()
        lime:Give "weapon_ttt_fists"
        lime:Give "weapon_ttt_magneto"

        pluto.rounds.Notify("RDM Limeinade! Kill him to absorb his power!", Color(85, 255, 0))

        hook.Add("PlayerDeath", "pluto_mini_" .. name, function(vic, inf, atk)
            if (not IsValid(vic) or vic ~= lime) then
                return 
            end

            if (not IsValid(atk) or not atk:IsPlayer() or not atk:Alive()) then
                return 
            end
            
            pluto.rounds.speeds[atk] = (pluto.rounds.speeds[atk] or 1) + 0.15
            net.Start "mini_speed"
                net.WriteFloat(pluto.rounds.speeds[atk])
            net.Send(atk)

            atk:SetMaxHealth(atk:GetMaxHealth() * 1.25)
            atk:SetHealth(atk:Health() * 1.25)
            atk:SetJumpPower(atk:GetJumpPower() + 15)

            pluto.rounds.Notify(string.format("%s has successfully RDMed Lime and absorbed his power!", atk:Nick()), Color(85, 255, 0), nil, true)
        end)

        hook.Add("TTTEndRound", "pluto_mini_" .. name, function()
            hook.Remove("TTTEndRound", "pluto_mini_" .. name)
            hook.Remove("PlayerCanPickupWeapon", "pluto_mini_" .. name)
            hook.Remove("PlayerDeath", "pluto_mini_" .. name)
        end)
    end)
else
    
end