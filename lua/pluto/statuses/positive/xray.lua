STAT.Name = "xray"
STAT.IsNegative = false
if (SERVER)then
    util.AddNetworkString("PlutoXrayUpdate")
end

function STAT:AddStatus(target, atk, stacks, seconds)
    local status
    if(not isentity(target)) then return end
    for _, ent in pairs(target:GetChildren()) do
        if(ent.PrintName == "xray") then
            status = ent
            break 
        end
    end
    if(not IsValid(status)) then
        status = ents.Create("pluto_status")
        status:SetParent(target)
        status.PrintName = "xray"
        status.Data = {
            Dealer = atk,
            Stax = stacks,
            TicksLeft = seconds,
            ThinkDelay = 1,
        }
        status:Spawn()
    else
        status.Data.Stax = (status.Data.Stax or 0) + stacks
        status.Data.TicksLeft = (status.Data.TicksLeft or 0) + seconds
    end
    net.Start("PlutoXrayUpdate")
    net.WriteEntity(target)
    net.WriteUInt(stacks,8)
    net.Send(target)
end

function STAT:OnExpire(status)
    if(IsValid(status:GetParent())) then
        net.Start("PlutoXrayUpdate")
        net.WriteEntity(status:GetParent())
        net.WriteUInt(0,8)
        net.Send(status:GetParent())
    end
end

if(not CLIENT) then return STAT end

net.Receive("PlutoXrayUpdate",function()
    local target = net.ReadEntity()
    local lvl = net.ReadUInt(8)
    if(target ~= LocalPlayer()) then return end
    LocalPlayer()["XrayLevel"] = lvl
end)

hook.Add("PostDrawOpaqueRenderables","pluto_xraybuff",function()
    if((LocalPlayer()["XrayLevel"] or 0) >= 1) then
        local owner = LocalPlayer()
        local dist = (LocalPlayer()["XrayLevel"] or 0) * 15 * 39.37
	    local ang = math.cos(math.rad(LocalPlayer()["XrayLevel"] or 0) * 12.5)
        if (ttt.GetHUDTarget() ~= owner) then
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
    end
end)


return STAT