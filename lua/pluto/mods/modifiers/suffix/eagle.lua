--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
MOD.Type = "suffix"
MOD.Name = "The Eagle"
MOD.Color = Color(211, 180, 3)
MOD.Tags = {
	"vision", "util"
}

function MOD:IsNegative(roll)
	return false
end

function MOD:CanRollOn(class)
	return class.Ironsights or false 
end

function MOD:FormatModifier(index, roll)
	return string.format("%.01f", roll)
end

MOD.Description = "Shows most entities within %s meters after aiming down sights for 2 seconds; penetration points increase time needed by 1/40th a second."

MOD.Synergies = {
    ["greed"] = "Also shows currency.",
}

MOD.Tiers = {
	{ 30, 40 },
	{ 20, 30 },
	{ 10, 20 },
}

function MOD:ModifyWeapon(wep, rolls)
	local old = wep.GetSlowdown
	function wep:GetSlowdown()
		local m
		if (old) then
			m = old(self)
		else
			m = 1
		end

		return m * (self:GetIronsights() and 0.4 or 1)
	end

    local buffed = false
    local data = wep:GetInventoryItem()
    if(data.Mods and data.Mods.suffix) then
        for _,mod in ipairs(data.Mods.suffix) do
            if(mod.Mod == "greed") then
                buffed = true
                break
            end
        end
    end
    
    wep.buffed = buffed
	if (not CLIENT) then
		return
	end

	local dist = rolls[1] * 39.37

	local ang = math.cos(math.rad(25))

	hook.Add("PostDrawOpaqueRenderables", wep, function(self)
		if (not self:GetIronsights() or self:GetIronsightsTime() + 2 + (self:GetPenetration() * 0.025) > CurTime()) then
			return
		end

		local owner = self:GetOwner()
		if (ttt.GetHUDTarget() ~= owner) then
			return
		end

		if (owner:GetActiveWeapon() ~= self) then
			return
		end

		local es = ents.FindInCone(owner:GetShootPos(), owner:GetAimVector(), dist, ang)

		for i = #es, 1, -1 do
			local e = es[i]
			if (not e:IsPlayer() or not e:Alive()) then
				table.remove(es, i)
				continue
			end
		end
	
		render.SetStencilEnable(true)
		render.ClearStencil()
		render.SuppressEngineLighting(true)
		render.OverrideColorWriteEnable(true, false)
		render.SetBlend(2 / 255)
	
	
		-- first pass: mark pixels
		render.SetStencilWriteMask(0xff)
		render.SetStencilTestMask(0xff)
		render.SetStencilReferenceValue(0)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_INVERT)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
	
		for _, ent in pairs(es) do
			ent:DrawModel()
		end
	
		-- second pass: z check
	
		
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_INCR)
		for _, ent in pairs(es) do
			ent:DrawModel()
		end
	
		render.OverrideColorWriteEnable(false)
		render.SetBlend(1)
	
		-- second pass: draw pixels
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
	
		render.SetColorMaterial()
	
		render.DrawScreenQuad()
	
		render.SetStencilEnable(false)
		render.SuppressEngineLighting(false)
	end)

    hook.Add("PostDrawTranslucentRenderables", wep, function(self)
        if (not self:GetIronsights() or self:GetIronsightsTime() + 2 + (self:GetPenetration() * 0.025) > CurTime()) then
            return
        end

        if(not wep.buffed) then return end
        local owner = self:GetOwner()
        if (ttt.GetHUDTarget() ~= owner) then
            return
        end
        if (owner:GetActiveWeapon() ~= self) then
            return
        end
        local wait = 1.5
        local timing = 1 - ((wait + CurTime()) % wait) / wait * 2
        local up_offset = vector_up * (math.sin(timing * math.pi) + 1) / 2 * 15 * 0.25
        local es = pluto.inv.getcurrlist()
        for i = #es, 1, -1 do
            local e = es[i]
            if not(util.IsPointInCone(e:GetPos(),owner:GetShootPos(), owner:GetAimVector(),ang,dist)) then
                table.remove(es, i)
                continue
            end
        end

        for _, curren in pairs(es) do
            cam.IgnoreZ(dist > curren:GetPos():Distance(LocalPlayer():GetPos()))

            render.SetMaterial(curren:GetMaterial(true))
            local pos = curren:GetPos()
                
            pos = pos + up_offset
            local size = curren:GetSize()

            render.DrawSprite(pos, size, size, color_white)
        end
        cam.IgnoreZ(false)
    end)
end

return MOD